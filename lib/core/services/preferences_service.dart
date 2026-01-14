import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const _keyTheme = 'theme_index';
  static const _keyFontSize = 'font_size';
  static const _keyNotificationTime = 'notification_time';
  static const _keyDarkMode = 'dark_mode';

  static Future<void> setThemeIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTheme, index);
  }

  static Future<int> getThemeIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyTheme) ?? 0;
  }

  static Future<void> setFontSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyFontSize, size);
  }

  static Future<double> getFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyFontSize) ?? 18.0;
  }

  static Future<void> setNotificationTime(String time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyNotificationTime, time);
  }

  static Future<String?> getNotificationTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyNotificationTime);
  }

  static Future<void> setDarkMode(bool dark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, dark);
  }

  static Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDarkMode) ?? false;
  }
}

