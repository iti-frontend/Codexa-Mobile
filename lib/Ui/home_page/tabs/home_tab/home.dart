import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_cubit/my_courses_cubit.dart';

import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/enroll_cubit/enroll_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/enroll_cubit/enroll_states.dart';

class HomeTab extends StatefulWidget {
  final String userToken;

  const HomeTab({super.key, required this.userToken});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  void initState() {
    super.initState();
    context.read<MyCoursesCubit>().fetchMyCourses(widget.userToken);
  }

  void _refreshCourses() {
    context.read<MyCoursesCubit>().fetchMyCourses(widget.userToken);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EnrollCubit, EnrollState>(
      listener: (context, state) {
        if (state is EnrollSuccess) {
          // Refresh my courses when enrollment is successful
          _refreshCourses();
          print(
              'Enrollment successful for course: ${state.courseId}, refreshing My Courses in HomeTab...');
        }
      },
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _refreshCourses(),
          child: SingleChildScrollView(
              // ... your existing HomeTab content
              ),
        ),
      ),
    );
  }
}
