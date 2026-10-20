// ignore_for_file: prefer_const_constructors, deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/service_category.dart';
import '../../models/customer_profile.dart';
import '../../providers/auth_provider.dart';
import '../../providers/location_provider.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import '../../l10n/app_localizations.dart';
import 'job_status_screen.dart';
import '../../providers/locale_provider.dart';

class CreateJobScreen extends StatefulWidget {
  final ServiceCategory category;

  const CreateJobScreen({super.key, required this.category});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _descriptionController = TextEditingController();
  final apiService = ApiService();
  bool _isLoading = false;
  bool _scheduleForLater = false;
  DateTime? _selectedDateTime;
  CustomerProfile? _customerProfile;

  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFFFF9800);
  static const Color backgroundColor = Color(0xFFF8F9FC);
  static const Color surfaceColor = Colors.white;
  static const Color textPrimary = Color(0xFF1A2C3E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color successColor = Color(0xFF4CAF50);

  @override
  void initState() {
    super.initState();
    _fetchCustomerProfile();
  }

  Future<void> _fetchCustomerProfile() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/customers/profile'),
        headers: {'Authorization': 'Bearer ${authProvider.token}'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _customerProfile = CustomerProfile.fromJson(data);
        });
      }
    } catch (e) {
      debugPrint('Error fetching customer profile: $e');
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest(AppLocalizations l10n) async {
    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.describeIssue),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final locationProvider = context.read<LocationProvider>();

      if (locationProvider.latitude == null ||
          locationProvider.longitude == null) {
        await locationProvider.getCurrentLocation();
      }

      final address = _customerProfile?.address ??
          locationProvider.currentAddress ??
          'Unknown Location';

      final requestData = {
        'serviceCategoryId': widget.category.id,
        'description': _descriptionController.text,
        'locationLat': locationProvider.latitude ?? 13.0827,
        'locationLng': locationProvider.longitude ?? 80.2707,
        'locationAddress': address,
        'imageUrls': [],
      };

      if (_scheduleForLater && _selectedDateTime != null) {
        requestData['preferredDateTime'] = _selectedDateTime!.toIso8601String();
      }

      final request = await apiService.createServiceRequest(
        authProvider.token!,
        requestData,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.requestCreated),
            backgroundColor: successColor,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => JobStatusScreen(jobId: request.id),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);
    
    // Get screen width for responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 380;
    final paddingSize = isSmallScreen ? 12.0 : 16.0;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(l10n, localeProvider),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(paddingSize),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildServiceInfoCard(l10n, localeProvider),
                const SizedBox(height: 20),
                _buildDescriptionCard(l10n),
                const SizedBox(height: 20),
                _buildSchedulingCard(l10n),
                const SizedBox(height: 20),
                _buildPriceCard(l10n),
                const SizedBox(height: 20),
                _buildSubmitButton(l10n),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      AppLocalizations l10n, LocaleProvider localeProvider) {
    final displayName = localeProvider.locale.languageCode == 'ta'
        ? (widget.category.nameTa.isNotEmpty
            ? widget.category.nameTa
            : widget.category.nameEn)
        : widget.category.nameEn;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        displayName,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.3,
        ),
        overflow: TextOverflow.ellipsis,  // ← Responsive
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

  Widget _buildServiceInfoCard(
      AppLocalizations l10n, LocaleProvider localeProvider) {
    final displayName = localeProvider.locale.languageCode == 'ta'
        ? (widget.category.nameTa.isNotEmpty
            ? widget.category.nameTa
            : widget.category.nameEn)
        : widget.category.nameEn;

    final displayDescription = localeProvider.locale.languageCode == 'ta'
        ? (widget.category.descriptionTa != null &&
                widget.category.descriptionTa!.isNotEmpty
            ? widget.category.descriptionTa!
            : widget.category.description)
        : widget.category.description;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,  // ← Responsive
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                _getServiceIcon(widget.category.nameEn),
                size: 32,
                color: primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                    softWrap: true,  // ← Responsive
                    overflow: TextOverflow.visible,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    displayDescription ?? l10n.professionalService,
                    style: TextStyle(
                      fontSize: 13,
                      color: textSecondary,
                    ),
                    softWrap: true,  // ← Responsive
                    overflow: TextOverflow.visible,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.description_rounded,
                    size: 18,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(  // ← Responsive - allows text to wrap
                  child: Text(
                    l10n.describeIssue,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                    softWrap: true,  // ← Responsive
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: l10n.issueHint,
                hintStyle: TextStyle(color: textTertiary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: primaryColor, width: 2),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchedulingCard(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.schedule_rounded,
                    size: 18,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(  // ← Responsive
                  child: Text(
                    l10n.scheduleForLater,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                    softWrap: true,  // ← Responsive
                  ),
                ),
                Switch(
                  value: _scheduleForLater,
                  onChanged: (value) {
                    setState(() {
                      _scheduleForLater = value;
                      if (!value) {
                        _selectedDateTime = null;
                      }
                    });
                  },
                  activeColor: primaryColor,
                ),
              ],
            ),
            if (_scheduleForLater) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              if (_selectedDateTime != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.calendar_today_rounded,
                          size: 20,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatDateTime(_selectedDateTime!),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: textPrimary,
                              ),
                              softWrap: true,
                            ),
                            Text(
                              l10n.preferredServiceTime,
                              style: TextStyle(
                                fontSize: 12,
                                color: textTertiary,
                              ),
                              softWrap: true,
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => _pickDateTime(l10n),
                        child: Text(
                          l10n.change,
                          style: TextStyle(color: primaryColor),
                        ),
                      ),
                    ],
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _pickDateTime(l10n),
                    icon: const Icon(Icons.access_time_rounded),
                    label: Text(l10n.selectDateTime),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      side: BorderSide(color: borderColor),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPriceCard(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: secondaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: secondaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,  // ← Responsive
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: secondaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.currency_rupee_rounded,
                size: 24,
                color: secondaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.estimatedBasePrice,
                    style: const TextStyle(
                      fontSize: 13,
                      color: textSecondary,
                    ),
                    softWrap: true,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${widget.category.basePrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: secondaryColor,
                    ),
                    softWrap: true,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.finalPriceNote,
                    style: const TextStyle(
                      fontSize: 11,
                      color: textTertiary,
                    ),
                    softWrap: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : () => _submitRequest(l10n),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                l10n.requestTechnician,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
                softWrap: true,
                textAlign: TextAlign.center,
              ),
      ),
    );
  }

  Future<void> _pickDateTime(AppLocalizations l10n) async {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));

    final date = await showDatePicker(
      context: context,
      initialDate: tomorrow,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: primaryColor),
          ),
          child: child!,
        );
      },
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: primaryColor),
          ),
          child: child!,
        );
      },
    );

    if (time == null) return;

    final selectedDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    if (selectedDateTime.isBefore(now.add(const Duration(hours: 1)))) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.timeAtLeastOneHour),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() {
      _selectedDateTime = selectedDateTime;
    });
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final month = months[dateTime.month - 1];
    final day = dateTime.day;
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '$month $day, ${hour == 0 ? 12 : hour}:$minute $period';
  }

  // UPDATED: Added new service icons
  IconData _getServiceIcon(String name) {
    final value = name.toLowerCase();
    if (value.contains('electric')) return Icons.electrical_services_rounded;
    if (value.contains('plumb')) return Icons.plumbing_rounded;
    if (value.contains('ac')) return Icons.ac_unit_rounded;
    if (value.contains('motor')) return Icons.settings_rounded;
    if (value.contains('washing')) return Icons.local_laundry_service_rounded;
    if (value.contains('clean')) return Icons.cleaning_services_rounded;
    if (value.contains('carpentry')) return Icons.handyman_rounded;
    if (value.contains('activa') || value.contains('driver')) return Icons.directions_bike_rounded;
    if (value.contains('home appliance') || value.contains('appliance service')) return Icons.devices_other_rounded;
    return Icons.build_circle_rounded;
  }
}