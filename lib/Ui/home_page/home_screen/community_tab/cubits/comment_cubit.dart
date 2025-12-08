import 'package:codexa_mobile/Domain/entities/community_entity.dart';
import 'package:codexa_mobile/Domain/usecases/community/add_comment_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/community/delete_comment_usecase.dart';
import 'package:codexa_mobile/Ui/home_page/home_screen/community_tab/states/comment_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CommentCubit extends Cubit<CommentState> {
  final AddCommentUseCase addCommentUseCase;
  final DeleteCommentUseCase deleteCommentUseCase;

  CommentCubit({
    required this.addCommentUseCase,
    required this.deleteCommentUseCase,
  }) : super(CommentInitial());

  // Note: currentUser is passed in, no BuildContext here.
  Future<void> addComment(
      String postId, String text, UserEntity currentUser) async {
    emit(CommentLoading());
    final result = await addCommentUseCase(postId: postId, text: text);

    result.fold(
      (failure) => emit(CommentError(failure.errorMessage)),
      (comment) {
        // Inject current user if backend didn't return it
        final safeComment = CommentsEntity(
          id: comment.id,
          text: comment.text ?? text,
          createdAt: comment.createdAt ?? DateTime.now().toIso8601String(),
          userType: comment.userType,
          replies: comment.replies,
          user: comment.user ?? currentUser,
        );

        emit(CommentAdded(postId: postId, newComment: safeComment));
      },
    );
  }

  Future<void> deleteComment(String postId, String commentId) async {
    emit(CommentLoading());
    final result = await deleteCommentUseCase(
      postId: postId,
      commentId: commentId,
    );

    result.fold(
      (failure) => emit(CommentError(failure.errorMessage)),
      (_) => emit(CommentDeleted(commentId)),
    );
  }
}
