import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Added
import 'onboarding_widgets.dart';

class OnboardingPage2 extends StatelessWidget {
  final VoidCallback onNext;

  const OnboardingPage2({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              "assets/images/on_boarding_2.png",
              width: 180,
              height: 180,
              fit: BoxFit.cover,
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms)
              .scale(curve: Curves.easeOutBack, duration: 600.ms),
          const SizedBox(height: 40),
          Text(
            "Learn from the best",
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.iconTheme.color,
            ),
          )
              .animate()
              .fadeIn(delay: 200.ms)
              .slideY(begin: 0.5, end: 0, duration: 500.ms),
          const SizedBox(height: 12),
          Text(
            "Access high-quality courses, track your progress, and engage with a vibrant community of learners.",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.iconTheme.color,
            ),
          )
              .animate()
              .fadeIn(delay: 400.ms)
              .slideY(begin: 0.5, end: 0, duration: 500.ms),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.check_circle, color: theme.iconTheme.color),
              const SizedBox(width: 8),
              Text(
                "High-Quality Content",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.iconTheme.color,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.2, end: 0),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.bar_chart, color: theme.iconTheme.color),
              const SizedBox(width: 8),
              Text(
                "Progress Tracking",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.iconTheme.color,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 800.ms).slideX(begin: -0.2, end: 0),
          const Spacer(),
          OnboardingButton(text: "Next", onPressed: onNext)
              .animate()
              .fadeIn(delay: 1000.ms)
              .scale(),
        ],
      ),
    );
  }
}
