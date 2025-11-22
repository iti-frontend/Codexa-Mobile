import 'package:codexa_mobile/Domain/entities/community_entity.dart';
import 'package:codexa_mobile/Domain/failures.dart';
import 'package:codexa_mobile/Domain/repo/community_repo.dart';
import 'package:dartz/dartz.dart';

class GetAllPostsUseCase {
  final CommunityRepo repo;

  GetAllPostsUseCase(this.repo);

  Future<Either<Failures, List<CommunityEntity>>> call() async {
    return await repo.getAllPosts();
  }
}
