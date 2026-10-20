import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../core/constants.dart';
import '../../l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../home_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _experienceController = TextEditingController();
  final _radiusController = TextEditingController(text: '10');

  final List<String> _availableSkills = [
    'Electrician',
    'Plumber',
    'AC Service',
    'Washing Machine',
    'Bike Repair',
    'Motor Repair',
  ];

  final List<String> _availableSkillsTa = [
    'எலக்ட்ரீஷியன்',
    'பிளம்பர்',
    'ஏசி சர்வீஸ்',
    'வாஷிங் மெஷின்',
    'பைக் ரிப்பேர்',
    'மோட்டார் ரிப்பேர்',
  ];

  final Set<String> _selectedSkills = {};
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _experienceController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  Future<void> _submitProfile(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.selectAtLeastOneSkill)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/technicians/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authProvider.token}',
        },
        body: jsonEncode({
          'name': _nameController.text.trim(),
          'skills': _selectedSkills.toList(),
          'experience': int.parse(_experienceController.text),

          // Changed field name
          'serviceRadiusKm': double.parse(_radiusController.text),

          // Changed field name
          'aadhaarImageUrl': 'placeholder.jpg',
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.profileCreatedWaiting),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } else {
        throw Exception('Failed to create profile: ${response.body}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.error}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isTamil = localeProvider.locale.languageCode == 'ta';

    // Get skills list based on language
    final displaySkills = isTamil ? _availableSkillsTa : _availableSkills;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.completeYourProfile),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.profileWelcomeMessage,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.fullName,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (v) =>
                    v?.trim().isEmpty ?? true ? l10n.required : null,
              ),
              const SizedBox(height: 16),

              // Experience
              TextFormField(
                controller: _experienceController,
                decoration: InputDecoration(
                  labelText: l10n.yearsOfExperience,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.work),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v?.trim().isEmpty ?? true) return l10n.required;
                  if (int.tryParse(v!) == null) return l10n.enterValidNumber;
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Service Radius
              TextFormField(
                controller: _radiusController,
                decoration: InputDecoration(
                  labelText: l10n.serviceRadius,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.location_on),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v?.trim().isEmpty ?? true) return l10n.required;
                  if (double.tryParse(v!) == null) return l10n.enterValidNumber;
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Skills
              Text(
                l10n.selectYourSkills,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: displaySkills.asMap().entries.map((entry) {
                  final index = entry.key;
                  final skillEn = _availableSkills[index];
                  final skillDisplay = entry.value;
                  final isSelected = _selectedSkills.contains(skillEn);
                  return FilterChip(
                    label: Text(skillDisplay),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedSkills.add(skillEn);
                        } else {
                          _selectedSkills.remove(skillEn);
                        }
                      });
                    },
                    selectedColor: Colors.blue.shade100,
                    checkmarkColor: Colors.blue,
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : () => _submitProfile(l10n),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        l10n.submitProfile,
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.profileNote,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
