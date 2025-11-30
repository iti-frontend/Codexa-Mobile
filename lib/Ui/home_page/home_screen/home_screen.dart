import 'package:codexa_mobile/Domain/entities/instructor_entity.dart';
import 'package:codexa_mobile/Domain/entities/student_entity.dart';
import 'package:codexa_mobile/Ui/home_page/additional_screens/profile/profile_screen.dart';
import 'package:codexa_mobile/Ui/home_page/cart_feature/screens/cart_screen.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/community_tab/community.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/courses_tab/courses_instructor.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/home_tab_instructor/home_tab_instructor.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/settings_tab/settings.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/community_tab/community.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_student.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/home_tab/home.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/settings_tab/student_favorites.dart';
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

  void _navigateToProfileScreen(BuildContext context) {
    Navigator.pushNamed(context, ProfileScreen.routeName);
  }

  String _getUserProfileImage() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.user is StudentEntity) {
      final student = userProvider.user as StudentEntity;
      return student.profileImage ?? 'assets/images/review-1.jpg';
    } else if (userProvider.user is InstructorEntity) {
      final instructor = userProvider.user as InstructorEntity;
      return instructor.profileImage ?? 'assets/images/review-1.jpg';
    }
    return 'assets/images/review-1.jpg'; // Fallback to dummy image
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
      FavoriteStudentTab(),
    ];

    List<Widget> instructorTabs = [
      HomeTabInstructor(),
      CoursesInstructorTab(),
      CommunityInstructorTab(),
      SettingsInstructorTab(),
    ];
    // Get the real user profile image
    final userProfileImage = _getUserProfileImage();
    if (role?.toLowerCase() == "student") {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: theme.appBarTheme.backgroundColor,
          title: GestureDetector(
            onTap: () => _navigateToProfileScreen(context),
            child: CustomAppbar(profileImage: userProfileImage),
          ),
        ),
        bottomNavigationBar: CustomBottomNavBar(
          selectedIndex: selectedIndex,
          onItemTapped: (index) => setState(() => selectedIndex = index),
        ),
        drawer: const Drawer(
          child: CartScreen(),
        ),
        body: studentTabs[selectedIndex],
      );
    }

    // Instructor View
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: theme.appBarTheme.backgroundColor,
        title: GestureDetector(
          onTap: () => _navigateToProfileScreen(context),
          child: CustomAppbar(profileImage: userProfileImage),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: selectedIndex,
        onItemTapped: (index) => setState(() => selectedIndex = index),
      ),
      drawer: const Drawer(
        child: CartScreen(),
      ),
      body: instructorTabs[selectedIndex],
    );
  }
}
