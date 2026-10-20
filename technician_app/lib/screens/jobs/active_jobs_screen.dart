// ignore_for_file: deprecated_member_use, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/job_provider.dart';
import '../../data/models/job_model.dart';
import '../../l10n/app_localizations.dart';
import 'job_tracking_screen.dart';

class ActiveJobsScreen extends StatelessWidget {
  const ActiveJobsScreen({super.key});

  static const Color primaryColor = Color(0xFF2196F3);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color cardShadowColor = Color(0xFF1E293B);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final jobProvider = Provider.of<JobProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          l10n.activeJobsTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, color: textPrimary),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: jobProvider.isLoading
          ? _buildLoadingState(l10n)
          : jobProvider.activeJobs.isEmpty
          ? _buildEmptyState(l10n)
          : RefreshIndicator(
              onRefresh: () => jobProvider.fetchMyJobs(),
              color: primaryColor,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: jobProvider.activeJobs.length,
                itemBuilder: (context, index) {
                  final job = jobProvider.activeJobs[index];
                  return _buildJobCard(context, job, l10n);
                },
              ),
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
            'Loading active jobs...',
            style: TextStyle(color: textSecondary),
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
              Icons.work_off,
              size: 64,
              color: primaryColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noActiveJobs,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noActiveJobsSubtitle,
            style: TextStyle(fontSize: 14, color: textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(BuildContext context, Job job, AppLocalizations l10n) {
    final statusInfo = _getStatusInfo(job.status, l10n);

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
              builder: (context) => JobTrackingScreen(jobId: job.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status and Price Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: statusInfo['bgColor'],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusInfo['icon'], color: statusInfo['color'], size: 16),
                        const SizedBox(width: 4),
                        Text(
                          statusInfo['text'],
                          style: TextStyle(
                            color: statusInfo['color'],
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
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.currency_rupee,
                          color: Colors.green,
                          size: 14,
                        ),
                        Text(
                          job.price.toStringAsFixed(0),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
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
                          style: const TextStyle(fontSize: 11, color: textSecondary),
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

              // Service Type
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.build,
                      size: 18,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.serviceTypeLabel,
                          style: const TextStyle(fontSize: 11, color: textSecondary),
                        ),
                        Text(
                          job.serviceType,
                          style: const TextStyle(
                            fontSize: 14,
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
                          style: const TextStyle(fontSize: 11, color: textSecondary),
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

              // Description (if available)
              if (job.description.isNotEmpty) ...[
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

              const SizedBox(height: 20),

              // Navigate Button
              ElevatedButton.icon(
                onPressed: () => _launchMaps(job.latitude, job.longitude, l10n),
                icon: const Icon(Icons.navigation, size: 18),
                label: Text(
                  l10n.navigateButton,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusInfo(JobStatus status, AppLocalizations l10n) {
    switch (status) {
      case JobStatus.accepted:
        return {
          'color': Colors.blue,
          'text': l10n.statusAssigned,
          'icon': Icons.assignment_turned_in,
          'bgColor': Colors.blue.withOpacity(0.1),
        };
      case JobStatus.started:
        return {
          'color': Colors.orange,
          'text': l10n.statusInProgress,
          'icon': Icons.build,
          'bgColor': Colors.orange.withOpacity(0.1),
        };
      case JobStatus.completed:
        return {
          'color': Colors.green,
          'text': l10n.statusCompleted,
          'icon': Icons.check_circle,
          'bgColor': Colors.green.withOpacity(0.1),
        };
      default:
        return {
          'color': Colors.grey,
          'text': l10n.statusUnknown,
          'icon': Icons.info,
          'bgColor': Colors.grey.withOpacity(0.1),
        };
    }
  }

  Future<void> _launchMaps(double latitude, double longitude, AppLocalizations l10n) async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw l10n.mapsLaunchError;
    }
  }
}