import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Minimalist social login icon with cool animations.
/// Appears "alone" (no background) but alive.
class CustomSocialIcon extends StatelessWidget {
  final String assetPath;
  final VoidCallback? onTap;
  final double size;

  const CustomSocialIcon({
    super.key,
    required this.assetPath,
    this.onTap,
    this.size = 50, // Slightly larger by default
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Image.asset(
        assetPath,
        height: size,
        width: size,
        fit: BoxFit.contain,
      )
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .scaleXY(
              begin: 1.0,
              end: 1.1,
              duration: 1.5.seconds,
              curve: Curves.easeInOut) // Breathing effect
          .then()
          .shimmer(duration: 2.seconds, delay: 1.seconds) // Occasional shimmer
          .animate() // Entrance animation
          .fadeIn(duration: 600.ms)
          .slideY(
              begin: 0.5, end: 0, duration: 600.ms, curve: Curves.easeOutBack),
    );
  }
}
