import 'package:codexa_mobile/Domain/entities/review_entity.dart';
import 'package:codexa_mobile/Domain/failures.dart';
import 'package:codexa_mobile/Domain/repo/review_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case for creating or updating a review (upsert)
class CreateOrUpdateReviewUseCase {
  final ReviewRepository repository;

  CreateOrUpdateReviewUseCase(this.repository);

  Future<Either<Failures, ReviewEntity>> call({
    required String itemId,
    required String itemType,
    required int rating,
    String? text,
  }) async {
    return await repository.createOrUpdateReview(
      itemId: itemId,
      itemType: itemType,
      rating: rating,
      text: text,
    );
  }
}
