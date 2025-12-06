import 'package:codexa_mobile/Domain/entities/review_entity.dart';

/// Base state for Review feature
abstract class ReviewState {}

/// Initial state before any data is loaded
class ReviewInitial extends ReviewState {}

/// Loading state while fetching data
class ReviewLoading extends ReviewState {}

/// State when reviews are loaded successfully
class ReviewsLoaded extends ReviewState {
  final List<ReviewEntity> reviews;
  final AverageRatingEntity? averageRating;
  final ReviewEntity? myReview;

  ReviewsLoaded({
    required this.reviews,
    this.averageRating,
    this.myReview,
  });
}

/// Error state when fetching reviews fails
class ReviewError extends ReviewState {
  final String message;

  ReviewError(this.message);
}

/// Success state after submitting a review
class SubmitReviewSuccess extends ReviewState {
  final ReviewEntity review;

  SubmitReviewSuccess(this.review);
}

/// Error state when submitting a review fails
class SubmitReviewError extends ReviewState {
  final String message;

  SubmitReviewError(this.message);
}

/// Success state after deleting a review
class DeleteReviewSuccess extends ReviewState {
  final String message;

  DeleteReviewSuccess(this.message);
}

/// Error state when deleting a review fails
class DeleteReviewError extends ReviewState {
  final String message;

  DeleteReviewError(this.message);
}

/// State when submitting review is in progress
class SubmitReviewLoading extends ReviewState {}

/// State when delete is in progress
class DeleteReviewLoading extends ReviewState {}
