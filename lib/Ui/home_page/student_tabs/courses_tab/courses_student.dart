import 'package:codexa_mobile/Domain/entities/courses_entity.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_cubit/courses_student_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_cubit/courses_student_states.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_details.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/settings_tab/favourite_toggle_notifier.dart';
import 'package:codexa_mobile/Ui/utils/provider_ui/auth_provider.dart';
import 'package:codexa_mobile/Ui/utils/theme/app_colors.dart';
import 'package:codexa_mobile/Ui/utils/widgets/custom_home_tape_components.dart';
import 'package:codexa_mobile/Ui/utils/widgets/custom_section_title.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_cubit/toggle_favourite_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_cubit/toggle_favourite_state.dart';
import 'package:codexa_mobile/Data/Repository/courses_repository.dart';
import 'package:codexa_mobile/Data/api_manager/api_manager.dart';
import 'package:codexa_mobile/Domain/usecases/courses/toggle_favourite_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/courses/get_favourites_usecase.dart';
import 'package:codexa_mobile/core/di/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:codexa_mobile/Ui/utils/widgets/course_card_skeleton.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:codexa_mobile/localization/localization_service.dart';
import 'package:codexa_mobile/generated/l10n.dart' as generated;

class StudentCoursesTab extends StatefulWidget {
  const StudentCoursesTab({super.key});

  @override
  State<StudentCoursesTab> createState() => _StudentCoursesTabState();
}

class _StudentCoursesTabState extends State<StudentCoursesTab> {
  List<CourseEntity> filteredCourses = [];
  List<String> categoryTitles = ['All'];
  int selectedCategoryIndex = 0;
  StreamSubscription<FavouriteToggleEvent>? _favouriteSubscription;
  late LocalizationService _localizationService;
  late generated.S _translations;

  @override
  void initState() {
    super.initState();
    print('🔵 [COURSES_TAB] initState called');
    _initializeLocalization();

    final cubit = context.read<StudentCoursesCubit>();

    // Always fetch latest courses to ensure data freshness (e.g. after course deletion)
    print('🔵 [COURSES_TAB] Fetching latest courses from API...');
    final apiManager = sl<ApiManager>();
    final coursesRepo = CoursesRepoImpl(apiManager);
    final getFavouritesUseCase = GetFavouritesUseCase(coursesRepo);

    cubit.fetchCoursesWithFavourites(getFavouritesUseCase.call);

    // Listen to favourite toggle events from other tabs
    _favouriteSubscription = FavouriteToggleNotifier().stream.listen((event) {
      print(
          '🔵 [COURSES_TAB] Received toggle event: courseId=${event.courseId}, isFavourite=${event.isFavourite}');
      context.read<StudentCoursesCubit>().updateCourseFavourite(
            event.courseId,
            event.isFavourite,
          );
    });
  }

  void _initializeLocalization() {
    _localizationService = LocalizationService();
    _translations = generated.S(_localizationService.locale);
    _localizationService.addListener(_onLocaleChanged);
  }

  void _onLocaleChanged() {
    if (mounted) {
      setState(() {
        _translations = generated.S(_localizationService.locale);
      });
    }
  }

