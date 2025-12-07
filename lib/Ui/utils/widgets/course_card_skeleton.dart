import 'package:flutter/material.dart';
import 'skeleton_shimmer.dart';

/// A skeleton placeholder that mimics the course card structure.
/// Used during loading states to provide visual continuity.
class CourseCardSkeleton extends StatelessWidget {
  final bool showFavouriteButton;
  final bool isRTL;

  const CourseCardSkeleton({
    super.key,
    this.showFavouriteButton = true,
    this.isRTL = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main content
          Expanded(
            child: Column(
              crossAxisAlignment:
                  isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Category badge skeleton
                const SkeletonBox(width: 80, height: 24, borderRadius: 6),
                const SizedBox(height: 12),
                // Title skeleton
                const SkeletonBox(width: double.infinity, height: 18),
                const SizedBox(height: 8),
                // Subtitle skeleton
                const SkeletonBox(width: 150, height: 14),
              ],
            ),
          ),
          if (showFavouriteButton) ...[
            const SizedBox(width: 12),
            // Favourite button skeleton
            const SkeletonBox(width: 32, height: 32, borderRadius: 16),
          ],
        ],
      ),
    );
  }
}

/// A skeleton for the horizontal enrolled course cards
class EnrolledCourseCardSkeleton extends StatelessWidget {
  final bool isRTL;

  const EnrolledCourseCardSkeleton({
    super.key,
    this.isRTL = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 280,
      margin: EdgeInsets.only(
        right: isRTL ? 0 : 16,
        left: isRTL ? 16 : 0,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Category badge skeleton
          const SkeletonBox(width: 70, height: 28, borderRadius: 8),
          const SizedBox(height: 12),
          // Title skeleton
          const SkeletonBox(width: double.infinity, height: 20),
          const SizedBox(height: 8),
          // Instructor name skeleton
          Row(
            children: isRTL
                ? [
                    const Expanded(child: SkeletonBox(width: 100, height: 14)),
                    const SizedBox(width: 4),
                    const SkeletonBox(width: 16, height: 16, borderRadius: 8),
                  ]
                : [
                    const SkeletonBox(width: 16, height: 16, borderRadius: 8),
                    const SizedBox(width: 4),
                    const Expanded(child: SkeletonBox(width: 100, height: 14)),
                  ],
          ),
          const Spacer(),
          // Button skeleton
          const SkeletonBox(
              width: double.infinity, height: 36, borderRadius: 8),
        ],
      ),
    );
  }
}

/// A skeleton for dashboard card content (course progress, community activity)
class DashboardContentSkeleton extends StatelessWidget {
  final int itemCount;

  const DashboardContentSkeleton({
    super.key,
    this.itemCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(itemCount, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              // Avatar skeleton
              const SkeletonBox(width: 40, height: 40, borderRadius: 20),
              const SizedBox(width: 12),
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SkeletonBox(width: double.infinity, height: 14),
                    SizedBox(height: 6),
                    SkeletonBox(width: 120, height: 12),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

/// A skeleton for the full courses list loading state
class CoursesListSkeleton extends StatelessWidget {
  final int itemCount;
  final bool showFavouriteButton;
  final bool isRTL;

  const CoursesListSkeleton({
    super.key,
    this.itemCount = 4,
    this.showFavouriteButton = true,
    this.isRTL = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (index) => CourseCardSkeleton(
          showFavouriteButton: showFavouriteButton,
          isRTL: isRTL,
        ),
      ),
    );
  }
}
