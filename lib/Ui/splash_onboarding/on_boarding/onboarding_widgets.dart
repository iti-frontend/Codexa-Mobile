import 'package:codexa_mobile/Ui/utils/theme/app_colors.dart';
import 'package:flutter/material.dart';

class OnboardingButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final Color textColor;

  const OnboardingButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = AppColorsDark.accentBlue,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
        ),
      ),
    );
  }
}

class PageIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const PageIndicator(
      {super.key, required this.currentPage, required this.totalPages});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: currentPage == index ? 12 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: currentPage == index ? Colors.white : Colors.grey.shade500,
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }
}
