import 'package:codexa_mobile/Domain/entities/courses_entity.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/reviews_cubit/review_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/widgets/reviews_section.dart';
import 'package:codexa_mobile/Ui/utils/provider_ui/auth_provider.dart';
import 'package:codexa_mobile/core/di/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:codexa_mobile/localization/localization_service.dart';
import 'package:codexa_mobile/generated/l10n.dart' as generated;

// Widget imports
import 'widgets/course_detail_items.dart';
import 'widgets/video_item_card.dart';
import 'widgets/cart_action_button.dart';

class CourseDetailsWrapper extends StatelessWidget {
  final CourseEntity course;

  const CourseDetailsWrapper({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return CourseDetails(course: course);
  }
}

class CourseDetails extends StatefulWidget {
  final CourseEntity course;

  const CourseDetails({super.key, required this.course});

  @override
  State<CourseDetails> createState() => _CourseDetailsState();
}

class _CourseDetailsState extends State<CourseDetails> {
  late CourseEntity _currentCourse;
  bool _isEnrolled = false;
  late Locale _currentLocale;
  late generated.S _translations;

  @override
  void initState() {
    super.initState();
    _currentCourse = widget.course;
    _initializeLocalization();
    _checkEnrollmentStatus();
  }

  void _initializeLocalization() {
    // Get locale directly from LocalizationService
    final localizationService = LocalizationService();
    _currentLocale = localizationService.locale;
    _translations = generated.S(_currentLocale);
  }

  // Check if current locale is RTL
  bool _isRTL() {
    return _currentLocale.languageCode == 'ar';
  }

  void _checkEnrollmentStatus() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = _getUserId(userProvider.user);

    if (userId != null && _currentCourse.enrolledStudents != null) {
      setState(() =>
      _isEnrolled = _currentCourse.enrolledStudents!.contains(userId));
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
    if (date == null) return _translations.notAvailable;
    final dt = DateTime.tryParse(date);
    if (dt == null) return date;

    // Format based on locale
    if (_isRTL()) {
      // Arabic/Islamic date format for RTL
      return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
    } else {
      // Default format for LTR
      return "${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}/${dt.year}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isInstructor = userProvider.role == 'instructor';
    final theme = Theme.of(context);
    final isRTL = _isRTL();

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentCourse.title ?? _translations.courseDetails),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: theme.colorScheme.onBackground,
      ),
      bottomNavigationBar: (isInstructor || _isEnrolled)
          ? null
          : CartActionButton(
        course: _currentCourse,
        translations: _translations,
      ),
      body: Directionality(
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Description Section
              SectionTitle(
                icon: Icons.article_outlined,
                title: _translations.description,
                isRTL: isRTL,
              ),
              const SizedBox(height: 10),
              Text(
                _currentCourse.description?.isNotEmpty == true
                    ? _currentCourse.description!
                    : _translations.noDescriptionAvailable,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.iconTheme.color,
                  height: 1.6,
                ),
                textAlign: isRTL ? TextAlign.right : TextAlign.left,
                textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
              ),
              const SizedBox(height: 25),
              const Divider(),

              // Detail Items
              DetailItem(
                icon: Icons.category_outlined,
                title: _translations.category,
                value: _currentCourse.category ?? _translations.noCategory,
                isRTL: isRTL,
              ),
              const SizedBox(height: 20),
              DetailItem(
                icon: Icons.attach_money_outlined,
                title: _translations.price,
                value: "\$${_currentCourse.price ?? 0}",
                valueColor: theme.progressIndicatorTheme.color,
                isRTL: isRTL,
              ),
              const SizedBox(height: 20),
              DetailItem(
                icon: Icons.stacked_bar_chart,
                title: _translations.level,
                value: _currentCourse.level ?? _translations.notAvailable,
                valueColor: theme.iconTheme.color,
                isRTL: isRTL,
              ),
              const SizedBox(height: 25),
              const Divider(),

              // Instructor Section
              if (_currentCourse.instructor != null)
                _buildInstructorSection(theme, isInstructor, userProvider, isRTL),

