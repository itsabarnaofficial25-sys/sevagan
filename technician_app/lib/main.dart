// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; //ADD THIS FOR kDebugMode
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:provider/provider.dart';
import 'package:technician_app/l10n/app_localizations.dart';
import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/job_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/availability_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/landing_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/profile_check_screen.dart';
import 'screens/home_screen.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'screens/profile/profile_setup_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Handling background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // App Check Configuration - Auto selects based on build mode
  if (kDebugMode) {
    // DEVELOPMENT: Use debug provider
    debugPrint('Running in DEBUG mode - Using App Check Debug Provider');
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.debug,
    );
  } else {
    // PRODUCTION: Use Play Integrity
    debugPrint('Running in PRODUCTION mode - Using Play Integrity');
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
    );
  }
  
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(const TechnicianApp());
}

class TechnicianApp extends StatelessWidget {
  const TechnicianApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => JobProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => AvailabilityProvider()),
      ],
      child: Consumer2<AuthProvider, LocaleProvider>(
        builder: (context, auth, localeProvider, _) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'Sevagan Technician',
            debugShowCheckedModeBanner: false,
            locale: localeProvider.locale,
            theme: AppTheme.lightTheme,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en', ''), Locale('ta', '')],
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(),
              '/landing': (context) => const LandingScreen(),
              '/login': (context) => const TechnicianLoginScreen(),
              '/technician-home': (context) => const HomeScreen(),
              '/profile-check': (context) => const ProfileCheckScreen(),
              '/profile-setup': (context) => const ProfileSetupScreen(),
            },
            onGenerateRoute: (settings) {
              debugPrint('Generating route: ${settings.name}');
              return MaterialPageRoute(builder: (_) => const SplashScreen());
            },
            onUnknownRoute: (settings) {
              debugPrint('Unknown route: ${settings.name}');
              return MaterialPageRoute(builder: (_) => const SplashScreen());
            },
          );
        },
      ),
    );
  }
}