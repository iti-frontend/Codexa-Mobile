import 'package:codexa_mobile/Domain/entities/review_entity.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/reviews_cubit/review_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/reviews_cubit/review_state.dart';
import 'package:codexa_mobile/Ui/utils/provider_ui/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:codexa_mobile/generated/l10n.dart' as generated;

/// Reviews Section Widget for CourseDetailsScreen
class ReviewsSection extends StatefulWidget {
  final String itemId;
  final String itemType; // "Course" or "Instructor"
  final bool isInstructor;
  final bool isEnrolled; // Whether the student is enrolled in the course
  final String? currentUserId;
  final ThemeData theme;
  final generated.S translations;

  const ReviewsSection({
    super.key,
    required this.itemId,
    required this.itemType,
    required this.isInstructor,
    this.isEnrolled = false, // Default to false - only enrolled students can add reviews
    required this.currentUserId,
    required this.theme,
    required this.translations,
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
              content: Text(_isEditing ? widget.translations.reviewUpdated : widget.translations.reviewSubmitted),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Average Rating Section
            _buildAverageRatingSection(averageRating),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),

            // Review Input Section (Students only - must be enrolled to add reviews)
            if (!widget.isInstructor && widget.isEnrolled) ...[
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
    final isRTL = Directionality.of(context) == TextDirection.rtl;

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
            textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          ),
          const SizedBox(width: 8),
          // Count
          Text(
            '($count ${widget.translations.reviews})',
            style: widget.theme.textTheme.bodyMedium?.copyWith(
              color: widget.theme.iconTheme.color?.withOpacity(0.7),
            ),
            textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          ),
        ],
      ),
    );
  }

  Widget _buildReviewInputSection(ReviewEntity? myReview, ReviewState state) {
    final isSubmitting = state is SubmitReviewLoading;
    final isDeleting = state is DeleteReviewLoading;
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    // If user already has a review and not editing, show their review with edit/delete
    if (myReview != null && !_isEditing) {
      return _buildMyReviewCard(myReview, isDeleting, isRTL);
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isEditing ? widget.translations.editReview : widget.translations.addReview,
            style: widget.theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: widget.theme.iconTheme.color,
            ),
            textAlign: isRTL ? TextAlign.right : TextAlign.left,
            textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
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
              hintText: widget.translations.writeYourReview,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: widget.theme.scaffoldBackgroundColor,
            ),
            textAlign: isRTL ? TextAlign.right : TextAlign.left,
            textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
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
                    child: Text(
                      widget.translations.cancel,
                      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                    ),
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
                    _isEditing ? widget.translations.editReview : widget.translations.submitReview,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMyReviewCard(ReviewEntity review, bool isDeleting, bool isRTL) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.translations.yourReview,
                style: widget.theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: widget.theme.progressIndicatorTheme.color,
                ),
                textAlign: isRTL ? TextAlign.right : TextAlign.left,
                textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _startEditing(review),
                    icon: Icon(
                      Icons.edit,
                      color: widget.theme.progressIndicatorTheme.color,
                    ),
                    tooltip: widget.translations.edit,
                  ),
                  IconButton(
                    onPressed: isDeleting
                        ? null
                        : () => _showDeleteConfirmation(review, isRTL),
                    icon: isDeleting
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : Icon(Icons.delete, color: Colors.red),
                    tooltip: widget.translations.delete,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildStarRating(review.rating ?? 0, isRTL),
          if (review.text != null && review.text!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.text!,
              style: widget.theme.textTheme.bodyMedium?.copyWith(
                color: widget.theme.iconTheme.color,
              ),
              textAlign: isRTL ? TextAlign.right : TextAlign.left,
              textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
            ),
          ],
        ],
      ),
    );
  }

  void _showDeleteConfirmation(ReviewEntity review, bool isRTL) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          widget.translations.deleteReview,
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        ),
        content: Text(
          widget.translations.confirmDeleteReview,
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        ),
        actionsAlignment: MainAxisAlignment.start,
        actions: [
          if (isRTL) ...[
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.read<ReviewCubit>().deleteReview(
                  reviewId: review.id!,
                  itemType: widget.itemType,
                  itemId: widget.itemId,
                );
              },
              child: Text(
                widget.translations.delete,
                style: const TextStyle(color: Colors.red),
                textDirection: TextDirection.rtl,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                widget.translations.cancel,
                textDirection: TextDirection.rtl,
              ),
            ),
          ] else ...[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(widget.translations.cancel),
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
              child: Text(
                widget.translations.delete,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewsListSection(List<ReviewEntity> reviews) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    if (reviews.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Text(
            widget.translations.noReviewsYet,
            style: widget.theme.textTheme.bodyMedium?.copyWith(
              color: widget.theme.iconTheme.color?.withOpacity(0.6),
            ),
            textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (!isRTL) ...[
              Icon(
                Icons.reviews_outlined,
                color: widget.theme.progressIndicatorTheme.color,
                size: 22,
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                widget.translations.reviews,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: widget.theme.iconTheme.color,
                ),
                textAlign: isRTL ? TextAlign.right : TextAlign.left,
                textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
              ),
            ),
            if (isRTL) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.reviews_outlined,
                color: widget.theme.progressIndicatorTheme.color,
                size: 22,
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        ...reviews.map((review) => _buildReviewItem(review, isRTL)),
      ],
    );
  }

  Widget _buildReviewItem(ReviewEntity review, bool isRTL) {
    final author = review.author;
    final createdAt = review.createdAt;
    String timeAgo = '';

    if (createdAt != null) {
      final date = DateTime.tryParse(createdAt);
      if (date != null) {
        // Use Arabic locale for timeago if RTL
        if (isRTL) {
          timeago.setLocaleMessages('ar', timeago.ArMessages());
          timeAgo = timeago.format(date, locale: 'ar');
        } else {
          timeAgo = timeago.format(date);
        }
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author info row
            Row(
              children: [
                if (!isRTL) ...[
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
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Builder(builder: (context) {
                        // Fallback logic for Current User
                        String displayName = author?.name ?? widget.translations.anonymous;
                        if ((displayName == widget.translations.anonymous ||
                            displayName.isEmpty) &&
                            widget.currentUserId != null &&
                            author?.id == widget.currentUserId) {
                          // Try fetching from UserProvider
                          try {
                            final userProvider = Provider.of<UserProvider>(
                                context,
                                listen: false);
                            final user = userProvider.user;
                            if (user != null) {
                              dynamic dUser = user;
                              try {
                                displayName = dUser.name ?? widget.translations.you;
                              } catch (_) {
                                try {
                                  displayName = dUser['name'] ?? widget.translations.you;
                                } catch (_) {}
                              }
                            }
                          } catch (_) {}
                        }

                        return Text(
                          displayName,
                          style: widget.theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: widget.theme.iconTheme.color,
                          ),
                          textAlign: isRTL ? TextAlign.right : TextAlign.left,
                          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                        );
                      }),
                      const SizedBox(height: 2),
                      Align(
                        alignment: isRTL ? Alignment.centerRight : Alignment.centerLeft,
                        child: _buildStarRating(review.rating ?? 0, isRTL),
                      ),
                    ],
                  ),
                ),
                if (isRTL) ...[
                  const SizedBox(width: 12),
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
                ],
              ],
            ),
            // Time and delete button row
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  timeAgo,
                  style: widget.theme.textTheme.bodySmall?.copyWith(
                    color: widget.theme.iconTheme.color?.withOpacity(0.6),
                  ),
                  textAlign: isRTL ? TextAlign.right : TextAlign.left,
                  textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                ),
                if (widget.currentUserId != null &&
                    author?.id == widget.currentUserId) ...[
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.red, size: 20),
                    onPressed: () => _showDeleteConfirmation(review, isRTL),
                    tooltip: widget.translations.deleteReview,
                  ),
                ],
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
                textAlign: isRTL ? TextAlign.right : TextAlign.left,
                textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating(int rating, bool isRTL) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
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