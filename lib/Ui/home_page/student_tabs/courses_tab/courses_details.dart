// lib/src/ui/courses/student_tabs/courses_tab/courses_details.dart

import 'package:flutter/material.dart';
import 'package:codexa_mobile/Domain/entities/courses_entity.dart';
import 'package:codexa_mobile/Ui/utils/theme/app_colors.dart';
import 'package:codexa_mobile/Ui/utils/widgets/custom_home_tape_components.dart';

class CourseDetails extends StatelessWidget {
  final CourseEntity course;

  const CourseDetails({super.key, required this.course});

  String formatDate(String? date) {
    if (date == null) return "N/A";
    final dt = DateTime.tryParse(date);
    if (dt == null) return date;
    return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(course.title ?? "Course Details"),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DashboardCard(
              haveBanner: false,
              child: CourseProgressItem(
                title: course.title ?? "",
                categoryTitle: course.category ?? "No category",
                categoryPercentage: "${((course.progress?.length ?? 0) * 10)}%",
                progress: 0, 
                hasCategory: true,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Description",
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColorsDark.primaryText),
            ),
            const SizedBox(height: 10),
            Text(
              course.description ?? "No description available",
              style: const TextStyle(
                  fontSize: 16, color: AppColorsDark.secondaryText),
            ),
            const SizedBox(height: 20),
            if (course.instructor != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Instructor",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColorsDark.primaryText),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Name: ${course.instructor!.name ?? "N/A"}",
                    style: const TextStyle(
                        fontSize: 16, color: AppColorsDark.secondaryText),
                  ),
                  Text(
                    "Email: ${course.instructor!.email ?? "N/A"}",
                    style: const TextStyle(
                        fontSize: 16, color: AppColorsDark.secondaryText),
                  ),
                  const SizedBox(height: 20),
                ],
              ),

            // Price
            Text(
              "Price: \$${course.price ?? 0}",
              style: const TextStyle(
                  fontSize: 16, color: AppColorsDark.secondaryText),
            ),
            const SizedBox(height: 20),

            // Dates
            Text(
              "Created At: ${formatDate(course.createdAt)}",
              style: const TextStyle(
                  fontSize: 16, color: AppColorsDark.secondaryText),
            ),
            Text(
              "Updated At: ${formatDate(course.updatedAt)}",
              style: const TextStyle(
                  fontSize: 16, color: AppColorsDark.secondaryText),
            ),
            const SizedBox(height: 20),

            // Enroll Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColorsDark.accentBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  // هنا تضيف logic التسجيل في الكورس
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enrolled successfully!')),
                  );
                },
                child: const Text(
                  "Enroll",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
