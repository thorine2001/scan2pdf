import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;

import '../models/document.dart';
import '../models/scan_page.dart';
import '../services/pdf_service.dart';
import '../services/storage_service.dart';

class DocumentProvider extends ChangeNotifier {
  List<ScannedDocument> _documents = [];
  final List<ScanPage> _currentScanPages = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<ScannedDocument> get documents {
    if (_searchQuery.isEmpty) return _documents;
    return _documents
        .where(
            (doc) => doc.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  List<ScannedDocument> get allDocuments => _documents;
  List<ScanPage> get currentScanPages => _currentScanPages;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  List<ScannedDocument> get recentDocuments {
    final sorted = List<ScannedDocument>.from(_documents)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sorted.take(5).toList();
  }

  DocumentProvider() {
    loadDocuments();
  }

  Future<void> loadDocuments() async {
    _isLoading = true;
    notifyListeners();

    _documents = await StorageService.loadDocumentsList();
    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void addScanPage(ScanPage page) {
    _currentScanPages.add(page);
    notifyListeners();
  }

  void removeScanPage(int index) {
    if (index >= 0 && index < _currentScanPages.length) {
      _currentScanPages.removeAt(index);
      notifyListeners();
    }
  }

  void reorderScanPages(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final page = _currentScanPages.removeAt(oldIndex);
    _currentScanPages.insert(newIndex, page);
    notifyListeners();
  }

  void updateScanPage(int index, ScanPage updatedPage) {
    if (index >= 0 && index < _currentScanPages.length) {
      _currentScanPages[index] = updatedPage;
      notifyListeners();
    }
  }

  void clearCurrentScan() {
    _currentScanPages.clear();
    notifyListeners();
  }

  Future<ScannedDocument> saveDocument({
    required String name,
    String pageSize = 'A4',
    bool addWatermark = true,
  }) async {
    _isLoading = true;
    notifyListeners();

    final uuid = const Uuid();
    final docId = uuid.v4();
    final imagePaths = <String>[];

    // Save processed images
    for (int i = 0; i < _currentScanPages.length; i++) {
      final page = _currentScanPages[i];
      if (page.processedImageBytes != null) {
        final fileName = '${docId}_page_$i.jpg';
        final savedPath =
            await StorageService.saveImage(page.processedImageBytes!, fileName);
        imagePaths.add(savedPath);
      } else {
        // Copy original image
        final imgDir = await StorageService.imagesDirectory;
        final ext = p.extension(page.imagePath);
        final newPath = p.join(imgDir, '${docId}_page_$i$ext');
        await File(page.imagePath).copy(newPath);
        imagePaths.add(newPath);
      }
    }

    // Generate PDF
    final pdfPath = await PdfService.createPdf(
      imagePaths: imagePaths,
      fileName: '${name}_$docId',
      pageSize: pageSize,
      addWatermark: addWatermark,
    );

    final document = ScannedDocument(
      id: docId,
      name: name,
      pageImagePaths: imagePaths,
      pdfPath: pdfPath,
      pageCount: imagePaths.length,
      pageSize: pageSize,
    );

    _documents.insert(0, document);
    await StorageService.saveDocumentsList(_documents);
    _currentScanPages.clear();
    _isLoading = false;
    notifyListeners();

    return document;
  }

  Future<void> renameDocument(String docId, String newName) async {
    final index = _documents.indexWhere((doc) => doc.id == docId);
    if (index != -1) {
      _documents[index].name = newName;
      _documents[index].updatedAt = DateTime.now();
      await StorageService.saveDocumentsList(_documents);
      notifyListeners();
    }
  }

  Future<void> deleteDocument(String docId) async {
    final index = _documents.indexWhere((doc) => doc.id == docId);
    if (index != -1) {
      await StorageService.deleteDocument(_documents[index]);
      _documents.removeAt(index);
      await StorageService.saveDocumentsList(_documents);
      notifyListeners();
    }
  }

  Future<String?> regeneratePdf(
    String docId, {
    String? pageSize,
    bool addWatermark = true,
  }) async {
    final index = _documents.indexWhere((doc) => doc.id == docId);
    if (index == -1) return null;

    final doc = _documents[index];
    final newPageSize = pageSize ?? doc.pageSize;

    // Delete old PDF
    if (doc.pdfPath != null) {
      await StorageService.deleteFile(doc.pdfPath!);
    }

    final pdfPath = await PdfService.createPdf(
      imagePaths: doc.pageImagePaths,
      fileName: '${doc.name}_${doc.id}',
      pageSize: newPageSize,
      addWatermark: addWatermark,
    );

    _documents[index] = doc.copyWith(
      pdfPath: pdfPath,
      pageSize: newPageSize,
      updatedAt: DateTime.now(),
    );

    await StorageService.saveDocumentsList(_documents);
    notifyListeners();

    return pdfPath;
  }
}
