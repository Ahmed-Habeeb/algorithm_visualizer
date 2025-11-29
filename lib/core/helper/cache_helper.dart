import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  final SharedPreferences _prefs;

  CacheHelper(this._prefs);

  // Theme
  static const String _themeKey = 'theme_mode';
  static const String _speedKey = 'animation_speed';
  static const String _localeKey = 'locale';

  Future<bool> setThemeMode(String mode) async {
    return await _prefs.setString(_themeKey, mode);
  }

  String getThemeMode() {
    return _prefs.getString(_themeKey) ?? 'system';
  }

  Future<bool> setAnimationSpeed(double speed) async {
    return await _prefs.setDouble(_speedKey, speed);
  }

  double getAnimationSpeed() {
    return _prefs.getDouble(_speedKey) ?? 1.0;
  }

  Future<bool> setLocale(String locale) async {
    return await _prefs.setString(_localeKey, locale);
  }

  String getLocale() {
    return _prefs.getString(_localeKey) ?? 'en';
  }
}
