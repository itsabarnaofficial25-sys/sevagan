// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/job_provider.dart';
import '../../models/service_request.dart';
import '../jobs/job_status_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';

class MyJobsScreen extends StatefulWidget {
  const MyJobsScreen({super.key});

  @override
  State<MyJobsScreen> createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends State<MyJobsScreen> {
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFFFF9800);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFF44336);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.token != null) {
        context.read<JobProvider>().fetchMyRequests(authProvider.token!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final jobProvider = Provider.of<JobProvider>(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(l10n),
      body: jobProvider.isLoading
          ? _buildLoadingState(l10n)
          : jobProvider.requests.isEmpty
              ? _buildEmptyState(l10n)
              : RefreshIndicator(
                  onRefresh: () async {
                    final authProvider = context.read<AuthProvider>();
                    if (authProvider.token != null) {
                      await context
                          .read<JobProvider>()
                          .fetchMyRequests(authProvider.token!);
                    }
                  },
                  color: primaryColor,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: jobProvider.requests.length,
                    itemBuilder: (context, index) {
                      final request = jobProvider.requests[index];
                      return _buildRequestCard(context, request, l10n, localeProvider);
                    },
                  ),
                ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppLocalizations l10n) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        l10n.myServiceRequests,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: Colors.grey.shade100),
      ),
    );
  }

  Widget _buildLoadingState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.loadingServices,
            style: TextStyle(
              fontSize: 14,
              color: textSecondary,
              fontWeight: FontWeight.w500,
            ),
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
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history_rounded,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.noServices,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.checkBackLater,
            style: TextStyle(
              fontSize: 14,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: Text(
              l10n.browseServices,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, ServiceRequest request, 
      AppLocalizations l10n, LocaleProvider localeProvider) {
    final statusInfo = _getStatusInfo(request.status, l10n);
    
    // Get category name based on language
    final categoryName = localeProvider.locale.languageCode == 'ta'
        ? (request.serviceCategory?['nameTa']?.isNotEmpty == true
            ? request.serviceCategory!['nameTa']
            : request.serviceCategory?['nameEn'] ?? 'Service')
        : request.serviceCategory?['nameEn'] ?? 'Service';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => JobStatusScreen(jobId: request.id),
              ),
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Badge and Price
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusInfo['color'].withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            statusInfo['icon'],
                            size: 16,
                            color: statusInfo['color'],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            statusInfo['text'],
                            style: TextStyle(
                              color: statusInfo['color'],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: secondaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '₹${request.estimatedPrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: secondaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Service Category with Icon
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        _getServiceIcon(request.serviceCategory?['nameEn'] ?? 'Service'),
                        size: 24,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            categoryName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                          if (request.description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              request.description,
                              style: TextStyle(
                                fontSize: 13,
                                color: textSecondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Date and Time Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.calendar_today_rounded,
                        size: 12,
                        color: textTertiary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(request.createdAt, l10n),
                      style: TextStyle(
                        fontSize: 12,
                        color: textTertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: textTertiary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTime(request.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: textTertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // View Details Button
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        l10n.viewDetails,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: primaryColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusInfo(String status, AppLocalizations l10n) {
    switch (status) {
      case 'REQUESTED':
        return {
          'color': warningColor,
          'text': l10n.findingTechnician,
          'icon': Icons.search_rounded,
        };
      case 'TECHNICIAN_ASSIGNED':
        return {
          'color': primaryColor,
          'text': l10n.technicianAssigned,
          'icon': Icons.person_rounded,
        };
      case 'JOB_STARTED':
        return {
          'color': successColor,
          'text': l10n.workInProgress,
          'icon': Icons.build_rounded,
        };
      case 'JOB_COMPLETED':
        return {
          'color': secondaryColor,
          'text': l10n.paymentPending,
          'icon': Icons.payment_rounded,
        };
      case 'COMPLETED':
        return {
          'color': successColor,
          'text': l10n.completed,
          'icon': Icons.check_circle_rounded,
        };
      case 'CANCELLED':
        return {
          'color': errorColor,
          'text': l10n.cancelled,
          'icon': Icons.cancel_rounded,
        };
      default:
        return {
          'color': Colors.grey,
          'text': status,
          'icon': Icons.info_rounded,
        };
    }
  }

  // UPDATED: Added new service icons
  IconData _getServiceIcon(String name) {
    switch (name.toLowerCase()) {
      case 'electrician':
        return Icons.electrical_services_rounded;
      case 'plumber':
        return Icons.plumbing_rounded;
      case 'ac service':
        return Icons.ac_unit_rounded;
      case 'motor repair':
        return Icons.settings_rounded;
      case 'washing machine':
        return Icons.local_laundry_service_rounded;
      case 'carpenter':
        return Icons.handyman_rounded;
      case 'painter':
        return Icons.format_paint_rounded;
      case 'cleaning':
        return Icons.cleaning_services_rounded;
      case 'activa driver':
        return Icons.directions_bike_rounded;
      case 'home appliance service':
        return Icons.devices_other_rounded;
      default:
        // Fallback to contains check for flexibility
        final value = name.toLowerCase();
        if (value.contains('activa') || value.contains('driver')) return Icons.directions_bike_rounded;
        if (value.contains('home appliance') || value.contains('appliance service')) return Icons.devices_other_rounded;
        return Icons.build_circle_rounded;
    }
  }

  String _formatDate(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return l10n.today;
    } else if (difference.inDays == 1) {
      return l10n.yesterday;
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${l10n.daysAgo}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}