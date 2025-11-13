// lib/src/ui/courses/student_courses_tab.dart

import 'package:codexa_mobile/Domain/entities/courses_entity.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_cubit/courses_student_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_cubit/courses_student_states.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_cubit/my_courses_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_details.dart';
import 'package:codexa_mobile/Ui/utils/theme/app_colors.dart';
import 'package:codexa_mobile/Ui/utils/widgets/custom_home_tape_components.dart';
import 'package:codexa_mobile/Ui/utils/widgets/custom_section_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/enroll_cubit/enroll_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/enroll_cubit/enroll_states.dart';
import 'package:codexa_mobile/Ui/utils/provider_ui/auth_provider.dart';

class StudentCoursesTab extends StatefulWidget {
  const StudentCoursesTab({super.key});

  @override
  State<StudentCoursesTab> createState() => _StudentCoursesTabState();
}

class _StudentCoursesTabState extends State<StudentCoursesTab> {
  List<String> mainTitles = ['All', 'In Progress', 'Completed'];
  List<String> categoryTitles = [
    'All',
    'Frontend',
    'DevOps',
    'Data Structure',
    'OOP',
    'Machine Learning'
  ];
  int selectedMainIndex = 0;
  int selectedCategoryIndex = 0;

  void _refreshMyCourses() {
    final userProvider = context.read<UserProvider>();
    final token = userProvider.token;
    if (token != null) {
      context.read<MyCoursesCubit>().fetchMyCourses(token);
    }
  }

  @override
  void initState() {
    super.initState();
    final cubit = context.read<StudentCoursesCubit>();
    cubit.fetchCourses();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for enrollment success events
    return BlocListener<EnrollCubit, EnrollState>(
      listener: (context, state) {
        if (state is EnrollSuccess) {
          // Refresh my courses when enrollment is successful
          _refreshMyCourses();
          print(
              'Enrollment successful for course: ${state.courseId}, refreshing My Courses...');
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20.0),

              // Main Sections
              Wrap(
                spacing: 8,
                children: List.generate(mainTitles.length, (index) {
                  final isSelected = selectedMainIndex == index;
                  return customSectionTitle(
                    backgroundColor: isSelected
                        ? AppColorsDark.accentBlue
                        : Colors.transparent,
                    textColor: isSelected
                        ? AppColorsDark.primaryText
                        : AppColorsDark.secondaryText,
                    context: context,
                    title: mainTitles[index],
                    isSelected: isSelected,
                    onPressed: () {
                      setState(() => selectedMainIndex = index);
                    },
                  );
                }),
              ),

              const SizedBox(height: 30.0),

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
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error),
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

                    final theme = Theme.of(context);
                    final isDark = theme.brightness == Brightness.dark;
                    final screenWidth = MediaQuery.of(context).size.width;
                    final cardWidth = screenWidth * 0.5;
                    final listHeight = screenWidth * 0.4;

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

              const SizedBox(height: 30.0),

              const Text(
                'Category',
                style: TextStyle(
                  color: AppColorsDark.primaryText,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20.0),

              // Categories
              Wrap(
                spacing: 4,
                runSpacing: 16,
                children: List.generate(categoryTitles.length, (index) {
                  final isSelected = selectedCategoryIndex == index;
                  return customSectionTitle(
                    backgroundColor:
                        isSelected ? Color(0xff1e293b) : Colors.transparent,
                    textColor: isSelected
                        ? Color(0xff2563eb)
                        : AppColorsDark.secondaryText,
                    context: context,
                    title: categoryTitles[index],
                    isSelected: isSelected,
                    onPressed: () {
                      setState(() => selectedCategoryIndex = index);
                    },
                  );
                }),
              ),

              const SizedBox(height: 30.0),

              const Text(
                'All Courses',
                style: TextStyle(
                  color: AppColorsDark.primaryText,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20.0),

              // Courses List (existing functionality)
              BlocBuilder<StudentCoursesCubit, StudentCoursesState>(
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

                    return Column(
                      children: List.generate(courses.length, (index) {
                        final course = courses[index];
                        return DashboardCard(
                          haveBanner: false,
                          child: InkWell(
                            onTap: () => {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CourseDetails(course: course),
                                ),
                              )
                            },
                            child: CourseProgressItem(
                              categoryTitle: course.category ?? "No category",
                              hasCategory: true,
                              categoryPercentage: "0%",
                              title: course.title ?? "",
                              progress: 0,
                            ),
                          ),
                        );
                      }),
                    );
                  } else {
                    return const SizedBox();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