  @override
  void dispose() {
    _favouriteSubscription?.cancel();
    _localizationService.removeListener(_onLocaleChanged);
    super.dispose();
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
    final isRTL = _localizationService.isRTL();

    // Manual Instantiation of Dependencies for ToggleFavouriteCubit
    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: BlocProvider(
        create: (context) => ToggleFavouriteCubit(
          ToggleFavouriteUseCase(
            CoursesRepoImpl(sl<ApiManager>()),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
                  isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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
                        return course.enrolledStudents?.contains(userId) ??
                            false;
                      }).toList();
                      if (enrolledCourses.isEmpty) {
                        return Column(
                          crossAxisAlignment: isRTL
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              child: Text(
                                _translations.myCourses,
                                style: TextStyle(
                                  color: theme.iconTheme.color,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign:
                                    isRTL ? TextAlign.right : TextAlign.left,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: theme.iconTheme.color,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  _translations.noCoursesEnrolledYet,
                                  style: TextStyle(
                                    color: theme.dividerTheme.color,
                                    fontSize: 14,
                                  ),
                                  textAlign: isRTL
                                      ? TextAlign.right
                                      : TextAlign.center,
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                          ],
                        );
                      }
                      return Column(
                        crossAxisAlignment: isRTL
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            child: Text(
                              _translations.myCourses,
                              style: TextStyle(
                                color: theme.iconTheme.color,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign:
                                  isRTL ? TextAlign.right : TextAlign.left,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 180,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              reverse: isRTL,
                              itemCount: enrolledCourses.length,
                              itemBuilder: (context, index) {
                                final course = enrolledCourses[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => CourseDetailsWrapper(
                                            course: course),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 280,
                                    margin: EdgeInsets.only(
                                      right: isRTL ? 0 : 16,
                                      left: isRTL ? 16 : 0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.cardTheme.color,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.04),
                                          blurRadius: 10,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: isRTL
                                            ? CrossAxisAlignment.end
                                            : CrossAxisAlignment.start,
                                        children: [
                                          // Category badge
                                          if (course.category != null)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: theme
                                                    .progressIndicatorTheme
                                                    .color,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                course.category!,
                                                style: TextStyle(
                                                  color: theme.iconTheme.color,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                textAlign: isRTL
                                                    ? TextAlign.right
                                                    : TextAlign.left,
                                              ),
                                            ),
                                          const SizedBox(height: 12),
                                          // Course title
                                          Text(
                                            course.title ??
                                                _translations.untitledCourse,
                                            style: TextStyle(
                                              color: theme.iconTheme.color,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: isRTL
                                                ? TextAlign.right
                                                : TextAlign.left,
                                          ),
                                          const SizedBox(height: 8),
                                          // Instructor name
                                          Row(
                                            children: isRTL
                                                ? [
                                                    Expanded(
                                                      child: Text(
                                                        course.instructor
                                                                ?.name ??
                                                            _translations
                                                                .unknownInstructor,
                                                        style: TextStyle(
                                                          color: theme
                                                              .dividerTheme
                                                              .color,
                                                          fontSize: 14,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        textAlign:
                                                            TextAlign.right,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Icon(
                                                      Icons.person_outline,
                                                      size: 16,
                                                      color: theme
                                                          .dividerTheme.color,
                                                    ),
                                                  ]
                                                : [
                                                    Icon(
                                                      Icons.person_outline,
                                                      size: 16,
                                                      color: theme
                                                          .dividerTheme.color,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Expanded(
                                                      child: Text(
                                                        course.instructor
                                                                ?.name ??
                                                            _translations
                                                                .unknownInstructor,
                                                        style: TextStyle(
                                                          color: theme
                                                              .dividerTheme
                                                              .color,
                                                          fontSize: 14,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        textAlign:
                                                            TextAlign.left,
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
                                              color: theme
                                                  .progressIndicatorTheme.color,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Center(
                                              child: Text(
                                                _translations.continueLearning,
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
                Container(
                  width: double.infinity,
                  child: Text(
                    _translations.category,
                    style: TextStyle(
                        color: theme.iconTheme.color,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                    textAlign: isRTL ? TextAlign.right : TextAlign.left,
                  ),
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
                  isRTL: isRTL,
                ),
                const SizedBox(height: 30.0),
                BlocBuilder<StudentCoursesCubit, StudentCoursesState>(
                  builder: (context, state) {
                    if (state is StudentCoursesLoading) {
                      return CoursesListSkeleton(
                        itemCount: 4,
                        showFavouriteButton: true,
                        isRTL: isRTL,
                      );
                    } else if (state is StudentCoursesError) {
                      return Center(
                        child: Text(
                          '${_translations.error}: ${state.message}',
                          style: TextStyle(color: Colors.red),
                          textAlign: isRTL ? TextAlign.right : TextAlign.center,
                        ),
                      );
                    } else if (state is StudentCoursesLoaded) {
                      final courses = state.courses;

                      if (courses.isEmpty) {
                        return Center(
                          child: Text(
                            _translations.noCoursesFound,
                            textAlign:
                                isRTL ? TextAlign.right : TextAlign.center,
                          ),
                        );
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
                          return BlocListener<ToggleFavouriteCubit,
                              ToggleFavouriteState>(
                            listener: (context, state) {
                              print(
                                  '🔵 BlocListener received state: ${state.runtimeType}');
                              if (state is ToggleFavouriteSuccess &&
                                  state.courseId == course.id) {
                                print(
                                    '🟢 BlocListener: Success for course ${course.id}, isFavourite: ${state.isFavourite}');
                                // Update global state in StudentCoursesCubit
                                context
                                    .read<StudentCoursesCubit>()
                                    .updateCourseFavourite(
                                        state.courseId, state.isFavourite);
                              } else if (state is ToggleFavouriteError &&
                                  state.courseId == course.id) {
                                print(
                                    '🔴 BlocListener: Error - ${state.message}');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(state.message)),
                                );
                              }
                            },
                            child: InkWell(
                              onTap: () => {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        CourseDetailsWrapper(course: course),
                                  ),
                                )
                              },
                              child: DashboardCard(
                                child: CourseProgressItem(
                                  instructorName: course.instructor!.name ?? "",
                                  categoryTitle: course.category ??
                                      _translations.noCategory,
                                  hasCategory: true,
                                  title: course.title ?? _translations.untitled,
                                  isFavourite: course.isFavourite ?? false,
                                  showFavouriteButton: true,
                                  onFavouriteTap: () {
                                    print(
                                        '🔵 Favourite icon tapped for course: ${course.id}, current isFavourite: ${course.isFavourite}');
                                    if (course.id != null) {
                                      context
                                          .read<ToggleFavouriteCubit>()
                                          .toggleFavourite(course.id!);
                                    } else {
                                      print('🔴 Course ID is null!');
                                    }
                                  },
                                  isRTL: isRTL,
                                ),
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
      ),
    );
  }
}
