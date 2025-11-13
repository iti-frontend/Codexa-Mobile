import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'package:codexa_mobile/Domain/entities/courses_entity.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/enroll_cubit/enroll_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/enroll_cubit/enroll_states.dart';
import 'package:codexa_mobile/Ui/utils/theme/app_colors.dart';
import 'package:codexa_mobile/Ui/utils/widgets/custom_home_tape_components.dart';
import 'package:codexa_mobile/Ui/utils/provider_ui/auth_provider.dart';

class CourseDetails extends StatelessWidget {
  final CourseEntity course;

  const CourseDetails({super.key, required this.course});

  String formatDate(String? date) {
    if (date == null) return "N/A";
    final dt = DateTime.tryParse(date);
    if (dt == null) return date;
    return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} "
        "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.token ?? '';

    return BlocConsumer<EnrollCubit, EnrollState>(
      listener: (context, state) {
        if (state is EnrollSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Enrolled successfully!')),
          );
        } else if (state is EnrollFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: ${state.errorMessage}')),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(course.title ?? "Course Details"),
            backgroundColor: Colors.transparent,
            elevation: 0,
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
                    categoryPercentage:
                        "${((course.progress?.length ?? 0) * 10)}%",
                    progress: 0,
                    hasCategory: true,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Description",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColorsDark.primaryText,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  course.description ?? "No description available",
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColorsDark.secondaryText,
                  ),
                ),
                const SizedBox(height: 20),
                if (course.instructor != null) ...[
                  const Text(
                    "Instructor",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColorsDark.primaryText,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Name: ${course.instructor!.name ?? "N/A"}",
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColorsDark.secondaryText,
                    ),
                  ),
                  Text(
                    "Email: ${course.instructor!.email ?? "N/A"}",
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColorsDark.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                Text(
                  "Price: \$${course.price ?? 0}",
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColorsDark.secondaryText,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Created At: ${formatDate(course.createdAt)}",
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColorsDark.secondaryText,
                  ),
                ),
                Text(
                  "Updated At: ${formatDate(course.updatedAt)}",
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColorsDark.secondaryText,
                  ),
                ),
                const SizedBox(height: 20),
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
                    onPressed: state is EnrollLoading
                        ? null
                        : () {
                            context.read<EnrollCubit>().enroll(
                                  token: token,
                                  courseId: course.id!,
                                );
                          },
                    child: state is EnrollLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Enroll",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
