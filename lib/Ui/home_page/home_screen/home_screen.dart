import 'package:codexa_mobile/Ui/home_page/tabs/community_tab/community.dart';
import 'package:codexa_mobile/Ui/home_page/tabs/courses_tab/courses.dart';
import 'package:codexa_mobile/Ui/home_page/tabs/home_tab/home.dart';
import 'package:codexa_mobile/Ui/home_page/tabs/home_tab_instructor/home_tab_instructor.dart';
import 'package:codexa_mobile/Ui/home_page/tabs/settings_tab/settings.dart';
import 'package:codexa_mobile/Ui/utils/theme/app_theme_data.dart';
import 'package:codexa_mobile/Ui/utils/widgets/custom_appbar.dart';
import 'package:codexa_mobile/Ui/utils/widgets/custom_bottom_navbar.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = "/home";
  @override
  State<HomeScreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: selectedIndex == 3
          ? AppBar(
              automaticallyImplyLeading: false,
              title: Text(
                'Settings',
                style: TextStyle(color: theme.iconTheme.color),
              ),
              backgroundColor: theme.appBarTheme.backgroundColor,
            )
          : AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: theme.appBarTheme.backgroundColor,
              title: CustomAppbar(profileImage: "assets/images/review-1.jpg"),
            ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: selectedIndex,
        onItemTapped: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
      body: tabs[selectedIndex],
    );
  }

  List<Widget> tabs = [
    HomeTabInstructor(),
    CoursesTab(),
    CommunityTab(),
    SettingsTab(),
  ];
}
