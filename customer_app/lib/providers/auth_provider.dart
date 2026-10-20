// ignore_for_file: unused_element, curly_braces_in_flow_control_structures

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/otp_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../config/api_config.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _userId;
  String? _phone;
  String? _userName;

  String? _lastError;
  String? get lastError => _lastError;

  Map<String, dynamic>? _userData;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  final OtpService _otpService = OtpService();
  final ApiService _apiService = ApiService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  String? get userId => _userId;
  String? get phone => _phone;
  String? get userName => _userName;
  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;

  Map<String, dynamic>? get user {
    if (_userId != null) {
      return {
        'id': _userId,
        'phone': _phone,
        'name': _userName,
        'email': _userData?['email'],
        'role': _userData?['role'],
        'isProfileComplete': _userData?['isProfileComplete'] ?? false,
      };
    }
    return null;
  }

  AuthProvider() {
    _loadToken();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        debugPrint(
            ' Firebase auth state changed: User logged in - ${user.phoneNumber}');
        // Update app state based on Firebase user
        _phone = user.phoneNumber;
        notifyListeners();
      } else {
        debugPrint(' Firebase auth state changed: User logged out');
      }
    });
  }

  void initialize() {
    // ignore: avoid_print
    print('AuthProvider initialized');
  }

  // ==================== TOKEN MANAGEMENT ====================

  Future<void> _loadToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');
      _userId = prefs.getString('userId');
      _phone = prefs.getString('phone');
      _userName = prefs.getString('userName');

      final userDataString = prefs.getString('userData');
      if (userDataString != null) {
        _userData = json.decode(userDataString);
      }

      _isAuthenticated = _token != null && _token!.isNotEmpty;

      debugPrint('=== AuthProvider Loaded ===');
      debugPrint('isAuthenticated: $_isAuthenticated');
      debugPrint('token exists: ${_token != null ? "Yes" : "No"}');

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading token: $e');
    }
  }

  // ==================== OTP AUTHENTICATION ====================

  Future<bool> requestOtp(String mobileNumber) async {
    if (mobileNumber.isEmpty) {
      debugPrint('Request OTP failed: Empty mobile number');
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('📱 Requesting OTP via Firebase for: $mobileNumber');
      bool success = await _otpService.sendOtp(mobileNumber);

      _isLoading = false;
      notifyListeners();

      if (success) {
        debugPrint('OTP request successful for: $mobileNumber');
        return true;
      } else {
        debugPrint('OTP request failed for: $mobileNumber');
        return false;
      }
    } catch (e) {
      debugPrint('Request OTP error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOtp(
    String mobileNumber,
    String otp,
    String role,
  ) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      // STEP 1 : Verify OTP with Firebase
      await _otpService.verifyOtp(otp);

      // STEP 2 : Get current Firebase user
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        _lastError = "OTP verification failed.";
        return false;
      }

      debugPrint("✅ Firebase OTP Verified");
      debugPrint("User UID: ${currentUser.uid}");

 final String? idToken = await currentUser.getIdToken(true);

if (idToken == null || idToken.isEmpty) {
  _lastError = "Unable to get Firebase Token.";
  return false;
}

debugPrint("========== FIREBASE TOKEN ==========");
debugPrint("Current User: ${currentUser.uid}");
debugPrint("ID Token Empty: ${idToken.isEmpty}");
debugPrint("ID Token Length: ${idToken.length}");
debugPrint(idToken);

      // STEP 4 : Verify with Backend
      final response = await _apiService.verifyOtpBackend(
        idToken,
        role,
      );

      final Map<String, dynamic> data = response;

      _token = data["accessToken"];
      _userId = data["user"]["id"].toString();
      _phone = data["user"]?["phone"] ?? mobileNumber;
      _userName = data["user"]?["name"];

      _userData = Map<String, dynamic>.from(
        data["user"],
      );

      _isAuthenticated = true;

      await _saveUserData();

      debugPrint("✅ Customer Login Success");

      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint(e.toString());

      switch (e.code) {
        case "invalid-verification-code":
          _lastError = "Invalid OTP";
          break;

        case "session-expired":
          _lastError = "OTP Expired";
          break;

        default:
          _lastError = e.message;
      }

      return false;
    } catch (e) {
      debugPrint(e.toString());

      _lastError = e.toString();

      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_token != null) await prefs.setString('token', _token!);
      if (_userId != null) await prefs.setString('userId', _userId!);
      if (_phone != null) await prefs.setString('phone', _phone!);
      if (_userData != null)
        await prefs.setString('userData', json.encode(_userData!));
      debugPrint('User data saved to SharedPreferences');
    } catch (e) {
      debugPrint('Error saving user data: $e');
    }
  }

  Future<void> _saveFirebaseUserData(String phone, String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('phone', phone);
      await prefs.setString('userId', uid);
      await prefs.setString('token', uid); // Use UID as token for now

      debugPrint('Firebase user data saved to SharedPreferences');
      debugPrint('   Phone: $phone');
      debugPrint('   UID: $uid');
    } catch (e) {
      debugPrint('Error saving user data: $e');
    }
  }
// ==================== FCM TOKEN UPDATE ====================

  Future<void> updateFcmToken() async {
    try {
      if (_token == null || _token!.isEmpty) {
        debugPrint("JWT Token not found");
        return;
      }

      String? fcmToken = await FirebaseMessaging.instance.getToken();

      if (fcmToken == null) {
        debugPrint("FCM Token is null");
        return;
      }

      debugPrint("📱 Customer FCM Token : $fcmToken");

      await _apiService.post(
        ApiConfig.updateFcmToken, // <-- comma added

        data: {
          "fcmToken": fcmToken,
        },

        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token",
        },
      );

      debugPrint("✅ Customer FCM Token Updated");
    } catch (e) {
      debugPrint("❌ FCM Update Error : $e");
    }
  }
  // ==================== LOGOUT ====================

  Future<void> logout() async {
    debugPrint('=== Logging Out ===');

    _token = null;
    _userId = null;
    _phone = null;
    _userName = null;
    _userData = null;
    _isAuthenticated = false;
    _isLoading = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    await _otpService.signOut();

    debugPrint('Logged out successfully');
    notifyListeners();
  }
}
