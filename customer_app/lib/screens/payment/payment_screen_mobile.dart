// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:sevagan_customer/l10n/app_localizations.dart';

/// Mobile payment handler using the razorpay_flutter package.
class PaymentHandler {
  final BuildContext context;
  final Future<void> Function(String paymentId, String signature) onSuccess;
  final void Function(String message) onError;

  late final Razorpay _razorpay;

  PaymentHandler({
    required this.context,
    required this.onSuccess,
    required this.onError,
  }) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _success);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _error);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _wallet);
  }

  void _success(PaymentSuccessResponse response) {
    onSuccess(response.paymentId ?? '', response.signature ?? '');
  }

  void _error(PaymentFailureResponse response) {
    final errorMessage = response.message ?? 'Unknown error';
    onError(errorMessage);
  }

  void _wallet(ExternalWalletResponse response) {
    final walletName = response.walletName ?? 'Unknown';
    final message = 'External wallet selected: $walletName';
    onError(message);
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
    final options = {
      'key': keyId,
      'amount': amount,
      'name': name,
      'description': description,
      'order_id': orderId,
      'prefill': {
        'contact': contact,
        'email': email,
      },
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
