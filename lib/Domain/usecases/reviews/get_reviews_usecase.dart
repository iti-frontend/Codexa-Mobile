import 'package:codexa_mobile/Domain/entities/review_entity.dart';
import 'package:codexa_mobile/Domain/failures.dart';
import 'package:codexa_mobile/Domain/repo/review_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case for getting paginated reviews
class GetReviewsUseCase {
  final ReviewRepository repository;

  GetReviewsUseCase(this.repository);

  Future<Either<Failures, List<ReviewEntity>>> call({
    required String itemType,
    required String itemId,
    int page = 1,
    int limit = 10,
  }) async {
    return await repository.getReviews(
      itemType: itemType,
      itemId: itemId,
      page: page,
      limit: limit,
    );
  }
}
