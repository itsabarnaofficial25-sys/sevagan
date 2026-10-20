import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String baseUrl = 'http://159.65.144.107:3000/api';

  // Auth endpoints
  static const String otpRequest = '/auth/otp';

  static const String otpVerify = '/auth/verify';

  // Customer FCM Token
  static const String updateFcmToken = '/customers/update-fcm-token';

  // Service endpoints
  static const String services = '/services';

  static const String createServiceRequest = '/jobs';

  static const String myRequests = '/jobs/my-requests';

  static const String jobDetails = '/jobs';

  static const String rateJob = '/jobs';

  // Payment endpoints
  static const String createPayment = '/payments/create';

  static const String verifyPayment = '/payments/verify';

  static const String createOrder = '/payments/create-order';

  static const String razorpayKeyId = 'rzp_test_mock_key';
}

void debugPrintApiConfig() {
  if (kDebugMode) {
    print('API Configuration:');

    print('Base URL: ${ApiConfig.baseUrl}');

    print('FCM API: ${ApiConfig.updateFcmToken}');

    print('Razorpay Key: ${ApiConfig.razorpayKeyId}');
  }
}
