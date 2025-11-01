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
  final double progress;
  final bool hasCategory;
  final String? categoryTitle;
  final String? categoryPercentage;

  const CourseProgressItem({
    super.key,
    required this.title,
    required this.progress,
    this.categoryTitle,
    this.categoryPercentage,
    this.hasCategory = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: theme.dividerTheme.color,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasCategory) ...[
                Text(
                  categoryTitle ?? '',
                  style: TextStyle(color: theme.progressIndicatorTheme.color),
                ),
                const SizedBox(height: 10.0),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: TextStyle(color: theme.dividerTheme.color),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (hasCategory)
                    Text(
                      categoryPercentage ?? '',
                      style:
                          TextStyle(color: theme.progressIndicatorTheme.color),
                    ),
                ],
              ),
              SizedBox(height: hasCategory ? 15.0 : 6),
              LinearProgressIndicator(
                value: progress,
                color: theme.progressIndicatorTheme.color,
                backgroundColor: theme.progressIndicatorTheme.linearTrackColor,
                borderRadius: BorderRadius.circular(10),
                minHeight: 6,
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

  const CommunityItem({
    super.key,
    required this.name,
    required this.action,
    required this.message,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(radius: 18, backgroundColor: theme.dividerTheme.color),
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
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: action),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                message,
                style: TextStyle(color: theme.dividerTheme.color),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(color: theme.dividerTheme.color),
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
