// ignore_for_file: deprecated_member_use, unused_field, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../config/api_config.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';
import 'package:intl/intl.dart';

class ReviewsListScreen extends StatefulWidget {
  const ReviewsListScreen({super.key});

  @override
  State<ReviewsListScreen> createState() => _ReviewsListScreenState();
}

class _ReviewsListScreenState extends State<ReviewsListScreen> {
  bool _isLoading = true;
  List<dynamic> _reviews = [];
  String? _error;

  static const Color primaryColor = Color(0xFF2196F3);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color cardShadowColor = Color(0xFF1E293B);

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await Dio().get(
        '${ApiConfig.baseUrl}/technicians/reviews',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _reviews = response.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load reviews';
        _isLoading = false;
      });
      debugPrint('Error fetching reviews: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.customerReviews,
          style: const TextStyle(fontWeight: FontWeight.bold, color: textPrimary),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: primaryColor),
            onPressed: _fetchReviews,
            tooltip: l10n.refresh,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorState(l10n)
          : _reviews.isEmpty
          ? _buildEmptyState(l10n)
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _reviews.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final review = _reviews[index];
                return _buildReviewCard(review, l10n, localeProvider);
              },
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
            '${l10n.error}: $_error',
            style: const TextStyle(fontSize: 16, color: textSecondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchReviews,
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

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.rate_review_outlined,
              size: 64,
              color: primaryColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noReviewsYet,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noReviewsSubtitle,
            style: const TextStyle(fontSize: 14, color: textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review, AppLocalizations l10n, LocaleProvider localeProvider) {
    final customer = review['customer'];
    final rating = review['rating'] as int;
    final comment = review['comment'] ?? '';
    final date = DateTime.parse(review['createdAt']);
    
    // Get service name based on language
    final serviceNameEn = review['serviceRequest']?['serviceCategory']?['nameEn'] ?? 'Service';
    final serviceNameTa = review['serviceRequest']?['serviceCategory']?['nameTa'] ?? '';
    
    final serviceName = localeProvider.locale.languageCode == 'ta'
        ? (serviceNameTa.isNotEmpty ? serviceNameTa : serviceNameEn)
        : serviceNameEn;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          (customer?['name']?[0] ?? 'A').toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer?['name'] ?? l10n.anonymousCustomer,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          serviceName,
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getRatingColor(rating).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 14,
                        color: _getRatingColor(rating),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        rating.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getRatingColor(rating),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: List.generate(5, (i) {
                return Icon(
                  i < rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 18,
                );
              }),
            ),
            if (comment.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  comment,
                  style: const TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: textSecondary,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 12, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text(
                  _formatDate(date, l10n),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getRatingColor(int rating) {
    if (rating >= 4) return Colors.green;
    if (rating == 3) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return DateFormat('MMM d, yyyy').format(date);
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} ${l10n.monthsAgo}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${l10n.daysAgo}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${l10n.hoursAgo}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${l10n.minutesAgo}';
    } else {
      return l10n.justNow;
    }
  }
}