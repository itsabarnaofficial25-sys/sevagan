// payment_handler_web.dart
// ignore_for_file: avoid_web_libraries_in_flutter, duplicate_ignore, deprecated_member_use

// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:js' as js;

class PaymentHandler {
  final Function(String, String) onSuccess;
  final Function(String) onError;

  PaymentHandler({required this.onSuccess, required this.onError});

  Future<void> openCheckout({
    required String keyId,
    required String orderId,
    required int amount,
    required String name,
    required String description,
    required String contact,
    required String email,
  }) async {
    final options = {
      'key': keyId,
      'amount': amount,
      'currency': 'INR',
      'name': name,
      'description': description,
      'order_id': orderId,
      'handler': (response) {
        onSuccess(
          response['razorpay_payment_id'],
          response['razorpay_signature'],
        );
      },
      'prefill': {
        'contact': contact,
        'email': email,
      },
      'theme': {
        'color': '#2196F3',
      },
      'modal': {
        'ondismiss': () {
          onError('Payment cancelled');
        },
      },
    };

    try {
      js.context.callMethod('Razorpay', [options]).callMethod('open');
    } catch (e) {
      onError('Failed to open Razorpay: $e');
    }
  }

  void dispose() {}
}