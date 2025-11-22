import 'package:codexa_mobile/Domain/entities/community_entity.dart';
import 'package:codexa_mobile/Domain/failures.dart';
import 'package:codexa_mobile/Domain/repo/community_repo.dart';
import 'package:dartz/dartz.dart';

class AddReplyUseCase {
  final CommunityRepo repo;

  AddReplyUseCase(this.repo);

  Future<Either<Failures, CommentsEntity>> call({
    required String postId,
    required String commentId,
    required String text,
  }) {
    return repo.addReply(
      postId: postId,
      commentId: commentId,
      text: text,
    );
  }
}
