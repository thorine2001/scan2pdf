class AppConstants {
  AppConstants._();

  static const String appName = 'Scan2PDF';
  static const String appTagline = 'Scan → Clean → Convert → Share in seconds';

  // Premium pricing
  static const double monthlyPrice = 99.0;
  static const double yearlyPrice = 499.0;
  static const double lifetimePrice = 799.0;
  static const String currency = '₹';

  // PDF page sizes
  static const Map<String, List<double>> pageSizes = {
    'A4': [595.28, 841.89],
    'Letter': [612.0, 792.0],
    'Legal': [612.0, 1008.0],
  };

  // Image filters
  static const List<String> filterNames = [
    'Original',
    'Black & White',
    'Grayscale',
    'Color Enhance',
    'High Contrast',
  ];

  // Shared preferences keys
  static const String keyIsPremium = 'is_premium';
  static const String keyPinEnabled = 'pin_enabled';
  static const String keyPinCode = 'pin_code';
  static const String keyFirstLaunch = 'first_launch';
  static const String keyDocuments = 'documents';

  // Watermark text for free users
  static const String watermarkText = 'Created with Scan2PDF';
}