              // Videos Section
              SectionTitle(
                icon: Icons.play_circle_outline,
                title: _translations.videos,
                isRTL: isRTL,
              ),
              const SizedBox(height: 10),
              _buildVideosSection(theme, isInstructor, isRTL),
              const SizedBox(height: 25),
              const Divider(),

              // Enrolled Students
              DetailItem(
                icon: Icons.people_outline,
                title: _translations.enrolledStudents,
                value:
                "${_currentCourse.enrolledStudents?.length ?? 0} ${_translations.students}",
                isRTL: isRTL,
              ),
              const SizedBox(height: 25),

              // Dates
              DetailItem(
                icon: Icons.access_time_outlined,
                title: _translations.createdAt,
                value: formatDate(_currentCourse.createdAt),
                isRTL: isRTL,
              ),
              const SizedBox(height: 10),
              DetailItem(
                icon: Icons.update,
                title: _translations.updatedAt,
                value: formatDate(_currentCourse.updatedAt),
                isRTL: isRTL,
              ),
              const SizedBox(height: 30),
              const Divider(),

              // Course Reviews Section
              const SizedBox(height: 20),
              Text(
                _translations.courseReviews,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.iconTheme.color,
                ),
                textAlign: isRTL ? TextAlign.right : TextAlign.left,
                textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
              ),
              const SizedBox(height: 10),
              BlocProvider(
                create: (_) => sl<ReviewCubit>(),
                child: ReviewsSection(
                  itemId: _currentCourse.id ?? '',
                  itemType: 'Course',
                  isInstructor: isInstructor,
                  isEnrolled: _isEnrolled,
                  currentUserId: _getUserId(userProvider.user),
                  theme: theme,
                  translations: _translations,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructorSection(
      ThemeData theme, bool isInstructor, UserProvider userProvider, bool isRTL) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          icon: Icons.person_outline,
          title: _translations.instructor,
          isRTL: isRTL,
        ),
        const SizedBox(height: 10),
        Text(
          _currentCourse.instructor!.name ?? _translations.notAvailable,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.iconTheme.color,
          ),
          textAlign: isRTL ? TextAlign.right : TextAlign.left,
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        ),
        Text(
          _currentCourse.instructor!.email ?? _translations.notAvailable,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.iconTheme.color,
          ),
          textAlign: isRTL ? TextAlign.right : TextAlign.left,
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        ),
        const SizedBox(height: 10),
        // Instructor Reviews Expansion Tile
        Card(
          elevation: 0,
          color: theme.dividerTheme.color?.withOpacity(0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: theme.dividerTheme.color!.withOpacity(0.2)),
          ),
          child: Directionality(
            textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
            child: ExpansionTile(
              leading: Icon(Icons.star_rate_rounded, color: Colors.amber),
              title: Text(
                _translations.instructorReviews,
                textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: BlocProvider(
                    create: (_) => sl<ReviewCubit>(),
                    child: ReviewsSection(
                      itemId: _currentCourse.instructor!.id ?? '',
                      itemType: 'Instructor',
                      isInstructor: isInstructor,
                      isEnrolled: _isEnrolled,
                      currentUserId: _getUserId(userProvider.user),
                      theme: theme,
                      translations: _translations,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 25),
        const Divider(),
      ],
    );
  }

  Widget _buildVideosSection(ThemeData theme, bool isInstructor, bool isRTL) {
    if (_currentCourse.videos != null && _currentCourse.videos!.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _currentCourse.videos!.map((video) {
          final v = video as Map<String, dynamic>;
          final videoUrl = v['url'] ?? '';
          final videoTitle = v['title'] ?? _translations.untitledVideo;

          return VideoItemCard(
            videoTitle: videoTitle,
            videoUrl: videoUrl,
            isLocked: !_isEnrolled && !isInstructor,
            translations: _translations,
          );
        }).toList(),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Text(
          _translations.noVideosAvailable,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.iconTheme.color),
          textAlign: isRTL ? TextAlign.center : TextAlign.center,
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        ),
      ),
    );
  }
}
