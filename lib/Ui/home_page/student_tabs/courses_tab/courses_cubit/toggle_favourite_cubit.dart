import 'package:codexa_mobile/Domain/usecases/courses/toggle_favourite_usecase.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_cubit/toggle_favourite_state.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/favorites_tab/favourite_toggle_notifier.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ToggleFavouriteCubit extends Cubit<ToggleFavouriteState> {
  final ToggleFavouriteUseCase toggleFavouriteUseCase;

  ToggleFavouriteCubit(this.toggleFavouriteUseCase)
      : super(ToggleFavouriteInitial());

  Future<void> toggleFavourite(String courseId) async {
    print('🔵 ToggleFavouriteCubit: Starting toggle for courseId: $courseId');
    emit(ToggleFavouriteLoading());
    final result = await toggleFavouriteUseCase(courseId);
    result.fold(
      (failure) {
        print('🔴 ToggleFavouriteCubit: Error - ${failure.errorMessage}');
        emit(ToggleFavouriteError(courseId, failure.errorMessage));
      },
      (isFavourite) {
        print(
            '🟢 ToggleFavouriteCubit: Success - courseId: $courseId, isFavourite: $isFavourite');
        emit(ToggleFavouriteSuccess(courseId, isFavourite));
        // Notify other tabs about the change
        FavouriteToggleNotifier().notify(courseId, isFavourite);
      },
    );
  }
}
