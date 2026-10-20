// technician_app/lib/services/otp_service.dart

// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class OtpService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;

  Future<bool> sendOtp(String phoneNumber) async {
    try {
      phoneNumber = phoneNumber.trim();
      if (!phoneNumber.startsWith("+")) {
        phoneNumber = "+91$phoneNumber";
      }

      if (_auth.currentUser != null) {
        await _auth.signOut();
        print("Cleared stale session before new OTP request");
      }
      _verificationId = null;

      print("📱 Sending OTP to: $phoneNumber");

      final completer = Completer<bool>();

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            print("Auto Verification Started");

            if (_auth.currentUser == null) {
              await _auth.signInWithCredential(credential);
              print("Auto Verification Success");
            } else {
              print("Already Logged In");
            }
          } catch (e) {
            print(e);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          print("========== FIREBASE OTP ERROR ==========");
          print("Code    : ${e.code}");
          print("Message : ${e.message}");
          print("Details : $e");
          print("========================================");

          if (!completer.isCompleted) {
            completer.complete(false);
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;

          print("OTP Sent");
          print(verificationId);

          if (!completer.isCompleted) {
            completer.complete(true);
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 120),
      );

      return completer.future;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<void> verifyOtp(String otpCode) async {
    if (_verificationId == null) {
      throw FirebaseAuthException(
        code: "session-expired",
        message: "Verification ID not found",
      );
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: otpCode,
    );

    await _auth.signInWithCredential(credential);

    print("OTP verified successfully");
  }

  /// STEP 3: Get ID Token (use this for NestJS API)
  Future<String?> getIdToken() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      return await user.getIdToken(true);
    } catch (e) {
      print("Error getting ID token: $e");
      return null;
    }
  }

  /// Logout
  Future<void> signOut() async {
    await _auth.signOut();
    print("Signed out");
  }
}
