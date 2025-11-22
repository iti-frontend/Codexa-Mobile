import 'package:codexa_mobile/Domain/entities/community_entity.dart';
import 'package:codexa_mobile/Domain/failures.dart';
import 'package:codexa_mobile/Domain/repo/community_repo.dart';
import 'package:dartz/dartz.dart';

class AddCommentUseCase {
  final CommunityRepo repo;

  AddCommentUseCase(this.repo);

  Future<Either<Failures, CommentsEntity>> call({
    required String postId,
    required String text,
  }) {
    return repo.addComment(
      postId: postId,
      text: text,
    );
  }
}
