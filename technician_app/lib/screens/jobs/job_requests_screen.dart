// ignore_for_file: deprecated_member_use, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:technician_app/l10n/app_localizations.dart';
import '../../providers/job_provider.dart';
import '../../providers/locale_provider.dart';
import 'job_detail_screen.dart';

class JobRequestsScreen extends StatefulWidget {
  const JobRequestsScreen({super.key});

  @override
  State<JobRequestsScreen> createState() => _JobRequestsScreenState();
}

class _JobRequestsScreenState extends State<JobRequestsScreen> {
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color cardShadowColor = Color(0xFF1E293B);
  static const Color successColor = Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobProvider>().fetchAvailableJobs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          l10n.newJobRequests,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: primaryColor),
            onPressed: () => context.read<JobProvider>().fetchAvailableJobs(),
            tooltip: l10n.refresh,
          ),
        ],
      ),
      body: Consumer<JobProvider>(
        builder: (context, jobProvider, _) {
          if (jobProvider.isLoading) {
            return _buildLoadingState(l10n);
          }

          final jobs = jobProvider.pendingJobs;

          if (jobs.isEmpty) {
            return _buildEmptyState(l10n, jobProvider);
          }

          return RefreshIndicator(
            onRefresh: () => jobProvider.fetchAvailableJobs(),
            color: primaryColor,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: jobs.length,
              itemBuilder: (context, index) {
                final job = jobs[index];
                return _buildJobCard(context, job, l10n);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState(AppLocalizations l10n) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
          SizedBox(height: 16),
          Text(
            'Loading job requests...',
            style: TextStyle(color: textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n, JobProvider jobProvider) {
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
              Icons.notifications_none,
              size: 64,
              color: primaryColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noNewJobRequests,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noPendingJobRequests,
            style: TextStyle(fontSize: 14, color: textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => jobProvider.fetchAvailableJobs(),
            icon: const Icon(Icons.refresh),
            label: Text(l10n.refresh),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(
    BuildContext context,
    dynamic job,
    AppLocalizations l10n,
  ) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    // Get service type based on language
    final serviceType = localeProvider.locale.languageCode == 'ta'
        ? (job.serviceTypeTa.isNotEmpty ? job.serviceTypeTa : job.serviceType)
        : job.serviceType;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shadowColor: cardShadowColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  JobDetailScreen(job: job), // ← Pass full job object
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row with Service Type and Price
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.build, color: primaryColor, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          serviceType,
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.currency_rupee,
                          color: successColor,
                          size: 14,
                        ),
                        Text(
                          job.price.toStringAsFixed(0),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: successColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Divider
              Divider(height: 1, color: borderColor, thickness: 1),
              const SizedBox(height: 16),

              // Customer Name
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 18,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.customerLabel,
                          style: const TextStyle(
                            fontSize: 11,
                            color: textSecondary,
                          ),
                        ),
                        Text(
                          job.customerName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Address
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.location_on,
                      size: 18,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.locationLabel,
                          style: const TextStyle(
                            fontSize: 11,
                            color: textSecondary,
                          ),
                        ),
                        Text(
                          job.address,
                          style: const TextStyle(
                            fontSize: 14,
                            color: textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Description if available
              if (job.description != null && job.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.description,
                        size: 18,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.descriptionLabel,
                            style: const TextStyle(
                              fontSize: 11,
                              color: textSecondary,
                            ),
                          ),
                          Text(
                            job.description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 16),

              // View Details Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JobDetailScreen(job: job),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: BorderSide(color: primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    l10n.viewDetails,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              // Request Time
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, size: 12, color: textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    _getTimeAgo(job.createdAt, l10n),
                    style: TextStyle(fontSize: 11, color: textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime createdAt, AppLocalizations l10n) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
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
