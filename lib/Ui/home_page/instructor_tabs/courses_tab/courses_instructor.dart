import 'package:flutter/material.dart';

class CoursesTab extends StatefulWidget {
  const CoursesTab({super.key});

  @override
  State<CoursesTab> createState() => _CoursesTabState();
}

class _CoursesTabState extends State<CoursesTab> {
  final List<Map<String, dynamic>> courseCards = [
    {
      'categoryTitle': 'Web Development',
      'courseTitle': 'Mastering React.js',
      'percentage': 0.85,
      'percentageByNumber': '85%',
      'enrolled': 30
    },
    {
      'categoryTitle': 'Mobile Development',
      'courseTitle': 'Flutter from Zero to Hero',
      'percentage': 0.65,
      'percentageByNumber': '65%',
      'enrolled': 15
    },
    {
      'categoryTitle': 'Data Science',
      'courseTitle': 'Python for Machine Learning',
      'percentage': 0.45,
      'percentageByNumber': '45%',
      'enrolled': 10
    },
    {
      'categoryTitle': 'UI/UX Design',
      'courseTitle': 'Design Thinking Basics',
      'percentage': 0.75,
      'percentageByNumber': '75%',
      'enrolled': 6
    },
    {
      'categoryTitle': 'Backend Development',
      'courseTitle': 'Node.js & MongoDB Masterclass',
      'percentage': 0.9,
      'percentageByNumber': '90%',
      'enrolled': 45
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20.0),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: courseCards.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final course = courseCards[index];
                return Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course['courseTitle'],
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.iconTheme.color,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${course['enrolled'] ?? 0} enrolled",
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.iconTheme.color,
                              ),
                            ),
                            Text(
                              course['percentageByNumber'],
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.iconTheme.color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: course['percentage'],
                            minHeight: MediaQuery.of(context).size.width > 600
                                ? 10
                                : 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
