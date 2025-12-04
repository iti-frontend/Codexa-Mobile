import 'dart:io';

import 'package:codexa_mobile/Data/api_manager/api_manager.dart';
import 'package:codexa_mobile/Data/constants/api_constants.dart';
import 'package:codexa_mobile/Domain/failures.dart';
import 'package:codexa_mobile/Domain/repo/community_repo.dart';
import 'package:dartz/dartz.dart';

import '../../Domain/entities/community_entity.dart';
import '../models/community_dto.dart';

class CommunityRepoImpl implements CommunityRepo {
  final ApiManager apiManager;

  CommunityRepoImpl(this.apiManager);

  // ==============================
  // 🚀 Get All Posts
  // ==============================
  @override
  Future<Either<Failures, List<CommunityEntity>>> getAllPosts() async {
    try {
      final response = await apiManager.getData(ApiConstants.communityGetAll);

      if (response.statusCode == 200) {
        final data = response.data;

        final List<dynamic> dataList = (data is Map && data['data'] != null)
            ? data['data']
            : (data is List ? data : []);

        final posts =
            dataList.map((item) => CommunityDto.fromJson(item)).toList();

        return Right(posts);
      } else {
        return Left(Failures(
          errorMessage: response.data?['message']?.toString() ?? "Server Error",
        ));
      }
    } catch (e) {
      return Left(Failures(errorMessage: e.toString()));
    }
  }

  // ==============================
  // 🚀 Get User Posts
  // ==============================
  @override
  Future<Either<Failures, List<CommunityEntity>>> getUserPosts(
      String userId) async {
    try {
      final response = await apiManager.getData(
        ApiConstants.communityGetAll,
      );

      if (response.statusCode == 200) {
        final data = response.data;

        final List<dynamic> dataList = (data is Map && data['data'] != null)
            ? data['data']
            : (data is List ? data : []);

        final allPosts =
            dataList.map((item) => CommunityDto.fromJson(item)).toList();

        // Filter posts by author ID
        final userPosts =
            allPosts.where((post) => post.author?.id == userId).toList();

        return Right(userPosts);
      } else {
        return Left(Failures(
          errorMessage: response.data?['message']?.toString() ?? "Server Error",
        ));
      }
    } catch (e) {
      return Left(Failures(errorMessage: e.toString()));
    }
  }

  // ==============================
  // 🚀 Create Post
  // ==============================
  @override
  Future<Either<Failures, CommunityEntity>> createPost({
    required String content,
    File? imageFile,
    dynamic linkUrl,
    List<dynamic>? attachments,
  }) async {
    try {
      // Backend expects JSON, not multipart
      // For now, create text-only posts since we don't have image upload endpoint
      String? imageUrl;
      if (imageFile != null) {
        print(
            'WARNING: Image upload not implemented. Creating text-only post.');
      }

      final response = await apiManager.postData(
        ApiConstants.communityCreatePost,
        body: {
          "content": content,
          if (imageUrl != null) "image": imageUrl,
          if (linkUrl != null) "linkUrl": linkUrl,
          if (attachments != null && attachments.isNotEmpty)
            "attachments": attachments,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final post = CommunityDto.fromJson(response.data);
        return Right(post);
      } else {
        return Left(Failures(
          errorMessage: response.data?['message'] ?? "Failed to create post",
        ));
      }
    } catch (e) {
      return Left(Failures(errorMessage: e.toString()));
    }
  }

  // ==============================
  // 🚀 Toggle Like
  // ==============================
  @override
  Future<Either<Failures, bool>> toggleLike({required String postId}) async {
    try {
      final response = await apiManager.postData(
        ApiConstants.communityToggleLike(postId),
        body: {},
      );

      if (response.statusCode == 200) {
        return const Right(true);
      }

      return Left(Failures(
        errorMessage: response.data?['message'] ?? "Failed to toggle like",
      ));
    } catch (e) {
      return Left(Failures(errorMessage: e.toString()));
    }
  }

  // ==============================
  // 🚀 Add Comment
  // ==============================
  @override
  Future<Either<Failures, CommentsEntity>> addComment({
    required String postId,
    required String text,
  }) async {
    try {
      final response = await apiManager.postData(
        ApiConstants.communityAddComment(postId),
        body: {"text": text},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final comment = CommentsDto.fromJson(response.data["comment"]);
        return Right(comment);
      }

      return Left(Failures(
        errorMessage: response.data?['message'] ?? "Failed to add comment",
      ));
    } catch (e) {
      return Left(Failures(errorMessage: e.toString()));
    }
  }

  // ==============================
  // 🚀 Add Reply
  // ==============================
  @override
  Future<Either<Failures, CommentsEntity>> addReply({
    required String postId,
    required String commentId,
    required String text,
  }) async {
    try {
      final response = await apiManager.postData(
        ApiConstants.communityAddReply(postId, commentId),
        body: {"text": text},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final reply = CommentsDto.fromJson(response.data["reply"]);
        return Right(reply);
      }

      return Left(Failures(
        errorMessage: response.data?['message'] ?? "Failed to add reply",
      ));
    } catch (e) {
      return Left(Failures(errorMessage: e.toString()));
    }
  }

  // ==============================
  // 🚀 Delete Post
  // ==============================
  @override
  Future<Either<Failures, bool>> deletePost({required String postId}) async {
    try {
      final response =
          await apiManager.deleteData(ApiConstants.communityDeletePost(postId));

      if (response.statusCode == 200) {
        return const Right(true);
      }

      return Left(Failures(
        errorMessage: response.data?['message'] ?? "Failed to delete post",
      ));
    } catch (e) {
      return Left(Failures(errorMessage: e.toString()));
    }
  }

  // ==============================
  // 🚀 Delete Comment
  // ==============================
  @override
  Future<Either<Failures, bool>> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    try {
      final response = await apiManager.deleteData(
        ApiConstants.communityDeleteComment(postId, commentId),
      );

      if (response.statusCode == 200) {
        return const Right(true);
      }

      return Left(Failures(
        errorMessage: response.data?['message'] ?? "Failed to delete comment",
      ));
    } catch (e) {
      return Left(Failures(errorMessage: e.toString()));
    }
  }

  // ==============================
  // 🚀 Delete Reply
  // ==============================
  @override
  Future<Either<Failures, bool>> deleteReply({
    required String postId,
    required String commentId,
    required String replyId,
  }) async {
    try {
      final response = await apiManager.deleteData(
        ApiConstants.communityDeleteReply(postId, commentId, replyId),
      );

      if (response.statusCode == 200) {
        return const Right(true);
      }

      return Left(Failures(
        errorMessage: response.data?['message'] ?? "Failed to delete reply",
      ));
    } catch (e) {
      return Left(Failures(errorMessage: e.toString()));
    }
  }
}
