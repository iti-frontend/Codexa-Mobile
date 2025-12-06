import 'package:codexa_mobile/Domain/entities/review_entity.dart';
import 'package:codexa_mobile/Domain/usecases/reviews/create_or_update_review_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/reviews/delete_review_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/reviews/get_average_rating_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/reviews/get_reviews_usecase.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/reviews_cubit/review_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReviewCubit extends Cubit<ReviewState> {
  final CreateOrUpdateReviewUseCase createOrUpdateReviewUseCase;
  final DeleteReviewUseCase deleteReviewUseCase;
  final GetReviewsUseCase getReviewsUseCase;
  final GetAverageRatingUseCase getAverageRatingUseCase;

  ReviewCubit({
    required this.createOrUpdateReviewUseCase,
    required this.deleteReviewUseCase,
    required this.getReviewsUseCase,
    required this.getAverageRatingUseCase,
  }) : super(ReviewInitial());

  // Cached data
  List<ReviewEntity> _reviews = [];
  AverageRatingEntity? _averageRating;
  ReviewEntity? _myReview;
  String? _currentUserId;

  // Getters for cached data
  List<ReviewEntity> get reviews => _reviews;
  AverageRatingEntity? get averageRating => _averageRating;
  ReviewEntity? get myReview => _myReview;

  /// Set current user ID to identify user's own review
  void setCurrentUserId(String? userId) {
    _currentUserId = userId;
    print('📌 [REVIEW_CUBIT] Current user ID set: $userId');
  }

  /// Load reviews and average rating for a course/instructor
  Future<void> loadReviewsAndRating({
    required String itemType,
    required String itemId,
    int page = 1,
    int limit = 20,
  }) async {
    print('🔄 [REVIEW_CUBIT] loadReviewsAndRating called');
    emit(ReviewLoading());

    // Load reviews
    final reviewsResult = await getReviewsUseCase.call(
      itemType: itemType,
      itemId: itemId,
      page: page,
      limit: limit,
    );

    // Load average rating
    final averageResult = await getAverageRatingUseCase.call(
      itemType: itemType,
      itemId: itemId,
    );

    reviewsResult.fold(
      (failure) {
        print('❌ [REVIEW_CUBIT] loadReviews FAILED: ${failure.errorMessage}');
        emit(ReviewError(failure.errorMessage));
      },
      (reviewsList) {
        _reviews = reviewsList;
        print(
            '✅ [REVIEW_CUBIT] loadReviews SUCCESS: ${_reviews.length} reviews');

        // Find current user's review
        _myReview = _findMyReview();

        averageResult.fold(
          (failure) {
            print(
                '⚠️ [REVIEW_CUBIT] getAverageRating FAILED: ${failure.errorMessage}');
            // Still emit loaded state even if average fails
            _averageRating = null;
          },
          (avgRating) {
            _averageRating = avgRating;
            print(
                '✅ [REVIEW_CUBIT] getAverageRating SUCCESS: avg=${avgRating.average}, count=${avgRating.count}');
          },
        );

        emit(ReviewsLoaded(
          reviews: _reviews,
          averageRating: _averageRating,
          myReview: _myReview,
        ));
      },
    );
  }

  /// Find the current user's review in the list
  ReviewEntity? _findMyReview() {
    if (_currentUserId == null || _currentUserId!.isEmpty) return null;

    try {
      return _reviews.firstWhere(
        (review) => review.author?.id == _currentUserId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Submit a new review or update existing one
  Future<void> submitReview({
    required String itemType,
    required String itemId,
    required int rating,
    String? text,
  }) async {
    print('🔄 [REVIEW_CUBIT] submitReview called: rating=$rating');
    emit(SubmitReviewLoading());

    final result = await createOrUpdateReviewUseCase.call(
      itemId: itemId,
      itemType: itemType,
      rating: rating,
      text: text,
    );

    result.fold(
      (failure) {
        print('❌ [REVIEW_CUBIT] submitReview FAILED: ${failure.errorMessage}');
        emit(SubmitReviewError(failure.errorMessage));
        // Re-emit loaded state to restore UI
        emit(ReviewsLoaded(
          reviews: _reviews,
          averageRating: _averageRating,
          myReview: _myReview,
        ));
      },
      (review) {
        print('✅ [REVIEW_CUBIT] submitReview SUCCESS');
        emit(SubmitReviewSuccess(review));

        // Refresh the reviews list
        loadReviewsAndRating(
          itemType: itemType,
          itemId: itemId,
        );
      },
    );
  }

  /// Delete a review
  Future<void> deleteReview({
    required String reviewId,
    required String itemType,
    required String itemId,
  }) async {
    print('🔄 [REVIEW_CUBIT] deleteReview called: reviewId=$reviewId');
    emit(DeleteReviewLoading());

    final result = await deleteReviewUseCase.call(reviewId);

    result.fold(
      (failure) {
        print('❌ [REVIEW_CUBIT] deleteReview FAILED: ${failure.errorMessage}');
        emit(DeleteReviewError(failure.errorMessage));
        // Re-emit loaded state to restore UI
        emit(ReviewsLoaded(
          reviews: _reviews,
          averageRating: _averageRating,
          myReview: _myReview,
        ));
      },
      (message) {
        print('✅ [REVIEW_CUBIT] deleteReview SUCCESS: $message');
        emit(DeleteReviewSuccess(message));

        // Refresh the reviews list
        loadReviewsAndRating(
          itemType: itemType,
          itemId: itemId,
        );
      },
    );
  }
}
