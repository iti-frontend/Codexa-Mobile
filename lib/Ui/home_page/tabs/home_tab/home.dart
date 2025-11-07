import 'package:codexa_mobile/Ui/utils/widgets/custom_home_tape_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:codexa_mobile/Ui/utils/provider_ui/auth_provider.dart';
import 'package:codexa_mobile/Domain/usecases/courses/get_my_courses_usecase.dart';
import 'package:codexa_mobile/Data/Repository/courses_repository.dart';
import 'package:codexa_mobile/Data/api_manager/api_manager.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_cubit/my_courses_cubit.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProvider = Provider.of<UserProvider>(context);
    final token = userProvider.token ?? '';

    return BlocProvider(
      create: (_) => MyCoursesCubit(
        GetMyCoursesUseCase(CoursesRepoImpl(ApiManager())),
      )..fetchMyCourses(token),
      child: BlocBuilder<MyCoursesCubit, MyCoursesState>(
        builder: (context, state) {
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

                // My Courses Section (Dynamic)
                DashboardCard(
                  title: "My Courses",
                  child: _buildMyCoursesSection(context, state, theme),
                ),

                const SizedBox(height: 16),
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

                const SizedBox(height: 16),
                DashboardCard(
                  title: "Skill Development",
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 5,
                    children: const [
                      SkillCard(
                          title: "Python", level: "Advanced", progress: 0.9),
                      SkillCard(
                          title: "SQL", level: "Intermediate", progress: 0.6),
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

                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    StatBox(title: "100K+", subtitle: "Learners"),
                    SizedBox(width: 10),
                    StatBox(title: "500+", subtitle: "Courses"),
                    SizedBox(width: 10),
                    StatBox(title: "10K+", subtitle: "Companies"),
                  ],
                ),

                const SizedBox(height: 16),
                DashboardCard(
                  title: "Recommended for You",
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          "https://images.unsplash.com/photo-1581090700227-1e37b190418e?auto=format&fit=crop&w=400&q=60",
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Advanced Analytics with R",
                              style: TextStyle(
                                color: theme.iconTheme.color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Dive deep into statistical analysis and data modeling.",
                              style: TextStyle(color: theme.iconTheme.color),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {},
                              child: const Text("View Course"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMyCoursesSection(
      BuildContext context, MyCoursesState state, ThemeData theme) {
    if (state is MyCoursesLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is MyCoursesError) {
      return Center(child: Text(state.message));
    } else if (state is MyCoursesLoaded) {
      if (state.courses.isEmpty) {
        return const Text("No enrolled courses yet.");
      }
      return Row(
        children: state.courses.take(2).map((course) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.blueGrey[800],
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    course.title ?? 'Untitled',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: ((course.progress as num?) ?? 0) / 100,
                    color: Colors.tealAccent,
                    backgroundColor: Colors.white10,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${course.progress ?? 0}% complete',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    }
    return const SizedBox();
  }
}
