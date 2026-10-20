// ignore_for_file: deprecated_member_use, unused_local_variable, unused_import

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../core/constants.dart';
import '../l10n/app_localizations.dart';
import 'home_screen.dart';
import 'profile/profile_setup_screen.dart';

class ProfileCheckScreen extends StatefulWidget {
  const ProfileCheckScreen({super.key});

  @override
  State<ProfileCheckScreen> createState() => _ProfileCheckScreenState();
}

class _ProfileCheckScreenState extends State<ProfileCheckScreen> {
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkProfile();
  }

  Future<void> _checkProfile() async {
    try {
      final authProvider = context.read<AuthProvider>();

      // ✅ Get token from AuthProvider
      final token = authProvider.token;

      debugPrint(
          '🔍 Checking profile with token: ${token?.substring(0, 20)}...');
      debugPrint('🔍 API URL: ${ApiConstants.baseUrl}/technicians/profile');

      // ✅ Check if token exists
      if (token == null || token.isEmpty) {
        debugPrint('❌ No token found, redirecting to login');
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/technicians/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('📥 Profile check response: ${response.statusCode}');
      debugPrint('📥 Response body: ${response.body}');

      if (!mounted) return;

      switch (response.statusCode) {
        case 200:
          debugPrint('✅ Technician profile found');

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const HomeScreen(),
            ),
          );
          break;

        case 404:
          debugPrint('🆕 Technician profile not found');

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const ProfileSetupScreen(),
            ),
          );
          break;

        case 401:
          debugPrint('❌ Unauthorized');

          Navigator.pushReplacementNamed(context, '/login');
          break;

        default:
          setState(() {
            _errorMessage =
                'Server Error (${response.statusCode})\n${response.body}';
          });
      }
    } catch (e) {
      debugPrint('❌ Error checking profile: $e');
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
