import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/app_state_provider.dart';
import 'screens/camera_screen.dart';
import 'screens/crop_edit_screen.dart';
import 'screens/document_list_screen.dart';
import 'screens/home_screen.dart';
import 'screens/pdf_preview_screen.dart';
import 'screens/pin_lock_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/share_screen.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';
import 'utils/constants.dart';

class Scan2PdfApp extends StatelessWidget {
  const Scan2PdfApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, _) {
        return MaterialApp(
          title: AppConstants.appName,
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          initialRoute: appState.isLocked ? '/pin-lock' : '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/home': (context) => const HomeScreen(),
            '/camera': (context) => const CameraScreen(),
            '/crop-edit': (context) => const CropEditScreen(),
            '/pdf-preview': (context) => const PdfPreviewScreen(),
            '/documents': (context) => const DocumentListScreen(),
            '/share': (context) => const ShareScreen(),
            '/profile': (context) => const ProfileScreen(),
            '/pin-lock': (context) => const PinLockScreen(),
          },
        );
      },
    );
  }
}
