import 'package:codexa_mobile/Domain/entities/community_entity.dart';
import 'package:codexa_mobile/Domain/entities/courses_entity.dart';
import 'package:codexa_mobile/Domain/entities/student_entity.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/community_tab/community_tab_cubit/posts_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/community_tab/community_tab_states/posts_state.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/courses_tab/create_course.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/courses_tab/upload_courses_cubit/upload_instructor_courses_state.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/courses_tab/upload_courses_cubit/upload_instructors_courses_cubit.dart';
import 'package:codexa_mobile/Ui/utils/widgets/custom_button.dart';
import 'package:codexa_mobile/Ui/utils/widgets/custom_course_progress_instructor.dart';
import 'package:codexa_mobile/Ui/utils/widgets/custom_home_tape_components.dart';
import 'package:codexa_mobile/Ui/utils/widgets/recent_activity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;

// Model for community activity (post or comment)
class ActivityItemModel {
  final String userName;
  final String action;
  final String message;
  final DateTime timestamp;
  final String profileImage;

  ActivityItemModel({
    required this.userName,
    required this.action,
    required this.message,
    required this.timestamp,
    required this.profileImage,
  });
}

// Model for recent enrollment displayed in instructor home tab
class EnrollmentActivityModel {
  final String studentName;
  final String? studentImage; // URL or asset path
  final String courseTitle;
  final DateTime? enrolledAt; // Nullable to handle missing timestamps

  EnrollmentActivityModel({
    required this.studentName,
    this.studentImage,
    required this.courseTitle,
    this.enrolledAt,
  });
}

