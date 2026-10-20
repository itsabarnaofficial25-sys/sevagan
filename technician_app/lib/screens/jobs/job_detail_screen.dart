// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:technician_app/l10n/app_localizations.dart';
import '../../providers/job_provider.dart';
import '../../providers/locale_provider.dart';
import '../../data/models/job_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'job_tracking_screen.dart';

class JobDetailScreen extends StatelessWidget {
  final Job job; // ✅ Changed from String to Job

  const JobDetailScreen({super.key, required this.job}); // ✅ Now matches

  Future<void> _openMap(
    double lat,
    double lng,
    AppLocalizations l10n,
    BuildContext context,
  ) async {
    final googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(Uri.parse(googleMapsUrl));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.mapsLaunchError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final jobProvider = Provider.of<JobProvider>(context);

    // Get service type based on language
    final serviceType = localeProvider.locale.languageCode == 'ta'
        ? (job.serviceTypeTa.isNotEmpty ? job.serviceTypeTa : job.serviceType)
        : job.serviceType;

    // Get description based on language
    final description = localeProvider.locale.languageCode == 'ta'
        ? (job.descriptionTa.isNotEmpty ? job.descriptionTa : job.description)
        : job.description;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.jobDetails),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Type
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                serviceType,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Customer Name
            _buildInfoRow(
              icon: Icons.person,
              label: l10n.customerLabel,
              value: job.customerName,
              context: context,
            ),
            const SizedBox(height: 12),

            // Address
            _buildInfoRow(
              icon: Icons.location_on,
              label: l10n.locationLabel,
              value: job.address,
              context: context,
            ),
            const SizedBox(height: 12),

            // Description
            if (description.isNotEmpty) ...[
              _buildInfoRow(
                icon: Icons.description,
                label: l10n.descriptionLabel,
                value: description,
                context: context,
              ),
              const SizedBox(height: 12),
            ],

            // Price
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.currency_rupee,
                    color: Colors.green,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.priceLabel,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '₹${job.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons based on job status
            if (job.status == JobStatus.pending) ...[
              _buildActionButtonsForPending(l10n, jobProvider, job, context),
            ] else if (job.status == JobStatus.accepted) ...[
              _buildActionButtonsForAccepted(l10n, job, context),
            ] else if (job.status == JobStatus.started) ...[
              _buildActionButtonsForStarted(l10n, job, context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required BuildContext context,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: Colors.blue.shade700),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtonsForPending(
    AppLocalizations l10n,
    JobProvider jobProvider,
    Job job,
    BuildContext context,
  ) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Reject Job'),
                  content: const Text(
                    'Are you sure you want to reject this job?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Reject'),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                final success = await jobProvider.rejectJob(job.id);
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Job rejected successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        jobProvider.errorMessage ?? 'Failed to reject job',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: jobProvider.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Reject'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: jobProvider.isLoading
                ? null
                : () async {
                    final success = await jobProvider.acceptJob(job.id);
                    if (success && context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              JobTrackingScreen(jobId: job.id),
                        ),
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Accept'),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtonsForAccepted(
    AppLocalizations l10n,
    Job job,
    BuildContext context,
  ) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () =>
                _openMap(job.latitude, job.longitude, l10n, context),
            icon: const Icon(Icons.map),
            label: Text(l10n.navigateToLocation),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JobTrackingScreen(jobId: job.id),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(l10n.startJob),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtonsForStarted(
    AppLocalizations l10n,
    Job job,
    BuildContext context,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JobTrackingScreen(jobId: job.id),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(l10n.completeJob),
      ),
    );
  }
}
