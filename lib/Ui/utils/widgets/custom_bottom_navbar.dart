import 'package:codexa_mobile/Ui/utils/provider_ui/theme_provider.dart';
import 'package:codexa_mobile/Ui/utils/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  CustomBottomNavBar({
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  final List<Map<String, dynamic>> items = const [
    {"icon": CupertinoIcons.home, "label": "Home"},
    {"icon": CupertinoIcons.book, "label": "Courses"},
    {"icon": CupertinoIcons.person_2, "label": "Community"},
    {"icon": CupertinoIcons.settings, "label": "Settings"},
  ];

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<ThemeProvider>(context);
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: AppColorsDark.cardBackground,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final isActive = widget.selectedIndex == index;
          final color =
              isActive ? AppColorsDark.accentBlue : AppColorsDark.secondaryText;
          return GestureDetector(
            onTap: () => widget.onItemTapped(index),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(items[index]['icon'], color: color),
                const SizedBox(height: 4),
                Text(
                  items[index]['label'],
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
