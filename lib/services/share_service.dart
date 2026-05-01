import 'package:share_plus/share_plus.dart';

class ShareService {
  static Future<void> sharePdf(String filePath, String fileName) async {
    await Share.shareXFiles(
      [XFile(filePath)],
      subject: fileName,
      text: 'Shared via Scan2PDF',
    );
  }

  static Future<void> shareMultipleFiles(
      List<String> filePaths, String subject) async {
    final files = filePaths.map((path) => XFile(path)).toList();
    await Share.shareXFiles(
      files,
      subject: subject,
      text: 'Shared via Scan2PDF',
    );
  }
}
