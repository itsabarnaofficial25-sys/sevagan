//lib/customer_app/screens/payment/payment/_screen_web.dart
// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;
import 'dart:async';

/// Web payment handler using Razorpay JS SDK
class PaymentHandler {
  final Future<void> Function(String paymentId, String signature) onSuccess;
  final void Function(String message) onError;

  PaymentHandler({
    required this.onSuccess, 
    required this.onError
  });

  Future<void> openCheckout({
    required String keyId,
    required String orderId,
    required int amount,
    required String name,
    required String description,
    required String contact,
    required String email,
  }) async {
    try {
      // Load Razorpay script dynamically if not already loaded
      if (!_isRazorpayLoaded()) {
        await _loadRazorpayScript();
      }

      final options = {
        'key': keyId,
        'amount': amount,
        'currency': 'INR',
        'name': name,
        'description': description,
        'order_id': orderId,
        'prefill': {
          'contact': contact,
          'email': email,
        },
        'theme': {
          'color': '#3F51B5',
        },
        'modal': {
          'ondismiss': () {
            onError('Payment window closed');
          }
        }
      };

      final razorpay = (html.window as dynamic)['Razorpay'];
      if (razorpay == null) {
        onError('Razorpay SDK not loaded');
        return;
      }
      
      final razorpayInstance = razorpay(options);
      
      razorpayInstance.on('payment.success', (dynamic response) {
        onSuccess(
          response['razorpay_payment_id'] as String,
          response['razorpay_signature'] as String,
        );
      });
      
      razorpayInstance.on('payment.error', (dynamic response) {
        onError(response['error']['description'] as String? ?? 'Payment failed');
      });
      
      razorpayInstance.open();
    } catch (e) {
      onError('Failed to open payment gateway: $e');
    }
  }

  bool _isRazorpayLoaded() {
    return (html.window as dynamic)['Razorpay'] != null;
  }

  Future<void> _loadRazorpayScript() async {
    final completer = Completer<void>();
    
    // Check if script already exists
    final existingScript = html.document.querySelector('script[src="https://checkout.razorpay.com/v1/checkout.js"]');
    if (existingScript != null) {
      completer.complete();
      return completer.future;
    }
    
    final script = html.ScriptElement()
      ..src = 'https://checkout.razorpay.com/v1/checkout.js'
      ..onLoad.listen((_) => completer.complete())
      ..onError.listen((e) => completer.completeError('Failed to load Razorpay SDK'));
    
    html.document.head?.append(script);
    return completer.future;
  }

  void dispose() {
    // Web cleanup if needed
  }
}