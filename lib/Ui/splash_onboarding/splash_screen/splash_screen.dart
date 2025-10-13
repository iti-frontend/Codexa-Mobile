import 'package:codexa_mobile/Ui/home_page/home_screen/homeScreen.dart';
import 'package:codexa_mobile/Ui/splash_onboarding/on_boarding/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:codexa_mobile/Ui/utils/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = '/';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // الانتقال بعد 2 ثانية
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, OnboardingScreen.routeName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsDark.seconderyBackground,
      body: const Center(
        child: Text(
          "Codexa",
          style: TextStyle(
            color: AppColorsDark.primaryText,
            fontSize: 25,
          ),
        ),
      ),
    );
  }
}
