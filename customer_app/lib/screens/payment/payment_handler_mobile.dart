// payment_handler_mobile.dart
// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentHandler {
  final Function(String, String) onSuccess;
  final Function(String) onError;
  late Razorpay _razorpay;

  PaymentHandler({
    required this.onSuccess,
    required this.onError,
  }) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    onSuccess(response.paymentId ?? '', response.signature ?? '');
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    onError(response.message ?? 'Payment failed');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    onError('External wallet selected');
  }

  Future<void> openCheckout({
    required String keyId,
    required String orderId,
    required int amount,
    required String name,
    required String description,
    required String contact,
    required String email,
  }) async {
    var options = {
      'key': keyId,
      'amount': amount,
      'name': name,
      'order_id': orderId,
      'description': description,
      'prefill': {'contact': contact, 'email': email},
      'external': {
        'wallets': ['paytm']
      }
    };
    _razorpay.open(options);
  }

  void dispose() {
    _razorpay.clear();
  }
}