import 'package:flutter/material.dart';

import 'package:codexa_mobile/generated/l10n.dart' as generated;

/// Reusable section title with icon - RTL aware
class SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isRTL;

  const SectionTitle({
    Key? key,
    required this.icon,
    required this.title,
    required this.isRTL,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: isRTL
          ? [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.iconTheme.color,
                ),
              ),
              const SizedBox(width: 8),
              Icon(icon, color: theme.progressIndicatorTheme.color, size: 22),
            ]
          : [
              Icon(icon, color: theme.progressIndicatorTheme.color, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.iconTheme.color,
                ),
              ),
            ],
    );
  }
}

/// Reusable detail item with icon, title, and value - RTL aware
class DetailItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color? valueColor;
  final bool isRTL;

  const DetailItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.value,
    this.valueColor,
    required this.isRTL,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        children: isRTL
            ? [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: theme.iconTheme.color,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 16,
                          color: valueColor ?? theme.iconTheme.color,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(icon, color: theme.progressIndicatorTheme.color, size: 22),
              ]
            : [
                Icon(icon, color: theme.progressIndicatorTheme.color, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: theme.iconTheme.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 16,
                          color: valueColor ?? theme.iconTheme.color,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
      ),
    );
  }
}
