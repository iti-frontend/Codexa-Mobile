import 'package:codexa_mobile/Ui/utils/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'onboarding_widgets.dart';

class OnboardingPage1 extends StatelessWidget {
  final VoidCallback onNext;

  const OnboardingPage1({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColorsDark.seconderyBackground,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          const Icon(Icons.bar_chart,
              color: AppColorsDark.accentBlue, size: 90),
          const SizedBox(height: 40),
          const Text(
            "Welcome to Codexa",
            style: TextStyle(
                color: AppColorsDark.primaryText,
                fontSize: 24,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            "Your go-to platform for professional growth and community engagement. Connect with peers, learn new skills, and advance your career.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColorsDark.primaryText, fontSize: 14),
          ),
          const Spacer(),
          OnboardingButton(text: "Get Started", onPressed: onNext),
        ],
      ),
    );
  }
}
