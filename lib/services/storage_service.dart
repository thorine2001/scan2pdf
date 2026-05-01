import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;
import '../models/document.dart';
import '../utils/constants.dart';

class StorageService {
  static Future<String> get documentsDirectory async {
    final dir = await getApplicationDocumentsDirectory();
    final docsDir = Directory(p.join(dir.path, 'scan2pdf_documents'));
    if (!await docsDir.exists()) {
      await docsDir.create(recursive: true);
    }
    return docsDir.path;
  }

  static Future<String> get pdfDirectory async {
    final dir = await getApplicationDocumentsDirectory();
    final pdfDir = Directory(p.join(dir.path, 'scan2pdf_pdfs'));
    if (!await pdfDir.exists()) {
      await pdfDir.create(recursive: true);
    }
    return pdfDir.path;
  }

  static Future<String> get imagesDirectory async {
    final dir = await getApplicationDocumentsDirectory();
    final imgDir = Directory(p.join(dir.path, 'scan2pdf_images'));
    if (!await imgDir.exists()) {
      await imgDir.create(recursive: true);
    }
    return imgDir.path;
  }

  static Future<String> saveImage(List<int> imageBytes, String fileName) async {
    final imgDir = await imagesDirectory;
    final filePath = p.join(imgDir, fileName);
    final file = File(filePath);
    await file.writeAsBytes(imageBytes);
    return filePath;
  }

  static Future<void> saveDocumentsList(
      List<ScannedDocument> documents) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = documents.map((doc) => doc.toJson()).toList();
    await prefs.setString(AppConstants.keyDocuments, jsonEncode(jsonList));
  }

  static Future<List<ScannedDocument>> loadDocumentsList() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(AppConstants.keyDocuments);
    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List;
    return jsonList
        .map((json) =>
            ScannedDocument.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  static Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  static Future<void> deleteDocument(ScannedDocument document) async {
    for (final imagePath in document.pageImagePaths) {
      await deleteFile(imagePath);
    }
    if (document.pdfPath != null) {
      await deleteFile(document.pdfPath!);
    }
  }
}
