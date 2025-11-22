import 'package:codexa_mobile/Domain/entities/community_entity.dart';
import 'package:codexa_mobile/Domain/usecases/community/add_reply_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/community/delete_reply_usecase.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/community_tab/community_tab_states/reply_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReplyCubit extends Cubit<ReplyState> {
  final AddReplyUseCase addReplyUseCase;
  final DeleteReplyUseCase deleteReplyUseCase;

  ReplyCubit({
    required this.addReplyUseCase,
    required this.deleteReplyUseCase,
  }) : super(ReplyInitial());

  Future<void> addReply({
    required String postId,
    required String commentId,
    required String text,
  }) async {
    emit(ReplyLoading());
    final result = await addReplyUseCase(
      postId: postId,
      commentId: commentId,
      text: text,
    );

    result.fold(
      (failure) => emit(ReplyError(failure.errorMessage)),
      (reply) => emit(
          ReplyAdded(postId: postId, commentId: commentId, newReply: reply)),
    );
  }

  Future<void> deleteReply({
    required String postId,
    required String commentId,
    required String replyId,
  }) async {
    emit(ReplyLoading());
    final result = await deleteReplyUseCase(
      postId: postId,
      commentId: commentId,
      replyId: replyId,
    );

    result.fold(
      (failure) => emit(ReplyError(failure.errorMessage)),
      (_) => emit(ReplyAdded(
          postId: postId,
          commentId: commentId,
          newReply:
              CommentsEntity())), // Consider a different state for deletion
    );
  }
}
