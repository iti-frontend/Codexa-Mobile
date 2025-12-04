import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _currentTheme = ThemeMode.light;
  static const String _themeKey = 'theme_mode';

  ThemeMode get currentTheme => _currentTheme;

  bool get isDarkMode => _currentTheme == ThemeMode.dark;

  ThemeProvider() {
    _loadTheme();
  }

  // Load saved theme from SharedPreferences
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);

    if (savedTheme != null) {
      _currentTheme = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    }
  }

  // Save theme to SharedPreferences
  Future<void> _saveTheme(ThemeMode theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _themeKey, theme == ThemeMode.dark ? 'dark' : 'light');
  }

  // Toggle between light and dark theme
  Future<void> toggleTheme() async {
    _currentTheme =
        _currentTheme == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await _saveTheme(_currentTheme);
    notifyListeners();
  }

  // Change theme mode (keep for backward compatibility)
  Future<void> changeThemeMode(ThemeMode newTheme) async {
    if (_currentTheme == newTheme) return;
    _currentTheme = newTheme;
    await _saveTheme(newTheme);
    notifyListeners();
  }
}
