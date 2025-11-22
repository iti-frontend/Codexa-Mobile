import 'package:codexa_mobile/Ui/home_page/instructor_tabs/community_tab/community.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/courses_tab/courses_instructor.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/home_tab_instructor/home_tab_instructor.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/settings_tab/settings.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/community_tab/community.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_student.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/home_tab/home.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/settings_tab/settings.dart';
import 'package:codexa_mobile/Ui/utils/provider_ui/auth_provider.dart';
import 'package:codexa_mobile/Ui/utils/widgets/custom_appbar.dart';
import 'package:codexa_mobile/Ui/utils/widgets/custom_bottom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = "/home";

  @override
  State<HomeScreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  bool _isUserLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.loadUser();
    setState(() {
      _isUserLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isUserLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final role = userProvider.role;
    final theme = Theme.of(context);

    List<Widget> studentTabs = [
      HomeStudentTab(),
      StudentCoursesTab(),
      CommunityStudentTab(),
      SettingsStudentTab(),
    ];

    List<Widget> instructorTabs = [
      HomeTabInstructor(),
      CoursesInstructorTab(),
      CommunityInstructorTab(),
      SettingsInstructorTab(),
    ];

    if (role == "student") {
      return Scaffold(
        appBar: selectedIndex == 3
            ? AppBar(
                automaticallyImplyLeading: false,
                title: Text('Settings',
                    style: TextStyle(color: theme.iconTheme.color)),
                backgroundColor: theme.appBarTheme.backgroundColor,
              )
            : AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: theme.appBarTheme.backgroundColor,
                title: CustomAppbar(profileImage: "assets/images/review-1.jpg"),
              ),
        bottomNavigationBar: CustomBottomNavBar(
          selectedIndex: selectedIndex,
          onItemTapped: (index) => setState(() => selectedIndex = index),
        ),
        body: studentTabs[selectedIndex],
      );
    }

    // Instructor View
    return Scaffold(
      appBar: selectedIndex == 3
          ? AppBar(
              automaticallyImplyLeading: false,
              title: Text('Settings',
                  style: TextStyle(color: theme.iconTheme.color)),
              backgroundColor: theme.appBarTheme.backgroundColor,
            )
          : AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: theme.appBarTheme.backgroundColor,
              title: CustomAppbar(profileImage: "assets/images/review-1.jpg"),
            ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: selectedIndex,
        onItemTapped: (index) => setState(() => selectedIndex = index),
      ),
      body: instructorTabs[selectedIndex],
    );
  }
}
