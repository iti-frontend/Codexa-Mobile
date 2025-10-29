import 'package:codexa_mobile/Data/Repository/courses_repository.dart';
import 'package:codexa_mobile/Data/api_manager/api_manager.dart';
import 'package:codexa_mobile/Domain/usecases/courses/get_courses_usecase.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_cubit/courses_student_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_student.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/home_tab/home.dart';
import 'package:codexa_mobile/Ui/home_page/tabs/community_tab/community.dart';
import 'package:codexa_mobile/Ui/home_page/tabs/courses_tab/courses.dart';
import 'package:codexa_mobile/Ui/home_page/tabs/home_tab_instructor/home_tab_instructor.dart';
import 'package:codexa_mobile/Ui/home_page/tabs/settings_tab/settings.dart';
import 'package:codexa_mobile/Ui/utils/provider_ui/auth_provider.dart';
import 'package:codexa_mobile/Ui/utils/widgets/custom_appbar.dart';
import 'package:codexa_mobile/Ui/utils/widgets/custom_bottom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = "/home";
  @override
  State<HomeScreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final role = userProvider.role;
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
      body: role == "student"
          ? BlocProvider(
              create: (_) => StudentCoursesCubit(
                GetCoursesUseCase(CoursesRepoImpl(ApiManager())),
              )..fetchCourses(),
              child: studentTabs[selectedIndex],
            )
          : instructorTabs[selectedIndex],
    );
  }

  List<Widget> studentTabs = [
    HomeTab(),
    StudentCoursesTab(),
    CommunityTab(),
    SettingsTab(),
  ];
  List<Widget> instructorTabs = [
    HomeTabInstructor(),
    CoursesTab(),
    CommunityTab(),
    SettingsTab(),
  ];
}
