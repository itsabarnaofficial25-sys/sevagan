// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_app_check/firebase_app_check.dart'; 
import 'package:sevagan_customer/screens/customer_profile_check_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/job_provider.dart';
import 'providers/location_provider.dart';
import 'providers/locale_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/landing_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'package:sevagan_customer/l10n/app_localizations.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'screens/profile/customer_profile_setup_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Handling background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // App Check Configuration - Auto selects based on build mode
  if (kDebugMode) {
    debugPrint('🔧 Running in DEBUG mode - Using App Check Debug Provider');
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.debug,
    );
  } else {
    debugPrint('🚀 Running in PRODUCTION mode - Using Play Integrity');
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
    );
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  NotificationService.navigatorKey = navigatorKey;
  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(const SevaganCustomerApp());
}

class SevaganCustomerApp extends StatelessWidget {
  const SevaganCustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => JobProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'Sevagan',
            debugShowCheckedModeBanner: false,
            locale: context.watch<LocaleProvider>().locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
              Locale('ta', ''),
            ],
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 0,
              ),
            ),
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(),
              '/landing': (context) => const LandingScreen(),
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const HomeScreen(),
              '/profile-check': (context) => const CustomerProfileCheckScreen(),
              '/profile-setup': (context) => const CustomerProfileSetupScreen(),
            },
            onUnknownRoute: (settings) {
              debugPrint('Unknown route: ${settings.name}');
              return MaterialPageRoute(
                builder: (context) => const Scaffold(
                  body: Center(child: Text('Page not found')),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
