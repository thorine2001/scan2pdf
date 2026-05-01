import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/document.dart';
import '../providers/document_provider.dart';
import '../theme/app_theme.dart';

class DocumentCard extends StatelessWidget {
  final ScannedDocument document;

  const DocumentCard({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.pushNamed(context, '/share', arguments: document);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _buildThumbnail(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.pages, size: 14, color: AppTheme.textLight),
                        const SizedBox(width: 4),
                        Text(
                          '${document.pageCount} pages',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.calendar_today,
                            size: 14, color: AppTheme.textLight),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(document.updatedAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    if (document.isPasswordProtected)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(Icons.lock, size: 14, color: AppTheme.premiumGold),
                            const SizedBox(width: 4),
                            Text(
                              'Password Protected',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.premiumGold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) =>
                    _handleMenuAction(context, value),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'rename',
                    child: ListTile(
                      leading: Icon(Icons.edit, size: 20),
                      title: Text('Rename'),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'share',
                    child: ListTile(
                      leading: Icon(Icons.share, size: 20),
                      title: Text('Share'),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, size: 20,
                          color: AppTheme.errorColor),
                      title: Text('Delete',
                          style: TextStyle(color: AppTheme.errorColor)),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
                child: const Icon(Icons.more_vert,
                    color: AppTheme.textLight),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    if (document.pageImagePaths.isNotEmpty) {
      final firstImage = File(document.pageImagePaths.first);
      if (firstImage.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 56,
            height: 72,
            child: Image.file(firstImage, fit: BoxFit.cover),
          ),
        );
      }
    }

    return Container(
      width: 56,
      height: 72,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.picture_as_pdf,
        color: AppTheme.primaryColor,
        size: 28,
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'rename':
        _showRenameDialog(context);
        break;
      case 'share':
        Navigator.pushNamed(context, '/share', arguments: document);
        break;
      case 'delete':
        _showDeleteDialog(context);
        break;
    }
  }

  void _showRenameDialog(BuildContext context) {
    final controller = TextEditingController(text: document.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Document'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Document Name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context
                    .read<DocumentProvider>()
                    .renameDocument(document.id, controller.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text('Are you sure you want to delete "${document.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context
                  .read<DocumentProvider>()
                  .deleteDocument(document.id);
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(
                foregroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${date.day}/${date.month}/${date.year}';
  }
}
