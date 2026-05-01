import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/document_provider.dart';
import '../providers/premium_provider.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/document_card.dart';
import '../widgets/ad_banner.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.document_scanner_rounded, size: 28),
            SizedBox(width: 8),
            Text(AppConstants.appName),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(context, '/documents'),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: Consumer2<DocumentProvider, PremiumProvider>(
        builder: (context, docProvider, premiumProvider, _) {
          return Column(
            children: [
              if (premiumProvider.shouldShowAds) const AdBannerWidget(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildQuickActions(context),
                      const SizedBox(height: 24),
                      if (!premiumProvider.isPremium) ...[
                        _buildPremiumBanner(context),
                        const SizedBox(height: 24),
                      ],
                      _buildRecentDocuments(context, docProvider),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/camera'),
        icon: const Icon(Icons.camera_alt_rounded, size: 28),
        label: const Text('Scan'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: Consumer<DocumentProvider>(
        builder: (context, provider, _) {
          return BottomNavigationBar(
            currentIndex: 0,
            onTap: (index) {
              switch (index) {
                case 0:
                  break;
                case 1:
                  Navigator.pushNamed(context, '/camera');
                  break;
                case 2:
                  Navigator.pushNamed(context, '/documents');
                  break;
                case 3:
                  Navigator.pushNamed(context, '/profile');
                  break;
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.camera_alt_rounded),
                label: 'Scan',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.folder_rounded),
                label: 'Documents',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.camera_alt_rounded,
                label: 'Scan',
                color: AppTheme.primaryColor,
                onTap: () => Navigator.pushNamed(context, '/camera'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.photo_library_rounded,
                label: 'Import',
                color: AppTheme.secondaryColor,
                onTap: () => _importFromGallery(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.folder_rounded,
                label: 'All Docs',
                color: AppTheme.warningColor,
                onTap: () => Navigator.pushNamed(context, '/documents'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPremiumBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/profile'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.premiumGold.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.workspace_premium_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upgrade to Premium',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'No ads, no watermark, advanced features',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentDocuments(
      BuildContext context, DocumentProvider provider) {
    final recentDocs = provider.recentDocuments;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Documents',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            if (recentDocs.isNotEmpty)
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/documents'),
                child: const Text('See All'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (provider.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (recentDocs.isEmpty)
          _buildEmptyState()
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentDocs.length,
            separatorBuilder: (_, index2) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return DocumentCard(document: recentDocs[index]);
            },
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        children: [
          Icon(
            Icons.document_scanner_outlined,
            size: 64,
            color: AppTheme.textLight.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No documents yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the Scan button to get started!',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }

  void _importFromGallery(BuildContext context) {
    Navigator.pushNamed(context, '/camera', arguments: {'fromGallery': true});
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
