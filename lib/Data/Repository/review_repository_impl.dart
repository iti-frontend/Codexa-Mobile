import 'dart:convert';
import 'package:codexa_mobile/Data/api_manager/api_manager.dart';
import 'package:codexa_mobile/Data/constants/api_constants.dart';
import 'package:codexa_mobile/Data/models/review_dto.dart';
import 'package:codexa_mobile/Domain/entities/review_entity.dart';
import 'package:codexa_mobile/Domain/failures.dart';
import 'package:codexa_mobile/Domain/repo/review_repository.dart';
import 'package:dartz/dartz.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ApiManager apiManager;

  ReviewRepositoryImpl(this.apiManager);

  @override
  Future<Either<Failures, ReviewEntity>> createOrUpdateReview({
    required String itemId,
    required String itemType,
    required int rating,
    String? text,
  }) async {
    try {
      print('🌐 [REVIEW_REPO] createOrUpdateReview API call started');
      print('📤 [REVIEW_REPO] Endpoint: ${ApiConstants.createOrUpdateReview}');
      print(
          '📤 [REVIEW_REPO] Body: {itemId: $itemId, itemType: $itemType, rating: $rating, text: $text}');

      final body = {
        'itemId': itemId,
        'itemType': itemType,
        'rating': rating,
        if (text != null && text.isNotEmpty) 'text': text,
      };

      final response = await apiManager.postData(
        ApiConstants.createOrUpdateReview,
        body: body,
      );

      print('📥 [REVIEW_REPO] Response Status: ${response.statusCode}');
      print('📥 [REVIEW_REPO] Response Data: ${response.data}');

      var data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse the Review
        // Check if data is Map first
        if (data is Map) {
          final reviewData = data['review'] ?? data;
          if (reviewData is Map<String, dynamic>) {
            final reviewDto = ReviewDto.fromJson(reviewData);
            print('✅ [REVIEW_REPO] createOrUpdateReview SUCCESS');
            return Right(reviewDto);
          } else if (reviewData is Map) {
            // Handle dynamic map
            final reviewDto =
                ReviewDto.fromJson(Map<String, dynamic>.from(reviewData));
            return Right(reviewDto);
          }
        }

        return Left(Failures(
            errorMessage:
                'Unexpected success response format: ${data.runtimeType}'));
      } else {
        String errorMsg = 'Failed to submit review';
        if (data is Map) {
          errorMsg = data['message']?.toString() ?? errorMsg;
        } else if (data is List && data.isNotEmpty) {
          // If list of errors, take first
          if (data[0] is Map) {
            errorMsg = data[0]['message']?.toString() ?? data[0].toString();
          } else {
            errorMsg = data.toString();
          }
        } else if (data is String) {
          errorMsg = data;
        }

        print('❌ [REVIEW_REPO] createOrUpdateReview FAILED: $errorMsg');
        return Left(Failures(errorMessage: errorMsg));
      }
    } catch (e) {
      print('💥 [REVIEW_REPO] createOrUpdateReview EXCEPTION: $e');
      return Left(Failures(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failures, String>> deleteReview(String reviewId) async {
    try {
      print('🌐 [REVIEW_REPO] deleteReview API call started');
      print(
          '📤 [REVIEW_REPO] Endpoint: ${ApiConstants.deleteReview(reviewId)}');

      final response = await apiManager.deleteData(
        ApiConstants.deleteReview(reviewId),
      );

      print('📥 [REVIEW_REPO] Response Status: ${response.statusCode}');
      print('📥 [REVIEW_REPO] Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final message =
            response.data['message'] ?? 'Review deleted successfully';
        print('✅ [REVIEW_REPO] deleteReview SUCCESS: $message');
        return Right(message);
      } else {
        final errorMsg =
            response.data?['message']?.toString() ?? 'Failed to delete review';
        print('❌ [REVIEW_REPO] deleteReview FAILED: $errorMsg');
        return Left(Failures(errorMessage: errorMsg));
      }
    } catch (e) {
      print('💥 [REVIEW_REPO] deleteReview EXCEPTION: $e');
      return Left(Failures(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failures, List<ReviewEntity>>> getReviews({
    required String itemType,
    required String itemId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      print('🌐 [REVIEW_REPO] getReviews API call started');
      final endpoint =
          ApiConstants.listReviewsPaged(itemType, itemId, page, limit);
      print('📤 [REVIEW_REPO] Endpoint: $endpoint');

      final response = await apiManager.getData(endpoint);

      print('📥 [REVIEW_REPO] Response Status: ${response.statusCode}');
      print('📥 [REVIEW_REPO] Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final reviewsListDto = ReviewsListDto.fromJson(response.data);
        final reviews = reviewsListDto.items ?? [];
        print('✅ [REVIEW_REPO] getReviews SUCCESS: ${reviews.length} reviews');
        return Right(reviews);
      } else {
        final errorMsg =
            response.data?['message']?.toString() ?? 'Failed to get reviews';
        print('❌ [REVIEW_REPO] getReviews FAILED: $errorMsg');
        return Left(Failures(errorMessage: errorMsg));
      }
    } catch (e) {
      print('💥 [REVIEW_REPO] getReviews EXCEPTION: $e');
      return Left(Failures(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failures, AverageRatingEntity>> getAverageRating({
    required String itemType,
    required String itemId,
  }) async {
    try {
      print('🌐 [REVIEW_REPO] getAverageRating API call started');
      final endpoint = ApiConstants.averageRating(itemType, itemId);
      print('📤 [REVIEW_REPO] Endpoint: $endpoint');

      final response = await apiManager.getData(endpoint);

      print('📥 [REVIEW_REPO] Response Status: ${response.statusCode}');
      print('📥 [REVIEW_REPO] Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final averageRatingDto = AverageRatingDto.fromJson(response.data);
        print(
            '✅ [REVIEW_REPO] getAverageRating SUCCESS: avg=${averageRatingDto.average}, count=${averageRatingDto.count}');
        return Right(averageRatingDto);
      } else {
        final errorMsg = response.data?['message']?.toString() ??
            'Failed to get average rating';
        print('❌ [REVIEW_REPO] getAverageRating FAILED: $errorMsg');
        return Left(Failures(errorMessage: errorMsg));
      }
    } catch (e) {
      print('💥 [REVIEW_REPO] getAverageRating EXCEPTION: $e');
      return Left(Failures(errorMessage: e.toString()));
    }
  }
}
