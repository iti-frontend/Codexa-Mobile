import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomAppbar extends StatelessWidget {
  final String profileImage;

  const CustomAppbar({required this.profileImage, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentBlue = const Color(0xFF4A90E2);

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor:
          theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
      elevation: 0,
      title: Row(
        children: [
          // Profile avatar
          CircleAvatar(
            backgroundImage: AssetImage(profileImage),
            radius: 20,
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.02),

          // Search box
          Expanded(
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: theme.cardColor.withOpacity(0.8),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                cursorColor: theme.textTheme.bodyLarge?.color,
                decoration: InputDecoration(
                  hintText: "Search",
                  hintStyle: TextStyle(
                    color: theme.textTheme.bodyLarge?.color?.withOpacity(0.6),
                    fontSize: 16,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: theme.iconTheme.color?.withOpacity(0.8),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),

          SizedBox(width: MediaQuery.of(context).size.width * 0.02),

          // Chat icon with blue dot
          Stack(
            children: [
              Icon(
                CupertinoIcons.chat_bubble,
                color: theme.iconTheme.color,
                size: 28,
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: accentBlue,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(width: MediaQuery.of(context).size.width * 0.02),

          // Notification icon with blue dot
          Stack(
            children: [
              Icon(
                CupertinoIcons.bell,
                color: theme.iconTheme.color,
                size: 28,
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: accentBlue,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
