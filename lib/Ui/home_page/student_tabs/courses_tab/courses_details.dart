import 'package:codexa_mobile/Domain/entities/courses_entity.dart';
import 'package:codexa_mobile/Ui/home_page/additional_screens/video_player_course.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_cubit/courses_student_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/enroll_cubit/enroll_courses_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/enroll_cubit/enroll_courses_state.dart';
import 'package:codexa_mobile/Ui/utils/provider_ui/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:codexa_mobile/Ui/utils/theme/app_colors.dart';

class CourseDetails extends StatefulWidget {
  final CourseEntity course;

  const CourseDetails({
    super.key,
    required this.course,
  });

  @override
  State<CourseDetails> createState() => _CourseDetailsState();
}

class _CourseDetailsState extends State<CourseDetails> {
  late CourseEntity _currentCourse;
  bool _isEnrolled = false;

  @override
  void initState() {
    super.initState();
    _currentCourse = widget.course;
    _checkEnrollmentStatus();
  }

  void _checkEnrollmentStatus() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = _getUserId(userProvider.user);

    if (userId != null && _currentCourse.enrolledStudents != null) {
      setState(() {
        _isEnrolled = _currentCourse.enrolledStudents!.contains(userId);
      });
    }
  }

  String? _getUserId(dynamic user) {
    if (user == null) return null;
    if (user is Map) return user['_id']?.toString() ?? user['id']?.toString();
    try {
      return (user as dynamic).id?.toString();
    } catch (_) {
      return null;
    }
  }

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
        title: Text(_currentCourse.title ?? "Course Details"),
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
              _currentCourse.description?.isNotEmpty == true
                  ? _currentCourse.description!
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
              value: _currentCourse.category ?? "No category",
            ),
            const SizedBox(height: 20),
            _buildDetailItem(
              icon: Icons.attach_money_outlined,
              title: "Price",
              value: "\$${_currentCourse.price ?? 0}",
              valueColor: AppColorsDark.accentBlue,
            ),
            const SizedBox(height: 20),
            _buildDetailItem(
              icon: Icons.stacked_bar_chart,
              title: "Level",
              value: _currentCourse.level ?? "N/A",
              valueColor: AppColorsDark.secondaryText,
            ),
            const SizedBox(height: 25),
            const Divider(),
            if (_currentCourse.instructor != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle(Icons.person_outline, "Instructor"),
                  const SizedBox(height: 10),
                  Text(
                    _currentCourse.instructor!.name ?? "N/A",
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColorsDark.cardBackground,
                    ),
                  ),
                  Text(
                    _currentCourse.instructor!.email ?? "N/A",
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
            if (_currentCourse.videos != null &&
                _currentCourse.videos!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _currentCourse.videos!.map((video) {
                  final v = video as Map<String, dynamic>;
                  final videoUrl = v['url'] ?? '';
                  final videoTitle = v['title'] ?? 'Untitled Video';

                  return _buildVideoItem(
                    videoTitle: videoTitle,
                    videoUrl: videoUrl,
                    isLocked: !_isEnrolled && !isInstructor,
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
                  "${_currentCourse.enrolledStudents?.length ?? 0} student(s) enrolled",
            ),
            const SizedBox(height: 25),
            _buildDetailItem(
              icon: Icons.access_time_outlined,
              title: "Created At",
              value: formatDate(_currentCourse.createdAt),
            ),
            const SizedBox(height: 10),
            _buildDetailItem(
              icon: Icons.update,
              title: "Updated At",
              value: formatDate(_currentCourse.updatedAt),
            ),
            if (!isInstructor && !_isEnrolled) ...[
              const SizedBox(height: 40),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: BlocConsumer<EnrollCubit, EnrollState>(
                    listener: (context, state) {
                      if (state is EnrollSuccess) {
                        // Update enrollment status
                        setState(() {
                          _isEnrolled = true;
                          // Update the course's enrolled students list
                          final userId = _getUserId(userProvider.user);
                          if (userId != null) {
                            _currentCourse = CourseEntity(
                              id: _currentCourse.id,
                              title: _currentCourse.title,
                              description: _currentCourse.description,
                              price: _currentCourse.price,
                              category: _currentCourse.category,
                              level: _currentCourse.level,
                              instructor: _currentCourse.instructor,
                              enrolledStudents: [
                                ...(_currentCourse.enrolledStudents ?? []),
                                userId
                              ],
                              videos: _currentCourse.videos,
                              progress: _currentCourse.progress,
                              createdAt: _currentCourse.createdAt,
                              updatedAt: _currentCourse.updatedAt,
                              v: _currentCourse.v,
                            );
                          }
                        });

                        // Refresh courses list
                        context.read<StudentCoursesCubit>().fetchCourses();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Enrolled successfully! Videos are now unlocked.'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else if (state is EnrollFailureState) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.errorMessage),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      final isLoading = state is EnrollLoading;
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColorsDark.accentBlue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: isLoading
                            ? null
                            : () {
                                final cubit = context.read<EnrollCubit>();
                                cubit.enroll(courseId: _currentCourse.id!);
                              },
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Enroll Now",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVideoItem({
    required String videoTitle,
    required String videoUrl,
    required bool isLocked,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isLocked ? Colors.grey.shade100 : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border:
            isLocked ? Border.all(color: Colors.grey.shade300, width: 1) : null,
        boxShadow: isLocked
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                )
              ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isLocked ? Colors.grey.shade400 : AppColorsDark.accentBlue,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isLocked ? Icons.lock_outline : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  videoTitle,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isLocked ? Colors.grey.shade600 : Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (isLocked) ...[
                  const SizedBox(height: 4),
                  Text(
                    "Enroll to unlock",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isLocked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "Locked",
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            )
          else
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorsDark.accentBlue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              onPressed: () {
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
              child: const Text(
                "Watch",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
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
