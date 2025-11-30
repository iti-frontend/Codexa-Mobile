import 'package:codexa_mobile/Data/Repository/courses_repository.dart';
import 'package:codexa_mobile/Data/api_manager/api_manager.dart';
import 'package:codexa_mobile/Domain/usecases/courses/get_favourites_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/courses/toggle_favourite_usecase.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_details.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_cubit/toggle_favourite_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_cubit/toggle_favourite_state.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_cubit/courses_student_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/settings_tab/favourite_toggle_notifier.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/settings_tab/favourites_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/settings_tab/favourites_state.dart';
import 'package:codexa_mobile/Ui/utils/theme/app_colors.dart';
import 'package:codexa_mobile/Ui/utils/widgets/custom_home_tape_components.dart';
import 'package:codexa_mobile/core/di/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

class FavoriteStudentTab extends StatelessWidget {
  const FavoriteStudentTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Manual Instantiation of Dependencies
    final apiManager = sl<ApiManager>();
    final coursesRepo = CoursesRepoImpl(apiManager);
    final getFavouritesUseCase = GetFavouritesUseCase(coursesRepo);
    final toggleFavouriteUseCase = ToggleFavouriteUseCase(coursesRepo);

    // Get StudentCoursesCubit from context
    final studentCoursesCubit = context.read<StudentCoursesCubit>();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => FavouritesCubit(
            getFavouritesUseCase,
            studentCoursesCubit, // Pass StudentCoursesCubit
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

  @override
  void initState() {
    super.initState();
    print('🔵 [SETTINGS_TAB] initState called');
    _scrollController.addListener(_onScroll);

    // Listen to favourite toggle events from other tabs
    _favouriteSubscription =
        FavouriteToggleNotifier().stream.listen((event) async {
          print(
              '🔵 [SETTINGS_TAB] Received toggle event: courseId=${event.courseId}, isFavourite=${event.isFavourite}');
          print('🔵 [SETTINGS_TAB] Waiting 500ms for backend to update...');

          // Wait a bit for backend to update
          await Future.delayed(const Duration(milliseconds: 500));

          if (mounted) {
            print('🟢 [SETTINGS_TAB] Refreshing favourites list...');
            context.read<FavouritesCubit>().getFavourites(refresh: true);
          } else {
            print('🔴 [SETTINGS_TAB] Widget unmounted, skipping refresh');
          }
        });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _favouriteSubscription?.cancel();
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

    return BlocListener<ToggleFavouriteCubit, ToggleFavouriteState>(
      listener: (context, state) {
        if (state is ToggleFavouriteSuccess) {
          // Refresh list when item is unfavourited
          context.read<FavouritesCubit>().getFavourites(refresh: true);
        } else if (state is ToggleFavouriteError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Favourites',
              style: TextStyle(
                color: theme.iconTheme.color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<FavouritesCubit, FavouritesState>(
                builder: (context, state) {
                  if (state is FavouritesLoading &&
                      context.read<FavouritesCubit>().allCourses.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
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
                            'No favourites yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: theme.iconTheme.color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (state is FavouritesError &&
                      context.read<FavouritesCubit>().allCourses.isEmpty) {
                    return Center(
                      child: Text(
                        'Error: ${state.message}',
                        style: TextStyle(color: theme.iconTheme.color),
                      ),
                    );
                  }

                  final courses = context.read<FavouritesCubit>().allCourses;

                  return RefreshIndicator(
                    onRefresh: () async {
                      await context
                          .read<FavouritesCubit>()
                          .getFavourites(refresh: true);
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      // padding: const EdgeInsets.all(16), // Padding handled by parent
                      itemCount:
                      courses.length + (state is FavouritesLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= courses.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final course = courses[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      CourseDetailsWrapper(course: course),
                                ),
                              );
                            },
                            child: DashboardCard(
                              child: CourseProgressItem(
                                instructorName:
                                course.instructor?.name ?? "Unknown",
                                categoryTitle: course.category ?? "General",
                                hasCategory: true,
                                title: course.title ?? "Untitled",
                                isFavourite: course.isFavourite ?? true,
                                showFavouriteButton: true,
                                onFavouriteTap: () {
                                  if (course.id != null) {
                                    context
                                        .read<ToggleFavouriteCubit>()
                                        .toggleFavourite(course.id!);
                                  }
                                },
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
          ],
        ),
      ),
    );
  }
}