import 'package:flutter/material.dart';

import 'package:codexa_mobile/Domain/entities/courses_entity.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_details.dart';
import 'package:codexa_mobile/generated/l10n.dart' as generated;

/// Horizontal scrollable list of enrolled courses
class EnrolledCoursesSection extends StatelessWidget {
  final List<CourseEntity> enrolledCourses;
  final bool isRTL;
  final generated.S translations;

  const EnrolledCoursesSection({
    Key? key,
    required this.enrolledCourses,
    required this.isRTL,
    required this.translations,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (enrolledCourses.isEmpty) {
      return _buildEmptyState(theme);
    }

    return Column(
      crossAxisAlignment:
          isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(theme),
        const SizedBox(height: 16),
        SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            reverse: isRTL,
            itemCount: enrolledCourses.length,
            itemBuilder: (context, index) {
              final course = enrolledCourses[index];
              return _EnrolledCourseCard(
                course: course,
                isRTL: isRTL,
                translations: translations,
              );
            },
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Column(
      crossAxisAlignment:
          isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(theme),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.iconTheme.color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              translations.noCoursesEnrolledYet,
              style: TextStyle(
                color: theme.dividerTheme.color,
                fontSize: 14,
              ),
              textAlign: isRTL ? TextAlign.right : TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildSectionTitle(ThemeData theme) {
    return Container(
      width: double.infinity,
      child: Text(
        translations.myCourses,
        style: TextStyle(
          color: theme.iconTheme.color,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        textAlign: isRTL ? TextAlign.right : TextAlign.left,
      ),
    );
  }
}

/// Single enrolled course card
class _EnrolledCourseCard extends StatelessWidget {
  final CourseEntity course;
  final bool isRTL;
  final generated.S translations;

  const _EnrolledCourseCard({
    required this.course,
    required this.isRTL,
    required this.translations,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final coverImageUrl = course.coverImage?['url'] as String?;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CourseDetailsWrapper(course: course),
          ),
        );
      },
      child: Container(
        width: 280,
        margin: EdgeInsets.only(
          right: isRTL ? 0 : 16,
          left: isRTL ? 16 : 0,
        ),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Cover Image
            if (coverImageUrl != null && coverImageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.network(
                  coverImageUrl,
                  height: 80,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 80,
                      width: double.infinity,
                      color:
                          theme.progressIndicatorTheme.color?.withOpacity(0.2),
                      child: Icon(
                        Icons.image,
                        size: 32,
                        color: theme.progressIndicatorTheme.color,
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                height: 80,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.progressIndicatorTheme.color?.withOpacity(0.2),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Icon(
                  Icons.school,
                  size: 32,
                  color: theme.progressIndicatorTheme.color,
                ),
              ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment:
                      isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    // Category badge
                    if (course.category != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.progressIndicatorTheme.color,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          course.category!,
                          style: TextStyle(
                            color: theme.iconTheme.color,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: isRTL ? TextAlign.right : TextAlign.left,
                        ),
                      ),
                    const SizedBox(height: 6),
                    // Course title
                    Text(
                      course.title ?? translations.untitledCourse,
                      style: TextStyle(
                        color: theme.iconTheme.color,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: isRTL ? TextAlign.right : TextAlign.left,
                    ),
                    const SizedBox(height: 4),
                    // Instructor name
                    _buildInstructorRow(theme),
                    const Spacer(),
                    // Continue learning button
                    _buildContinueButton(theme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructorRow(ThemeData theme) {
    return Row(
      children: isRTL
          ? [
              Expanded(
                child: Text(
                  course.instructor?.name ?? translations.unknownInstructor,
                  style: TextStyle(
                    color: theme.dividerTheme.color,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.person_outline,
                size: 16,
                color: theme.dividerTheme.color,
              ),
            ]
          : [
              Icon(
                Icons.person_outline,
                size: 16,
                color: theme.dividerTheme.color,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  course.instructor?.name ?? translations.unknownInstructor,
                  style: TextStyle(
                    color: theme.dividerTheme.color,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                ),
              ),
            ],
    );
  }

  Widget _buildContinueButton(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: theme.progressIndicatorTheme.color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          translations.continueLearning,
          style: TextStyle(
            color: theme.iconTheme.color,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
