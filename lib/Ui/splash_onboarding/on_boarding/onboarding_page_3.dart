import 'package:flutter/material.dart';
import 'onboarding_widgets.dart';

class OnboardingPage3 extends StatelessWidget {
  final VoidCallback onFinish;

  const OnboardingPage3({super.key, required this.onFinish});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Icon(Icons.group, size: 90, color: theme.iconTheme.color),
          const SizedBox(height: 40),
          Text(
            "Join the Codexa Community",
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.iconTheme.color,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Connect with peers, share insights, and grow together in your professional journey.",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.iconTheme.color,
            ),
          ),
          const Spacer(),
          OnboardingButton(text: "Join Community", onPressed: onFinish),
          const SizedBox(height: 8),
          OnboardingButton(text: "Skip for now", onPressed: onFinish),
        ],
      ),
    );
  }
}
