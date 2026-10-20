// lib/screens/customer_profile_check_screen.dart

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../providers/auth_provider.dart';
import '../../config/api_config.dart';
import '../l10n/app_localizations.dart';
import 'home/home_screen.dart';
import 'profile/customer_profile_setup_screen.dart';

class CustomerProfileCheckScreen extends StatefulWidget {
  const CustomerProfileCheckScreen({super.key});

  @override
  State<CustomerProfileCheckScreen> createState() =>
      _CustomerProfileCheckScreenState();
}

class _CustomerProfileCheckScreenState
    extends State<CustomerProfileCheckScreen> {
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkProfile();
  }

  Future<void> _checkProfile() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final token = authProvider.token;

      debugPrint('Checking customer profile...');
      debugPrint('Token: ${token?.substring(0, 20)}...');

      if (token == null || token.isEmpty) {
        debugPrint('No token found, redirecting to login');
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/customers/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('Profile check response: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (mounted) {
        final hasProfile = response.statusCode == 200;
        debugPrint('📱 Customer profile exists: $hasProfile');

        if (hasProfile) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const CustomerProfileSetupScreen(),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error checking customer profile: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Network error: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Center(
        child: _errorMessage != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.profileCheckError,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _errorMessage = null;
                      });
                      _checkProfile();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(l10n.retry),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.checkingProfile,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}