import 'package:codexa_mobile/Ui/home_page/additional_screens/video_player_course.dart';
import 'package:codexa_mobile/Ui/utils/provider_ui/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:codexa_mobile/Domain/entities/courses_entity.dart';
import 'package:codexa_mobile/Ui/utils/theme/app_colors.dart';
import 'package:provider/provider.dart';

class CourseDetails extends StatelessWidget {
  final CourseEntity course;

  const CourseDetails({
    super.key,
    required this.course,
  });

  String formatDate(String? date) {
    if (date == null) return "N/A";
    final dt = DateTime.tryParse(date);
    if (dt == null) return date;
    return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isInstructor = userProvider.role == 'instructor';
    return Scaffold(
      appBar: AppBar(
        title: Text(course.title ?? "Course Details"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(Icons.article_outlined, "Description"),
            const SizedBox(height: 10),
            Text(
              course.description?.isNotEmpty == true
                  ? course.description!
                  : "No description available for this course.",
              style: const TextStyle(
                fontSize: 16,
                color: AppColorsDark.secondaryText,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 25),
            const Divider(),
            _buildDetailItem(
              icon: Icons.category_outlined,
              title: "Category",
              value: course.category ?? "No category",
            ),
            const SizedBox(height: 20),
            _buildDetailItem(
              icon: Icons.attach_money_outlined,
              title: "Price",
              value: "\$${course.price ?? 0}",
              valueColor: AppColorsDark.accentBlue,
            ),
            const SizedBox(height: 25),
            const Divider(),
            if (course.instructor != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle(Icons.person_outline, "Instructor"),
                  const SizedBox(height: 10),
                  Text(
                    course.instructor!.name ?? "N/A",
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColorsDark.cardBackground,
                    ),
                  ),
                  Text(
                    course.instructor!.email ?? "N/A",
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColorsDark.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Divider(),
                ],
              ),
            _sectionTitle(Icons.play_circle_outline, "Videos"),
            const SizedBox(height: 10),
            if (course.videos != null && course.videos!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: course.videos!.map((video) {
                
                  final videoUrl = video?.toString() ?? '';

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: InkWell(
                      onTap: () {
                        if (videoUrl.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Video URL is empty")),
                          );
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VideoPlayerScreen(url: videoUrl),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[600],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          videoUrl
                              .split('/')
                              .last, 
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )
            else
              const Text(
                "No videos available yet.",
                style: TextStyle(
                  fontSize: 16,
                  color: AppColorsDark.secondaryText,
                ),
              ),
            const SizedBox(height: 25),
            const Divider(),
            _buildDetailItem(
              icon: Icons.people_outline,
              title: "Enrolled Students",
              value:
                  "${course.enrolledStudents?.length ?? 0} student(s) enrolled",
            ),
            const SizedBox(height: 25),
            _buildDetailItem(
              icon: Icons.access_time_outlined,
              title: "Created At",
              value: formatDate(course.createdAt),
            ),
            const SizedBox(height: 10),
            _buildDetailItem(
              icon: Icons.update,
              title: "Updated At",
              value: formatDate(course.updatedAt),
            ),
            if (!isInstructor) ...[
              const SizedBox(height: 40),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColorsDark.accentBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Enrolled successfully!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: const Text(
                      "Enroll Now",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppColorsDark.accentBlue, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColorsDark.primaryBackground,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColorsDark.accentBlue, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: valueColor ?? AppColorsDark.secondaryText,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
