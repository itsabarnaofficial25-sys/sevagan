// ignore_for_file: deprecated_member_use, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants.dart';
import '../../data/models/job_model.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../../services/location_push_service.dart';

class JobTrackingScreen extends StatefulWidget {
  final String jobId;

  const JobTrackingScreen({super.key, required this.jobId});

  @override
  State<JobTrackingScreen> createState() => _JobTrackingScreenState();
}

class _JobTrackingScreenState extends State<JobTrackingScreen> {
  Job? _job;
  bool _isLoading = true;
  final _otpController = TextEditingController();
  final _priceController = TextEditingController();

  static const Color primaryColor = Color(0xFF2196F3);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color cardShadowColor = Color(0xFF1E293B);
  static const Color successColor = Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    _loadJobDetails();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _priceController.dispose();
    LocationPushService().stop();
    super.dispose();
  }

  Future<void> _loadJobDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await Dio().get(
        '${ApiConstants.baseUrl}/jobs/${widget.jobId}',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final json = response.data;
        final parsedStatus = _parseStatus(json['status']);
        setState(() {
          _job = Job(
            id: json['id'].toString(),
            customerName: json['customer']?['name'] ?? json['customerName'] ?? 'Customer',
            serviceType: json['serviceCategory']?['nameEn'] ?? 'Service',
            serviceTypeTa: json['serviceCategory']?['nameTa'] ?? '',
            description: json['description'] ?? '',
            descriptionTa: json['descriptionTa'] ?? '',
            address: json['locationAddress'] ?? json['address'] ?? 'Unknown',
            latitude: (json['locationLat'] as num?)?.toDouble() ?? 0.0,
            longitude: (json['locationLng'] as num?)?.toDouble() ?? 0.0,
            price: (json['estimatedPrice'] as num?)?.toDouble() ?? 0.0,
            createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
            status: parsedStatus,
          );
          _isLoading = false;
        });

        if (parsedStatus == JobStatus.accepted || parsedStatus == JobStatus.started) {
          LocationPushService().start();
        }
      }
    } catch (e) {
      debugPrint('Error loading job: $e');
      setState(() => _isLoading = false);
    }
  }

  JobStatus _parseStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'TECHNICIAN_ASSIGNED':
      case 'ACCEPTED':
        return JobStatus.accepted;
      case 'JOB_STARTED':
      case 'STARTED':
        return JobStatus.started;
      case 'JOB_COMPLETED':
      case 'COMPLETED':
        return JobStatus.completed;
      default:
        return JobStatus.pending;
    }
  }

  Future<void> _startJob(AppLocalizations l10n) async {
    if (_otpController.text.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.validOtpError),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      await Dio().post(
        '${ApiConstants.baseUrl}/jobs/${widget.jobId}/start',
        data: {'otp': _otpController.text},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (!mounted) return;
      LocationPushService().start();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.jobStarted),
          backgroundColor: successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      _loadJobDetails();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.error}: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _completeJob(AppLocalizations l10n) async {
    if (_priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.enterFinalPrice)),
      );
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      await Dio().post(
        '${ApiConstants.baseUrl}/jobs/${widget.jobId}/complete',
        data: {'finalPrice': double.parse(_priceController.text)},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (!mounted) return;
      LocationPushService().stop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.jobCompleted),
          backgroundColor: successColor,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.error}: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _callCustomer(String phone) async {
    final Uri url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _navigateToJob(AppLocalizations l10n) async {
    if (_job == null) return;
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${_job!.latitude},${_job!.longitude}&travelmode=driving',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.mapsLaunchError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          l10n.jobTracking,
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primaryColor)))
          : _job == null
          ? Center(child: Text(l10n.jobError))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildCustomerCard(l10n, localeProvider),
                  const SizedBox(height: 24),
                  if (_job!.status == JobStatus.accepted) _buildStartJobCard(l10n),
                  if (_job!.status == JobStatus.started) _buildCompleteJobCard(l10n),
                  if (_job!.status == JobStatus.completed) _buildCompletedCard(l10n),
                ],
              ),
            ),
    );
  }

  Widget _buildCustomerCard(AppLocalizations l10n, LocaleProvider localeProvider) {
    final description = localeProvider.locale.languageCode == 'ta'
        ? (_job!.descriptionTa.isNotEmpty ? _job!.descriptionTa : _job!.description)
        : _job!.description;

    return Card(
      elevation: 2,
      shadowColor: cardShadowColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.person, color: primaryColor, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.customerLabel, style: const TextStyle(fontSize: 11, color: textSecondary)),
                      const SizedBox(height: 2),
                      Text(_job!.customerName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textPrimary)),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.phone, color: successColor),
                    tooltip: l10n.callCustomer,
                    onPressed: () => _callCustomer('9876543210'),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.navigation_rounded, color: primaryColor),
                    tooltip: l10n.navigateToLocation,
                    onPressed: () => _navigateToJob(l10n),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(height: 1, color: borderColor),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.location_on, l10n.locationLabel, _job!.address),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.description, '${l10n.issueLabel}:', description),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _navigateToJob(l10n),
                icon: const Icon(Icons.directions, size: 18),
                label: Text(l10n.navigateToCustomerLocation, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: primaryColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: textSecondary)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textPrimary)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStartJobCard(AppLocalizations l10n) {
    return Card(
      elevation: 2,
      shadowColor: cardShadowColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.lock_clock, size: 32, color: Colors.orange),
            ),
            const SizedBox(height: 16),
            Text(l10n.enterOtpFromCustomer, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary)),
            const SizedBox(height: 16),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 8),
              decoration: InputDecoration(
                hintText: l10n.otpHintShort,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryColor, width: 2)),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _startJob(l10n),
              style: ElevatedButton.styleFrom(
                backgroundColor: successColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text(l10n.startJob, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompleteJobCard(AppLocalizations l10n) {
    return Card(
      elevation: 2,
      shadowColor: cardShadowColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.engineering, size: 32, color: primaryColor),
            ),
            const SizedBox(height: 16),
            Text(l10n.jobInProgress, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: primaryColor)),
            const SizedBox(height: 20),
            Text(l10n.enterFinalAmount, style: const TextStyle(fontSize: 14, color: textSecondary)),
            const SizedBox(height: 12),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixText: '₹ ',
                prefixStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textPrimary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryColor, width: 2)),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _completeJob(l10n),
              style: ElevatedButton.styleFrom(
                backgroundColor: successColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text(l10n.completeJob, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedCard(AppLocalizations l10n) {
    return Card(
      elevation: 2,
      color: successColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 48),
            const SizedBox(height: 12),
            Text(
              l10n.jobCompletedSuccessfully,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}