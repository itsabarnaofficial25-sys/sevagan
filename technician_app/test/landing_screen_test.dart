import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:technician_app/screens/landing_screen.dart';
import 'package:technician_app/providers/locale_provider.dart';
import 'package:technician_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  testWidgets('LandingScreen only shows Technician login button', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LocaleProvider(),
        child: Consumer<LocaleProvider>(
          builder: (context, localeProvider, _) {
            return MaterialApp(
              locale: localeProvider.locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('en', ''), Locale('ta', '')],
              home: const LandingScreen(),
            );
          },
        ),
      ),
    );

    // Verify that 'Technician' button is found
    expect(find.text('Technician'), findsOneWidget);

    // Verify that 'Customer' button is NOT found
    expect(find.text('Customer'), findsNothing);
  });
}
