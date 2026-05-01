import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/scan_page.dart';
import '../providers/document_provider.dart';
import '../theme/app_theme.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isCapturing = false;
  bool _flashOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['fromGallery'] == true) {
        _pickFromGallery();
      }
    });
  }

  Future<void> _captureImage() async {
    if (_isCapturing) return;
    setState(() => _isCapturing = true);

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 95,
      );

      if (photo != null && mounted) {
        final page = ScanPage(
          id: const Uuid().v4(),
          imagePath: photo.path,
        );
        if (mounted) {
          context.read<DocumentProvider>().addScanPage(page);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error capturing image: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 95,
      );

      if (images.isNotEmpty && mounted) {
        final provider = context.read<DocumentProvider>();
        for (final image in images) {
          final page = ScanPage(
            id: const Uuid().v4(),
            imagePath: image.path,
          );
          provider.addScanPage(page);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking images: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Document'),
        actions: [
          IconButton(
            icon: Icon(_flashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: () => setState(() => _flashOn = !_flashOn),
          ),
        ],
      ),
      body: Consumer<DocumentProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              Expanded(
                child: provider.currentScanPages.isEmpty
                    ? _buildCameraPlaceholder()
                    : _buildPagePreview(provider),
              ),
              _buildBottomControls(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCameraPlaceholder() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.camera_alt_rounded,
              size: 80,
              color: Colors.white.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Tap the capture button or import from gallery',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagePreview(DocumentProvider provider) {
    return Container(
      color: Colors.grey[200],
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              '${provider.currentScanPages.length} page(s) scanned',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: PageView.builder(
              itemCount: provider.currentScanPages.length,
              itemBuilder: (context, index) {
                final page = provider.currentScanPages[index];
                return Stack(
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(page.imagePath),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 16,
                      child: Row(
                        children: [
                          _buildActionChip(
                            icon: Icons.edit,
                            label: 'Edit',
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/crop-edit',
                                arguments: {
                                  'pageIndex': index,
                                  'page': page,
                                },
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildActionChip(
                            icon: Icons.delete,
                            label: 'Remove',
                            color: AppTheme.errorColor,
                            onTap: () => provider.removeScanPage(index),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Page ${index + 1} of ${provider.currentScanPages.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    Color color = AppTheme.primaryColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls(DocumentProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildControlButton(
              icon: Icons.photo_library_rounded,
              label: 'Gallery',
              onTap: _pickFromGallery,
            ),
            GestureDetector(
              onTap: _isCapturing ? null : _captureImage,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryColor,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _isCapturing
                    ? const Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
              ),
            ),
            _buildControlButton(
              icon: Icons.check_circle_rounded,
              label: 'Done',
              color: provider.currentScanPages.isNotEmpty
                  ? AppTheme.secondaryColor
                  : AppTheme.textLight,
              onTap: provider.currentScanPages.isNotEmpty
                  ? () => Navigator.pushNamed(context, '/pdf-preview')
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    Color color = AppTheme.textSecondary,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color),
          ),
        ],
      ),
    );
  }
}
