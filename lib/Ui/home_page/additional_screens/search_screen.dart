import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_details.dart';
import 'package:codexa_mobile/Ui/utils/widgets/custom_home_tape_components.dart';
import 'package:flutter/material.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_cubit/courses_student_cubit.dart';

class SearchCoursesScreen extends SearchDelegate {
  final StudentCoursesCubit cubit;

  SearchCoursesScreen(this.cubit);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final allCourses = cubit.allCourses;

    final normalizedQuery = query.trim().toLowerCase();

    final filteredCourses = allCourses.where((course) {
      final title = (course.title ?? '').trim().toLowerCase();
      final desc = (course.description ?? '').trim().toLowerCase();
      final category = (course.category ?? '').trim().toLowerCase();

      return title.contains(normalizedQuery) ||
          desc.contains(normalizedQuery) ||
          category.contains(normalizedQuery);
    }).toList();

    if (filteredCourses.isEmpty) {
      return const Center(child: Text("No courses found"));
    }

    return ListView.builder(
      itemCount: filteredCourses.length,
      itemBuilder: (context, index) {
        final course = filteredCourses[index];
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
              instructorName: course.instructor!.name ?? "",
              categoryTitle: course.category ?? "No category",
              hasCategory: true,
              
              title: course.title ?? "",
              
            ),
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const Center(
      child: Text('Search for a course...'),
    );
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context);
  }
}
