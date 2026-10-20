// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/service_request.dart';
import '../models/service_category.dart';

class ApiService {
  // Helper method to check if status code indicates success
  bool _isSuccess(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  // Generic POST API Method
  Future<dynamic> post(
    String endpoint, {
    required Map<String, dynamic> data,
    Map<String, String>? headers,
  }) async {

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}$endpoint'),

      headers: headers ??
          {
            'Content-Type': 'application/json',
          },

      body: jsonEncode(data),
    );


    print("POST API:");
    print("URL: ${ApiConfig.baseUrl}$endpoint");
    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");


    if (!_isSuccess(response.statusCode)) {
      throw Exception(response.body);
    }


    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> verifyOtpBackend(
  String idToken,
  String role,
) async {

  print("========== VERIFY BACKEND ==========");
  print("Role: $role");
  print("Token Empty : ${idToken.isEmpty}");
  print("Token Length : ${idToken.length}");

  final body = {
    "idToken": idToken,
    "role": role,
  };

  print(jsonEncode(body));

  final response = await http.post(
    Uri.parse('${ApiConfig.baseUrl}${ApiConfig.otpVerify}'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode(body),
  );

  print("Status: ${response.statusCode}");
  print(response.body);

  if (!_isSuccess(response.statusCode)) {
    throw Exception(response.body);
  }

  return jsonDecode(response.body);
}

  // Auth
  Future<void> requestOtp(String phone) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.otpRequest}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone}),
    );

    if (!_isSuccess(response.statusCode)) {
      throw Exception('Failed to request OTP');
    }
  }

  Future<Map<String, dynamic>> loginWithPassword(
      String mobileNumber, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone': mobileNumber, // ✅ Changed from 'mobileNumber' to 'phone'
        'password': password,
      }),
    );

    print('Login response: ${response.statusCode} - ${response.body}');

    // Accept 200, 201, 202, etc. - any 2xx status code
    if (_isSuccess(response.statusCode)) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String mobileNumber,
    String? email,
    required String password,
    required String role,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'mobileNumber': mobileNumber,
        'email': email,
        'password': password,
        'role': role,
      }),
    );

    print('Register response: ${response.statusCode} - ${response.body}');

    if (_isSuccess(response.statusCode)) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Registration failed: ${response.body}');
    }
  }

  Future<void> forgotPassword(String mobileNumber) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'mobileNumber': mobileNumber}),
    );

    print('Forgot password: ${response.statusCode} - ${response.body}');

    if (!_isSuccess(response.statusCode)) {
      throw Exception('Failed to send OTP');
    }
  }

  Future<void> resetPassword(
      String mobileNumber, String otp, String newPassword) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'mobileNumber': mobileNumber,
        'otp': otp,
        'newPassword': newPassword,
      }),
    );

    print('Reset password: ${response.statusCode} - ${response.body}');

    if (!_isSuccess(response.statusCode)) {
      throw Exception('Password reset failed');
    }
  }

  Future<Map<String, dynamic>> createRazorpayOrder(
    String token,
    double amount,
    String serviceRequestId,
  ) async {
    print('Creating Razorpay order for amount: ₹$amount');

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/payments/create-order'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'amount': amount,
        'currency': 'INR',
        'serviceRequestId': serviceRequestId,
      }),
    );

    print('Create order response status: ${response.statusCode}');
    print('Create order response body: ${response.body}');

    if (!_isSuccess(response.statusCode)) {
      throw Exception('Failed to create Razorpay order: ${response.body}');
    }

    return jsonDecode(response.body);
  }

  Future<void> updateFcmToken(String fcmToken, String token) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.updateFcmToken}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'fcmToken': fcmToken}),
    );

    // Don't throw error if this fails - it's not critical
    if (!_isSuccess(response.statusCode)) {
      print('Failed to update FCM token: ${response.statusCode}');
    }
  }

