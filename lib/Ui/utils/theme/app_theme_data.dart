import 'package:codexa_mobile/Ui/utils/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppThemeData {
  // ! Dark Theme
  static ThemeData darkTheme = ThemeData(
      scaffoldBackgroundColor: AppColorsDark.seconderyBackground,
      appBarTheme:
          AppBarTheme(backgroundColor: AppColorsDark.seconderyBackground));
  // ! Light Theme
  static ThemeData lightTheme = ThemeData(
      scaffoldBackgroundColor: AppColorsLight.primaryBackground,
      appBarTheme:
          AppBarTheme(backgroundColor: AppColorsLight.primaryBackground));
}
