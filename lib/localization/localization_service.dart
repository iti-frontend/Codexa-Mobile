import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService {
  static const String defaultLanguage = 'en';
  static const List<String> supportedLanguages = ['en', 'ar'];

  static Locale _locale = const Locale(defaultLanguage);
  static Locale get locale => _locale;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language') ?? defaultLanguage;
    _locale = Locale(languageCode);
  }

  static Future<void> changeLanguage(String languageCode) async {
    if (!supportedLanguages.contains(languageCode)) return;

    _locale = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageCode);

    // Force RTL for Arabic
    if (languageCode == 'ar') {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
  }

  static bool isRTL() {
    return _locale.languageCode == 'ar';
  }

  static TextDirection get textDirection {
    return isRTL() ? TextDirection.rtl : TextDirection.ltr;
  }

  static Alignment get alignmentStart {
    return isRTL() ? Alignment.centerRight : Alignment.centerLeft;
  }

  static Alignment get alignmentEnd {
    return isRTL() ? Alignment.centerLeft : Alignment.centerRight;
  }

  static CrossAxisAlignment get crossAxisAlignmentStart {
    return isRTL() ? CrossAxisAlignment.end : CrossAxisAlignment.start;
  }

  static CrossAxisAlignment get crossAxisAlignmentEnd {
    return isRTL() ? CrossAxisAlignment.start : CrossAxisAlignment.end;
  }
}
