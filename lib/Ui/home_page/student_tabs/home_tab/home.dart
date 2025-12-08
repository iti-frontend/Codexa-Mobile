import 'package:codexa_mobile/Domain/entities/community_entity.dart';
import 'package:codexa_mobile/Domain/entities/courses_entity.dart';
import 'package:codexa_mobile/Ui/home_page/home_screen/community_tab/cubits/posts_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/home_screen/community_tab/states/posts_state.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_cubit/courses_student_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_cubit/courses_student_states.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_details.dart';
import 'package:codexa_mobile/Ui/utils/provider_ui/auth_provider.dart';
import 'package:codexa_mobile/Ui/utils/widgets/custom_home_tape_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:codexa_mobile/localization/localization_service.dart';
import 'package:codexa_mobile/generated/l10n.dart' as generated;
import 'package:codexa_mobile/Ui/utils/widgets/course_card_skeleton.dart';
import 'package:codexa_mobile/Ui/utils/widgets/skeleton_shimmer.dart';

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

class HomeStudentTab extends StatefulWidget {
  const HomeStudentTab({super.key});

  @override
  State<HomeStudentTab> createState() => _HomeStudentTabState();
}

class _HomeStudentTabState extends State<HomeStudentTab> {
  late LocalizationService _localizationService;
  late generated.S _translations;

  @override
  void initState() {
    super.initState();
    _initializeLocalization();
  }

  void _initializeLocalization() {
    _localizationService = LocalizationService();
    _translations = generated.S(_localizationService.locale);
    _localizationService.addListener(_onLocaleChanged);
  }

