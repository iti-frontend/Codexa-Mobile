import 'package:codexa_mobile/Domain/entities/review_entity.dart';
import 'package:codexa_mobile/Domain/failures.dart';
import 'package:dartz/dartz.dart';

/// Repository contract for Reviews feature
abstract class ReviewRepository {
  /// Create a new review or update existing one (upsert)
  Future<Either<Failures, ReviewEntity>> createOrUpdateReview({
    required String itemId,
    required String itemType,
    required int rating,
    String? text,
  });

  /// Delete a review (student can only delete their own)
  Future<Either<Failures, String>> deleteReview(String reviewId);

  /// Get paginated list of reviews for a course/instructor
  Future<Either<Failures, List<ReviewEntity>>> getReviews({
    required String itemType,
    required String itemId,
    int page = 1,
    int limit = 10,
  });

  /// Get average rating and count for a course/instructor
  Future<Either<Failures, AverageRatingEntity>> getAverageRating({
    required String itemType,
    required String itemId,
  });
}
