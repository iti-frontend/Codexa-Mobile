import 'package:codexa_mobile/Domain/entities/instructor_entity.dart';
import 'package:codexa_mobile/Domain/entities/student_entity.dart';
import 'package:codexa_mobile/Ui/home_page/additional_screens/chatbot_screen.dart';
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
  bool _isChatVisible = true;

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

  void _navigateToChatbot() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChatbotScreen(),
      ),
    );
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

  Widget _buildFloatingChatButton(ThemeData theme) {
    return AnimatedOpacity(
      opacity: _isChatVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _navigateToChatbot,
          backgroundColor: theme.progressIndicatorTheme.color,
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          child: const Icon(Icons.chat, size: 24),
          elevation: 0,
        ),
      ),
    );
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

    final userProfileImage = _getUserProfileImage();

    final scaffold = Scaffold(
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
      body: Stack(
        children: [
          role?.toLowerCase() == "student"
              ? studentTabs[selectedIndex]
              : instructorTabs[selectedIndex],
          // Floating chat button positioned just above bottom navigation bar
          Positioned(
            right: 20,
            bottom: MediaQuery.of(context).padding.bottom ,
            child: _buildFloatingChatButton(theme),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );

    // Add listener to hide/show chat button based on scroll
    if (role?.toLowerCase() == "student") {
      return NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification) {
            if (notification.metrics.pixels > 100 && _isChatVisible) {
              setState(() => _isChatVisible = false);
            } else if (notification.metrics.pixels <= 100 && !_isChatVisible) {
              setState(() => _isChatVisible = true);
            }
          }
          return false;
        },
        child: scaffold,
      );
    }

    return scaffold;
  }
}