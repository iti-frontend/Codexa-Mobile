import 'package:codexa_mobile/Ui/utils/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppThemeData {
  // ! Dark Theme
  static ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: AppColorsDark.seconderyBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColorsDark.seconderyBackground,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColorsDark.primaryText),
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
    progressIndicatorTheme: ProgressIndicatorThemeData(
      linearTrackColor: AppColorsDark.secondaryText,
      color: AppColorsDark.accentGreen,
    ),
    iconTheme: IconThemeData(color: AppColorsDark.primaryText),
    dividerTheme: DividerThemeData(color: AppColorsDark.secondaryText),
  );

  // ! Light Theme
  static ThemeData lightTheme = ThemeData(
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
