import 'package:bloc/bloc.dart';

import 'package:codexa_mobile/Domain/usecases/community/toggle_like_usecase.dart';
import '../states/likes_state.dart';

class LikeCubit extends Cubit<LikeState> {
  final ToggleLikeUseCase toggleLikeUseCase;

  LikeCubit(this.toggleLikeUseCase) : super(LikeInitial());

  Future<void> toggleLike(String postId) async {
    emit(LikeLoading());
    final result = await toggleLikeUseCase(postId);

    result.fold(
      (failure) => emit(LikeError(failure.errorMessage)),
      (_) => emit(LikeSuccess()),
    );
  }
}
