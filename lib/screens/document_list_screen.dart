import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/document_provider.dart';
import '../providers/premium_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/document_card.dart';
import '../widgets/ad_banner.dart';

class DocumentListScreen extends StatefulWidget {
  const DocumentListScreen({super.key});

  @override
  State<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends State<DocumentListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search documents...',
                  hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7)),
                  border: InputBorder.none,
                  filled: false,
                ),
                onChanged: (value) {
                  context.read<DocumentProvider>().setSearchQuery(value);
                },
              )
            : const Text('My Documents'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  context.read<DocumentProvider>().setSearchQuery('');
                }
              });
            },
          ),
        ],
      ),
      body: Consumer2<DocumentProvider, PremiumProvider>(
        builder: (context, docProvider, premiumProvider, _) {
          return Column(
            children: [
              if (premiumProvider.shouldShowAds) const AdBannerWidget(),
              Expanded(
                child: docProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : docProvider.documents.isEmpty
                        ? _buildEmptyState()
                        : _buildDocumentList(docProvider),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/camera'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isFiltered = _searchController.text.isNotEmpty;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isFiltered ? Icons.search_off : Icons.folder_open,
            size: 64,
            color: AppTheme.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            isFiltered ? 'No documents found' : 'No documents yet',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isFiltered
                ? 'Try a different search term'
                : 'Start scanning to create your first document',
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentList(DocumentProvider provider) {
    final docs = provider.documents;
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: docs.length,
      separatorBuilder: (_, index2) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return Dismissible(
          key: ValueKey(docs[index].id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            decoration: BoxDecoration(
              color: AppTheme.errorColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (_) => _confirmDelete(context, docs[index].name),
          onDismissed: (_) => provider.deleteDocument(docs[index].id),
          child: DocumentCard(document: docs[index]),
        );
      },
    );
  }

  Future<bool?> _confirmDelete(BuildContext context, String name) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
