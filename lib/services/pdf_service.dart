import 'dart:io';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path/path.dart' as p;

import '../utils/constants.dart';
import 'storage_service.dart';

class PdfService {
  static Future<String> createPdf({
    required List<String> imagePaths,
    required String fileName,
    String pageSize = 'A4',
    bool addWatermark = true,
    String? password,
  }) async {
    final pdf = pw.Document();
    final size = AppConstants.pageSizes[pageSize] ?? AppConstants.pageSizes['A4']!;
    final pdfPageFormat = PdfPageFormat(size[0], size[1]);

    for (final imagePath in imagePaths) {
      final file = File(imagePath);
      if (!await file.exists()) continue;

      final imageBytes = await file.readAsBytes();
      final image = pw.MemoryImage(imageBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: pdfPageFormat,
          margin: pw.EdgeInsets.zero,
          build: (pw.Context context) {
            return pw.Stack(
              children: [
                pw.Center(
                  child: pw.Image(image, fit: pw.BoxFit.contain),
                ),
                if (addWatermark)
                  pw.Positioned(
                    bottom: 10,
                    right: 10,
                    child: pw.Opacity(
                      opacity: 0.3,
                      child: pw.Text(
                        AppConstants.watermarkText,
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      );
    }

    final pdfDir = await StorageService.pdfDirectory;
    final outputPath = p.join(pdfDir, '$fileName.pdf');
    final file = File(outputPath);
    final Uint8List pdfBytes = await pdf.save();
    await file.writeAsBytes(pdfBytes);

    return outputPath;
  }

  static Future<Uint8List> createPdfBytes({
    required List<String> imagePaths,
    String pageSize = 'A4',
    bool addWatermark = true,
  }) async {
    final pdf = pw.Document();
    final size = AppConstants.pageSizes[pageSize] ?? AppConstants.pageSizes['A4']!;
    final pdfPageFormat = PdfPageFormat(size[0], size[1]);

    for (final imagePath in imagePaths) {
      final file = File(imagePath);
      if (!await file.exists()) continue;

      final imageBytes = await file.readAsBytes();
      final image = pw.MemoryImage(imageBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: pdfPageFormat,
          margin: pw.EdgeInsets.zero,
          build: (pw.Context context) {
            return pw.Stack(
              children: [
                pw.Center(
                  child: pw.Image(image, fit: pw.BoxFit.contain),
                ),
                if (addWatermark)
                  pw.Positioned(
                    bottom: 10,
                    right: 10,
                    child: pw.Opacity(
                      opacity: 0.3,
                      child: pw.Text(
                        AppConstants.watermarkText,
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      );
    }

    return pdf.save();
  }
}
