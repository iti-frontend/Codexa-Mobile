import 'package:codexa_mobile/Domain/entities/community/community_entity.dart';
import 'package:codexa_mobile/Domain/failures.dart';
import 'package:codexa_mobile/Domain/repo/community_repo.dart';
import 'package:dartz/dartz.dart';

class CreatePostUseCase {
  final CommunityRepo repo;

  CreatePostUseCase(this.repo);

  Future<Either<Failures, CommunityEntity>> call(Map<String, dynamic> body) {
    return repo.createPost(body);
  }
}
