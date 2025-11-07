import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_cubit/courses_student_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_cubit/courses_student_states.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_details.dart';
import 'package:codexa_mobile/Ui/utils/widgets/custom_home_tape_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_cubit/my_courses_cubit.dart';
import 'package:codexa_mobile/Domain/entities/courses_entity.dart';
import 'package:codexa_mobile/Ui/utils/theme/app_colors.dart';

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

  Future<void> _refreshCourses() async {
    await context.read<MyCoursesCubit>().fetchMyCourses(widget.userToken);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.5;
    final listHeight = screenWidth * 0.4;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _refreshCourses,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= Dashboard Title =================
              Text(
                "Dashboard",
                style: TextStyle(
                  color: theme.iconTheme.color,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // ================= My Courses Section =================
              BlocBuilder<MyCoursesCubit, MyCoursesState>(
                builder: (context, state) {
                  if (state is MyCoursesLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else if (state is MyCoursesError) {
                    return DashboardCard(
                      title: "My Courses",
                      child: Center(
                        child: Text(
                          "Error loading courses: ${state.message}",
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ),
                    );
                  } else if (state is MyCoursesLoaded) {
                    final List<CourseEntity> courses = state.courses;
                    if (courses.isEmpty) {
                      return DashboardCard(
                        title: "My Courses",
                        child: const Center(
                          child: Text("No courses enrolled yet."),
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "My Courses",
                          style: TextStyle(
                            color: isDark
                                ? AppColorsDark.primaryText
                                : AppColorsLight.primaryText,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: listHeight,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: courses.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 15),
                            itemBuilder: (context, index) {
                              final course = courses[index];
                              double progress = 0.0;
                              if (course.progress != null &&
                                  course.progress!.isNotEmpty) {
                                progress = (course.progress!.length /
                                        (course.videos?.length ?? 1))
                                    .clamp(0.0, 1.0);
                              }

                              return Container(
                                width: cardWidth,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColorsDark.cardBackground
                                      : AppColorsLight.cardBackground,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    if (!isDark)
                                      BoxShadow(
                                        color: AppColorsLight.shadow,
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // ===== Image =====
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      child: Container(
                                        height: listHeight * 0.6,
                                        width: listHeight * 0.6,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          image: course.videos != null &&
                                                  course.videos!.isNotEmpty
                                              ? DecorationImage(
                                                  image: NetworkImage(course
                                                      .videos!.first
                                                      .toString()),
                                                  fit: BoxFit.cover,
                                                )
                                              : null,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // ===== Title and Progress =====
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            course.title ?? "Untitled Course",
                                            style: TextStyle(
                                              color: isDark
                                                  ? AppColorsDark.primaryText
                                                  : AppColorsLight.primaryText,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),
                                          LinearProgressIndicator(
                                            value: progress,
                                            backgroundColor: isDark
                                                ? AppColorsDark.secondaryText
                                                    .withOpacity(0.3)
                                                : AppColorsLight.divider,
                                            color: isDark
                                                ? AppColorsDark.accentGreen
                                                : AppColorsLight.accentGreen,
                                            minHeight: 5,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "${(progress * 100).toInt()}% complete",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDark
                                                  ? AppColorsDark.secondaryText
                                                  : AppColorsLight
                                                      .secondaryText,
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
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              const SizedBox(height: 24),

              // ================= Community Activity =================
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