class HomeTabInstructor extends StatelessWidget {
  const HomeTabInstructor({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<InstructorCoursesCubit, InstructorCoursesState>(
      builder: (context, coursesState) {
        // Loading state
        if (coursesState is InstructorCoursesLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        // Error state
        if (coursesState is InstructorCoursesError) {
          return Center(
            child: Text(
              'Error: ${coursesState.message}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        // Loaded state
        if (coursesState is InstructorCoursesLoaded) {
          final courses = coursesState.courses;
          final activeCoursesCount = courses.length;
          final totalStudents = courses.fold<int>(
            0,
            (prev, course) => prev + (course.enrolledStudents?.length ?? 0),
          );
          final lastTwoCourses = courses.length >= 2
              ? courses.sublist(courses.length - 2)
              : courses;

          // Recent enrollments list
          final recentEnrollments = _getRecentEnrollments(courses);

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dashboard stats
                  Text(
                    "Dashboard",
                    style: TextStyle(
                      color: theme.iconTheme.color,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StatBox(
                          title: "$activeCoursesCount",
                          subtitle: "Active Course"),
                      const SizedBox(width: 10),
                      StatBox(
                          title: "$totalStudents", subtitle: "All Students"),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // My Courses section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "My Courses",
                        style: TextStyle(
                            color: theme.iconTheme.color, fontSize: 16),
                      ),
                      Icon(Icons.more_vert, color: theme.iconTheme.color),
                    ],
                  ),
                  const SizedBox(height: 5),
                  if (lastTwoCourses.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        "No courses created yet.",
                        style: TextStyle(color: theme.iconTheme.color),
                      ),
                    ),
                  ...lastTwoCourses.map((course) => Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: CourseProgressCard(
                          title: course.title ?? '',
                          students: course.enrolledStudents?.length ?? 0,
                          progress: 0.0,
                        ),
                      )),
                  const SizedBox(height: 5),
                  CustomButton(
                    text: "Create new Course",
                    onPressed: () {
                      final cubit = context.read<InstructorCoursesCubit>();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: cubit,
                            child: AddEditCourseScreen(cubit: cubit),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 25),
                  // Recent Activity (Enrollments)
                  DashboardCard(
                    title: "Recent Activity",
                    child: recentEnrollments.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "No recent enrollments.",
                              style: TextStyle(color: theme.iconTheme.color),
                            ),
                          )
                        : Column(
                            children: recentEnrollments.map((activity) {
                              // Determine time display - show "Recently" if timestamp is missing
                              final timeDisplay = activity.enrolledAt != null
                                  ? timeago.format(activity.enrolledAt!)
                                  : "Recently";

                              return Column(
                                children: [
                                  RecentActivityItem(
                                    action: "enrolled in",
                                    avatarImg: activity.studentImage,
                                    name: activity.studentName,
                                    subject: activity.courseTitle,
                                    timeAgo: timeDisplay,
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              );
                            }).toList(),
                          ),
                  ),
                  const SizedBox(height: 10),
                  // Community Activity (global feed)
                  DashboardCard(
                    title: "Community Activity",
                    child:
                        BlocBuilder<CommunityPostsCubit, CommunityPostsState>(
                      builder: (context, state) {
                        if (state is CommunityPostsLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (state is CommunityPostsLoaded) {
                          final allActivities =
                              _aggregateActivities(state.posts);
                          if (allActivities.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "No community activity yet.",
                                style: TextStyle(color: theme.iconTheme.color),
                              ),
                            );
                          }
                          final displayActivities =
                              allActivities.take(5).toList();
                          return Column(
                            children: displayActivities.map((activity) {
                              return Column(
                                children: [
                                  CommunityItem(
                                    name: activity.userName,
                                    action: activity.action,
                                    message: activity.message,
                                    time: timeago.format(activity.timestamp),
                                    profileImage: activity.profileImage ?? "",
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              );
                            }).toList(),
                          );
                        } else if (state is CommunityPostsError) {
                          return const Text("Failed to load activity");
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        // Fallback when no state matches
        return const SizedBox.shrink();
      },
    );
  }

  // Helper to extract recent enrollments from courses list
  List<EnrollmentActivityModel> _getRecentEnrollments(
      List<CourseEntity> courses) {
    final List<EnrollmentActivityModel> enrollments = [];

    for (var course in courses) {
      final enrolledStudents = course.enrolledStudents ?? [];

      for (var studentData in enrolledStudents) {
        StudentEntity? student;
        DateTime? enrolledAt;

        // Parse student data from API
        if (studentData is Map<String, dynamic>) {
          // Skip if student has no name
          if (studentData['name'] == null ||
              studentData['name'].toString().isEmpty) {
            continue;
          }

          student = StudentEntity(
            id: studentData['_id'],
            name: studentData['name'],
            email: studentData['email'],
            profileImage: studentData['profileImage'],
            role: studentData['role'],
            isAdmin: studentData['isAdmin'],
            isActive: studentData['isActive'],
            emailVerified: studentData['emailVerified'],
            authProvider: studentData['authProvider'],
            token: studentData['token'],
          );

          // Try to get enrollment timestamp from student data
          if (studentData['enrolledAt'] != null) {
            enrolledAt =
                DateTime.tryParse(studentData['enrolledAt'].toString());
          }
        } else if (studentData is StudentEntity) {
          student = studentData;
        }

        // Only add valid students with names
        if (student != null &&
            student.name != null &&
            student.name!.isNotEmpty) {
          // Use enrollment timestamp, or fallback to course updatedAt, then createdAt
          enrolledAt ??= DateTime.tryParse(course.updatedAt ?? '') ??
              DateTime.tryParse(course.createdAt ?? '');

          enrollments.add(EnrollmentActivityModel(
            studentName: student.name!,
            studentImage: student.profileImage,
            courseTitle: course.title ?? "Course",
            enrolledAt: enrolledAt, // Can be null, will show "Recently"
          ));
        }
      }
    }

    // Sort by most recent first (treat null as now for sorting)
    enrollments.sort((a, b) {
      final aTime = a.enrolledAt ?? DateTime.now();
      final bTime = b.enrolledAt ?? DateTime.now();
      return bTime.compareTo(aTime);
    });

    // Return last 3 enrollments
    return enrollments.take(3).toList();
  }

  // Helper to aggregate community posts and comments
  List<ActivityItemModel> _aggregateActivities(List<CommunityEntity> posts) {
    final List<ActivityItemModel> activities = [];
    for (var post in posts) {
      final postTime =
          DateTime.tryParse(post.createdAt ?? "") ?? DateTime.now();
      final authorName = post.author?.name ?? "Unknown User";
      // Post activity
      activities.add(ActivityItemModel(
        userName: authorName,
        action: "posted",
        message: post.content ?? "No content",
        timestamp: postTime,
        profileImage: post.author?.profileImage ?? "",
      ));
      // Comment activities
      if (post.comments != null) {
        for (var comment in post.comments!) {
          final commentTime =
              DateTime.tryParse(comment.createdAt ?? "") ?? postTime;
          activities.add(ActivityItemModel(
            userName: comment.user?.name ?? "Unknown User",
            action: "commented on $authorName's post",
            message: comment.text ?? "",
            timestamp: commentTime,
            profileImage: comment.user?.profileImage ?? "",
          ));
        }
      }
    }
    activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return activities;
  }
}
