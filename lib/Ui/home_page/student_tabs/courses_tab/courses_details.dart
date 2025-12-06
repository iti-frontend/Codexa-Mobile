import 'package:codexa_mobile/Domain/entities/courses_entity.dart';
import 'package:codexa_mobile/Ui/home_page/additional_screens/video_player_course.dart';
import 'package:codexa_mobile/Ui/home_page/cart_feature/cubit/cart_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/cart_feature/cubit/cart_state.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/reviews_cubit/review_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/widgets/reviews_section.dart';
import 'package:codexa_mobile/Ui/utils/provider_ui/auth_provider.dart';
import 'package:codexa_mobile/core/di/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:codexa_mobile/localization/localization_service.dart';
import 'package:codexa_mobile/generated/l10n.dart' as generated;
import 'package:codexa_mobile/Ui/utils/theme/app_colors.dart';

class CourseDetailsWrapper extends StatelessWidget {
  final CourseEntity course;

  const CourseDetailsWrapper({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    // Removed shared ReviewCubit to allow separate instances for Course and Instructor
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
  late LocalizationService _localizationService;
  late generated.S _translations;

  @override
  void initState() {
    super.initState();
    _currentCourse = widget.course;
    _initializeLocalization();
    _checkEnrollmentStatus();
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
    return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
  }

  @override
  void dispose() {
    _localizationService.removeListener(_onLocaleChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isInstructor = userProvider.role == 'instructor';
    final theme = Theme.of(context);
    final isRTL = _localizationService.isRTL();

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_currentCourse.title ?? _translations.courseDetails),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: theme.colorScheme.onBackground,
        ),
        bottomNavigationBar: (isInstructor || _isEnrolled)
            ? null
            : Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: BlocConsumer<CartCubit, CartState>(
                    listener: (context, state) {
                      if (state is AddToCartSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else if (state is AddToCartError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } else if (state is RemoveFromCartSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      } else if (state is RemoveFromCartError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } else if (state is CartError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      final cubit = context.read<CartCubit>();
                      final isInCart = cubit.currentCart?.items?.any(
                              (item) => item.courseId == _currentCourse.id) ??
                          false;

                      if (state is CartLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return ElevatedButton(
                        onPressed: () {
                          if (_currentCourse.id != null) {
                            if (isInCart) {
                              cubit.removeFromCart(_currentCourse.id!);
                            } else {
                              cubit.addToCart(_currentCourse.id!);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isInCart
                              ? Colors.red
                              : (theme.brightness == Brightness.dark
                                  ? AppColorsDark.accentGreen
                                  : AppColorsLight.accentBlue),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isInCart
                                  ? Icons.remove_shopping_cart
                                  : Icons.add_shopping_cart,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isInCart
                                  ? _translations.removeFromCart
                                  : _translations.addToCart,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              _sectionTitle(Icons.article_outlined, _translations.description,
                  theme, isRTL),
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
              ),
              const SizedBox(height: 25),
              const Divider(),
              _buildDetailItem(
                  Icons.category_outlined,
                  _translations.category,
                  _currentCourse.category ?? _translations.noCategory,
                  theme,
                  isRTL),
              const SizedBox(height: 20),
              _buildDetailItem(Icons.attach_money_outlined, _translations.price,
                  "\$${_currentCourse.price ?? 0}", theme, isRTL,
                  valueColor: theme.progressIndicatorTheme.color),
              const SizedBox(height: 20),
              _buildDetailItem(
                  Icons.stacked_bar_chart,
                  _translations.level,
                  _currentCourse.level ?? _translations.notAvailable,
                  theme,
                  isRTL,
                  valueColor: theme.iconTheme.color),
              const SizedBox(height: 25),
              const Divider(),

              // Instructor Section
              if (_currentCourse.instructor != null)
                Column(
                  crossAxisAlignment:
                      isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    _sectionTitle(Icons.person_outline,
                        _translations.instructor, theme, isRTL),
                    const SizedBox(height: 10),
                    Text(
                      _currentCourse.instructor!.name ??
                          _translations.notAvailable,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.iconTheme.color,
                      ),
                      textAlign: isRTL ? TextAlign.right : TextAlign.left,
                    ),
                    Text(
                      _currentCourse.instructor!.email ??
                          _translations.notAvailable,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.iconTheme.color),
                      textAlign: isRTL ? TextAlign.right : TextAlign.left,
                    ),
                    const SizedBox(height: 10),
                    // Instructor Reviews Expansion Tile
                    Card(
                      elevation: 0,
                      color: theme.dividerTheme.color?.withOpacity(0.05),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                            color: theme.dividerTheme.color!.withOpacity(0.2)),
                      ),
                      child: ExpansionTile(
                        leading:
                            Icon(Icons.star_rate_rounded, color: Colors.amber),
                        title: Text("Instructor Reviews"),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: BlocProvider(
                              create: (_) => sl<ReviewCubit>(),
                              child: ReviewsSection(
                                itemId: _currentCourse.instructor!.id ?? '',
                                itemType: 'Instructor',
                                isInstructor: isInstructor,
                                currentUserId: _getUserId(userProvider.user),
                                theme: theme,
                                isRTL: isRTL,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Divider(),
                  ],
                ),
              _sectionTitle(Icons.play_circle_outline, _translations.videos,
                  theme, isRTL),
              const SizedBox(height: 10),
              if (_currentCourse.videos != null &&
                  _currentCourse.videos!.isNotEmpty)
                Column(
                  crossAxisAlignment:
                      isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: _currentCourse.videos!.map((video) {
                    final v = video as Map<String, dynamic>;
                    final videoUrl = v['url'] ?? '';
                    final videoTitle =
                        v['title'] ?? _translations.untitledVideo;

                    return _buildVideoItem(
                      videoTitle: videoTitle,
                      videoUrl: videoUrl,
                      isLocked: !_isEnrolled && !isInstructor,
                      theme: theme,
                      isRTL: isRTL,
                    );
                  }).toList(),
                )
              else
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      _translations.noVideosAvailable,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.iconTheme.color),
                      textAlign: isRTL ? TextAlign.right : TextAlign.center,
                    ),
                  ),
                ),
              const SizedBox(height: 25),
              const Divider(),
              _buildDetailItem(
                  Icons.people_outline,
                  _translations.enrolledStudents,
                  "${_currentCourse.enrolledStudents?.length ?? 0} ${_translations.students}",
                  theme,
                  isRTL),
              const SizedBox(height: 25),
              _buildDetailItem(
                  Icons.access_time_outlined,
                  _translations.createdAt,
                  formatDate(_currentCourse.createdAt),
                  theme,
                  isRTL),
              const SizedBox(height: 10),
              _buildDetailItem(Icons.update, _translations.updatedAt,
                  formatDate(_currentCourse.updatedAt), theme, isRTL),
              const SizedBox(height: 20),

              // Course Reviews Section
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 20),
              Text(
                "Course Reviews",
                style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold, color: theme.iconTheme.color),
              ),
              const SizedBox(height: 10),
              BlocProvider(
                create: (_) => sl<ReviewCubit>(),
                child: ReviewsSection(
                  itemId: _currentCourse.id ?? '',
                  itemType: 'Course',
                  isInstructor: isInstructor,
                  currentUserId: _getUserId(userProvider.user),
                  theme: theme,
                  isRTL: isRTL,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoItem({
    required String videoTitle,
    required String videoUrl,
    required bool isLocked,
    required ThemeData theme,
    required bool isRTL,
  }) {
    return Card(
      elevation: isLocked ? 0 : 2,
      color: isLocked
          ? theme.dividerTheme.color?.withOpacity(0.1)
          : theme.cardTheme.color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isLocked
              ? theme.dividerTheme.color?.withOpacity(0.2)
              : theme.progressIndicatorTheme.color?.withOpacity(0.1),
          child: Icon(
            isLocked ? Icons.lock_outline : Icons.play_arrow_rounded,
            color: isLocked
                ? theme.dividerTheme.color
                : theme.progressIndicatorTheme.color,
          ),
        ),
        title: Text(
          videoTitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: theme.iconTheme.color),
          textAlign: isRTL ? TextAlign.right : TextAlign.left,
        ),
        subtitle: isLocked
            ? Text(
                _translations.enrollToUnlock,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: theme.iconTheme.color?.withOpacity(0.6),
                ),
                textAlign: isRTL ? TextAlign.right : TextAlign.left,
              )
            : null,
        trailing: isLocked
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.progressIndicatorTheme.color?.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color:
                        theme.progressIndicatorTheme.color?.withOpacity(0.3) ??
                            Colors.blue,
                  ),
                ),
                child: Text(
                  _translations.locked,
                  style: TextStyle(
                    color: theme.progressIndicatorTheme.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.progressIndicatorTheme.color,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  if (videoUrl.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(_translations.videoUrlEmpty)),
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
                child: Text(
                  _translations.watch,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _sectionTitle(
      IconData icon, String title, ThemeData theme, bool isRTL) {
    return Row(
      children: isRTL
          ? [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.iconTheme.color,
                ),
              ),
              const SizedBox(width: 8),
              Icon(icon, color: theme.progressIndicatorTheme.color, size: 22),
            ]
          : [
              Icon(icon, color: theme.progressIndicatorTheme.color, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.iconTheme.color,
                ),
              ),
            ],
    );
  }

  Widget _buildDetailItem(
      IconData icon, String title, String value, ThemeData theme, bool isRTL,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        children: isRTL
            ? [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: theme.iconTheme.color,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 16,
                          color: valueColor ?? theme.iconTheme.color,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(icon, color: theme.progressIndicatorTheme.color, size: 22),
              ]
            : [
                Icon(icon, color: theme.progressIndicatorTheme.color, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: theme.iconTheme.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 16,
                          color: valueColor ?? theme.iconTheme.color,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
      ),
    );
  }
}
