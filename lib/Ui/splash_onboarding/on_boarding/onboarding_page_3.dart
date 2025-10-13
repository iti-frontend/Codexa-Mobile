import 'package:codexa_mobile/Ui/utils/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'onboarding_widgets.dart';

class OnboardingPage3 extends StatelessWidget {
  final VoidCallback onFinish;

  const OnboardingPage3({super.key, required this.onFinish});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColorsDark.seconderyBackground,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          const Icon(Icons.group, color: AppColorsDark.accentBlue, size: 90),
          const SizedBox(height: 40),
          const Text(
            "Join the Codexa Community",
            style: TextStyle(
                color: AppColorsDark.primaryText,
                fontSize: 24,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            "Connect with peers, share insights, and grow together in your professional journey.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColorsDark.primaryText, fontSize: 14),
          ),
          const Spacer(),
          OnboardingButton(text: "Join Community", onPressed: onFinish),
          const SizedBox(height: 8),
          OnboardingButton(
            text: "Skip for now",
            onPressed: onFinish,
            color: AppColorsDark.primaryBackground,
            textColor: AppColorsDark.primaryText,
          ),
        ],
      ),
    );
  }
}