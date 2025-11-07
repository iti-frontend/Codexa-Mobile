import 'package:codexa_mobile/Domain/entities/courses_entity.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_cubit/my_courses_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_details.dart';
import 'package:codexa_mobile/Ui/utils/theme/app_colors.dart';
import 'package:codexa_mobile/Ui/utils/widgets/custom_home_tape_components.dart';
import 'package:codexa_mobile/Ui/utils/widgets/custom_section_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentCoursesTab extends StatefulWidget {
  final String userToken; // add user token to fetch personal courses

  const StudentCoursesTab({super.key, required this.userToken});

  @override
  State<StudentCoursesTab> createState() => _StudentCoursesTabState();
}

class _StudentCoursesTabState extends State<StudentCoursesTab> {
  List<CourseEntity> filteredCourses = [];

  List<String> mainTitles = ['All', 'In Progress', 'Completed'];
  List<String> categoryTitles = ['All'];
  int selectedMainIndex = 0;
  int selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    // Fetch My Courses using MyCoursesCubit
    final cubit = context.read<MyCoursesCubit>();
    cubit.fetchMyCourses(widget.userToken);
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
    return Padding(
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
            const Text(
              'Category',
              style: TextStyle(
                  color: AppColorsDark.primaryText,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
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
                      isSelected ? const Color(0xff1e293b) : Colors.transparent,
                  textColor: isSelected
                      ? const Color(0xff2563eb)
                      : AppColorsDark.secondaryText,
                  context: context,
                  title: categoryTitles[index],
                  isSelected: isSelected,
                  onPressed: () {
                    setState(() => selectedCategoryIndex = index);
                    final cubit = context.read<StudentCoursesCubit>();
                    cubit.filterByCategory(categoryTitles[index]);
                    final List<CourseEntity> courses =
                        cubit.state is StudentCoursesLoaded
                            ? (cubit.state as StudentCoursesLoaded).courses
                            : [];
                    filterCoursesByCategory(courses, categoryTitles[index]);
                  },
                );
              }),
            ),
            const SizedBox(height: 30.0),
            // My Courses Section using MyCoursesCubit
            BlocBuilder<MyCoursesCubit, MyCoursesState>(
              builder: (context, state) {
                if (state is MyCoursesLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is MyCoursesError) {
                  return Center(
                    child: Text(
                      'Error: ${state.message}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                } else if (state is MyCoursesLoaded) {
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
                      double progress = 0.0;
                      if (course.progress != null &&
                          course.progress!.isNotEmpty) {
                        progress = (course.progress!.length /
                                (course.videos?.length ?? 1))
                            .clamp(0.0, 1.0);
                      }

                      return DashboardCard(
                        haveBanner: false,
                        child: InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CourseDetails(course: course),
                            ),
                          ),
                          child: CourseProgressItem(
                            categoryTitle: course.category ?? "No category",
                            hasCategory: true,
                            categoryPercentage: "${(progress * 100).toInt()}%",
                            title: course.title ?? "",
                            progress: progress,
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
