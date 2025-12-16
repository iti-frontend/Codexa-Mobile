import 'package:codexa_mobile/Data/Repository/courses_repository.dart';
import 'package:codexa_mobile/Data/api_manager/api_manager.dart';
import 'package:codexa_mobile/Domain/usecases/courses/get_favourites_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/courses/toggle_favourite_usecase.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_cubit/courses_student_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_details.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_cubit/toggle_favourite_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_cubit/toggle_favourite_state.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/favorites_tab/favourite_toggle_notifier.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/favorites_tab/favourites_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/favorites_tab/favourites_state.dart';
import 'package:codexa_mobile/Ui/utils/widgets/custom_home_tape_components.dart';
import 'package:codexa_mobile/core/di/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:codexa_mobile/localization/localization_service.dart';
import 'package:codexa_mobile/generated/l10n.dart' as generated;
import 'package:codexa_mobile/Ui/utils/widgets/course_card_skeleton.dart';

class FavoriteStudentTab extends StatelessWidget {
  const FavoriteStudentTab({super.key});

  @override
  Widget build(BuildContext context) {
    final apiManager = sl<ApiManager>();
    final coursesRepo = CoursesRepoImpl(apiManager);
    final getFavouritesUseCase = GetFavouritesUseCase(coursesRepo);
    final toggleFavouriteUseCase = ToggleFavouriteUseCase(coursesRepo);

    final studentCoursesCubit = context.read<StudentCoursesCubit>();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => FavouritesCubit(
            getFavouritesUseCase,
            studentCoursesCubit,
          )..getFavourites(refresh: true),
        ),
        BlocProvider(
          create: (context) => ToggleFavouriteCubit(toggleFavouriteUseCase),
        ),
      ],
      child: const FavouritesView(),
    );
  }
}

class FavouritesView extends StatefulWidget {
  const FavouritesView({super.key});

  @override
  State<FavouritesView> createState() => _FavouritesViewState();
}

class _FavouritesViewState extends State<FavouritesView> {
  final ScrollController _scrollController = ScrollController();
  StreamSubscription<FavouriteToggleEvent>? _favouriteSubscription;
  late LocalizationService _localizationService;
  late generated.S _translations;

  @override
  void initState() {
    super.initState();
    _initializeLocalization();
    _scrollController.addListener(_onScroll);

    _favouriteSubscription =
        FavouriteToggleNotifier().stream.listen((event) async {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        context.read<FavouritesCubit>().getFavourites(refresh: true);
      }
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
    _scrollController.dispose();
    _favouriteSubscription?.cancel();
    _localizationService.removeListener(_onLocaleChanged);
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<FavouritesCubit>().getFavourites();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRTL = _localizationService.isRTL();

    return BlocListener<ToggleFavouriteCubit, ToggleFavouriteState>(
      listener: (context, state) {
        if (state is ToggleFavouriteSuccess) {
          context.read<FavouritesCubit>().getFavourites(refresh: true);
        } else if (state is ToggleFavouriteError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Directionality(
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment:
                  isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    _translations.favorites,
                    style: TextStyle(
                      color: theme.iconTheme.color,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: isRTL ? TextAlign.right : TextAlign.left,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ClipRect(
                    child: BlocBuilder<FavouritesCubit, FavouritesState>(
                      builder: (context, state) {
                        if (state is FavouritesLoading &&
                            context
                                .read<FavouritesCubit>()
                                .allCourses
                                .isEmpty) {
                          return CoursesListSkeleton(
                            itemCount: 4,
                            showFavouriteButton: true,
                            isRTL: isRTL,
                          );
                        } else if (state is FavouritesEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.favorite_border,
                                  size: 64,
                                  color: theme.dividerTheme.color,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _translations.noFavouritesYet,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: theme.iconTheme.color,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _translations.addCoursesToFavourites,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: theme.dividerTheme.color,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        } else if (state is FavouritesError &&
                            context
                                .read<FavouritesCubit>()
                                .allCourses
                                .isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Colors.red[300],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '${_translations.error}: ${state.message}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: theme.iconTheme.color,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    context
                                        .read<FavouritesCubit>()
                                        .getFavourites(refresh: true);
                                  },
                                  child: Text(_translations.retry),
                                ),
                              ],
                            ),
                          );
                        }

                        final courses =
                            context.read<FavouritesCubit>().allCourses;

                        return RefreshIndicator(
                          onRefresh: () async {
                            await context
                                .read<FavouritesCubit>()
                                .getFavourites(refresh: true);
                          },
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount: courses.length +
                                (state is FavouritesLoading ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index >= courses.length) {
                                return const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              final course = courses[index];
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: 16,
                                  right: isRTL ? 0 : 4,
                                  left: isRTL ? 4 : 0,
                                ),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => CourseDetailsWrapper(
                                            course: course),
                                      ),
                                    );
                                  },
                                  child: DashboardCard(
                                    child: CourseProgressItem(
                                      instructorName: course.instructor?.name ??
                                          _translations.unknownInstructor,
                                      categoryTitle: course.category ??
                                          _translations.noCategory,
                                      hasCategory: true,
                                      title: course.title ??
                                          _translations.untitledCourse,
                                      isFavourite: course.isFavourite ?? true,
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
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
