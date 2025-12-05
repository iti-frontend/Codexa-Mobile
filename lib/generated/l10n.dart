import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class S {
  S(this.locale);

  final Locale locale;

  static S? _current;

  // Static getter to access current instance
  static S get current {
    if (_current == null) {
      throw FlutterError('S.current called before S loaded. '
          'Make sure to initialize localization properly.');
    }
    return _current!;
  }

  // Method to update current instance when locale changes
  static void updateLocale(Locale locale) {
    _current = S(locale);
  }

  static S of(BuildContext context) {
    final inherited = context.dependOnInheritedWidgetOfExactType<_InheritedS>();
    if (inherited == null) {
      throw FlutterError(
          'S.of() called with a context that does not contain S. '
              'Make sure your widget is wrapped in MaterialApp or Localizations widget.');
    }
    return inherited.localizations;
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ar'),
  ];

  // App Common
  String get appTitle => _translate('appTitle');
  String get welcome => _translate('welcome');
  String get orContinueWith => _translate('orContinueWith');
  String get registerForFree => _translate('registerForFree');
  String get loginNow => _translate('loginNow');
  String get alreadyHaveAccount => _translate('alreadyHaveAccount');
  String get dontHaveAccount => _translate('dontHaveAccount');
  String get loading => _translate('loading');
  String get error => _translate('error');
  String get success => _translate('success');
  String get cancel => _translate('cancel');
  String get save => _translate('save');
  String get delete => _translate('delete');
  String get edit => _translate('edit');
  String get confirm => _translate('confirm');
  String get continueText => _translate('continueText');
  String get back => _translate('back');
  String get next => _translate('next');
  String get skip => _translate('skip');
  String get finish => _translate('finish');
  String get search => _translate('search');
  String get clear => _translate('clear');
  String get submit => _translate('submit');
  String get send => _translate('send');
  String get add => _translate('add');
  String get remove => _translate('remove');
  String get update => _translate('update');
  String get create => _translate('create');
  String get view => _translate('view');
  String get profile => _translate('profile');
  String get settings => _translate('settings');
  String get logout => _translate('logout');
  String get language => _translate('language');
  String get theme => _translate('theme');
  String get darkTheme => _translate('darkTheme');
  String get help => _translate('help');
  String get about => _translate('about');
  String get privacy => _translate('privacy');
  String get notifications => _translate('notifications');

  // Login Screen
  String get login => _translate('login');
  String get signIn => _translate('signIn');
  String get iAmA => _translate('iAmA');
  String get student => _translate('student');
  String get instructor => _translate('instructor');
  String get email => _translate('email');
  String get password => _translate('password');
  String get forgotPassword => _translate('forgotPassword');
  String get enterValidEmail => _translate('enterValidEmail');
  String get emailCannotBeEmpty => _translate('emailCannotBeEmpty');
  String get passwordCannotBeEmpty => _translate('passwordCannotBeEmpty');
  String get passwordMinLength => _translate('passwordMinLength');
  String get selectRole => _translate('selectRole');
  String get selectRoleSocial => _translate('selectRoleSocial');
  String get loginFailed => _translate('loginFailed');
  String get loginSuccess => _translate('loginSuccess');
  String get googleLoginFailed => _translate('googleLoginFailed');
  String get githubLoginFailed => _translate('githubLoginFailed');

  // Register Screen
  String get register => _translate('register');
  String get registerTitle => _translate('registerTitle');
  String get fullName => _translate('fullName');
  String get confirmPassword => _translate('confirmPassword');
  String get enterValidName => _translate('enterValidName');
  String get passwordTooShort => _translate('passwordTooShort');
  String get passwordsDoNotMatch => _translate('passwordsDoNotMatch');
  String get registrationSuccessful => _translate('registrationSuccessful');
  String get registrationFailed => _translate('registrationFailed');

  // Profile Screen
  String get profileTitle => _translate('profileTitle');
  String get studentProfile => _translate('studentProfile');
  String get instructorProfile => _translate('instructorProfile');
  String get editProfile => _translate('editProfile');
  String get saveChanges => _translate('saveChanges');
  String get cancelEditing => _translate('cancelEditing');
  String get changeProfilePicture => _translate('changeProfilePicture');
  String get chooseFromGallery => _translate('chooseFromGallery');
  String get takePhoto => _translate('takePhoto');
  String get newImageSelected => _translate('newImageSelected');
  String get imageSelectionRemoved => _translate('imageSelectionRemoved');
  String get profileUpdated => _translate('profileUpdated');
  String get enterName => _translate('enterName');
  String get enterEmail => _translate('enterEmail');
  String get validEmail => _translate('validEmail');
  String get profilePreview => _translate('profilePreview');
  String get tapToChangePhoto => _translate('tapToChangePhoto');
  String get updatingProfile => _translate('updatingProfile');

  // Placeholders
  String get usernamePlaceholder => _translate('usernamePlaceholder');
  String get passwordPlaceholder => _translate('passwordPlaceholder');
  String get fullNamePlaceholder => _translate('fullNamePlaceholder');

  // Errors
  String get somethingWentWrong => _translate('somethingWentWrong');
  String get userDataNotAvailable => _translate('userDataNotAvailable');

  String _translate(String key) {
    switch (locale.languageCode) {
      case 'ar':
        return _arabicTranslations[key] ?? _englishTranslations[key] ?? key;
      default:
        return _englishTranslations[key] ?? key;
    }
  }

  static final Map<String, String> _englishTranslations = {
    // App Common
    'appTitle': 'Codexa',
    'welcome': 'Welcome',
    'orContinueWith': 'or continue with',
    'registerForFree': 'Register for free',
    'loginNow': 'Login Now',
    'alreadyHaveAccount': 'Already Have An Account? ',
    'dontHaveAccount': "Don't have an account yet? ",
    'loading': 'Loading...',
    'error': 'Error',
    'success': 'Success',
    'cancel': 'Cancel',
    'save': 'Save',
    'delete': 'Delete',
    'edit': 'Edit',
    'confirm': 'Confirm',
    'continueText': 'Continue',
    'back': 'Back',
    'next': 'Next',
    'skip': 'Skip',
    'finish': 'Finish',
    'search': 'Search',
    'clear': 'Clear',
    'submit': 'Submit',
    'send': 'Send',
    'add': 'Add',
    'remove': 'Remove',
    'update': 'Update',
    'create': 'Create',
    'view': 'View',
    'profile': 'Profile',
    'settings': 'Settings',
    'logout': 'Logout',
    'language': 'Language',
    'theme': 'Theme',
    'darkTheme': 'Dark Theme',
    'help': 'Help',
    'about': 'About',
    'privacy': 'Privacy',
    'notifications': 'Notifications',

    // Login Screen
    'login': 'Login',
    'signIn': 'Sign in',
    'iAmA': 'I am a:',
    'student': 'Student',
    'instructor': 'Instructor',
    'email': 'Email',
    'password': 'Password',
    'forgotPassword': 'Forgot Password?',
    'enterValidEmail': 'Enter a valid email',
    'emailCannotBeEmpty': 'Email cannot be empty',
    'passwordCannotBeEmpty': 'Password cannot be empty',
    'passwordMinLength': 'Password must be at least 6 characters',
    'selectRole': 'Please select a role (Student or Instructor)',
    'selectRoleSocial': 'Please select a role before social login',
    'loginFailed': 'Login failed',
    'loginSuccess': 'Logged in successfully!',
    'googleLoginFailed': 'Google login failed',
    'githubLoginFailed': 'GitHub login failed',

    // Register Screen
    'register': 'Register',
    'registerTitle': 'Register',
    'fullName': 'Full Name',
    'confirmPassword': 'Confirm Password',
    'enterValidName': 'Enter valid full name',
    'passwordTooShort': 'Password too short',
    'passwordsDoNotMatch': 'Passwords do not match',
    'registrationSuccessful': 'Registration Successful! Redirecting...',
    'registrationFailed': 'Registration failed',

    // Profile Screen
    'profileTitle': 'Profile',
    'studentProfile': 'Student Profile',
    'instructorProfile': 'Instructor Profile',
    'editProfile': 'Edit Profile',
    'saveChanges': 'Save Changes',
    'cancelEditing': 'Cancel',
    'changeProfilePicture': 'Change Profile Picture',
    'chooseFromGallery': 'Choose from Gallery',
    'takePhoto': 'Take Photo',
    'newImageSelected': 'New image selected',
    'imageSelectionRemoved': 'Image selection removed',
    'profileUpdated': 'Profile updated successfully',
    'enterName': 'Please enter your name',
    'enterEmail': 'Please enter your email',
    'validEmail': 'Please enter a valid email address',
    'profilePreview': 'Profile Preview',
    'tapToChangePhoto': 'Tap the camera icon to change photo',
    'updatingProfile': 'Updating profile...',

    // Placeholders
    'usernamePlaceholder': 'username@gmail.com',
    'passwordPlaceholder': 'Password',
    'fullNamePlaceholder': 'Full Name',

    // Errors
    'somethingWentWrong': 'Something went wrong',
    'userDataNotAvailable': 'User data not available',
  };

  static final Map<String, String> _arabicTranslations = {
    // App Common
    'appTitle': 'كوديكسا',
    'welcome': 'مرحباً',
    'orContinueWith': 'أو متابعة باستخدام',
    'registerForFree': 'سجل مجاناً',
    'loginNow': 'سجل الدخول الآن',
    'alreadyHaveAccount': 'هل لديك حساب بالفعل؟ ',
    'dontHaveAccount': 'ليس لديك حساب بعد؟ ',
    'loading': 'جاري التحميل...',
    'error': 'خطأ',
    'success': 'نجاح',
    'cancel': 'إلغاء',
    'save': 'حفظ',
    'delete': 'حذف',
    'edit': 'تعديل',
    'confirm': 'تأكيد',
    'continueText': 'متابعة',
    'back': 'رجوع',
    'next': 'التالي',
    'skip': 'تخطي',
    'finish': 'إنهاء',
    'search': 'بحث',
    'clear': 'مسح',
    'submit': 'إرسال',
    'send': 'إرسال',
    'add': 'إضافة',
    'remove': 'إزالة',
    'update': 'تحديث',
    'create': 'إنشاء',
    'view': 'عرض',
    'profile': 'الملف الشخصي',
    'settings': 'الإعدادات',
    'logout': 'تسجيل الخروج',
    'language': 'اللغة',
    'theme': 'الثيم',
    'darkTheme': 'الثيم الداكن',
    'help': 'مساعدة',
    'about': 'حول',
    'privacy': 'الخصوصية',
    'notifications': 'الإشعارات',

    // Login Screen
    'login': 'تسجيل الدخول',
    'signIn': 'تسجيل الدخول',
    'iAmA': 'أنا:',
    'student': 'طالب',
    'instructor': 'مدرس',
    'email': 'البريد الإلكتروني',
    'password': 'كلمة المرور',
    'forgotPassword': 'نسيت كلمة المرور؟',
    'enterValidEmail': 'أدخل بريد إلكتروني صحيح',
    'emailCannotBeEmpty': 'البريد الإلكتروني لا يمكن أن يكون فارغاً',
    'passwordCannotBeEmpty': 'كلمة المرور لا يمكن أن تكون فارغة',
    'passwordMinLength': 'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
    'selectRole': 'الرجاء اختيار دور (طالب أو مدرس)',
    'selectRoleSocial': 'الرجاء اختيار دور قبل التسجيل الاجتماعي',
    'loginFailed': 'فشل تسجيل الدخول',
    'loginSuccess': 'تم تسجيل الدخول بنجاح!',
    'googleLoginFailed': 'فشل تسجيل الدخول عبر جوجل',
    'githubLoginFailed': 'فشل تسجيل الدخول عبر جيثب',

    // Register Screen
    'register': 'تسجيل',
    'registerTitle': 'التسجيل',
    'fullName': 'الاسم الكامل',
    'confirmPassword': 'تأكيد كلمة المرور',
    'enterValidName': 'أدخل اسم كامل صحيح',
    'passwordTooShort': 'كلمة المرور قصيرة جداً',
    'passwordsDoNotMatch': 'كلمات المرور لا تتطابق',
    'registrationSuccessful': 'تم التسجيل بنجاح! جاري التوجيه...',
    'registrationFailed': 'فشل التسجيل',

    // Profile Screen
    'profileTitle': 'الملف الشخصي',
    'studentProfile': 'ملف الطالب',
    'instructorProfile': 'ملف المدرس',
    'editProfile': 'تعديل الملف',
    'saveChanges': 'حفظ التغييرات',
    'cancelEditing': 'إلغاء التعديل',
    'changeProfilePicture': 'تغيير صورة الملف',
    'chooseFromGallery': 'اختيار من المعرض',
    'takePhoto': 'التقاط صورة',
    'newImageSelected': 'تم اختيار صورة جديدة',
    'imageSelectionRemoved': 'تمت إزالة اختيار الصورة',
    'profileUpdated': 'تم تحديث الملف الشخصي بنجاح',
    'enterName': 'الرجاء إدخال اسمك',
    'enterEmail': 'الرجاء إدخال بريدك الإلكتروني',
    'validEmail': 'الرجاء إدخال بريد إلكتروني صحيح',
    'profilePreview': 'معاينة الملف',
    'tapToChangePhoto': 'انقر على أيقونة الكاميرا لتغيير الصورة',
    'updatingProfile': 'جاري تحديث الملف...',

    // Placeholders
    'usernamePlaceholder': 'اسم المستخدم@gmail.com',
    'passwordPlaceholder': 'كلمة المرور',
    'fullNamePlaceholder': 'الاسم الكامل',

    // Errors
    'somethingWentWrong': 'حدث خطأ ما',
    'userDataNotAvailable': 'بيانات المستخدم غير متاحة',
  };
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<S> load(Locale locale) {
    final s = S(locale);
    S.updateLocale(locale); // Update the static current instance
    return SynchronousFuture<S>(s);
  }

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