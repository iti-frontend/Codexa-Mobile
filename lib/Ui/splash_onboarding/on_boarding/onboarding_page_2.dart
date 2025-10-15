import 'package:codexa_mobile/Ui/utils/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'onboarding_widgets.dart';

class OnboardingPage2 extends StatelessWidget {
  final VoidCallback onNext;

  const OnboardingPage2({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColorsDark.seconderyBackground,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset("assets/images/on_boarding_2.png",
                width: 180, height: 180, fit: BoxFit.cover),
          ),
          const SizedBox(height: 40),
          const Text(
            "Learn from the best",
            style: TextStyle(
                color: AppColorsDark.primaryText,
                fontSize: 24,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            "Access high-quality courses, track your progress, and engage with a vibrant community of learners.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColorsDark.primaryText, fontSize: 14),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: const [
              Icon(Icons.check_circle, color: AppColorsDark.accentBlue),
              SizedBox(width: 8),
              Text("High-Quality Content",
                  style: TextStyle(color: AppColorsDark.primaryText)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: const [
              Icon(Icons.bar_chart, color: AppColorsDark.accentBlue),
              SizedBox(width: 8),
              Text("Progress Tracking",
                  style: TextStyle(color: AppColorsDark.primaryText)),
            ],
          ),
          const Spacer(),
          OnboardingButton(text: "Get Started", onPressed: onNext),
        ],
      ),
    );
  }
}
