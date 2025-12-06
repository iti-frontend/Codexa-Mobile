// lib/localization/localization_service.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:codexa_mobile/generated/l10n.dart';

class LocalizationService extends ChangeNotifier {
  static const String defaultLanguage = 'en';
  static const List<String> supportedLanguages = ['en', 'ar'];

  static LocalizationService? _instance;

  Locale _locale = const Locale(defaultLanguage);
  Locale get locale => _locale;

  // Add a setter for locale if needed
  set locale(Locale newLocale) {
    _locale = newLocale;
    notifyListeners();
  }

  factory LocalizationService() {
    return _instance ??= LocalizationService._internal();
  }

  LocalizationService._internal();

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language') ?? defaultLanguage;
    _locale = Locale(languageCode);

    // Force load the delegate with the current locale
    await S.delegate.load(_locale);

    notifyListeners();
  }

  Future<void> changeLanguage(String languageCode) async {
    if (!supportedLanguages.contains(languageCode)) return;

    _locale = Locale(languageCode);

    // Force load the delegate with new locale
    await S.delegate.load(_locale);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageCode);

    // Notify listeners (widgets) that locale has changed
    notifyListeners();

    // Force RTL for Arabic
    if (languageCode == 'ar') {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  bool isRTL() {
    return _locale.languageCode == 'ar';
  }

  TextDirection get textDirection {
    return isRTL() ? TextDirection.rtl : TextDirection.ltr;
  }

  Alignment get alignmentStart {
    return isRTL() ? Alignment.centerRight : Alignment.centerLeft;
  }

  Alignment get alignmentEnd {
    return isRTL() ? Alignment.centerLeft : Alignment.centerRight;
  }

  CrossAxisAlignment get crossAxisAlignmentStart {
    return isRTL() ? CrossAxisAlignment.end : CrossAxisAlignment.start;
  }

  CrossAxisAlignment get crossAxisAlignmentEnd {
    return isRTL() ? CrossAxisAlignment.start : CrossAxisAlignment.end;
  }
}