// payment_screen.dart
// ignore_for_file: avoid_print, prefer_const_constructors, deprecated_member_use, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import '../../models/service_request.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'payment_success_screen.dart';
import 'payment_handler.dart';

class PaymentScreen extends StatefulWidget {
  final ServiceRequest job;

  const PaymentScreen({super.key, required this.job});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isLoading = false;
  String? _paymentId;
  String? _orderId;
  late final PaymentHandler _paymentHandler;

  static const Color primaryColor = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color backgroundColor = Color(0xFFF8F9FC);
  static const Color surfaceColor = Colors.white;
  static const Color textPrimary = Color(0xFF1A2C3E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color successColor = Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    _paymentHandler = PaymentHandler(
      onSuccess: _handlePaymentSuccess,
      onError: _handlePaymentError,
    );
  }

  @override
  void dispose() {
    _paymentHandler.dispose();
    super.dispose();
  }

  Future<void> _initiatePayment() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = context.read<AuthProvider>();
      final apiService = ApiService();

      final amount = widget.job.finalPrice ?? 0;
      print('Creating order for amount: ₹$amount');

      final orderData = await apiService.createRazorpayOrder(
        authProvider.token!,
        amount,
        widget.job.id,
      );

      if (orderData['isMock'] == true) {
        final paymentData = await apiService.createPayment(
          authProvider.token!,
          widget.job.id,
          'MOCK',
        );
        _paymentId = paymentData['id'];
        _orderId = orderData['order_id'] ?? orderData['orderId'];
        await _handlePaymentSuccess(
            'mock_payment_${DateTime.now().millisecondsSinceEpoch}',
            'mock_signature');
        return;
      }

      final paymentData = await apiService.createPayment(
        authProvider.token!,
        widget.job.id,
        'UPI',
      );
      _paymentId = paymentData['id'];
      _orderId = orderData['order_id'] ?? orderData['orderId'];
      final amountInPaise = (amount * 100).toInt();

      await _paymentHandler.openCheckout(
        keyId: ApiConfig.razorpayKeyId,
        orderId: _orderId!,
        amount: amountInPaise,
        name: 'Sevagan Services',
        description: 'Payment for ${widget.job.serviceCategory?['nameEn'] ?? 'Service'}',
        contact: authProvider.user?['phone'] ?? '',
        email: authProvider.user?['email'] ?? 'customer@example.com',
      );
    } catch (e) {
      debugPrint('Error initiating payment: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initiate payment'), backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handlePaymentSuccess(
      String razorpayPaymentId, String razorpaySignature) async {
    try {
      final authProvider = context.read<AuthProvider>();
      final apiService = ApiService();

      if (_paymentId == null || _orderId == null) {
        if (mounted) {
          Fluttertoast.showToast(msg: "Payment Successful!", backgroundColor: successColor, textColor: Colors.white);
          Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) => PaymentSuccessScreen(job: widget.job, razorpayPaymentId: razorpayPaymentId),
          ));
        }
        return;
      }

      await apiService.verifyPayment(authProvider.token!, _paymentId!, razorpayPaymentId, razorpaySignature, _orderId!);

      if (mounted) {
        Fluttertoast.showToast(msg: "Payment Successful!", backgroundColor: successColor, textColor: Colors.white);
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => PaymentSuccessScreen(job: widget.job, razorpayPaymentId: razorpayPaymentId),
        ));
      }
    } catch (e) {
      debugPrint('Error verifying payment: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment verification failed'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handlePaymentError(String message) {
    debugPrint('Payment Error: $message');
    Fluttertoast.showToast(msg: "Payment Failed: $message", backgroundColor: Colors.red, textColor: Colors.white);
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final amount = widget.job.finalPrice ?? 0;
    final serviceName = widget.job.serviceCategory?['nameEn'] ?? 'Service';

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        title: const Text('Payment', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Amount Display
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [primaryColor, primaryDark],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
                    ),
                    child: Column(
                      children: [
                        Text('Total Amount', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9))),
                        const SizedBox(height: 12),
                        Text('₹${amount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 52, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.shield_rounded, color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              Text('Secure Payment', style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Service Info
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: primaryColor.withOpacity(0.08), borderRadius: BorderRadius.circular(14)),
                          child: Icon(Icons.home_repair_service_rounded, color: primaryColor, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(serviceName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary)),
                              const SizedBox(height: 4),
                              Text('Professional service at your doorstep', style: TextStyle(fontSize: 13, color: textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Payment Methods
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Payment Method', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textPrimary)),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: primaryColor, width: 1.5),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                                child: Icon(Icons.account_balance_wallet_rounded, color: primaryColor, size: 22),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text('UPI / Cards / Net Banking', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textPrimary)),
                              ),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                                child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (kIsWeb) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3CD),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text('Payment will open in a new window', style: TextStyle(fontSize: 13, color: textPrimary)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Pay Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: surfaceColor,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
            ),
            child: SafeArea(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _initiatePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: primaryColor.withOpacity(0.5),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('PAY ₹${amount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}