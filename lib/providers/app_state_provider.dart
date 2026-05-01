import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class AppStateProvider extends ChangeNotifier {
  bool _isLocked = false;
  bool _pinEnabled = false;
  String _pinCode = '';
  bool _isFirstLaunch = true;
  int _currentNavIndex = 0;

  bool get isLocked => _isLocked;
  bool get pinEnabled => _pinEnabled;
  bool get isFirstLaunch => _isFirstLaunch;
  int get currentNavIndex => _currentNavIndex;

  AppStateProvider() {
    _loadAppState();
  }

  Future<void> _loadAppState() async {
    final prefs = await SharedPreferences.getInstance();
    _pinEnabled = prefs.getBool(AppConstants.keyPinEnabled) ?? false;
    _pinCode = prefs.getString(AppConstants.keyPinCode) ?? '';
    _isFirstLaunch = prefs.getBool(AppConstants.keyFirstLaunch) ?? true;

    if (_pinEnabled && _pinCode.isNotEmpty) {
      _isLocked = true;
    }

    notifyListeners();
  }

  void setNavIndex(int index) {
    _currentNavIndex = index;
    notifyListeners();
  }

  Future<void> enablePin(String pin) async {
    _pinCode = pin;
    _pinEnabled = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyPinEnabled, true);
    await prefs.setString(AppConstants.keyPinCode, pin);
    notifyListeners();
  }

  Future<void> disablePin() async {
    _pinCode = '';
    _pinEnabled = false;
    _isLocked = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyPinEnabled, false);
    await prefs.remove(AppConstants.keyPinCode);
    notifyListeners();
  }

  bool verifyPin(String pin) {
    if (pin == _pinCode) {
      _isLocked = false;
      notifyListeners();
      return true;
    }
    return false;
  }

  void lockApp() {
    if (_pinEnabled) {
      _isLocked = true;
      notifyListeners();
    }
  }

  Future<void> setFirstLaunchDone() async {
    _isFirstLaunch = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyFirstLaunch, false);
    notifyListeners();
  }
}
