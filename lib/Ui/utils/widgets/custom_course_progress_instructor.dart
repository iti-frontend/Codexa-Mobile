import 'package:flutter/material.dart';

class CourseProgressCard extends StatelessWidget {
  final String title;
  final int students;
  final double progress;

  const CourseProgressCard({
    required this.title,
    required this.students,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: theme.iconTheme.color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "$students students",
              style: TextStyle(color: theme.dividerTheme.color),
            ),
            SizedBox(height: 8),
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
    );
  }
}
