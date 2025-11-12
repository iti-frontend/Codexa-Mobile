import 'package:codexa_mobile/Ui/home_page/instructor_tabs/courses_tab/create_course.dart';
import 'package:codexa_mobile/Ui/utils/widgets/custom_button.dart';
import 'package:codexa_mobile/Ui/utils/widgets/custom_course_progress_instructor.dart';
import 'package:codexa_mobile/Ui/utils/widgets/custom_home_tape_components.dart';
import 'package:codexa_mobile/Ui/utils/widgets/recent_activity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/courses_tab/upload_courses_cubit/upload_instructors_courses_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/courses_tab/upload_courses_cubit/upload_instructor_courses_state.dart';

class HomeTabInstructor extends StatelessWidget {
  const HomeTabInstructor({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<InstructorCoursesCubit, InstructorCoursesState>(
      builder: (context, state) {
        // Loading state
        if (state is InstructorCoursesLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Error state
        if (state is InstructorCoursesError) {
          return Center(
            child: Text(
              'Error: ${state.message}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        // Loaded state
        if (state is InstructorCoursesLoaded) {
          final courses = state.courses;
          final activeCoursesCount = courses.length;
          final totalStudents = courses.fold<int>(
            0,
            (previousValue, course) =>
                previousValue + (course.enrolledStudents?.length ?? 0),
          );
          final lastTwoCourses = courses.length >= 2
              ? courses.sublist(courses.length - 2)
              : courses;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dashboard Section
                  Text(
                    "Dashboard",
                    style: TextStyle(
                        color: theme.iconTheme.color,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StatBox(
                          title: "$activeCoursesCount",
                          subtitle: "Active Course"),
                      const SizedBox(width: 10),
                      StatBox(
                          title: "$totalStudents", subtitle: "All Students"),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // My Courses Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "My Courses",
                        style: TextStyle(
                            color: theme.iconTheme.color, fontSize: 16),
                      ),
                      Icon(Icons.more_vert, color: theme.iconTheme.color),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ...lastTwoCourses.map((course) => Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: CourseProgressCard(
                          title: course.title ?? '',
                          students: course.enrolledStudents?.length ?? 0,
                          progress: 0.0,
                        ),
                      )),

                  const SizedBox(height: 5),
                  CustomButton(
                    text: "Create new Course",
                    onPressed: () {
                      final cubit = context.read<InstructorCoursesCubit>();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: cubit,
                            child: AddEditCourseScreen(cubit: cubit),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 25),

                  // Recent Activity Section
                  DashboardCard(
                    title: "Recent Activity",
                    child: Column(
                      children: [
                        RecentActivityItem(
                          action: "submitted an assignment in",
                          avatarImg: "assets/images/review-1.jpg",
                          name: "Ali",
                          subject: "Data Science",
                          timeAgo: "15m ago",
                        ),
                        const SizedBox(height: 20),
                        RecentActivityItem(
                          action: "submitted an assignment in",
                          avatarImg: "assets/images/review-1.jpg",
                          name: "Ali",
                          subject: "Data Science",
                          timeAgo: "15m ago",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Community Activity Section
                  DashboardCard(
                    title: "Community Activity",
                    child: Column(
                      children: const [
                        CommunityItem(
                          name: "Alice J.",
                          action: "posted in #DataScience",
                          message:
                              "“Just finished a great module on ML algorithms!”",
                          time: "2h ago",
                        ),
                        SizedBox(height: 10),
                        CommunityItem(
                          name: "Bob W.",
                          action: "commented on your post",
                          message:
                              "“That’s awesome! Which ones did you find most useful?”",
                          time: "4h ago",
                        ),
                        SizedBox(height: 10),
                        CommunityItem(
                          name: "Charlie S.",
                          action: "joined a new group",
                          message:
                              "“New to the AI Ethics group. Looking forward to discussions!”",
                          time: "1d ago",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // fallback
        return const SizedBox.shrink();
      },
    );
  }
}
