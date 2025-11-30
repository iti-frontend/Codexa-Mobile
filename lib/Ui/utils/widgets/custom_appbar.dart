import 'package:codexa_mobile/Ui/auth/login/login_view/login_screen.dart';
import 'package:codexa_mobile/Ui/home_page/additional_screens/search_screen.dart';
import 'package:codexa_mobile/Ui/home_page/tabs/settings_tab/theme_settings_screen.dart';
import 'package:codexa_mobile/Ui/utils/provider_ui/auth_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_cubit/courses_student_cubit.dart';
import 'dart:io';

import 'package:provider/provider.dart';

class CustomAppbar extends StatelessWidget {
  final String profileImage;
  final VoidCallback? onProfileTap;

  const CustomAppbar(
      {required this.profileImage, this.onProfileTap, super.key});

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
          GestureDetector(
            onTap: () {
              Scaffold.of(context).openDrawer();
            },
            child: Icon(
              CupertinoIcons.cart,
              color: theme.iconTheme.color,
              size: 28,
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.02,
          ),
          // Profile avatar - MAKE THIS CLICKABLE
          GestureDetector(
            onTap: onProfileTap,
            child: CircleAvatar(
              backgroundImage: _getProfileImage(profileImage),
              radius: 20,
              child: profileImage.isEmpty
                  ? Icon(Icons.person, color: theme.iconTheme.color)
                  : null,
            ),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.02),

          // 🔍 Search box
          Expanded(
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: theme.cardColor.withOpacity(0.8),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                onTap: () {
                  final cubit = context.read<StudentCoursesCubit>();
                  showSearch(
                    context: context,
                    delegate: SearchCoursesScreen(cubit),
                  );
                },
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                cursorColor: theme.textTheme.bodyLarge?.color,
                decoration: InputDecoration(
                  hintText: "Search courses...",
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

          // theme icon
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ThemeSettingsScreen()),
              );
            },
            child: Stack(
              children: [
                Icon(
                  Icons.brightness_6, // theme icon
                  color: theme.iconTheme.color,
                  size: 28,
                ),
              ],
            ),
          ),


          SizedBox(width: MediaQuery.of(context).size.width * 0.02),


          // logout icon
          GestureDetector(
            onTap: () {
              final userProvider = Provider.of<UserProvider>(context, listen: false);
              userProvider.logout();
              Navigator.pushReplacementNamed(context, LoginScreen.routeName);
            },
            child: Stack(
              children: [
                Icon(
                  Icons.logout,
                  color: theme.iconTheme.color,
                  size: 28,
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }

  ImageProvider _getProfileImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return NetworkImage(imageUrl);
    } else if (imageUrl.startsWith('assets/')) {
      return AssetImage(imageUrl);
    } else if (imageUrl.startsWith('/')) {
      return FileImage(File(imageUrl));
    } else {
      return AssetImage('assets/$imageUrl');
    }
  }
}
