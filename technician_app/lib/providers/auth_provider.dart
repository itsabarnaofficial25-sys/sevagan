// technician_app/lib/providers/auth_provider.dart

// ignore_for_file: unused_field, curly_braces_in_flow_control_structures

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../services/otp_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/constants.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _userId;
  String? _phone;
  String? _userName;
  String? _userRole;
  Map<String, dynamic>? _userData;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  String? _lastError;
  String? get lastError => _lastError;

  final OtpService _otpService = OtpService();
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 60),
    headers: {'Content-Type': 'application/json'},
  ));
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  String? get userId => _userId;
  String? get phone => _phone;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _loadToken();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        debugPrint(
            '✅ Firebase auth state changed: User logged in - ${user.phoneNumber}');
        _phone = user.phoneNumber;
        notifyListeners();
      } else {
        debugPrint('❌ Firebase auth state changed: User logged out');
      }
    });
  }

  Future<void> checkLoginStatus() async {
    await _loadToken();
  }

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
      if (_token != null) {
        debugPrint('token preview: ${_token!.substring(0, 20)}...');
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading token: $e');
    }
  }

  // ==================== OTP AUTHENTICATION ====================

  Future<bool> requestOtp(String mobileNumber) async {
    if (mobileNumber.isEmpty) {
      debugPrint('❌ Request OTP failed: Empty mobile number');
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
        debugPrint('✅ OTP request successful for: $mobileNumber');
        return true;
      } else {
        debugPrint('❌ OTP request failed for: $mobileNumber');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Request OTP error: $e');
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
      // STEP 1: Verify OTP with Firebase
      await _otpService.verifyOtp(otp);

      // STEP 2: Get current Firebase user
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        _lastError = "OTP verification failed.";
        return false;
      }

      debugPrint("==================================");
      debugPrint("✅ FIREBASE OTP VERIFIED");
      debugPrint("UID      : ${currentUser.uid}");
      debugPrint("PHONE    : ${currentUser.phoneNumber}");

      // STEP 3: Get Firebase ID Token
      final idToken = await currentUser.getIdToken(true);

      if (idToken == null || idToken.isEmpty) {
        _lastError = "Unable to get Firebase ID Token.";
        return false;
      }

      debugPrint("==================================");
      debugPrint("📤 BEFORE API CALL");
      debugPrint(
          "URL      : ${ApiConstants.baseUrl}${ApiConstants.authVerify}");
      debugPrint("ROLE     : $role");
      debugPrint("TOKEN LEN: ${idToken.length}");
      debugPrint("TOKEN    : ${idToken.substring(0, 40)}...");
      debugPrint("BODY     :");
      debugPrint({
        "idToken": idToken,
        "role": role,
      }.toString());

      // STEP 4: Call Backend
      final response = await _dio.post(
        ApiConstants.authVerify,
        data: {
          "idToken": idToken,
          "role": role,
        },
      );

      debugPrint("==================================");
      debugPrint("📥 BACKEND RESPONSE");
      debugPrint("STATUS : ${response.statusCode}");
      debugPrint(response.data.toString());

      if (response.statusCode == 200 || response.statusCode == 201) {
        _token = response.data["accessToken"];
        _userId = response.data["user"]["id"].toString();
        _phone = response.data["user"]["phone"] ?? mobileNumber;
        _userName = response.data["user"]["name"];
        _userRole = response.data["user"]["role"];

        _userData = Map<String, dynamic>.from(response.data["user"]);

        _isAuthenticated = true;
        await _saveUserData();

        // Upload FCM Token to Backend
        await updateFcmToken();

        debugPrint("LOGIN SUCCESS");
        return true;
      }

      _lastError = "Login failed.";
      return false;
    } on FirebaseAuthException catch (e) {
      debugPrint("==================================");
      debugPrint(" FIREBASE ERROR");
      debugPrint("Code    : ${e.code}");
      debugPrint("Message : ${e.message}");

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
    } on DioException catch (e) {
      debugPrint("==================================");
      debugPrint("🌐 BACKEND ERROR");
      debugPrint("TYPE   : ${e.type}");
      debugPrint("STATUS : ${e.response?.statusCode}");
      debugPrint("DATA   : ${e.response?.data}");

      if (e.response?.data is Map && e.response?.data["message"] != null) {
        _lastError = e.response?.data["message"].toString();
      } else {
        _lastError = e.message ?? "Server Error";
      }

      return false;
    } catch (e, stackTrace) {
      debugPrint("==================================");
      debugPrint("UNKNOWN ERROR");
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());

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
      if (_token != null) {
        await prefs.setString('token', _token!);
        debugPrint('✅ Token saved to SharedPreferences');
      }
      if (_userId != null) await prefs.setString('userId', _userId!);
      if (_phone != null) await prefs.setString('phone', _phone!);
      if (_userData != null)
        await prefs.setString('userData', json.encode(_userData!));
      if (_userName != null) await prefs.setString('userName', _userName!);
      debugPrint('✅ User data saved to SharedPreferences');
    } catch (e) {
      debugPrint('❌ Error saving user data: $e');
    }
  }

  Future<void> updateFcmToken() async {
    try {
      if (_token == null) return;

      final String? fcmToken = await FirebaseMessaging.instance.getToken();

      if (fcmToken == null) {
        debugPrint("❌ FCM Token is null");
        return;
      }

      debugPrint("📱 FCM Token : $fcmToken");

      await _dio.post(
        "/technicians/update-fcm-token",
        data: {
          "fcmToken": fcmToken,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $_token",
          },
        ),
      );

      debugPrint("✅ Technician FCM Token Updated");
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

    debugPrint('✅ Logged out successfully');
    notifyListeners();
  }
}
