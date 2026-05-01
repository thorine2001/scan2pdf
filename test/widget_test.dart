import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:scan2pdf/providers/app_state_provider.dart';
import 'package:scan2pdf/providers/document_provider.dart';
import 'package:scan2pdf/providers/premium_provider.dart';
import 'package:scan2pdf/screens/splash_screen.dart';

void main() {
  testWidgets('Splash screen displays app name', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppStateProvider()),
          ChangeNotifierProvider(create: (_) => PremiumProvider()),
          ChangeNotifierProvider(create: (_) => DocumentProvider()),
        ],
        child: const MaterialApp(
          home: SplashScreen(),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Scan2PDF'), findsOneWidget);
  });
}
