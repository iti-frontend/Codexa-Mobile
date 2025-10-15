import 'package:codexa_mobile/Ui/utils/theme/app_colors.dart';
import 'package:flutter/material.dart';

class SettingsGridItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const SettingsGridItem({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: AppColorsDark.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: AppColorsDark.primaryBackground,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColorsDark.accentBlue, size: 28),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColorsDark.primaryText),
            )
          ],
        ),
      ),
    );
  }
}
