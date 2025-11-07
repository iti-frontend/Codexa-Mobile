import 'package:codexa_mobile/Ui/utils/widgets/custom_home_tape_components.dart';
import 'package:flutter/material.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Dashboard",
            style: TextStyle(color: theme.iconTheme.color),
          ),
          const SizedBox(height: 16),
          DashboardCard(
            title: "Course Progress",
            child: Column(
              children: const [
                CourseProgressItem(
                  title: "Mastering Data Science",
                  progress: 0.75,
                ),
                SizedBox(height: 12),
                CourseProgressItem(
                  title: "UX/UI Design Principles",
                  progress: 0.4,
                ),
              ],
            ),
          ),
          DashboardCard(
            title: "Community Activity",
            child: Column(
              children: const [
                CommunityItem(
                  name: "Alice J.",
                  action: "posted in #DataScience",
                  message: "“Just finished a great module on ML algorithms!”",
                  time: "2h ago",
                ),
                SizedBox(height: 10),
                CommunityItem(
                  name: "Bob W.",
                  action: "commented on your post",
                  message:
                      "“That’s awesome! Which ones did you find most useful?”",
                  time: "4h ago",
                ),
                SizedBox(height: 10),
                CommunityItem(
                  name: "Charlie S.",
                  action: "joined a new group",
                  message:
                      "“New to the AI Ethics group. Looking forward to discussions!”",
                  time: "1d ago",
                ),
              ],
            ),
          ),
          DashboardCard(
            title: "Skill Development",
            child: Wrap(
              spacing: 10,
              runSpacing: 5,
              children: const [
                SkillCard(title: "Python", level: "Advanced", progress: 0.9),
                SkillCard(title: "SQL", level: "Intermediate", progress: 0.6),
                SkillCard(
                    title: "Machine Learning",
                    level: "Beginner",
                    progress: 0.3),
                SkillCard(
                    title: "Data Visualization",
                    level: "Intermediate",
                    progress: 0.5),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              StatBox(
                title: "100K+",
                subtitle: "Learners",
              ),
              SizedBox(width: 10),
              StatBox(
                title: "500+",
                subtitle: "Courses",
              ),
              SizedBox(width: 10),
              StatBox(
                title: "10K+",
                subtitle: "Companies",
              ),
            ],
          ),
          const SizedBox(height: 16),
          DashboardCard(
            title: "Recommended for You",
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    "https://images.unsplash.com/photo-1581090700227-1e37b190418e?auto=format&fit=crop&w=400&q=60",
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Advanced Analytics with R",
                        style: TextStyle(
                          color: theme.iconTheme.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Dive deep into statistical analysis and data modeling.",
                        style: TextStyle(color: theme.iconTheme.color),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {},
                        child: Text("View Course"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
