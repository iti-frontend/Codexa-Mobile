import 'package:bloc/bloc.dart';

import '../../../../../Domain/usecases/community/toggle_like_usecase.dart';
import '../community_tab_states/likes_state.dart';

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
