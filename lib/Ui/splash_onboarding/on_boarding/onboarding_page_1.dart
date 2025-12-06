import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Added
import 'onboarding_widgets.dart';

class OnboardingPage1 extends StatelessWidget {
  final VoidCallback onNext;

  const OnboardingPage1({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          // Icon with pulse animation
          Icon(Icons.bar_chart, size: 90, color: theme.iconTheme.color)
              .animate()
              .scale(duration: 600.ms, curve: Curves.easeOutBack)
              .then()
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(end: 1.1, duration: 2.seconds),

          const SizedBox(height: 40),

          Text(
            "Welcome to Codexa",
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.iconTheme.color,
            ),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.5, end: 0),

          const SizedBox(height: 12),

          Text(
            "Your go-to platform for professional growth and community engagement. Connect with peers, learn new skills, and advance your career.",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.iconTheme.color,
            ),
          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.5, end: 0),

          const Spacer(),

          OnboardingButton(text: "Next", onPressed: onNext)
              .animate()
              .fadeIn(delay: 700.ms)
              .scale(),
        ],
      ),
    );
  }
}
