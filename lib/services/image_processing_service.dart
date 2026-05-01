import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class ImageProcessingService {
  static Future<Uint8List> applyFilter(
    String imagePath,
    String filterName, {
    double brightness = 0.0,
    double contrast = 0.0,
  }) async {
    final file = File(imagePath);
    final bytes = await file.readAsBytes();
    var image = img.decodeImage(bytes);

    if (image == null) return bytes;

    image = _applyFilterToImage(image, filterName);

    if (brightness != 0.0) {
      final brightnessInt = (brightness * 100).toInt();
      image = img.adjustColor(image, brightness: brightnessInt);
    }

    if (contrast != 0.0) {
      final contrastInt = (contrast * 100).toInt();
      image = img.contrast(image, contrast: contrastInt);
    }

    return Uint8List.fromList(img.encodeJpg(image, quality: 90));
  }

  static img.Image _applyFilterToImage(img.Image image, String filterName) {
    switch (filterName) {
      case 'Black & White':
        image = img.grayscale(image);
        image = img.contrast(image, contrast: 50);
        return image;

      case 'Grayscale':
        return img.grayscale(image);

      case 'Color Enhance':
        image = img.adjustColor(image, saturation: 1.3);
        image = img.contrast(image, contrast: 20);
        return image;

      case 'High Contrast':
        image = img.contrast(image, contrast: 80);
        return image;

      case 'Original':
      default:
        return image;
    }
  }

  static Future<Uint8List> rotateImage(
      String imagePath, double degrees) async {
    final file = File(imagePath);
    final bytes = await file.readAsBytes();
    var image = img.decodeImage(bytes);
    if (image == null) return bytes;

    image = img.copyRotate(image, angle: degrees);
    return Uint8List.fromList(img.encodeJpg(image, quality: 90));
  }

  static Future<Uint8List> cropImage(
    String imagePath, {
    required int x,
    required int y,
    required int width,
    required int height,
  }) async {
    final file = File(imagePath);
    final bytes = await file.readAsBytes();
    var image = img.decodeImage(bytes);
    if (image == null) return bytes;

    image = img.copyCrop(image, x: x, y: y, width: width, height: height);
    return Uint8List.fromList(img.encodeJpg(image, quality: 90));
  }
}
