import 'package:codexa_mobile/Ui/utils/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppThemeData {
  // ! Dark Theme
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColorsDark.seconderyBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColorsDark.seconderyBackground,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColorsDark.primaryText),
      titleTextStyle: TextStyle(
        color: AppColorsDark.primaryText,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColorsDark.cardBackground,
      selectedItemColor: AppColorsDark.accentGreen,
      unselectedItemColor: AppColorsDark.secondaryText,
      elevation: 4,
    ),
    cardTheme: CardThemeData(
      color: AppColorsDark.cardBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColorsDark.accentGreen,
        foregroundColor: AppColorsDark.primaryText,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColorsDark.accentGreen,
      foregroundColor: AppColorsDark.primaryText,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      linearTrackColor: AppColorsDark.secondaryText,
      color: AppColorsDark.accentGreen,
    ),
    iconTheme: IconThemeData(color: AppColorsDark.primaryText),
    dividerTheme: DividerThemeData(color: AppColorsDark.secondaryText),
    textTheme: TextTheme(
      displayLarge: TextStyle(
          color: AppColorsDark.primaryText,
          fontSize: 32,
          fontWeight: FontWeight.bold),
      displayMedium: TextStyle(
          color: AppColorsDark.primaryText,
          fontSize: 28,
          fontWeight: FontWeight.bold),
      displaySmall: TextStyle(
          color: AppColorsDark.primaryText,
          fontSize: 24,
          fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(
          color: AppColorsDark.primaryText,
          fontSize: 20,
          fontWeight: FontWeight.w600),
      titleLarge: TextStyle(
          color: AppColorsDark.primaryText,
          fontSize: 18,
          fontWeight: FontWeight.w600),
      titleMedium: TextStyle(
          color: AppColorsDark.primaryText,
          fontSize: 16,
          fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(color: AppColorsDark.primaryText, fontSize: 16),
      bodyMedium: TextStyle(color: AppColorsDark.secondaryText, fontSize: 14),
      bodySmall: TextStyle(color: AppColorsDark.secondaryText, fontSize: 12),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColorsDark.cardBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(color: AppColorsDark.secondaryText),
    ),
  );

  // ! Light Theme
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColorsLight.primaryBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColorsLight.primaryBackground,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColorsLight.primaryText),
      titleTextStyle: TextStyle(
        color: AppColorsLight.primaryText,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColorsLight.cardBackground,
      selectedItemColor: AppColorsLight.accentBlue,
      unselectedItemColor: AppColorsLight.secondaryText,
      elevation: 4,
    ),
    cardTheme: CardThemeData(
      color: AppColorsLight.cardBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColorsLight.accentBlue,
        foregroundColor: AppColorsLight.primaryText,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColorsLight.accentBlue,
      foregroundColor: Colors.white,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      linearTrackColor: AppColorsLight.secondaryText,
      color: AppColorsLight.accentBlue,
    ),
    iconTheme: IconThemeData(color: AppColorsLight.primaryText),
    dividerTheme: DividerThemeData(color: AppColorsLight.secondaryText),
    textTheme: TextTheme(
      displayLarge: TextStyle(
          color: AppColorsLight.primaryText,
          fontSize: 32,
          fontWeight: FontWeight.bold),
      displayMedium: TextStyle(
          color: AppColorsLight.primaryText,
          fontSize: 28,
          fontWeight: FontWeight.bold),
      displaySmall: TextStyle(
          color: AppColorsLight.primaryText,
          fontSize: 24,
          fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(
          color: AppColorsLight.primaryText,
          fontSize: 20,
          fontWeight: FontWeight.w600),
      titleLarge: TextStyle(
          color: AppColorsLight.primaryText,
          fontSize: 18,
          fontWeight: FontWeight.w600),
      titleMedium: TextStyle(
          color: AppColorsLight.primaryText,
          fontSize: 16,
          fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(color: AppColorsLight.primaryText, fontSize: 16),
      bodyMedium: TextStyle(color: AppColorsLight.secondaryText, fontSize: 14),
      bodySmall: TextStyle(color: AppColorsLight.secondaryText, fontSize: 12),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColorsLight.cardBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(color: AppColorsLight.secondaryText),
    ),
  );
}
