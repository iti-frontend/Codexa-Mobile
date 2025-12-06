import 'package:codexa_mobile/Domain/failures.dart';
import 'package:codexa_mobile/Domain/repo/community_repo.dart';
import 'package:dartz/dartz.dart';

class DeleteReplyUseCase {
  final CommunityRepo repo;

  DeleteReplyUseCase(this.repo);

  Future<Either<Failures, bool>> call({
    required String postId,
    required String commentId,
    required String replyId,
  }) {
    return repo.deleteReply(
      postId: postId,
      commentId: commentId,
      replyId: replyId,
    );
  }
}
