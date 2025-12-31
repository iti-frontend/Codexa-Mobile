import 'package:codexa_mobile/Domain/entities/community_entity.dart';
import 'package:codexa_mobile/Domain/entities/courses_entity.dart';
import 'package:codexa_mobile/Ui/home_page/home_screen/community_tab/cubits/posts_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/home_screen/community_tab/states/posts_state.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/courses_tab/create_course.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/courses_tab/upload_courses_cubit/upload_instructor_courses_state.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/courses_tab/upload_courses_cubit/upload_instructors_courses_cubit.dart';
import 'package:codexa_mobile/Ui/utils/widgets/custom_button.dart';
import 'package:codexa_mobile/Ui/utils/widgets/custom_course_progress_instructor.dart';
import 'package:codexa_mobile/Ui/utils/widgets/custom_home_tape_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:codexa_mobile/localization/localization_service.dart';
import 'package:codexa_mobile/generated/l10n.dart' as generated;

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

class HomeTabInstructor extends StatefulWidget {
  const HomeTabInstructor({super.key});

  @override
  State<HomeTabInstructor> createState() => _HomeTabInstructorState();
}

class _HomeTabInstructorState extends State<HomeTabInstructor> {
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
              '${_translations.error}: ${coursesState.message}',
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

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dashboard stats
                  Text(
                    _translations.dashboard,
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
                          subtitle: _translations.activeCourses),
                      const SizedBox(width: 10),
                      StatBox(
                          title: "$totalStudents",
                          subtitle: _translations.allStudents),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // My Courses section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _translations.myCourses,
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
                        _translations.noCoursesCreated,
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
                    text: _translations.createNewCourse,
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
                  // Community Activity (global feed)
                  DashboardCard(
                    title: _translations.communityActivity,
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
                                _translations.noCommunityActivity,
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
                                    action:
                                        _getActionTranslation(activity.action),
                                    message: activity.message,
                                    time: _formatTimeAgo(activity.timestamp),
                                    profileImage: activity.profileImage,
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

  // Format time ago with localization support
  String _formatTimeAgo(DateTime dateTime) {
    // Initialize timeago with locale
    final localeCode = _localizationService.locale.languageCode;

    // Set locale for timeago
    if (localeCode == 'ar') {
      timeago.setLocaleMessages('ar', timeago.ArMessages());
    }

    return timeago.format(dateTime, locale: localeCode);
  }

  // Helper to get translated action text
  String _getActionTranslation(String action) {
    if (action.contains("posted")) {
      return _translations.posted;
    } else if (action.contains("commented")) {
      return _translations.commentedOn;
    } else if (action.contains("enrolled")) {
      return _translations.enrolledIn;
    }
    return action;
  }

  // Helper to aggregate community posts and comments
  List<ActivityItemModel> _aggregateActivities(List<CommunityEntity> posts) {
    final List<ActivityItemModel> activities = [];
    for (var post in posts) {
      final postTime =
          DateTime.tryParse(post.createdAt ?? "") ?? DateTime.now();
      final authorName = post.author?.name ?? _translations.unknownUser;
      // Post activity
      activities.add(ActivityItemModel(
        userName: authorName,
        action: "posted",
        message: post.content ?? _translations.noContent,
        timestamp: postTime,
        profileImage: post.author?.profileImage ?? "",
      ));
      // Comment activities
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
    activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return activities;
  }

  @override
  void dispose() {
    _localizationService.removeListener(_onLocaleChanged);
    super.dispose();
  }
}
