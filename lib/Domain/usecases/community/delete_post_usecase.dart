import 'package:codexa_mobile/Domain/failures.dart';
import 'package:codexa_mobile/Domain/repo/community_repo.dart';
import 'package:dartz/dartz.dart';

class DeletePostUseCase {
  final CommunityRepo repo;

  DeletePostUseCase(this.repo);

  Future<Either<Failures, bool>> call(String postId) {
    return repo.deletePost(postId: postId);
  }
}