  void _onLocaleChanged() {
    if (mounted) {
      setState(() {
        _translations = generated.S(_localizationService.locale);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProvider = Provider.of<UserProvider>(context);
    final userId = _getUserId(userProvider.user);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _translations.dashboard,
            style: TextStyle(color: theme.iconTheme.color),
          ),
          const SizedBox(height: 16),

          // ================== Course Progress Section ==================
          DashboardCard(
            title: _translations.courseProgress,
            child: BlocBuilder<StudentCoursesCubit, StudentCoursesState>(
              builder: (context, state) {
                if (state is StudentCoursesLoading) {
                  return const DashboardContentSkeleton(itemCount: 3);
                } else if (state is StudentCoursesLoaded) {
                  final courses = state.courses;

                  // Filter for enrolled courses
                  final enrolledCourses = courses.where((course) {
                    if (userId == null) return false;
                    return course.enrolledStudents?.contains(userId) ?? false;
                  }).toList();

                  if (enrolledCourses.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(_translations.noCoursesEnrolledYet,
                          style: TextStyle(color: theme.iconTheme.color)),
                    );
                  }

                  // Show top 3 enrolled courses
                  final displayCourses = enrolledCourses.take(3).toList();

                  return Column(
                    children: displayCourses.map((course) {
                      return Column(
                        children: [
                          CourseProgressItem(
                            instructorName: course.instructor?.name ??
                                _translations.unknownInstructor,
                            title: course.title ?? _translations.untitledCourse,
                            progress: _calculateProgress(course),
                          ),
                          const SizedBox(height: 12),
                        ],
                      );
                    }).toList(),
                  );
                }
                return const SizedBox();
              },
            ),
          ),

          // ================== Community Activity Section ==================
          DashboardCard(
            title: _translations.communityActivity,
            child: BlocBuilder<CommunityPostsCubit, CommunityPostsState>(
              builder: (context, state) {
                if (state is CommunityPostsLoading) {
                  return const DashboardContentSkeleton(itemCount: 5);
                } else if (state is CommunityPostsLoaded) {
                  final allActivities = _aggregateActivities(state.posts);

                  if (allActivities.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(_translations.noCommunityActivityYet,
                          style: TextStyle(color: theme.iconTheme.color)),
                    );
                  }

                  // Show latest 5 activities
                  final displayActivities = allActivities.take(5).toList();

                  return Column(
                    children: displayActivities.map((activity) {
                      return Column(
                        children: [
                          CommunityItem(
                            name: activity.userName,
                            profileImage: activity.profileImage,
                            action: _getTranslatedAction(activity.action),
                            message: activity.message,
                            time: _formatTimeAgo(activity.timestamp),
                          ),
                          const SizedBox(height: 10),
                        ],
                      );
                    }).toList(),
                  );
                } else if (state is CommunityPostsError) {
                  return Text(_translations.failedToLoadActivity);
                }
                return const SizedBox();
              },
            ),
          ),

          // ================== Skill Development Section ==================
          DashboardCard(
            title: _translations.skillDevelopment,
            child: BlocBuilder<StudentCoursesCubit, StudentCoursesState>(
              builder: (context, state) {
                if (state is StudentCoursesLoaded) {
                  final courses = state.courses;

                  // Filter for enrolled courses
                  final enrolledCourses = courses.where((course) {
                    if (userId == null) return false;
                    return course.enrolledStudents?.contains(userId) ?? false;
                  }).toList();

                  // Extract unique categories from enrolled courses only
                  final categories = enrolledCourses
                      .map((c) => c.title)
                      .where((c) => c != null && c.isNotEmpty)
                      .toSet()
                      .toList();

                  if (categories.isEmpty) {
                    return Text(_translations.enrollInCoursesToDevelopSkills,
                        style: TextStyle(color: theme.iconTheme.color));
                  }

                  return Wrap(
                    spacing: 10,
                    runSpacing: 5,
                    children: categories.map((title) {
                      // Calculate "progress" based on enrolled courses in this category
                      final count =
                          enrolledCourses.where((c) => c.title == title).length;
                      final progress = (count * 0.2).clamp(0.0, 1.0);
                      final level =
                          courses.where((c) => c.title == title).first.level;
                      return SkillCard(
                        title: title!,
                        level: level ?? "",
                        progress: progress,
                      );
                    }).toList(),
                  );
                }
                return const SizedBox();
              },
            ),
          ),

          // ================== Stats Section ==================
          BlocBuilder<StudentCoursesCubit, StudentCoursesState>(
            builder: (context, state) {
              int courseCount = 0;
              int learnersCount = 0;

              if (state is StudentCoursesLoaded) {
                courseCount = state.courses.length;
                learnersCount = 1000 + (courseCount * 50);
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatBox(
                    title: "${learnersCount}+",
                    subtitle: _translations.learners,
                  ),
                  const SizedBox(width: 10),
                  StatBox(
                    title: "$courseCount",
                    subtitle: _translations.courses,
                  ),
                  const SizedBox(width: 10),
                  StatBox(
                    title: "10K+",
                    subtitle: _translations.companies,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 16),

          // ================== Recommended Section ==================
          DashboardCard(
            title: _translations.recommendedForYou,
            child: BlocBuilder<StudentCoursesCubit, StudentCoursesState>(
              builder: (context, state) {
                if (state is StudentCoursesLoading) {
                  return const DelayedLoadingIndicator(
                    delay: Duration(milliseconds: 350),
                    placeholder: DashboardContentSkeleton(itemCount: 1),
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (state is StudentCoursesError) {
                  return Center(
                    child: Text(
                      '${_translations.error}: ${state.message}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                } else if (state is StudentCoursesLoaded) {
                  final courses = state.courses;

                  if (courses.isEmpty) {
                    return Center(child: Text(_translations.noCoursesFound));
                  }
                  final randomCourse = (courses..shuffle()).first;
                  return Row(
                    children: [
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              randomCourse.title ?? _translations.unknownCourse,
                              style: TextStyle(
                                color: theme.iconTheme.color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              randomCourse.description ??
                                  _translations.noDescriptionAvailable,
                              style: TextStyle(color: theme.iconTheme.color),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CourseDetailsWrapper(
                                          course: randomCourse),
                                    ));
                              },
                              child: Text(_translations.viewCourse),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  List<ActivityItemModel> _aggregateActivities(List<CommunityEntity> posts) {
    List<ActivityItemModel> activities = [];

    for (var post in posts) {
      final postTime =
          DateTime.tryParse(post.createdAt ?? "") ?? DateTime.now();
      final authorName = post.author?.name ?? _translations.unknownUser;

      // 1. Add Post Activity
      activities.add(ActivityItemModel(
        userName: authorName,
        action: "posted",
        message: post.content ?? _translations.noContent,
        timestamp: postTime,
        profileImage: post.author?.profileImage ?? "",
      ));

      // 2. Add Comment Activities
      if (post.comments != null) {
        for (var comment in post.comments!) {
          final commentTime =
              DateTime.tryParse(comment.createdAt ?? "") ?? postTime;
          activities.add(ActivityItemModel(
            userName: comment.user?.name ?? _translations.unknownUser,
            action: "commented on ${authorName}'s post",
            message: comment.text ?? "",
            timestamp: commentTime,
            profileImage: comment.user?.profileImage ?? "",
          ));
        }
      }
    }

    // Sort by timestamp descending
    activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return activities;
  }

  double _calculateProgress(CourseEntity course) {
    if (course.progress != null && course.progress is List) {
      return 0.0;
    }
    return 0.0;
  }

  // Format time ago with localization
  String _formatTimeAgo(DateTime dateTime) {
    final localeCode = _localizationService.locale.languageCode;

    if (localeCode == 'ar') {
      timeago.setLocaleMessages('ar', timeago.ArMessages());
    }

    return timeago.format(dateTime, locale: localeCode);
  }

  // Translate action text
  String _getTranslatedAction(String action) {
    if (action.contains("posted")) {
      return _translations.posted;
    } else if (action.contains("commented")) {
      return _translations.commentedOn;
    } else if (action.contains("enrolled")) {
      return _translations.enrolledIn;
    } else if (action.contains("liked")) {
      return _translations.liked;
    }
    return action;
  }

  @override
  void dispose() {
    _localizationService.removeListener(_onLocaleChanged);
    super.dispose();
  }
}
