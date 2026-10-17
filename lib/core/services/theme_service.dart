import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  static ThemeService? _instance;
  SharedPreferences? _prefs;
  ThemeMode _currentThemeMode = ThemeMode.system;

  ThemeService._();

  static ThemeService get instance {
    _instance ??= ThemeService._();
    return _instance!;
  }

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final savedThemeMode = _prefs?.getString(_themeModeKey);
    if (savedThemeMode != null) {
      _currentThemeMode = _parseThemeMode(savedThemeMode);
    }
  }

  ThemeMode get themeMode => _currentThemeMode;

  Future<void> setThemeMode(ThemeMode mode) async {
    _currentThemeMode = mode;
    await _prefs?.setString(_themeModeKey, mode.toString());
    notifyListeners();
  }

  ThemeMode _parseThemeMode(String modeString) {
    switch (modeString) {
      case 'ThemeMode.light':
        return ThemeMode.light;
      case 'ThemeMode.dark':
        return ThemeMode.dark;
      case 'ThemeMode.system':
      default:
        return ThemeMode.system;
    }
  }

  bool isDarkMode(BuildContext context) {
    switch (_currentThemeMode) {
      case ThemeMode.light:
        return false;
      case ThemeMode.dark:
        return true;
      case ThemeMode.system:
        return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
  }
}
