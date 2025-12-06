import 'package:codexa_mobile/Domain/entities/instructor_entity.dart';
import 'package:codexa_mobile/Domain/entities/student_entity.dart';
import 'package:codexa_mobile/Ui/home_page/additional_screens/chatbot_screen.dart';
import 'package:codexa_mobile/Ui/home_page/additional_screens/profile/profile_screen.dart';
import 'package:codexa_mobile/Ui/home_page/cart_feature/screens/cart_screen.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/community_tab/community.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/community_tab/community_tab_cubit/posts_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/community_tab/widgets/create_post_dialog.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/courses_tab/courses_instructor.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/home_tab_instructor/home_tab_instructor.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/community_tab/community.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_student.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/home_tab/home.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/settings_tab/student_favorites.dart';
import 'package:codexa_mobile/Ui/utils/provider_ui/auth_provider.dart';
import 'package:codexa_mobile/Ui/utils/widgets/custom_appbar.dart';
import 'package:codexa_mobile/Ui/utils/widgets/custom_bottom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:codexa_mobile/generated/l10n.dart' as generated;
import 'package:codexa_mobile/localization/localization_service.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = "/home";

  @override
  State<HomeScreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  bool _isUserLoaded = false;
  bool _isChatVisible = true;

  // Use the LocalizationService singleton directly
  late LocalizationService _localizationService;
  late generated.S _translations;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _initializeLocalization();
  }

  Future<void> _loadUser() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.loadUser();
    setState(() {
      _isUserLoaded = true;
    });
  }

  Future<void> _initializeLocalization() async {
    try {
      // Get the LocalizationService singleton instance
      _localizationService = LocalizationService();

      // Check if LocalizationService is initialized, if not initialize it
      await _localizationService.init();

      // Load translations with current locale using the generated S class
      _translations = generated.S(_localizationService.locale);

      print('✅ HomeScreen initialized with locale: ${_localizationService.locale}');
      print('📱 RTL: ${_localizationService.isRTL()}');

      // Listen to locale changes
      _localizationService.addListener(_onLocaleChanged);
    } catch (e) {
      print('❌ Error initializing localization: $e');
      // Fallback to English
      _localizationService = LocalizationService();
      _translations = generated.S(const Locale('en'));
    }
  }

  void _onLocaleChanged() {
    if (mounted) {
      print('🔄 Language changed in HomeScreen: ${_localizationService.locale}');
      setState(() {
        _translations = generated.S(_localizationService.locale);
      });
    }
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

  void _showCreatePostDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        // Get the context of the community tab by finding the navigator state
        return BlocProvider.value(
          value: context.read<CommunityPostsCubit>(),
          child: const CreatePostDialog(),
        );
      },
    );
  }

  String _getUserName(UserProvider userProvider) {
    // Use _translations which updates when locale changes
    if (userProvider.user is StudentEntity) {
      final student = userProvider.user as StudentEntity;
      return student.name ?? _translations.student;
    } else if (userProvider.user is InstructorEntity) {
      final instructor = userProvider.user as InstructorEntity;
      return instructor.name ?? _translations.instructor;
    }
    return _translations.profile;
  }

  String _getUserProfileImage(UserProvider userProvider) {
    if (userProvider.user is StudentEntity) {
      final student = userProvider.user as StudentEntity;
      return student.profileImage ?? '';
    } else if (userProvider.user is InstructorEntity) {
      final instructor = userProvider.user as InstructorEntity;
      return instructor.profileImage ?? '';
    }
    return ''; // Fallback to empty string, avatar will show default icon
  }

  Widget _buildFloatingChatButton(ThemeData theme, bool isRTL) {
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

    // Use context.watch to listen for UserProvider changes
    final userProvider = context.watch<UserProvider>();
    final role = userProvider.role;
    final theme = Theme.of(context);
    final isRTL = _localizationService.isRTL();

    print('🏠 Building HomeScreen with locale: ${_localizationService.locale}');

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
    ];

    final userProfileImage = _getUserProfileImage(userProvider);
    final userName = _getUserName(userProvider);

    // Show create post button for instructor AND student on community tab
    VoidCallback? onCreatePostTap;
    if (selectedIndex == 2) {
      // Community tab (index 2 for both roles)
      onCreatePostTap = _showCreatePostDialog;
    }

    // Wrap the entire Scaffold with Directionality for RTL support
    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: _buildScaffold(
        context: context,
        role: role,
        theme: theme,
        studentTabs: studentTabs,
        instructorTabs: instructorTabs,
        userProfileImage: userProfileImage,
        userName: userName,
        onCreatePostTap: onCreatePostTap,
        isRTL: isRTL,
        translations: _translations,
      ),
    );
  }

  Widget _buildScaffold({
    required BuildContext context,
    required String? role,
    required ThemeData theme,
    required List<Widget> studentTabs,
    required List<Widget> instructorTabs,
    required String userProfileImage,
    required String userName,
    required VoidCallback? onCreatePostTap,
    required bool isRTL,
    required generated.S translations,
  }) {
    final scaffold = Scaffold(
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: selectedIndex,
        onItemTapped: (index) => setState(() => selectedIndex = index),
        translations: translations,
      ),
      drawer: const Drawer(
        child: CartScreen(),
      ),
      body: Column(
        children: [
          CustomAppbar(
            profileImage: userProfileImage,
            userName: userName,
            onProfileTap: () => _navigateToProfileScreen(context),
            onCreatePostTap: onCreatePostTap,
            showCart: role?.toLowerCase() == "student",
            translations: translations,
          ),
          Expanded(
            child: Stack(
              children: [
                role?.toLowerCase() == "student"
                    ? studentTabs[selectedIndex]
                    : instructorTabs[selectedIndex],
                // Floating chat button positioned just above bottom navigation bar
                Positioned(
                  // Position based on RTL
                  right: isRTL ? null : 20,
                  left: isRTL ? 20 : null,
                  bottom: MediaQuery.of(context).padding.bottom,
                  child: _buildFloatingChatButton(theme, isRTL),
                ),
              ],
            ),
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

  @override
  void dispose() {
    // Remove listener when widget is disposed
    _localizationService.removeListener(_onLocaleChanged);
    super.dispose();
  }
}