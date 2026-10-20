//technician_app/lib/screens/home/home_screen.dart

// ignore_for_file: deprecated_member_use, unused_field, unused_local_variable, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:technician_app/l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/job_provider.dart';
import '../providers/availability_provider.dart';
import '../providers/locale_provider.dart';
import 'landing_screen.dart';
import 'jobs/job_requests_screen.dart';
import 'jobs/active_jobs_screen.dart';
import 'earnings/earnings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color cardShadowColor = Color(0xFF1E293B);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobProvider>().fetchMyJobs();
    });
  }

  Future<void> _showLogoutDialog(AppLocalizations l10n) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.logout, color: primaryColor, size: 28),
              const SizedBox(width: 12),
              Text(
                l10n.logout,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            l10n.areYouSureLogout,
            style: const TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: textSecondary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              child: Text(
                l10n.cancel,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();

                final authProvider = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                );
                final navigator = Navigator.of(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(l10n.loggingOut),
                      ],
                    ),
                    duration: const Duration(milliseconds: 500),
                  ),
                );

                await authProvider.logout();

                if (mounted) {
                  navigator.pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const LandingScreen(),
                    ),
                    (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              child: Text(l10n.logout),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          l10n.homeTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          // Language Selector
          PopupMenuButton<Locale>(
            icon: const Icon(Icons.language, color: primaryColor),
            onSelected: (Locale locale) {
              localeProvider.setLocale(locale);
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: Locale('en'),
                child: Row(
                  children: [
                    Icon(Icons.check, color: Colors.transparent),
                    SizedBox(width: 8),
                    Text('🇺🇸 English'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: Locale('ta'),
                child: Row(
                  children: [
                    Icon(Icons.check, color: Colors.transparent),
                    SizedBox(width: 8),
                    Text('🇮🇳 தமிழ்'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          // Logout Menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: primaryColor),
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutDialog(l10n);
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout, color: Colors.red, size: 20),
                    const SizedBox(width: 12),
                    Text(l10n.logout),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<JobProvider>().fetchMyJobs();
        },
        color: primaryColor,
        child: Consumer<JobProvider>(
          builder: (context, jobProvider, _) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildStatusCard(context, jobProvider, l10n),
                  const SizedBox(height: 24),

                  // Dashboard Title
                  Text(
                    l10n.dashboard,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Dashboard Items
                  Expanded(
                    child: ListView(
                      children: [
                        _buildDashboardItem(
                          context,
                          title: l10n.newJobRequests,
                          count: jobProvider.pendingJobs.length,
                          icon: Icons.notifications_active,
                          color: Colors.orange,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const JobRequestsScreen(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildDashboardItem(
                          context,
                          title: l10n.activeJobs,
                          count: jobProvider.activeJobs.length,
                          icon: Icons.work,
                          color: Colors.blue,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ActiveJobsScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildDashboardItem(
                          context,
                          title: l10n.earnings,
                          count: 0,
                          icon: Icons.account_balance_wallet,
                          color: Colors.green,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EarningsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusCard(
    BuildContext context,
    JobProvider provider,
    AppLocalizations l10n,
  ) {
    return Consumer<AvailabilityProvider>(
      builder: (context, availabilityProvider, _) {
        final isOnline = availabilityProvider.isOnline;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isOnline
                  ? [primaryColor, primaryColor.withOpacity(0.8)]
                  : [Colors.grey.shade600, Colors.grey.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isOnline
                    ? primaryColor.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isOnline ? Icons.flash_on : Icons.flash_off,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.status,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isOnline ? l10n.online : l10n.offline,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (availabilityProvider.isLoading)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                else
                  Switch(
                    value: isOnline,
                    onChanged: (val) {
                      availabilityProvider.setOnlineStatus(context, val);
                    },
                    activeColor: Colors.white,
                    activeTrackColor: Colors.white.withOpacity(0.5),
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: Colors.white.withOpacity(0.3),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDashboardItem(
    BuildContext context, {
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shadowColor: cardShadowColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
              ),
              if (count > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: textSecondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
