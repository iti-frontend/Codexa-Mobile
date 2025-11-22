import 'package:codexa_mobile/Domain/failures.dart';
import 'package:dartz/dartz.dart';

import '../entities/community_entity.dart';

abstract class CommunityRepo {
  Future<Either<Failures, List<CommunityEntity>>> getAllPosts();

  Future<Either<Failures, CommunityEntity>> createPost({
    required String content,
    String? image,
    dynamic linkUrl,
    List<dynamic>? attachments,
  });

  Future<Either<Failures, bool>> toggleLike({
    required String postId,
  });

  Future<Either<Failures, CommentsEntity>> addComment({
    required String postId,
    required String text,
  });

  Future<Either<Failures, CommentsEntity>> addReply({
    required String postId,
    required String commentId,
    required String text,
  });

  Future<Either<Failures, bool>> deletePost({
    required String postId,
  });

  Future<Either<Failures, bool>> deleteComment({
    required String postId,
    required String commentId,
  });

  Future<Either<Failures, bool>> deleteReply({
    required String postId,
    required String commentId,
    required String replyId,
  });
}
