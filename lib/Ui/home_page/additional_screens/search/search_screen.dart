import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_details.dart';
import 'package:codexa_mobile/Ui/utils/widgets/custom_home_tape_components.dart';
import 'package:flutter/material.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_cubit/courses_student_cubit.dart';
import 'package:codexa_mobile/localization/localization_service.dart';
import 'package:codexa_mobile/generated/l10n.dart' as generated;

class SearchCoursesScreen extends SearchDelegate {
  final StudentCoursesCubit cubit;
  late LocalizationService _localizationService;
  late generated.S _translations;
  late bool _isRTL;

  SearchCoursesScreen(this.cubit) {
    _initializeLocalization();
  }

  void _initializeLocalization() {
    _localizationService = LocalizationService();
    _translations = generated.S(_localizationService.locale);
    _isRTL = _localizationService.isRTL();
  }

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
      icon: Icon(_isRTL ? Icons.arrow_forward : Icons.arrow_back),
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: 16),
            Text(
              _translations.noCoursesFound,
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).iconTheme.color,
                fontWeight: FontWeight.w500,
              ),
              textAlign: _isRTL ? TextAlign.right : TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _translations.tryDifferentKeywords,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).disabledColor,
              ),
              textAlign: _isRTL ? TextAlign.right : TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Directionality(
      textDirection: _isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredCourses.length,
        itemBuilder: (context, index) {
          final course = filteredCourses[index];
          return Padding(
            padding: EdgeInsets.only(
              bottom: 16,
              right: _isRTL ? 0 : 4,
              left: _isRTL ? 4 : 0,
            ),
            child: DashboardCard(
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
                  instructorName: course.instructor?.name ??
                      _translations.unknownInstructor,
                  categoryTitle: course.category ?? _translations.noCategory,
                  hasCategory: true,
                  title: course.title ?? _translations.untitledCourse,
                  isRTL: _isRTL,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Directionality(
      textDirection: _isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: 16),
            Text(
              _translations.searchForCourses,
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).iconTheme.color,
                fontWeight: FontWeight.w500,
              ),
              textAlign: _isRTL ? TextAlign.right : TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _translations.searchHint,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).disabledColor,
              ),
              textAlign: _isRTL ? TextAlign.right : TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: theme.iconTheme.color,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(
          color: theme.disabledColor,
        ),
      ),
    );
  }

  @override
  String get searchFieldLabel => _translations.searchHint;

  @override
  TextInputType get keyboardType => TextInputType.text;

  @override
  TextInputAction get textInputAction => TextInputAction.search;
}
