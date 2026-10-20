// customer_app/lib/screens/splash_screen.dart
// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

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

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    // Initialize and navigate
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    // Wait for auth provider to load token
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Wait for animation
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted && !_isNavigating) {
      _checkAuthenticationAndNavigate();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkAuthenticationAndNavigate() async {
    if (_isNavigating) return;
    
    setState(() {
      _isNavigating = true;
    });

    final authProvider = context.read<AuthProvider>();

    debugPrint('=== SplashScreen Navigation Check ===');
    debugPrint('isAuthenticated: ${authProvider.isAuthenticated}');
    debugPrint('token: ${authProvider.token != null ? "Found" : "Not found"}');
    debugPrint('userId: ${authProvider.userId}');
    debugPrint('phone: ${authProvider.phone}');

    if (mounted) {
      if (authProvider.isAuthenticated && authProvider.token != null) {
        debugPrint('User authenticated, navigating to profile check');

        Navigator.pushReplacementNamed(context, '/profile-check');
      } else {
        debugPrint('Not authenticated, navigating to landing screen');
        Navigator.pushReplacementNamed(context, '/landing');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
              const Text(
                'Service at your doorstep',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 30),
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