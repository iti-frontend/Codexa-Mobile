import 'package:codexa_mobile/Domain/failures.dart';
import 'package:codexa_mobile/Domain/repo/community_repo.dart';
import 'package:dartz/dartz.dart';

class DeleteCommentUseCase {
  final CommunityRepo repo;

  DeleteCommentUseCase(this.repo);

  Future<Either<Failures, bool>> call({
    required String postId,
    required String commentId,
  }) {
    return repo.deleteComment(
      postId: postId,
      commentId: commentId,
    );
  }
}
