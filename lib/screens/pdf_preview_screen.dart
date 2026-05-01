import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/document_provider.dart';
import '../providers/premium_provider.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';

class PdfPreviewScreen extends StatefulWidget {
  const PdfPreviewScreen({super.key});

  @override
  State<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedPageSize = 'A4';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController.text =
        'Scan_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _savePdf() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a document name')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final premiumProvider = context.read<PremiumProvider>();
      final docProvider = context.read<DocumentProvider>();

      final document = await docProvider.saveDocument(
        name: _nameController.text.trim(),
        pageSize: _selectedPageSize,
        addWatermark: premiumProvider.shouldAddWatermark,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF saved successfully!'),
            backgroundColor: AppTheme.secondaryColor,
          ),
        );

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false,
          arguments: {'newDocument': document},
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving PDF: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Preview'),
        actions: [
          TextButton.icon(
            onPressed: _isSaving ? null : _savePdf,
            icon: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.save, color: Colors.white),
            label: Text(
              _isSaving ? 'Saving...' : 'Save',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Consumer<DocumentProvider>(
        builder: (context, provider, _) {
          final pages = provider.currentScanPages;

          return Column(
            children: [
              Expanded(
                child: ReorderableListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: pages.length,
                  onReorder: provider.reorderScanPages,
                  itemBuilder: (context, index) {
                    final page = pages[index];
                    return Card(
                      key: ValueKey(page.id),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 60,
                            height: 80,
                            child: page.processedImageBytes != null
                                ? Image.memory(
                                    page.processedImageBytes!,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    File(page.imagePath),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        title: Text(
                          'Page ${index + 1}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          'Filter: ${page.activeFilter}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  size: 20, color: AppTheme.primaryColor),
                              onPressed: () {
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
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  size: 20, color: AppTheme.errorColor),
                              onPressed: () {
                                provider.removeScanPage(index);
                              },
                            ),
                            const Icon(Icons.drag_handle,
                                color: AppTheme.textLight),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              _buildSettings(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSettings() {
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
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Document Name',
                prefixIcon: Icon(Icons.description),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text(
                  'Page Size: ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                ...AppConstants.pageSizes.keys.map((size) {
                  final isSelected = size == _selectedPageSize;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(size),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedPageSize = size);
                        }
                      },
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 12),
            Consumer<PremiumProvider>(
              builder: (context, premium, _) {
                if (!premium.isPremium) {
                  return Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.warningColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: AppTheme.warningColor, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Watermark will be added. Upgrade to Premium to remove.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.warningColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _savePdf,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.picture_as_pdf),
                label: Text(_isSaving ? 'Creating PDF...' : 'Create PDF'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
