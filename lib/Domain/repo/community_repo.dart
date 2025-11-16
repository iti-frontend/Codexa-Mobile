import 'package:codexa_mobile/Domain/entities/community/community_entity.dart';
import 'package:codexa_mobile/Domain/failures.dart';
import 'package:dartz/dartz.dart';

abstract class CommunityRepo {
  Future<Either<Failures, List<CommunityEntity>>> getAllPosts();
  Future<Either<Failures, CommunityEntity>> createPost(
      Map<String, dynamic> body);
  Future<Either<Failures, bool>> toggleLike(String postId);
  Future<Either<Failures, CommunityEntity>> addComment(
      String postId, Map<String, dynamic> body);
  Future<Either<Failures, bool>> deletePost(String postId);


  Future<Either<Failures, CommunityEntity>> addReply(
    String postId,
    String commentId,
    Map<String, dynamic> body,
  );

  Future<Either<Failures, CommunityEntity>> editReply(
    String postId,
    String commentId,
    String replyId,
    Map<String, dynamic> body,
  );

  Future<Either<Failures, bool>> deleteReply(
    String postId,
    String commentId,
    String replyId,
  );
}
