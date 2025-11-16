import 'package:codexa_mobile/Data/api_manager/api_manager.dart';
import 'package:codexa_mobile/Data/constants/api_constants.dart';
import 'package:codexa_mobile/Data/models/community/community_dto.dart';
import 'package:codexa_mobile/Domain/entities/community/community_entity.dart';
import 'package:codexa_mobile/Domain/failures.dart';
import 'package:codexa_mobile/Domain/repo/community_repo.dart';
import 'package:dartz/dartz.dart';

class CommunityRepoImpl implements CommunityRepo {
  final ApiManager api;

  CommunityRepoImpl(this.api);

// !==============================================get Posts=============================
  @override
  Future<Either<Failures, List<CommunityEntity>>> getAllPosts() async {
    try {
      final response = await api.getData(ApiConstants.communityGetAll);

      if (response.statusCode == 200) {
        final List data = response.data as List<dynamic>;
        final posts = data.map((json) => CommunityDto.fromJson(json)).toList();
        return Right(posts);
      }

      return Left(Failures(errorMessage: 'Failed to load posts'));
    } catch (e) {
      return Left(Failures(errorMessage: e.toString()));
    }
  }

// !=========================================Create Posts==================================
  @override
  Future<Either<Failures, CommunityEntity>> createPost(
      Map<String, dynamic> body) async {
    try {
      final response =
          await api.postData(ApiConstants.communityCreatePost, body: body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Right(CommunityDto.fromJson(response.data));
      }

      return Left(Failures(errorMessage: 'Failed to create post'));
    } catch (e) {
      return Left(Failures(errorMessage: e.toString()));
    }
  }

// !===================================================Like===================================
  @override
  Future<Either<Failures, bool>> toggleLike(String postId) async {
    try {
      final response =
          await api.postData(ApiConstants.communityToggleLike(postId));

      if (response.statusCode == 200) {
        return const Right(true);
      }

      return Left(Failures(errorMessage: 'Failed to toggle like'));
    } catch (e) {
      return Left(Failures(errorMessage: e.toString()));
    }
  }

// !==============================================Comment============================================
  @override
  Future<Either<Failures, CommunityEntity>> addComment(
      String postId, Map<String, dynamic> body) async {
    try {
      final response = await api
          .postData(ApiConstants.communityAddComment(postId), body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(CommunityDto.fromJson(response.data));
      }

      return Left(Failures(errorMessage: 'Failed to add comment'));
    } catch (e) {
      return Left(Failures(errorMessage: e.toString()));
    }
  }

// !============================================Delete Post=======================================
  @override
  Future<Either<Failures, bool>> deletePost(String postId) async {
    try {
      final response =
          await api.deleteData(ApiConstants.communityDeletePost(postId));

      if (response.statusCode == 200) {
        return const Right(true);
      }

      return Left(Failures(errorMessage: 'Failed to delete post'));
    } catch (e) {
      return Left(Failures(errorMessage: e.toString()));
    }
  }

  // !================================================Reply======================================

  @override
  Future<Either<Failures, CommunityEntity>> addReply(
    String postId,
    String commentId,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await api.postData(
        ApiConstants.communityAddReply(postId, commentId),
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(CommunityDto.fromJson(response.data));
      }

      return Left(Failures(errorMessage: "Failed to add reply"));
    } catch (e) {
      return Left(Failures(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failures, CommunityEntity>> editReply(
    String postId,
    String commentId,
    String replyId,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await api.putData(
        ApiConstants.communityEditReply(postId, commentId, replyId),
        body: body,
      );

      if (response.statusCode == 200) {
        return Right(CommunityDto.fromJson(response.data));
      }

      return Left(Failures(errorMessage: "Failed to edit reply"));
    } catch (e) {
      return Left(Failures(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failures, bool>> deleteReply(
    String postId,
    String commentId,
    String replyId,
  ) async {
    try {
      final response = await api.deleteData(
        ApiConstants.communityDeleteReply(postId, commentId, replyId),
      );

      if (response.statusCode == 200) {
        return const Right(true);
      }

      return Left(Failures(errorMessage: "Failed to delete reply"));
    } catch (e) {
      return Left(Failures(errorMessage: e.toString()));
    }
  }
}
