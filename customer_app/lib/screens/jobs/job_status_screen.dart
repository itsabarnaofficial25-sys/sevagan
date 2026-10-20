// ignore_for_file: unused_import, deprecated_member_use, prefer_const_constructors

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../models/service_request.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../screens/payment/payment_screen.dart';
import '../tracking/live_tracking_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';

class JobStatusScreen extends StatefulWidget {
  final String jobId;

  const JobStatusScreen({super.key, required this.jobId});

  @override
  State<JobStatusScreen> createState() => _JobStatusScreenState();
}

class _JobStatusScreenState extends State<JobStatusScreen> {
  ServiceRequest? _job;
  bool _isLoading = true;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadJobDetails();
    _pollingTimer =
        Timer.periodic(const Duration(seconds: 10), (_) => _loadJobDetails());
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadJobDetails() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final apiService = ApiService();
      final job =
          await apiService.getJobDetails(authProvider.token!, widget.jobId);

      if (mounted) {
        setState(() {
          _job = job;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading job details: $e');
    }
  }

  void _callTechnician() async {
    try {
      final tech = _job?.technician;
      String? phone;

      if (tech is Map<String, dynamic>) {
        phone = tech['phone']?.toString();

        if (phone == null || phone.isEmpty) {
          if (tech['user'] is Map) {
            phone = (tech['user'] as Map)['phone']?.toString();
          }
        }
      }

      if (phone != null && phone.isNotEmpty) {
        final Uri uri = Uri(scheme: 'tel', path: phone);

        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          throw 'Dialer not supported';
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Phone number not available')),
        );
      }
    } catch (e) {
      debugPrint('Call error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.blue,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.jobStatus,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey.shade200,
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _job == null
              ? Center(child: Text(l10n.jobNotFound))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildStatusCard(l10n, localeProvider),
                      const SizedBox(height: 24),
                      if (_job!.status == 'TECHNICIAN_ASSIGNED')
                        _buildOtpCard(l10n),
                      const SizedBox(height: 24),
                      _buildTechnicianCard(l10n),
                      const SizedBox(height: 24),
                      _buildJobDetailsCard(l10n, localeProvider),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatusCard(
      AppLocalizations l10n, LocaleProvider localeProvider) {
    final job = _job!;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    // Get category name for service-specific icon
    final categoryName = job.serviceCategory?['nameEn'] as String? ?? '';

    switch (job.status) {
      case 'REQUESTED':
        statusColor = Colors.orange;
        statusText = l10n.findingTechnician;
        statusIcon = _getServiceIcon(categoryName); // Use service-specific icon
        break;
      case 'TECHNICIAN_ASSIGNED':
        statusColor = Colors.blue;
        statusText = l10n.technicianAssigned;
        statusIcon = Icons.person_rounded;
        break;
      case 'JOB_STARTED':
        statusColor = Colors.green;
        statusText = l10n.workInProgress;
        statusIcon = _getServiceIcon(categoryName); // Use service-specific icon
        break;
      case 'JOB_COMPLETED':
        statusColor = Colors.teal;
        statusText = l10n.paymentPending;
        statusIcon = Icons.payment_rounded;
        break;
      case 'COMPLETED':
        statusColor = Colors.green;
        statusText = l10n.completed;
        statusIcon = Icons.check_circle_rounded;
        break;
      default:
        statusColor = Colors.grey;
        statusText = job.status;
        statusIcon = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor.withOpacity(0.15),
            statusColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, size: 48, color: statusColor),
          ),
          const SizedBox(height: 16),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
          if (job.status == 'JOB_COMPLETED') ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentScreen(job: job),
                    ),
                  );
                  if (result == true) _loadJobDetails();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: statusColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(l10n.payNow),
              ),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildOtpCard(AppLocalizations l10n) {
    final job = _job!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Icon(Icons.lock_clock_rounded, size: 32, color: Colors.orange),
          const SizedBox(height: 10),
          Text(
            l10n.shareOtpWithTechnician,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Text(
            job.startJobOtp ?? '---',
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              letterSpacing: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicianCard(AppLocalizations l10n) {
    final job = _job!;
    if (job.technician == null) return const SizedBox();

    final tech = job.technician!;

    // Get service-specific icon for technician avatar
    IconData techIcon = Icons.person;
    if (job.serviceCategory?['nameEn'] != null) {
      techIcon = _getServiceIcon(job.serviceCategory!['nameEn'] as String);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.blue.withOpacity(0.1),
            child: Icon(techIcon, color: Colors.blue, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tech['name'] ?? l10n.technician,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (tech['rating'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '⭐ ${(tech['rating'] ?? 0.0).toStringAsFixed(1)}',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.phone, color: Colors.green),
              onPressed: _callTechnician,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildJobDetailsCard(
      AppLocalizations l10n, LocaleProvider localeProvider) {
    final job = _job!;

    // Get category name based on language
    final categoryName = job.serviceCategory != null
        ? (localeProvider.locale.languageCode == 'ta'
            ? (job.serviceCategory!['nameTa']?.isNotEmpty == true
                ? job.serviceCategory!['nameTa']
                : job.serviceCategory!['nameEn'])
            : job.serviceCategory!['nameEn'])
        : l10n.unknown;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.jobDetails,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildDetailRow(l10n, l10n.category, categoryName ?? l10n.unknown),
          _buildDetailRow(l10n, l10n.description, job.description),
          _buildDetailRow(l10n, l10n.price, '₹${job.estimatedPrice}'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(AppLocalizations l10n, String label, String value,
      {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Service icon mapping with new services support
  IconData _getServiceIcon(String name) {
    final value = name.toLowerCase();
    if (value.contains('electric')) return Icons.electrical_services_rounded;
    if (value.contains('plumb')) return Icons.plumbing_rounded;
    if (value.contains('ac') && !value.contains('activa')) return Icons.ac_unit_rounded;
    if (value.contains('motor')) return Icons.settings_rounded;
    if (value.contains('washing')) return Icons.local_laundry_service_rounded;
    if (value.contains('clean')) return Icons.cleaning_services_rounded;
    if (value.contains('carpentry')) return Icons.handyman_rounded;
    if (value.contains('paint')) return Icons.format_paint_rounded;
    if (value.contains('activa') || value.contains('driver')) return Icons.directions_bike_rounded;
    if (value.contains('home appliance') || value.contains('appliance service')) return Icons.devices_other_rounded;
    return Icons.build_circle_rounded;
  }
}