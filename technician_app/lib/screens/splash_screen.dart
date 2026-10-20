// ignore_for_file: unused_import, use_super_parameters, unused_local_variable

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_localizations.dart';
import 'auth/login_screen.dart';
import 'landing_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();

    // Wait for auth status to be checked before navigating
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // First, ensure auth status is checked
    final authProvider = context.read<AuthProvider>();
    
    // Wait for animation to complete
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted && !_isNavigating) {
      _checkAuthentication();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkAuthentication() async {
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    final isAuthenticated = authProvider.isAuthenticated;
    final token = authProvider.token;

    debugPrint('=== SplashScreen Navigation Check ===');
    debugPrint('isAuthenticated: $isAuthenticated');
    debugPrint('token: $token');

    setState(() {
      _isNavigating = true;
    });

    // Small delay to ensure navigation context is ready
    await Future.delayed(const Duration(milliseconds: 100));

    if (mounted) {
     if (isAuthenticated && token != null) {
  debugPrint('✅ Authenticated, navigating to profile check');
  Navigator.pushReplacementNamed(context, '/profile-check');  // ✅ CORRECT
} else {
        debugPrint('❌ Not authenticated, navigating to landing');
        Navigator.pushReplacementNamed(context, '/landing');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Image
              Image.asset(
                'assets/sevagan.jpg',
                width: 350,
                height: 350,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 350,
                    height: 350,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(
                      Icons.handyman_rounded,
                      size: 80,
                      color: Colors.blue,
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              // Tagline Text - Localized
              Text(
                l10n.splashTagline,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              // Loading indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
                strokeWidth: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}