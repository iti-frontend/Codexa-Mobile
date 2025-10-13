import 'package:codexa_mobile/Ui/auth/login/login_view/loginScreen.dart';
import 'package:codexa_mobile/Ui/auth/register/register_view/registerScreen.dart';
import 'package:codexa_mobile/Ui/home_page/home_screen/homeScreen.dart';
import 'package:codexa_mobile/Ui/splash_onboarding/on_boarding/onboarding_screen.dart';
import 'package:codexa_mobile/Ui/splash_onboarding/splash_screen/splash_screen.dart';
import 'package:codexa_mobile/Ui/utils/provider_ui/theme_provider.dart';
import 'package:codexa_mobile/Ui/utils/theme/app_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(ChangeNotifierProvider(
      create: (context) => ThemeProvider(), child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        SplashScreen.routeName: (_) => SplashScreen(),
        OnboardingScreen.routeName: (_) => OnboardingScreen(),
        RegisterScreen.routeName: (_) => RegisterScreen(),
        LoginScreen.routeName: (_) => LoginScreen(),
        HomeScreen.routeName: (_) => HomeScreen(),
      },
      theme: AppThemeData.lightTheme,
      darkTheme: AppThemeData.darkTheme,
      themeMode: ThemeMode.dark,
    );
  }
}


// login
// register
// splash screen + on boarding
// landing page  => bottom navbar ==> home - courses - community - settings (theme - lanaguage - payment - history) (profile-screen - notifications - search-textfeild - chat-screen)
// 7-10-2025 ==> 11:59 pm