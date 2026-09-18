import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized reactive settings controller for Ngam Teams.
/// Controls ThemeMode (Dark/Light) and App Locale (English/Malay)
/// with persistent storage via SharedPreferences.
class AppSettings extends ChangeNotifier {
  static final AppSettings instance = AppSettings._();
  AppSettings._();

  static const String _themePrefKey = 'theme_mode';
  static const String _langPrefKey = 'language_code';

  ThemeMode _themeMode = ThemeMode.dark;
  Locale _locale = const Locale('en');

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  Locale get locale => _locale;
  String get languageCode => _locale.languageCode;

  /// Initializes persisted settings from SharedPreferences on app startup.
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool(_themePrefKey);
      if (isDark != null) {
        _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      }
      final lang = prefs.getString(_langPrefKey);
      if (lang != null && (lang == 'en' || lang == 'ms')) {
        _locale = Locale(lang);
      }
      notifyListeners();
    } catch (_) {
      // Gracefully continue with defaults if storage is unavailable
    }
  }

  Future<void> _saveThemeToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themePrefKey, _themeMode == ThemeMode.dark);
    } catch (_) {}
  }

  Future<void> _saveLangToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_langPrefKey, _locale.languageCode);
    } catch (_) {}
  }

  void toggleTheme() {
    _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    _saveThemeToPrefs();
    notifyListeners();
  }

  void setDarkMode(bool isDark) {
    final newMode = isDark ? ThemeMode.dark : ThemeMode.light;
    if (_themeMode != newMode) {
      _themeMode = newMode;
      _saveThemeToPrefs();
      notifyListeners();
    }
  }

  void setLocale(Locale newLocale) {
    if (_locale != newLocale) {
      _locale = newLocale;
      _saveLangToPrefs();
      notifyListeners();
    }
  }

  void setLanguageCode(String code) {
    setLocale(Locale(code));
  }

  void setLanguage(String code) => setLanguageCode(code);
}
