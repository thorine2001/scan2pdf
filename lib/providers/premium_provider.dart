import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class PremiumProvider extends ChangeNotifier {
  bool _isPremium = false;
  String? _subscriptionType;

  bool get isPremium => _isPremium;
  String? get subscriptionType => _subscriptionType;

  PremiumProvider() {
    _loadPremiumStatus();
  }

  Future<void> _loadPremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool(AppConstants.keyIsPremium) ?? false;
    _subscriptionType = prefs.getString('subscription_type');
    notifyListeners();
  }

  Future<void> setPremium(bool value, {String? type}) async {
    _isPremium = value;
    _subscriptionType = type;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyIsPremium, value);
    if (type != null) {
      await prefs.setString('subscription_type', type);
    }
    notifyListeners();
  }

  bool get shouldShowAds => !_isPremium;
  bool get shouldAddWatermark => !_isPremium;
  bool get canUseAdvancedFilters => _isPremium;
  bool get canPasswordProtect => _isPremium;
  bool get hasHighQualityExport => _isPremium;
}
