// ignore_for_file: prefer_const_constructors, unused_local_variable

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/service_request.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';
import 'package:intl/intl.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final ServiceRequest job;
  final String razorpayPaymentId;

  const PaymentSuccessScreen({
    super.key,
    required this.job,
    required this.razorpayPaymentId,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final amount = job.finalPrice ?? 0.0;
    
    final serviceName = localeProvider.locale.languageCode == 'ta'
        ? (job.serviceCategory?['nameTa']?.isNotEmpty == true
            ? job.serviceCategory!['nameTa']
            : job.serviceCategory?['nameEn'] ?? l10n.service)
        : job.serviceCategory?['nameEn'] ?? l10n.service;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            // Success Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Color(0xFF4CAF50),
                size: 70,
              ),
            ),
            const SizedBox(height: 32),
            // Title
            Text(
              l10n.paymentSuccessful,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 10),
            // Subtitle
            Text(
              l10n.paymentSuccessMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF666666),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 48),
            // Receipt Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE8E8E8)),
                ),
                child: Column(
                  children: [
                    // Transaction ID
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.transactionId,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF888888),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            razorpayPaymentId.length > 20
                                ? '${razorpayPaymentId.substring(0, 20)}...'
                                : razorpayPaymentId,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF333333),
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Divider(color: const Color(0xFFE0E0E0), height: 1),
                    const SizedBox(height: 20),
                    // Service
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.service,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF888888),
                          ),
                        ),
                        Text(
                          serviceName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Divider(color: const Color(0xFFE0E0E0), height: 1),
                    const SizedBox(height: 20),
                    // Amount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.amountPaid,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF888888),
                          ),
                        ),
                        Text(
                          '₹${amount.toStringAsFixed(0)}.00',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(flex: 2),
            // Back Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    l10n.backToHome,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}