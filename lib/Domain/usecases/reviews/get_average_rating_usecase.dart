import 'package:codexa_mobile/Domain/entities/review_entity.dart';
import 'package:codexa_mobile/Domain/failures.dart';
import 'package:codexa_mobile/Domain/repo/review_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case for getting average rating and count
class GetAverageRatingUseCase {
  final ReviewRepository repository;

  GetAverageRatingUseCase(this.repository);

  Future<Either<Failures, AverageRatingEntity>> call({
    required String itemType,
    required String itemId,
  }) async {
    return await repository.getAverageRating(
      itemType: itemType,
      itemId: itemId,
    );
  }
}
