import 'package:codexa_mobile/Domain/failures.dart';
import 'package:codexa_mobile/Domain/repo/community_repo.dart';
import 'package:dartz/dartz.dart';

class DeleteReplyUseCase {
  final CommunityRepo repo;

  DeleteReplyUseCase(this.repo);

  Future<Either<Failures, bool>> call(
    String postId,
    String commentId,
    String replyId,
  ) {
    return repo.deleteReply(postId, commentId, replyId);
  }
}

