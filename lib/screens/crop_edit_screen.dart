import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/scan_page.dart';
import '../providers/document_provider.dart';
import '../providers/premium_provider.dart';
import '../services/image_processing_service.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';

class CropEditScreen extends StatefulWidget {
  const CropEditScreen({super.key});

  @override
  State<CropEditScreen> createState() => _CropEditScreenState();
}

class _CropEditScreenState extends State<CropEditScreen> {
  late int _pageIndex;
  late ScanPage _page;
  Uint8List? _previewBytes;
  bool _isProcessing = false;
  String _selectedFilter = 'Original';
  double _brightness = 0.0;
  double _contrast = 0.0;
  double _rotation = 0.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _pageIndex = args['pageIndex'] as int;
      _page = args['page'] as ScanPage;
      _selectedFilter = _page.activeFilter;
      _brightness = _page.brightness;
      _contrast = _page.contrast;
      _rotation = _page.rotation;
    }
  }

  Future<void> _applyFilter(String filterName) async {
    final isPremium = context.read<PremiumProvider>().isPremium;
    if (!isPremium &&
        (filterName == 'Color Enhance' || filterName == 'High Contrast')) {
      _showPremiumDialog();
      return;
    }

    setState(() {
      _isProcessing = true;
      _selectedFilter = filterName;
    });

    try {
      final processed = await ImageProcessingService.applyFilter(
        _page.imagePath,
        filterName,
        brightness: _brightness,
        contrast: _contrast,
      );

      if (mounted) {
        setState(() {
          _previewBytes = processed;
          _isProcessing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error applying filter: $e')),
        );
      }
    }
  }

  Future<void> _updatePreview() async {
    setState(() => _isProcessing = true);

    try {
      final processed = await ImageProcessingService.applyFilter(
        _page.imagePath,
        _selectedFilter,
        brightness: _brightness,
        contrast: _contrast,
      );

      if (mounted) {
        setState(() {
          _previewBytes = processed;
          _isProcessing = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.workspace_premium_rounded,
                color: AppTheme.premiumGold),
            SizedBox(width: 8),
            Text('Premium Feature'),
          ],
        ),
        content: const Text(
          'Advanced filters are available for premium users. Upgrade to unlock all features!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamed(context, '/profile');
            },
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  void _saveChanges() {
    final updatedPage = _page.copyWith(
      processedImageBytes: _previewBytes,
      activeFilter: _selectedFilter,
      brightness: _brightness,
      contrast: _contrast,
      rotation: _rotation,
    );

    context.read<DocumentProvider>().updateScanPage(_pageIndex, updatedPage);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Page'),
        actions: [
          TextButton.icon(
            onPressed: _isProcessing ? null : _saveChanges,
            icon: const Icon(Icons.check, color: Colors.white),
            label: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _previewBytes != null
                          ? Image.memory(_previewBytes!, fit: BoxFit.contain)
                          : Image.file(File(_page.imagePath),
                              fit: BoxFit.contain),
                    ),
                  ),
                ),
                if (_isProcessing)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
          _buildEditControls(),
        ],
      ),
    );
  }

  Widget _buildEditControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filters',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: AppConstants.filterNames.length,
              separatorBuilder: (_, index2) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final filter = AppConstants.filterNames[index];
                final isSelected = filter == _selectedFilter;
                final isPremiumFilter =
                    filter == 'Color Enhance' || filter == 'High Contrast';

                return GestureDetector(
                  onTap: () => _applyFilter(filter),
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primaryColor
                                : AppTheme.dividerColor,
                            width: isSelected ? 2 : 1,
                          ),
                          color: isSelected
                              ? AppTheme.primaryColor.withValues(alpha: 0.1)
                              : Colors.grey[100],
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Icon(
                                _getFilterIcon(filter),
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : AppTheme.textSecondary,
                                size: 24,
                              ),
                            ),
                            if (isPremiumFilter)
                              const Positioned(
                                top: 2,
                                right: 2,
                                child: Icon(
                                  Icons.star,
                                  size: 12,
                                  color: AppTheme.premiumGold,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        filter,
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected
                              ? AppTheme.primaryColor
                              : AppTheme.textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _buildSlider('Brightness', _brightness, (value) {
            setState(() => _brightness = value);
          }),
          _buildSlider('Contrast', _contrast, (value) {
            setState(() => _contrast = value);
          }),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton.icon(
                onPressed: () async {
                  _rotation -= 90;
                  final rotated = await ImageProcessingService.rotateImage(
                    _page.imagePath,
                    _rotation,
                  );
                  if (mounted) setState(() => _previewBytes = rotated);
                },
                icon: const Icon(Icons.rotate_left, size: 18),
                label: const Text('Rotate Left'),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  _rotation += 90;
                  final rotated = await ImageProcessingService.rotateImage(
                    _page.imagePath,
                    _rotation,
                  );
                  if (mounted) setState(() => _previewBytes = rotated);
                },
                icon: const Icon(Icons.rotate_right, size: 18),
                label: const Text('Rotate Right'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    ValueChanged<double> onChanged,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: -1.0,
            max: 1.0,
            onChanged: onChanged,
            onChangeEnd: (_) => _updatePreview(),
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(
            value.toStringAsFixed(1),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  IconData _getFilterIcon(String filter) {
    switch (filter) {
      case 'Original':
        return Icons.image;
      case 'Black & White':
        return Icons.filter_b_and_w;
      case 'Grayscale':
        return Icons.tonality;
      case 'Color Enhance':
        return Icons.auto_fix_high;
      case 'High Contrast':
        return Icons.contrast;
      default:
        return Icons.filter;
    }
  }
}
