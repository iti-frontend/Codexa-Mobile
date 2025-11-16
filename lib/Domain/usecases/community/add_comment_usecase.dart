import 'package:codexa_mobile/Domain/entities/community/community_entity.dart';
import 'package:codexa_mobile/Domain/failures.dart';
import 'package:codexa_mobile/Domain/repo/community_repo.dart';
import 'package:dartz/dartz.dart';

class AddCommentUseCase {
  final CommunityRepo repo;

  AddCommentUseCase(this.repo);

  Future<Either<Failures, CommunityEntity>> call(String postId, String text) {
    final body = {"text": text};
    return repo.addComment(postId, body);
  }
}
