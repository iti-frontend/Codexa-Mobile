import 'package:codexa_mobile/Domain/failures.dart';
import 'package:codexa_mobile/Domain/repo/review_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case for deleting a review
class DeleteReviewUseCase {
  final ReviewRepository repository;

  DeleteReviewUseCase(this.repository);

  Future<Either<Failures, String>> call(String reviewId) async {
    return await repository.deleteReview(reviewId);
  }
}
