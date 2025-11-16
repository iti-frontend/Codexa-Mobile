import 'package:codexa_mobile/Domain/failures.dart';
import 'package:codexa_mobile/Domain/repo/community_repo.dart';
import 'package:dartz/dartz.dart';

class ToggleLikeUseCase {
  final CommunityRepo repo;

  ToggleLikeUseCase(this.repo);

  Future<Either<Failures, bool>> call(String postId) {
    return repo.toggleLike(postId);
  }
}
