// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/api_config.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../profile/reviews_list_screen.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _earningsData;
  String? _error;

  static const Color primaryColor = Color(0xFF2196F3);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);

  @override
  void initState() {
    super.initState();
    _fetchEarnings();
  }

Future<void> _fetchEarnings() async {
  setState(() {
    _isLoading = true;
    _error = null;
  });

  try {
    // ✅ Get token from AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null) {
      setState(() {
        _error = 'Please login again';
        _isLoading = false;
      });
      return;
    }

    final response = await Dio().get(
      '${ApiConfig.baseUrl}${ApiConfig.earnings}',
      options: Options(headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _earningsData = response.data;
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = 'Failed to load earnings data';
        _isLoading = false;
      });
    }
  } catch (e) {
    setState(() {
      _error = 'Failed to load earnings data';
      _isLoading = false;
    });
    debugPrint('Error fetching earnings: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.myEarnings,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchEarnings,
            tooltip: l10n.refresh,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorState(l10n)
          : RefreshIndicator(
              onRefresh: _fetchEarnings,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildWalletCard(l10n),
                    const SizedBox(height: 24),
                    _buildEarningsSummary(l10n),
                    const SizedBox(height: 24),
                    _buildCompletedJobsList(l10n, localeProvider),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildErrorState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            _error ?? l10n.error,
            style: const TextStyle(fontSize: 16, color: textSecondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchEarnings,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletCard(AppLocalizations l10n) {
    final walletBalance = _earningsData?['walletBalance'] ?? 0;
    return Card(
      color: Colors.green,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(
              Icons.account_balance_wallet,
              color: Colors.white,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.walletBalance,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '₹${walletBalance.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsSummary(AppLocalizations l10n) {
    final totalEarnings = _earningsData?['totalEarnings'] ?? 0;
    final totalCommission = _earningsData?['totalCommission'] ?? 0;
    final netEarnings = _earningsData?['netEarnings'] ?? 0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.earningsSummary,
              style:
                  Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ) ??
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            _buildSummaryRow(l10n.totalEarnings, totalEarnings),
            const SizedBox(height: 12),
            _buildSummaryRow(
              l10n.platformCommission,
              totalCommission,
              isNegative: true,
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(l10n.netEarnings, netEarnings, isBold: true),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ReviewsListScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.star_outline),
              label: Text(l10n.viewAllReviews),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: Colors.blue[50],
                foregroundColor: Colors.blue[800],
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    dynamic amount, {
    bool isNegative = false,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: textPrimary,
          ),
        ),
        Text(
          '${isNegative ? '-' : ''}₹${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isNegative ? Colors.red : Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedJobsList(
    AppLocalizations l10n,
    LocaleProvider localeProvider,
  ) {
    final completedJobs = (_earningsData?['completedJobs'] as List?) ?? [];

    if (completedJobs.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.work_off, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  l10n.noCompletedJobs,
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${l10n.completedJobs} (${completedJobs.length})',
          style:
              Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold) ??
              const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...completedJobs.map((job) => _buildJobCard(job, l10n, localeProvider)),
      ],
    );
  }

  Widget _buildJobCard(
    Map<String, dynamic> job,
    AppLocalizations l10n,
    LocaleProvider localeProvider,
  ) {
    final serviceCharge = job['finalPrice'] ?? 0;
    final commission = job['commission'] ?? 0;
    final netEarning = serviceCharge - commission;

    // Get category name based on language
    String categoryName = l10n.service;
    if (localeProvider.locale.languageCode == 'ta') {
      if (job['serviceCategory']?['nameTa'] != null &&
          job['serviceCategory']['nameTa'].toString().isNotEmpty) {
        categoryName = job['serviceCategory']['nameTa'];
      } else if (job['serviceCategory']?['nameEn'] != null) {
        categoryName = job['serviceCategory']['nameEn'];
      }
    } else {
      if (job['serviceCategory']?['nameEn'] != null) {
        categoryName = job['serviceCategory']['nameEn'];
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    categoryName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                ),
                Text(
                  '₹${netEarning.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              job['description'] ?? '',
              style: TextStyle(color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.serviceCharge,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Text('₹${serviceCharge.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.commission,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Text(
                  '-₹${commission.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
