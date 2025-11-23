import 'package:flutter/material.dart';

class DashboardCard extends StatelessWidget {
  final String? title;
  final Widget child;
  final bool haveBanner;

  const DashboardCard({
    super.key,
    this.title,
    required this.child,
    this.haveBanner = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (haveBanner && title != null) ...[
              Text(
                title!,
                style: TextStyle(color: theme.dividerTheme.color),
              ),
              const SizedBox(height: 12),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

class CourseProgressItem extends StatelessWidget {
  final String title;
  final double? progress;
  final bool hasCategory;
  final String? categoryTitle;
  final String? categoryPercentage;
  final String instructorName;

  const CourseProgressItem({
    super.key,
    required this.title,
    this.progress,
    this.categoryTitle,
    this.categoryPercentage,
    this.hasCategory = false,
    required this.instructorName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool showProgress = progress != null && progress! > 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.play_circle_outline_rounded,
            color: theme.dividerTheme.color,
            size: 28,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasCategory)
                Text(
                  categoryTitle ?? '',
                  style: TextStyle(
                    color: theme.progressIndicatorTheme.color,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              if (hasCategory) const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: theme.dividerTheme.color,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Instructor: $instructorName',
                style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  fontSize: 13,
                ),
              ),
              if (showProgress) const SizedBox(height: 8),
              if (showProgress)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(10),
                      color: theme.progressIndicatorTheme.color,
                      backgroundColor: theme
                          .progressIndicatorTheme.linearTrackColor
                          ?.withOpacity(0.3),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      categoryPercentage ?? '${(progress! * 100).toInt()}%',
                      style: TextStyle(
                        color: theme.progressIndicatorTheme.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class CommunityItem extends StatelessWidget {
  final String name;
  final String action;
  final String message;
  final String time;
  final String? profileImage;

  const CommunityItem({
    super.key,
    required this.name,
    required this.action,
    required this.message,
    required this.time,
    this.profileImage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine the image provider
    ImageProvider? imageProvider;
    if (profileImage != null && profileImage!.startsWith('http')) {
      imageProvider = NetworkImage(profileImage!);
    } else if (profileImage != null && profileImage!.isNotEmpty) {
      imageProvider = AssetImage(profileImage!);
    } else {
      // Default placeholder
      imageProvider = const AssetImage("assets/images/review-1.jpg");
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundImage: imageProvider,
          onBackgroundImageError: (_, __) {
            // Fallback is handled by the provider logic above
          },
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: TextStyle(color: theme.dividerTheme.color),
                  children: [
                    TextSpan(
                      text: "$name ",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: action),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                message,
                style: TextStyle(color: theme.dividerTheme.color),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(
                  color: theme.dividerTheme.color?.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SkillCard extends StatelessWidget {
  final String title;
  final String level;
  final double progress;

  const SkillCard({
    super.key,
    required this.title,
    required this.level,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(color: theme.dividerTheme.color),
            ),
            const SizedBox(height: 6),
            Text(
              level,
              style: TextStyle(color: theme.dividerTheme.color),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              color: theme.progressIndicatorTheme.color,
              backgroundColor: theme.progressIndicatorTheme.linearTrackColor,
              minHeight: 5,
            ),
          ],
        ),
      ),
    );
  }
}

class StatBox extends StatelessWidget {
  final String title;
  final String subtitle;

  const StatBox({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: theme.bottomNavigationBarTheme.selectedItemColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(color: theme.dividerTheme.color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
