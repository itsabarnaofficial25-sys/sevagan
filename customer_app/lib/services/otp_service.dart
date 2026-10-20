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

      //  Clear stale session before starting fresh OTP flow
      if (_auth.currentUser != null) {
        await _auth.signOut();
        print("🔄 Cleared stale session before new OTP request");
      }
      _verificationId = null;

      final completer = Completer<bool>();

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            if (_auth.currentUser == null) {
              await _auth.signInWithCredential(credential);
              print(" Auto verification success");
            }
          } catch (e) {
            print('Auto sign-in error: $e');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          print(' Verification failed: ${e.code} - ${e.message}');
          if (!completer.isCompleted) completer.complete(false);
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          print(' OTP sent to $phoneNumber');
          if (!completer.isCompleted) completer.complete(true);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 120),
      );

      return completer.future;
    } catch (e) {
      print('Error sending OTP: $e');
      return false;
    }
  }

  // Let exceptions propagate — do NOT swallow them as null.
  Future<UserCredential?> verifyOtp(String otpCode) async {
    if (_verificationId == null) {
      throw FirebaseAuthException(
        code: 'session-expired',
        message: 'OTP session expired. Please request OTP again.',
      );
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: otpCode,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    _verificationId = null;
    return userCredential;
  }

  Future<void> signOut() async {
    _verificationId = null;
    await _auth.signOut();
  }
}
