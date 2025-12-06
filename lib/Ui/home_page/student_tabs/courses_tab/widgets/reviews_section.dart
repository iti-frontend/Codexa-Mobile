import 'package:codexa_mobile/Domain/entities/review_entity.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/reviews_cubit/review_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/reviews_cubit/review_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Reviews Section Widget for CourseDetailsScreen
class ReviewsSection extends StatefulWidget {
  final String itemId;
  final String itemType; // "Course" or "Instructor"
  final bool isInstructor;
  final String? currentUserId;
  final ThemeData theme;
  final bool isRTL;

  const ReviewsSection({
    super.key,
    required this.itemId,
    required this.itemType,
    required this.isInstructor,
    required this.currentUserId,
    required this.theme,
    required this.isRTL,
  });

  @override
  State<ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<ReviewsSection> {
  final TextEditingController _reviewTextController = TextEditingController();
  int _selectedRating = 0;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  void _loadReviews() {
    final cubit = context.read<ReviewCubit>();
    cubit.setCurrentUserId(widget.currentUserId);
    cubit.loadReviewsAndRating(
      itemType: widget.itemType,
      itemId: widget.itemId,
    );
  }

  @override
  void dispose() {
    _reviewTextController.dispose();
    super.dispose();
  }

  void _resetForm() {
    setState(() {
      _selectedRating = 0;
      _reviewTextController.clear();
      _isEditing = false;
    });
  }

  void _startEditing(ReviewEntity review) {
    setState(() {
      _selectedRating = review.rating ?? 0;
      _reviewTextController.text = review.text ?? '';
      _isEditing = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReviewCubit, ReviewState>(
      listener: (context, state) {
        if (state is SubmitReviewSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(_isEditing ? 'Review updated!' : 'Review submitted!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          _resetForm();
        } else if (state is SubmitReviewError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is DeleteReviewSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
          _resetForm();
        } else if (state is DeleteReviewError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is ReviewLoading) {
          return _buildLoadingSection();
        }

        final cubit = context.read<ReviewCubit>();
        final averageRating = cubit.averageRating;
        final reviews = cubit.reviews;
        final myReview = cubit.myReview;

        return Column(
          crossAxisAlignment:
              widget.isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Average Rating Section
            _buildAverageRatingSection(averageRating),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),

            // Review Input Section (Students only)
            if (!widget.isInstructor) ...[
              _buildReviewInputSection(myReview, state),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
            ],

            // Reviews List
            _buildReviewsListSection(reviews),
          ],
        );
      },
    );
  }

  Widget _buildLoadingSection() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildAverageRatingSection(AverageRatingEntity? averageRating) {
    final avg = averageRating?.average ?? 0.0;
    final count = averageRating?.count ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.theme.cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.theme.dividerColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Stars
          Row(
            children: List.generate(5, (index) {
              final starValue = index + 1;
              if (avg >= starValue) {
                return Icon(Icons.star, color: Colors.amber, size: 28);
              } else if (avg >= starValue - 0.5) {
                return Icon(Icons.star_half, color: Colors.amber, size: 28);
              } else {
                return Icon(Icons.star_border, color: Colors.amber, size: 28);
              }
            }),
          ),
          const SizedBox(width: 12),
          // Average number
          Text(
            avg.toStringAsFixed(1),
            style: widget.theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: widget.theme.iconTheme.color,
            ),
          ),
          const SizedBox(width: 8),
          // Count
          Text(
            '($count reviews)',
            style: widget.theme.textTheme.bodyMedium?.copyWith(
              color: widget.theme.iconTheme.color?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewInputSection(ReviewEntity? myReview, ReviewState state) {
    final isSubmitting = state is SubmitReviewLoading;
    final isDeleting = state is DeleteReviewLoading;

    // If user already has a review and not editing, show their review with edit/delete
    if (myReview != null && !_isEditing) {
      return _buildMyReviewCard(myReview, isDeleting);
    }

    // Otherwise show the input form
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.theme.progressIndicatorTheme.color?.withOpacity(0.3) ??
              Colors.blue.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            widget.isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            _isEditing ? 'Edit Your Review' : 'Write a Review',
            style: widget.theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: widget.theme.iconTheme.color,
            ),
          ),
          const SizedBox(height: 16),

          // Stars Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starValue = index + 1;
              return GestureDetector(
                onTap: () => setState(() => _selectedRating = starValue),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    _selectedRating >= starValue
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                    size: 40,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),

          // Text Field
          TextField(
            controller: _reviewTextController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Share your experience (optional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: widget.theme.scaffoldBackgroundColor,
            ),
          ),
          const SizedBox(height: 16),

          // Submit and Cancel buttons
          Row(
            children: [
              if (_isEditing)
                Expanded(
                  child: OutlinedButton(
                    onPressed: isSubmitting ? null : _resetForm,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
              if (_isEditing) const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: isSubmitting || _selectedRating == 0
                      ? null
                      : () {
                          context.read<ReviewCubit>().submitReview(
                                itemType: widget.itemType,
                                itemId: widget.itemId,
                                rating: _selectedRating,
                                text: _reviewTextController.text.isNotEmpty
                                    ? _reviewTextController.text
                                    : null,
                              );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.theme.progressIndicatorTheme.color,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _isEditing ? 'Update Review' : 'Submit Review',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMyReviewCard(ReviewEntity review, bool isDeleting) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.theme.progressIndicatorTheme.color?.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.theme.progressIndicatorTheme.color?.withOpacity(0.3) ??
              Colors.blue.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            widget.isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Review',
                style: widget.theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: widget.theme.progressIndicatorTheme.color,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _startEditing(review),
                    icon: Icon(
                      Icons.edit,
                      color: widget.theme.progressIndicatorTheme.color,
                    ),
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    onPressed: isDeleting
                        ? null
                        : () => _showDeleteConfirmation(review),
                    icon: isDeleting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Delete',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildStarRating(review.rating ?? 0),
          if (review.text != null && review.text!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.text!,
              style: widget.theme.textTheme.bodyMedium?.copyWith(
                color: widget.theme.iconTheme.color,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showDeleteConfirmation(ReviewEntity review) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Review'),
        content: const Text('Are you sure you want to delete your review?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<ReviewCubit>().deleteReview(
                    reviewId: review.id!,
                    itemType: widget.itemType,
                    itemId: widget.itemId,
                  );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsListSection(List<ReviewEntity> reviews) {
    if (reviews.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Text(
            'No reviews yet',
            style: widget.theme.textTheme.bodyMedium?.copyWith(
              color: widget.theme.iconTheme.color?.withOpacity(0.6),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment:
          widget.isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          children: widget.isRTL
              ? [
                  Text(
                    'Reviews',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: widget.theme.iconTheme.color,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.reviews_outlined,
                    color: widget.theme.progressIndicatorTheme.color,
                    size: 22,
                  ),
                ]
              : [
                  Icon(
                    Icons.reviews_outlined,
                    color: widget.theme.progressIndicatorTheme.color,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Reviews',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: widget.theme.iconTheme.color,
                    ),
                  ),
                ],
        ),
        const SizedBox(height: 16),
        ...reviews.map((review) => _buildReviewItem(review)),
      ],
    );
  }

  Widget _buildReviewItem(ReviewEntity review) {
    final author = review.author;
    final createdAt = review.createdAt;
    String timeAgo = '';

    if (createdAt != null) {
      final date = DateTime.tryParse(createdAt);
      if (date != null) {
        timeAgo = timeago.format(date);
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              widget.isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Author info row
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: author?.profileImage != null &&
                          author!.profileImage!.isNotEmpty
                      ? NetworkImage(author.profileImage!)
                      : null,
                  backgroundColor: widget.theme.progressIndicatorTheme.color
                      ?.withOpacity(0.2),
                  child: author?.profileImage == null ||
                          author!.profileImage!.isEmpty
                      ? Icon(
                          Icons.person,
                          color: widget.theme.progressIndicatorTheme.color,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: widget.isRTL
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        author?.name ?? 'Anonymous',
                        style: widget.theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: widget.theme.iconTheme.color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      _buildStarRating(review.rating ?? 0),
                    ],
                  ),
                ),
                Text(
                  timeAgo,
                  style: widget.theme.textTheme.bodySmall?.copyWith(
                    color: widget.theme.iconTheme.color?.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            // Review text
            if (review.text != null && review.text!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                review.text!,
                style: widget.theme.textTheme.bodyMedium?.copyWith(
                  color: widget.theme.iconTheme.color,
                  height: 1.5,
                ),
                textAlign: widget.isRTL ? TextAlign.right : TextAlign.left,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 18,
        );
      }),
    );
  }
}
