import 'package:codexa_mobile/Ui/utils/widgets/custom_button.dart';
import 'package:codexa_mobile/Ui/utils/widgets/custom_course_progress_instructor.dart';
import 'package:codexa_mobile/Ui/utils/widgets/custom_home_tape_components.dart';
import 'package:codexa_mobile/Ui/utils/widgets/recent_activity.dart';
import 'package:flutter/material.dart';

class HomeTabInstructor extends StatelessWidget {
  const HomeTabInstructor({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Dashboard",
              style: TextStyle(color: theme.iconTheme.color),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatBox(title: "2", subtitle: "Active Course"),
                SizedBox(width: 10),
                StatBox(title: "160", subtitle: "All Students"),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "My Courses",
                  style: TextStyle(color: theme.iconTheme.color),
                ),
                Icon(Icons.more_vert, color: theme.iconTheme.color)
              ],
            ),
            SizedBox(height: 10),
            CourseProgressCard(
              progress: 0.75,
              students: 5,
              title: "Mastering Data Science",
            ),
            CourseProgressCard(
              progress: 0.5,
              students: 5,
              title: "UI/UX Design Principles",
            ),
            const SizedBox(height: 10),
            CustomButton(
              text: "Create new Course",
              onPressed: () {},
            ),
            const SizedBox(height: 25),
            DashboardCard(
              title: "Recent Activity",
              child: Column(
                children: [
                  RecentActivityItem(
                    action: "submitted an assignment in",
                    avatarImg: "assets/images/review-1.jpg",
                    name: "Ali",
                    subject: "Data Science",
                    timeAgo: "15m ago",
                  ),
                  const SizedBox(height: 20),
                  RecentActivityItem(
                    action: "submitted an assignment in",
                    avatarImg: "assets/images/review-1.jpg",
                    name: "Ali",
                    subject: "Data Science",
                    timeAgo: "15m ago",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
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
          ],
        ),
      ),
    );
  }
}
