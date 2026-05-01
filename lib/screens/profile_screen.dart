import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state_provider.dart';
import '../providers/document_provider.dart';
import '../providers/premium_provider.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      body: Consumer3<PremiumProvider, AppStateProvider, DocumentProvider>(
        builder: (context, premium, appState, docProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(premium),
                const SizedBox(height: 24),
                if (!premium.isPremium) ...[
                  _buildPremiumSection(context, premium),
                  const SizedBox(height: 24),
                ],
                _buildStatsSection(docProvider),
                const SizedBox(height: 24),
                _buildSecuritySection(context, premium, appState),
                const SizedBox(height: 24),
                _buildSettingsSection(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(PremiumProvider premium) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                size: 36,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Scan2PDF User',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: premium.isPremium
                          ? AppTheme.premiumGold.withValues(alpha: 0.1)
                          : AppTheme.textLight.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      premium.isPremium ? 'Premium' : 'Free Plan',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: premium.isPremium
                            ? AppTheme.premiumGold
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumSection(
      BuildContext context, PremiumProvider premium) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.workspace_premium_rounded,
                    color: AppTheme.premiumGold, size: 28),
                SizedBox(width: 8),
                Text(
                  'Upgrade to Premium',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFeatureRow(Icons.block, 'No advertisements'),
            _buildFeatureRow(Icons.water_drop_outlined, 'No watermark on PDFs'),
            _buildFeatureRow(Icons.auto_fix_high, 'Advanced image filters'),
            _buildFeatureRow(Icons.lock, 'Password-protected PDFs'),
            _buildFeatureRow(Icons.high_quality, 'High-quality export'),
            _buildFeatureRow(Icons.all_inclusive, 'Unlimited scans'),
            const SizedBox(height: 20),
            _buildPricingOptions(context, premium),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.secondaryColor),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingOptions(
      BuildContext context, PremiumProvider premium) {
    return Column(
      children: [
        _PricingCard(
          title: 'Monthly',
          price: '${AppConstants.currency}${AppConstants.monthlyPrice.toInt()}',
          period: '/month',
          color: AppTheme.primaryColor,
          onTap: () => _handlePurchase(context, premium, 'monthly'),
        ),
        const SizedBox(height: 8),
        _PricingCard(
          title: 'Yearly',
          price: '${AppConstants.currency}${AppConstants.yearlyPrice.toInt()}',
          period: '/year',
          color: AppTheme.secondaryColor,
          badge: 'Best Value',
          onTap: () => _handlePurchase(context, premium, 'yearly'),
        ),
        const SizedBox(height: 8),
        _PricingCard(
          title: 'Lifetime',
          price:
              '${AppConstants.currency}${AppConstants.lifetimePrice.toInt()}',
          period: 'one-time',
          color: AppTheme.premiumGold,
          onTap: () => _handlePurchase(context, premium, 'lifetime'),
        ),
      ],
    );
  }

  void _handlePurchase(
      BuildContext context, PremiumProvider premium, String type) {
    // In production, this would integrate with Google Play / App Store
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Purchase'),
        content: Text(
          'In-app purchases will be available when the app is published. '
          'For now, tap "Activate" to simulate premium activation ($type plan).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              premium.setPremium(true, type: type);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Premium activated!'),
                  backgroundColor: AppTheme.secondaryColor,
                ),
              );
            },
            child: const Text('Activate'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(DocumentProvider docProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.description,
                    label: 'Documents',
                    value: '${docProvider.allDocuments.length}',
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.pages,
                    label: 'Total Pages',
                    value: '${docProvider.allDocuments.fold<int>(0, (sum, doc) => sum + doc.pageCount)}',
                    color: AppTheme.secondaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySection(
    BuildContext context,
    PremiumProvider premium,
    AppStateProvider appState,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Security',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('App PIN Lock'),
              subtitle: Text(
                premium.isPremium
                    ? 'Protect app with a PIN'
                    : 'Premium feature',
                style: const TextStyle(fontSize: 12),
              ),
              value: appState.pinEnabled,
              onChanged: premium.isPremium
                  ? (value) {
                      if (value) {
                        _showSetPinDialog(context, appState);
                      } else {
                        appState.disablePin();
                      }
                    }
                  : null,
              secondary: Icon(
                Icons.lock,
                color: premium.isPremium
                    ? AppTheme.primaryColor
                    : AppTheme.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.info_outline,
                  color: AppTheme.primaryColor),
              title: const Text('About'),
              subtitle: const Text('Version 1.0.0'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showAboutDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showSetPinDialog(BuildContext context, AppStateProvider appState) {
    final pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set PIN'),
        content: TextField(
          controller: pinController,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Enter 4-digit PIN',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (pinController.text.length == 4) {
                appState.enablePin(pinController.text);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Set PIN'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.document_scanner_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(AppConstants.appName),
          ],
        ),
        content: const Text(
          '${AppConstants.appTagline}\n\n'
          'Version 1.0.0\n'
          'A fast, lightweight document scanner app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _PricingCard extends StatelessWidget {
  final String title;
  final String price;
  final String period;
  final Color color;
  final String? badge;
  final VoidCallback onTap;

  const _PricingCard({
    required this.title,
    required this.price,
    required this.period,
    required this.color,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            badge!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    '$price $period',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward, color: color),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