// Services
  Future<List<ServiceCategory>> getServiceCategories(String token) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.services}'),
      headers: {
        'Content-Type': 'application/json', // ✅ ADD THIS
        'Authorization': 'Bearer $token',
      },
    );

    print('📡 GetServiceCategories - Status: ${response.statusCode}');
    print('📡 GetServiceCategories - Body: ${response.body}');

    if (_isSuccess(response.statusCode)) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ServiceCategory.fromJson(json)).toList();
    } else {
      throw Exception(
          'Failed to load service categories: ${response.statusCode}');
    }
  }

  // Jobs
  Future<ServiceRequest> createServiceRequest(
    String token,
    Map<String, dynamic> data,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.createServiceRequest}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (!_isSuccess(response.statusCode)) {
      throw Exception('Failed to create service request');
    }

    return ServiceRequest.fromJson(jsonDecode(response.body));
  }

  Future<List<ServiceRequest>> getMyRequests(String token) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.myRequests}'),
      headers: {
        'Content-Type': 'application/json', // ✅ ADD THIS
        'Authorization': 'Bearer $token',
      },
    );

    if (!_isSuccess(response.statusCode)) {
      throw Exception('Failed to load requests');
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => ServiceRequest.fromJson(json)).toList();
  }

  Future<ServiceRequest> getJobDetails(String token, String jobId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.jobDetails}/$jobId'),
      headers: {
        'Content-Type': 'application/json', // ✅ ADD THIS
        'Authorization': 'Bearer $token',
      },
    );

    if (!_isSuccess(response.statusCode)) {
      throw Exception('Failed to load job details');
    }

    return ServiceRequest.fromJson(jsonDecode(response.body));
  }

  Future<void> rateJob(
    String token,
    String jobId,
    int rating,
    String? comment,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.rateJob}/$jobId/rate'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'rating': rating,
        if (comment != null) 'comment': comment,
      }),
    );

    if (!_isSuccess(response.statusCode)) {
      throw Exception('Failed to rate job');
    }
  }

  // Payments
  Future<Map<String, dynamic>> createPayment(
    String token,
    String serviceRequestId,
    String method,
  ) async {
    final backendMethod = method == 'MOCK' ? 'UPI' : method;

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.createPayment}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'serviceRequestId': serviceRequestId,
        'method': backendMethod,
      }),
    );

    print('Create payment response: ${response.statusCode} - ${response.body}');

    if (!_isSuccess(response.statusCode)) {
      throw Exception('Failed to create payment: ${response.body}');
    }

    return jsonDecode(response.body);
  }

  Future<void> verifyPayment(
    String token,
    String paymentId,
    String razorpayPaymentId,
    String razorpaySignature,
    String razorpayOrderId,
  ) async {
    print(
        'Verifying payment - PaymentId: $paymentId, RazorpayOrderId: $razorpayOrderId');

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.verifyPayment}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'paymentId': paymentId,
        'razorpayPaymentId': razorpayPaymentId,
        'razorpaySignature': razorpaySignature,
        'razorpayOrderId': razorpayOrderId,
      }),
    );

    print('Verify payment response: ${response.statusCode} - ${response.body}');

    if (!_isSuccess(response.statusCode)) {
      throw Exception('Failed to verify payment: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getCustomerProfile(String token) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/customers/profile'),
      headers: {
        'Content-Type': 'application/json', // ✅ ADD THIS
        'Authorization': 'Bearer $token',
      },
    );

    if (!_isSuccess(response.statusCode)) {
      throw Exception('Failed to get customer profile');
    }

    return jsonDecode(response.body);
  }

// In api_service.dart, update createCustomerProfile:
  Future<Map<String, dynamic>> createCustomerProfile(
    String token,
    String name,
    String address,
  ) async {
    print('=== Creating Customer Profile ===');
    print(
        'Token being used: ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
    print('Name: $name');
    print('Address: $address');

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/customers/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'address': address,
      }),
    );

    print('Create profile response status: ${response.statusCode}');
    print('Create profile response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create profile: ${response.body}');
    }
  }
}
