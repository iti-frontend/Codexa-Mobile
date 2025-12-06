import 'package:codexa_mobile/Ui/utils/provider_ui/auth_provider.dart';
import 'package:codexa_mobile/Ui/utils/provider_ui/theme_provider.dart';
import 'package:codexa_mobile/Ui/utils/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:codexa_mobile/generated/l10n.dart' as generated;

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final generated.S translations; // Accept S instance

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.translations,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Student tabs (4 items) - using translations directly
    final List<Map<String, dynamic>> studentItems = [
      {
        "icon": CupertinoIcons.home,
        "activeIcon": CupertinoIcons.house_fill,
        "label": translations.home, // Direct access
      },
      {
        "icon": CupertinoIcons.book,
        "activeIcon": CupertinoIcons.book_fill,
        "label": translations.courses, // Direct access
      },
      {
        "icon": CupertinoIcons.person_2,
        "activeIcon": CupertinoIcons.person_2_fill,
        "label": translations.community, // Direct access
      },
      {
        "icon": CupertinoIcons.square_favorites_alt,
        "activeIcon": CupertinoIcons.square_favorites_alt_fill,
        "label": translations.favorites, // Direct access
      },
    ];

    // Instructor tabs (3 items - no Favorites)
    final List<Map<String, dynamic>> instructorItems = [
      {
        "icon": CupertinoIcons.home,
        "activeIcon": CupertinoIcons.house_fill,
        "label": translations.home,
      },
      {
        "icon": CupertinoIcons.book,
        "activeIcon": CupertinoIcons.book_fill,
        "label": translations.courses,
      },
      {
        "icon": CupertinoIcons.person_2,
        "activeIcon": CupertinoIcons.person_2_fill,
        "label": translations.community,
      },
    ];

    // Choose items based on role
    final isInstructor = userProvider.role?.toLowerCase() == 'instructor';
    final items = isInstructor ? instructorItems : studentItems;

    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: theme.bottomNavigationBarTheme.backgroundColor ?? theme.cardColor,
        border: Border(
          top: BorderSide(
            width: 0.1,
            color: themeProvider.currentTheme == ThemeMode.light
                ? AppColorsLight.secondaryText
                : AppColorsDark.secondaryText,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final isActive = selectedIndex == index;
          final iconData =
          isActive ? items[index]['activeIcon'] : items[index]['icon'];

          final color = isActive
              ? themeProvider.currentTheme == ThemeMode.light
              ? AppColorsLight.accentBlue
              : AppColorsDark.accentGreen
              : theme.iconTheme.color;

          return GestureDetector(
            onTap: () => onItemTapped(index),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(iconData, color: color),
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