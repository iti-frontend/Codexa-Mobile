import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class S {
  S(this.locale);

  final Locale locale;

  static S of(BuildContext context) {
    final inherited = context.dependOnInheritedWidgetOfExactType<_InheritedS>();
    if (inherited == null) {
      throw FlutterError(
          'S.of() called with a context that does not contain S');
    }
    return inherited.localizations;
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ar'),
  ];

  // Your translations
  String get appTitle => _translate('appTitle');
  String get welcome => _translate('welcome');
  String get login => _translate('login');
  String get language => _translate('language');

  String _translate(String key) {
    switch (locale.languageCode) {
      case 'ar':
        return _arabicTranslations[key] ?? key;
      default:
        return _englishTranslations[key] ?? key;
    }
  }

  static final Map<String, String> _englishTranslations = {
    'appTitle': 'Codexa',
    'welcome': 'Welcome',
    'login': 'Login',
    'language': 'Language',
  };

  static final Map<String, String> _arabicTranslations = {
    'appTitle': 'كوديكسا',
    'welcome': 'مرحباً',
    'login': 'تسجيل الدخول',
    'language': 'اللغة',
  };
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<S> load(Locale locale) => SynchronousFuture<S>(S(locale));

  @override
  bool shouldReload(_SDelegate old) => false;
}

class _InheritedS extends InheritedWidget {
  const _InheritedS({
    required this.localizations,
    required super.child,
  });

  final S localizations;

  @override
  bool updateShouldNotify(_InheritedS old) => false;
}
