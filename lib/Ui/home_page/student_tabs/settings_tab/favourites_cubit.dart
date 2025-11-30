import 'package:codexa_mobile/Domain/entities/courses_entity.dart';
import 'package:codexa_mobile/Domain/usecases/courses/get_favourites_usecase.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/settings_tab/favourites_state.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_cubit/courses_student_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavouritesCubit extends Cubit<FavouritesState> {
  final GetFavouritesUseCase getFavouritesUseCase;
  final StudentCoursesCubit studentCoursesCubit;

  int currentPage = 1;
  final int limit = 10;
  List<CourseEntity> allCourses = [];
  bool isFetching = false;

  FavouritesCubit(this.getFavouritesUseCase, this.studentCoursesCubit)
      : super(FavouritesInitial());

  Future<void> getFavourites({bool refresh = false}) async {
    print(
        '🔵 [FAV_CUBIT] getFavourites called: refresh=$refresh, currentPage=$currentPage');

    if (isFetching) {
      print('🟡 [FAV_CUBIT] Already fetching, skipping...');
      return;
    }

    if (refresh) {
      print('🔵 [FAV_CUBIT] Refresh mode: resetting page and clearing cache');
      currentPage = 1;
      allCourses.clear();
      emit(FavouritesLoading());
    } else if (state is FavouritesLoaded &&
        (state as FavouritesLoaded).hasReachedMax) {
      print('🟡 [FAV_CUBIT] Already reached max, skipping...');
      return;
    }

    isFetching = true;
    print('🔵 [FAV_CUBIT] Fetching page $currentPage...');

    final result = await getFavouritesUseCase(page: currentPage, limit: limit);

    result.fold(
      (failure) {
        print('🔴 [FAV_CUBIT] Error: ${failure.errorMessage}');
        isFetching = false;
        emit(FavouritesError(failure.errorMessage));
      },
      (favouriteCourses) {
        print(
            '🟢 [FAV_CUBIT] Success! Received ${favouriteCourses.length} favourite course IDs');

        // Extract course IDs from favourites
        final favouriteIds =
            favouriteCourses.map((c) => c.id).whereType<String>().toSet();
        print('🔵 [FAV_CUBIT] Favourite IDs: $favouriteIds');

        // Get complete courses from StudentCoursesCubit
        final completeCourses = studentCoursesCubit.allCourses
            .where((course) => favouriteIds.contains(course.id))
            .map((course) => course.copyWith(isFavourite: true))
            .toList();

        print(
            '🟢 [FAV_CUBIT] Found ${completeCourses.length} complete courses from StudentCoursesCubit');

        isFetching = false;
        if (refresh && completeCourses.isEmpty) {
          print('🟡 [FAV_CUBIT] No favourites found, emitting Empty state');
          emit(FavouritesEmpty());
        } else {
          allCourses.addAll(completeCourses);
          currentPage++;
          print(
              '🟢 [FAV_CUBIT] Total courses: ${allCourses.length}, hasReachedMax: ${favouriteCourses.length < limit}');
          emit(FavouritesLoaded(List.from(allCourses),
              hasReachedMax: favouriteCourses.length < limit));
        }
      },
    );
  }
}
