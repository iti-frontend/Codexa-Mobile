import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_cubit/courses_student_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_cubit/courses_student_states.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_details.dart';
import 'package:codexa_mobile/Ui/utils/widgets/custom_home_tape_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeStudentTab extends StatelessWidget {
  const HomeStudentTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Dashboard",
            style: TextStyle(color: theme.iconTheme.color),
          ),
          const SizedBox(height: 16),
          DashboardCard(
            title: "Course Progress",
            child: Column(
              children: const [
                CourseProgressItem(
                  instructorName: "Ahmed",
                  title: "Mastering Data Science",
                  progress: 0.75,
                ),
                SizedBox(height: 12),
                CourseProgressItem(
                  instructorName: "Ahmed",
                  title: "UX/UI Design Principles",
                  progress: 0.4,
                ),
              ],
            ),
          ),
          DashboardCard(
            title: "Community Activity",
            child: Column(
              children: const [
                CommunityItem(
                  name: "Alice J.",
                  action: "posted in #DataScience",
                  message: "“Just finished a great module on ML algorithms!”",
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
          DashboardCard(
            title: "Skill Development",
            child: Wrap(
              spacing: 10,
              runSpacing: 5,
              children: const [
                SkillCard(title: "Python", level: "Advanced", progress: 0.9),
                SkillCard(title: "SQL", level: "Intermediate", progress: 0.6),
                SkillCard(
                    title: "Machine Learning",
                    level: "Beginner",
                    progress: 0.3),
                SkillCard(
                    title: "Data Visualization",
                    level: "Intermediate",
                    progress: 0.5),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              StatBox(
                title: "100K+",
                subtitle: "Learners",
              ),
              SizedBox(width: 10),
              StatBox(
                title: "500+",
                subtitle: "Courses",
              ),
              SizedBox(width: 10),
              StatBox(
                title: "10K+",
                subtitle: "Companies",
              ),
            ],
          ),
          const SizedBox(height: 16),
          DashboardCard(
            title: "Recommended for You",
            child: BlocBuilder<StudentCoursesCubit, StudentCoursesState>(
              builder: (context, state) {
                if (state is StudentCoursesLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is StudentCoursesError) {
                  return Center(
                    child: Text(
                      'Error: ${state.message}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                } else if (state is StudentCoursesLoaded) {
                  final courses = state.courses;

                  if (courses.isEmpty) {
                    return const Center(child: Text('No courses found'));
                  }
                  final randomCourse = (courses..shuffle()).first;
                  return Row(
                    children: [
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              randomCourse.title ?? "Unknown Course",
                              style: TextStyle(
                                color: theme.iconTheme.color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              randomCourse.description ??
                                  "No description available.",
                              style: TextStyle(color: theme.iconTheme.color),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          CourseDetails(course: randomCourse),
                                    ));
                              },
                              child: const Text("View Course"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}
