import 'package:codexa_mobile/Data/Repository/courses_repository.dart';
import 'package:codexa_mobile/Domain/usecases/courses/get_courses_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/courses/update_course_videos_usecase.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/community_tab/community.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/courses_tab/courses_instructor.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/home_tab_instructor/home_tab_instructor.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/settings_tab/settings.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/community_tab/community.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_cubit/courses_student_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_student.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/home_tab/home.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/settings_tab/settings.dart';
import 'package:codexa_mobile/Ui/utils/provider_ui/auth_provider.dart';
import 'package:codexa_mobile/Ui/utils/widgets/custom_appbar.dart';
import 'package:codexa_mobile/Ui/utils/widgets/custom_bottom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:codexa_mobile/Data/api_manager/api_manager.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/courses_tab/upload_courses_cubit/upload_instructors_courses_cubit.dart';
import 'package:codexa_mobile/Domain/usecases/courses/add_course_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/courses/update_course_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/courses/delete_course_usecase.dart';
import 'package:codexa_mobile/Data/Repository/add_course_repo_impl.dart';
import 'package:codexa_mobile/Ui/home_page/additional_screens/profile/profile_screen.dart';
import 'package:codexa_mobile/Domain/entities/student_entity.dart';
import 'package:codexa_mobile/Domain/entities/instructor_entity.dart';

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

    final apiManager = ApiManager(token: userProvider.token);
    final coursesRepo = CoursesRepoImpl(apiManager);
    final courseInstructorRepo =
        CourseInstructorRepoImpl(apiManager: apiManager);
    final getCoursesUseCase = GetCoursesUseCase(coursesRepo);

    List<Widget> studentTabs = [
      HomeStudentTab(),
      StudentCoursesTab(),
      // CommunityStudentTab(),
      SettingsStudentTab(),
    ];

    List<Widget> instructorTabs() {
      return [
        BlocProvider(
          create: (_) => InstructorCoursesCubit(
              getCoursesUseCase: getCoursesUseCase,
              addCourseUseCase: AddCourseUseCase(courseInstructorRepo),
              updateCourseUseCase: UpdateCourseUseCase(courseInstructorRepo),
              deleteCourseUseCase: DeleteCourseUseCase(courseInstructorRepo),
              uploadVideosUseCase: UploadVideosUseCase(courseInstructorRepo))
            ..fetchCourses(),
          child: const HomeTabInstructor(),
        ),
        BlocProvider(
          create: (_) => InstructorCoursesCubit(
              getCoursesUseCase: getCoursesUseCase,
              addCourseUseCase: AddCourseUseCase(courseInstructorRepo),
              updateCourseUseCase: UpdateCourseUseCase(courseInstructorRepo),
              deleteCourseUseCase: DeleteCourseUseCase(courseInstructorRepo),
              uploadVideosUseCase: UploadVideosUseCase(courseInstructorRepo))
            ..fetchCourses(),
          child: const CoursesInstructorTab(),
        ),
        const CommunityInstructorTab(),
        const SettingsInstructorTab(),
      ];
    }

    final currentTabs = role == "student" ? studentTabs : instructorTabs();
    final safeIndex = selectedIndex.clamp(0, currentTabs.length - 1);

    // Get the real user profile image
    final userProfileImage = _getUserProfileImage();

    if (role == "student") {
      return BlocProvider(
        create: (_) => StudentCoursesCubit(getCoursesUseCase)..fetchCourses(),
        child: Scaffold(
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
                  title: GestureDetector(
                    onTap: () => _navigateToProfileScreen(context),
                    child: CustomAppbar(profileImage: userProfileImage),
                  ),
                ),
          bottomNavigationBar: CustomBottomNavBar(
            selectedIndex: safeIndex,
            onItemTapped: (index) => setState(
                () => selectedIndex = index.clamp(0, currentTabs.length - 1)),
          ),
          body: currentTabs[safeIndex],
        ),
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
              title: GestureDetector(
                onTap: () => _navigateToProfileScreen(context),
                child: CustomAppbar(profileImage: userProfileImage),
              ),
            ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: safeIndex,
        onItemTapped: (index) => setState(
            () => selectedIndex = index.clamp(0, currentTabs.length - 1)),
      ),
      body: currentTabs[safeIndex],
    );
  }
}
