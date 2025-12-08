import 'package:codexa_mobile/Domain/entities/courses_entity.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_cubit/courses_student_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_cubit/courses_student_states.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_details.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/favorites_tab/favourite_toggle_notifier.dart';
import 'package:codexa_mobile/Ui/utils/provider_ui/auth_provider.dart';
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

// Widget imports
import 'widgets/enrolled_courses_section.dart';

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
    _initializeLocalization();

    final cubit = context.read<StudentCoursesCubit>();
    final apiManager = sl<ApiManager>();
    final coursesRepo = CoursesRepoImpl(apiManager);
    final getFavouritesUseCase = GetFavouritesUseCase(coursesRepo);

    cubit.fetchCoursesWithFavourites(getFavouritesUseCase.call);

    // Listen to favourite toggle events from other tabs
    _favouriteSubscription = FavouriteToggleNotifier().stream.listen((event) {
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

                // Enrolled Courses Section
                _buildEnrolledCoursesSection(theme, isRTL),

                // Category Title
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

                // Category Filter
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

                // Courses List
                _buildCoursesList(theme, isRTL),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnrolledCoursesSection(ThemeData theme, bool isRTL) {
    return BlocBuilder<StudentCoursesCubit, StudentCoursesState>(
      builder: (context, state) {
        if (state is StudentCoursesLoaded) {
          final userId = _getUserId(context);
          if (userId == null) return const SizedBox();

          final enrolledCourses = state.courses.where((course) {
            return course.enrolledStudents?.contains(userId) ?? false;
          }).toList();

          return EnrolledCoursesSection(
            enrolledCourses: enrolledCourses,
            isRTL: isRTL,
            translations: _translations,
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildCoursesList(ThemeData theme, bool isRTL) {
    return BlocBuilder<StudentCoursesCubit, StudentCoursesState>(
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
                textAlign: isRTL ? TextAlign.right : TextAlign.center,
              ),
            );
          }

          if (categoryTitles.length == 1) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              updateCategories(context.read<StudentCoursesCubit>().allCourses);
            });
          }

          return Column(
            children: List.generate(courses.length, (index) {
              final course = courses[index];
              return _buildCourseCard(context, course, isRTL);
            }),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildCourseCard(
      BuildContext context, CourseEntity course, bool isRTL) {
    return BlocListener<ToggleFavouriteCubit, ToggleFavouriteState>(
      listener: (context, state) {
        if (state is ToggleFavouriteSuccess && state.courseId == course.id) {
          context
              .read<StudentCoursesCubit>()
              .updateCourseFavourite(state.courseId, state.isFavourite);
        } else if (state is ToggleFavouriteError &&
            state.courseId == course.id) {
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
              builder: (_) => CourseDetailsWrapper(course: course),
            ),
          )
        },
        child: DashboardCard(
          child: CourseProgressItem(
            instructorName: course.instructor!.name ?? "",
            categoryTitle: course.category ?? _translations.noCategory,
            hasCategory: true,
            title: course.title ?? _translations.untitled,
            isFavourite: course.isFavourite ?? false,
            showFavouriteButton: true,
            onFavouriteTap: () {
              if (course.id != null) {
                context
                    .read<ToggleFavouriteCubit>()
                    .toggleFavourite(course.id!);
              }
            },
            isRTL: isRTL,
          ),
        ),
      ),
    );
  }
}
