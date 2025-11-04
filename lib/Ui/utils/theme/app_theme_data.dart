import 'package:flutter/material.dart';
import 'package:codexa_mobile/Ui/utils/theme/app_colors.dart';

class AppThemeData {
  // ! Dark Theme

  static ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.dark(
      primary: AppColorsDark.accentBlue,
      secondary: AppColorsDark.accentGreen,
      surface: AppColorsDark.cardBackground,
      error: AppColorsDark.errorColor,
      onPrimary: AppColorsDark.primaryText,
      onSecondary: AppColorsDark.primaryText,
      onSurface: AppColorsDark.primaryText,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: AppColorsDark.seconderyBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColorsDark.seconderyBackground,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColorsDark.primaryText),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColorsDark.cardBackground,
      selectedItemColor: AppColorsDark.accentBlue,
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
        backgroundColor: AppColorsDark.accentBlue,
        foregroundColor: AppColorsDark.primaryText,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      linearTrackColor: AppColorsDark.secondaryText,
      color: AppColorsDark.accentGreen,
    ),
    iconTheme: IconThemeData(color: AppColorsDark.primaryText),
    dividerTheme: DividerThemeData(color: AppColorsDark.secondaryText),
  );

  // ! Light Theme

  static ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.light(
      primary: AppColorsLight.accentBlue,
      secondary: AppColorsLight.accentGreen,
      surface: AppColorsLight.cardBackground,
      error: AppColorsLight.errorColor,
      onPrimary: AppColorsLight.primaryText,
      onSecondary: AppColorsLight.primaryText,
      onSurface: AppColorsLight.primaryText,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: AppColorsLight.primaryBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColorsLight.primaryBackground,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColorsLight.primaryText),
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
    progressIndicatorTheme: ProgressIndicatorThemeData(
      linearTrackColor: AppColorsLight.secondaryText,
      color: AppColorsLight.accentBlue,
    ),
    iconTheme: IconThemeData(color: AppColorsLight.primaryText),
    dividerTheme: DividerThemeData(color: AppColorsLight.secondaryText),
  );
}
