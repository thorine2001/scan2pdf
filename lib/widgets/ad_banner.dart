import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AdBannerWidget extends StatelessWidget {
  const AdBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder for Google AdMob banner
    // In production, replace with actual AdMob BannerAd widget
    return Container(
      width: double.infinity,
      height: 60,
      color: Colors.grey[100],
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.ad_units, size: 16, color: AppTheme.textLight),
            const SizedBox(width: 8),
            Text(
              'Ad Space - Integrate AdMob',
              style: TextStyle(
                color: AppTheme.textLight,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
