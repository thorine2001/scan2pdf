import 'dart:io';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../models/document.dart';
import '../services/pdf_service.dart';
import '../services/share_service.dart';
import '../theme/app_theme.dart';

class ShareScreen extends StatelessWidget {
  const ShareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final document =
        ModalRoute.of(context)?.settings.arguments as ScannedDocument?;

    if (document == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Share')),
        body: const Center(child: Text('No document selected')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(document.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDocumentInfo(document),
            const SizedBox(height: 24),
            const Text(
              'PDF Preview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            if (document.pdfPath != null)
              SizedBox(
                height: 400,
                child: PdfPreview(
                  build: (_) => File(document.pdfPath!).readAsBytesSync(),
                  canChangePageFormat: false,
                  canChangeOrientation: false,
                  canDebug: false,
                  allowSharing: false,
                  allowPrinting: false,
                ),
              ),
            const SizedBox(height: 24),
            const Text(
              'Share Options',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildShareOptions(context, document),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentInfo(ScannedDocument document) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.picture_as_pdf,
                    color: AppTheme.errorColor, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        document.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${document.pageCount} pages | ${document.pageSize}',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOptions(BuildContext context, ScannedDocument document) {
    return Column(
      children: [
        _ShareOptionTile(
          icon: Icons.share_rounded,
          title: 'Share PDF',
          subtitle: 'Share via any app (WhatsApp, Email, etc.)',
          color: AppTheme.primaryColor,
          onTap: () => _sharePdf(context, document),
        ),
        const SizedBox(height: 8),
        _ShareOptionTile(
          icon: Icons.print_rounded,
          title: 'Print',
          subtitle: 'Print the document',
          color: AppTheme.secondaryColor,
          onTap: () => _printPdf(context, document),
        ),
        const SizedBox(height: 8),
        _ShareOptionTile(
          icon: Icons.image_rounded,
          title: 'Share Images',
          subtitle: 'Share original scanned images',
          color: AppTheme.warningColor,
          onTap: () => _shareImages(context, document),
        ),
      ],
    );
  }

  Future<void> _sharePdf(
      BuildContext context, ScannedDocument document) async {
    if (document.pdfPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No PDF file found')),
      );
      return;
    }

    try {
      await ShareService.sharePdf(document.pdfPath!, document.name);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing: $e')),
        );
      }
    }
  }

  Future<void> _printPdf(
      BuildContext context, ScannedDocument document) async {
    if (document.pdfPath == null) return;

    try {
      final pdfBytes = await PdfService.createPdfBytes(
        imagePaths: document.pageImagePaths,
        pageSize: document.pageSize,
        addWatermark: false,
      );
      await Printing.layoutPdf(onLayout: (_) => pdfBytes);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error printing: $e')),
        );
      }
    }
  }

  Future<void> _shareImages(
      BuildContext context, ScannedDocument document) async {
    try {
      await ShareService.shareMultipleFiles(
        document.pageImagePaths,
        document.name,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing images: $e')),
        );
      }
    }
  }
}

class _ShareOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ShareOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: Icon(Icons.arrow_forward_ios,
            size: 16, color: AppTheme.textLight),
        onTap: onTap,
      ),
    );
  }
}
