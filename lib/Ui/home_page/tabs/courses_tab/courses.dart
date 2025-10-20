import 'package:codexa_mobile/Ui/utils/theme/app_colors.dart';
import 'package:codexa_mobile/Ui/utils/widgets/custom_home_tape_components.dart';
import 'package:codexa_mobile/Ui/utils/widgets/custom_section_title.dart';
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
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColorsDark.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // shrink to content
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course['courseTitle'],
                        style: TextStyle(
                          fontSize:
                              MediaQuery.of(context).size.width > 600 ? 20 : 18,
                          fontWeight: FontWeight.bold,
                          color: AppColorsDark.primaryText,
                          fontFamily: 'Gilroy',
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
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width > 600
                                  ? 16
                                  : 14,
                              color: AppColorsDark.secondaryText,
                            ),
                          ),
                          Text(
                            course['percentageByNumber'],
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width > 600
                                  ? 16
                                  : 14,
                              color: AppColorsDark.secondaryText,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: course['percentage'],
                          minHeight:
                              MediaQuery.of(context).size.width > 600 ? 10 : 8,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColorsDark.accentGreen),
                        ),
                      ),
                    ],
                  ),
                );
              },
            )
            // DashboardCard(
            //     haveBanner: false,
            //     child: CourseProgressItem(
            //         categoryTitle: 'Design',
            //         hasCategory: true,
            //         categoryPercentage: '75%',
            //         title: 'Product Design',
            //         progress: 0.8,
            //         color: AppColorsDark.accentGreen)
            // ),
          ],
        ),
      ),
    );
  }
}
