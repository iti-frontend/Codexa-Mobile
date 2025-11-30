import 'package:codexa_mobile/Domain/entities/courses_entity.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_cubit/courses_student_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_cubit/courses_student_states.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_details.dart';
import 'package:codexa_mobile/Ui/utils/provider_ui/auth_provider.dart';
import 'package:codexa_mobile/Ui/utils/theme/app_colors.dart';
import 'package:codexa_mobile/Ui/utils/widgets/custom_home_tape_components.dart';
import 'package:codexa_mobile/Ui/utils/widgets/custom_section_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class StudentCoursesTab extends StatefulWidget {
  const StudentCoursesTab({super.key});

  @override
  State<StudentCoursesTab> createState() => _StudentCoursesTabState();
}

class _StudentCoursesTabState extends State<StudentCoursesTab> {
  List<CourseEntity> filteredCourses = [];

  List<String> categoryTitles = ['All'];
  int selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<StudentCoursesCubit>();
    cubit.fetchCourses();
  }

  String? _getUserId(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    if (user == null) return null;
    if (user is Map) return user['_id']?.toString() ?? user['id']?.toString();
    try {
      return (user as dynamic).id?.toString();
    } catch (_) {
      return null;
    }
  }

  void updateCategories(List<CourseEntity> courses) {
    final categories = courses
        .map((c) => c.category ?? "")
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
    categories.insert(0, 'All');

    setState(() {
      categoryTitles = categories;
      if (selectedCategoryIndex >= categoryTitles.length) {
        selectedCategoryIndex = 0;
      }
      filteredCourses = List.from(courses);
    });
  }

  void filterCoursesByCategory(List<CourseEntity> courses, String category) {
    setState(() {
      if (category == 'All') {
        filteredCourses = List.from(courses);
      } else {
        filteredCourses = courses.where((c) => c.category == category).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20.0),
            BlocBuilder<StudentCoursesCubit, StudentCoursesState>(
              builder: (context, state) {
                if (state is StudentCoursesLoaded) {
                  final userId = _getUserId(context);
                  if (userId == null) {
                    return const SizedBox();
                  }
                  final enrolledCourses = state.courses.where((course) {
                    return course.enrolledStudents?.contains(userId) ?? false;
                  }).toList();
                  if (enrolledCourses.isEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text(
                          'My Courses',
                          style: TextStyle(
                            color: theme.iconTheme.color,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: theme.iconTheme.color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child:  Center(
                            child: Text(
                              'You haven\'t enrolled in any courses yet',
                              style: TextStyle(
                                color: theme.dividerTheme.color,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Text(
                        'My Courses',
                        style: TextStyle(
                          color: theme.iconTheme.color,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 180,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: enrolledCourses.length,
                          itemBuilder: (context, index) {
                            final course = enrolledCourses[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        CourseDetails(course: course),
                                  ),
                                );
                              },
                              child: Container(
                                width: 280,
                                margin: const EdgeInsets.only(right: 16),
                                decoration: BoxDecoration(
                                  color: theme.cardTheme.color,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 10,
                                        offset: const Offset(0, 6)
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Category badge
                                      if (course.category != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: theme.progressIndicatorTheme.color,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            course.category!,
                                            style:  TextStyle(
                                              color: theme.iconTheme.color,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      const SizedBox(height: 12),
                                      // Course title
                                      Text(
                                        course.title ?? 'Untitled Course',
                                        style:  TextStyle(
                                          color:
                                          theme.iconTheme.color,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      // Instructor name
                                      Row(
                                        children: [
                                           Icon(
                                            Icons.person_outline,
                                            size: 16,
                                            color: theme.dividerTheme.color,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              course.instructor?.name ??
                                                  'Unknown Instructor',
                                              style:  TextStyle(
                                                color: theme.dividerTheme.color,
                                                fontSize: 14,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      // View course button
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        decoration: BoxDecoration(
                                          color: theme.progressIndicatorTheme.color,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child:  Center(
                                          child: Text(
                                            'Continue Learning',
                                            style: TextStyle(
                                              color: theme.iconTheme.color,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  );
                }
                return const SizedBox();
              },
            ),
             Text(
              'Category',
              style: TextStyle(
                  color: theme.iconTheme.color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20.0),
            customSectionTitle(
              context: context,
              title: categoryTitles[selectedCategoryIndex],
              onPressed: () {},
              backgroundColor: theme.cardTheme.color ?? Colors.white,
              textColor: theme.iconTheme.color ?? Colors.black,
              dropdownItems: categoryTitles,
              selectedValue: categoryTitles[selectedCategoryIndex],
              onChanged: (value) {
                if (value == null) return;
                final index = categoryTitles.indexOf(value);
                setState(() => selectedCategoryIndex = index);
                final cubit = context.read<StudentCoursesCubit>();
                cubit.filterByCategory(value);
                final List<CourseEntity> courses =
                    cubit.state is StudentCoursesLoaded
                        ? (cubit.state as StudentCoursesLoaded).courses
                        : [];
                filterCoursesByCategory(courses, value);
              },
            ),
            const SizedBox(height: 30.0),
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
                  if (categoryTitles.length == 1) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      updateCategories(
                          context.read<StudentCoursesCubit>().allCourses);
                    });
                  }
                  return Column(
                    children: List.generate(courses.length, (index) {
                      final course = courses[index];
                      return InkWell(
                        onTap: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CourseDetails(course: course),
                            ),
                          )
                        },
                        child: DashboardCard(
                          child: CourseProgressItem(
                            instructorName: course.instructor!.name ?? "",
                            categoryTitle: course.category ?? "No category",
                            hasCategory: true,
                            title: course.title ?? "",
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
    );
  }
}
