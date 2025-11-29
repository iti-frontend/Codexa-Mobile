import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  final List<Map<String, dynamic>> items = const [
    {
      "icon": CupertinoIcons.home,
      "activeIcon": CupertinoIcons.house_fill,
      "label": "Home",
    },
    {
      "icon": CupertinoIcons.book,
      "activeIcon": CupertinoIcons.book_fill,
      "label": "Courses",
    },
    {
      "icon": CupertinoIcons.person_2,
      "activeIcon": CupertinoIcons.person_2_fill,
      "label": "Community",
    },
    {
      "icon": CupertinoIcons.square_favorites_alt,
      "activeIcon": CupertinoIcons.square_favorites_alt_fill,
      "label": "Favorites",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentBlue = const Color(0xFF4A90E2);

    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color:
            theme.bottomNavigationBarTheme.backgroundColor ?? theme.cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final isActive = widget.selectedIndex == index;
          final iconData =
              isActive ? items[index]['activeIcon'] : items[index]['icon'];

          final color = isActive ? accentBlue : theme.iconTheme.color;

          return GestureDetector(
            onTap: () => widget.onItemTapped(index),
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
