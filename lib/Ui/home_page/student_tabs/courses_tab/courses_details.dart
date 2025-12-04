import 'package:codexa_mobile/Domain/entities/courses_entity.dart';
import 'package:codexa_mobile/Ui/home_page/additional_screens/video_player_course.dart';
import 'package:codexa_mobile/Ui/home_page/cart_feature/cubit/cart_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/cart_feature/cubit/cart_state.dart';
import 'package:codexa_mobile/Ui/utils/provider_ui/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

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
    if (date == null) return "N/A";
    final dt = DateTime.tryParse(date);
    if (dt == null) return date;
    return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isInstructor = userProvider.role == 'instructor';
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentCourse.title ?? "Course Details"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: theme.colorScheme.onBackground,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(Icons.article_outlined, "Description", theme),
            const SizedBox(height: 10),
            Text(
              _currentCourse.description?.isNotEmpty == true
                  ? _currentCourse.description!
                  : "No description available for this course.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.iconTheme.color,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 25),
            const Divider(),
            _buildDetailItem(Icons.category_outlined, "Category",
                _currentCourse.category ?? "No category", theme),
            const SizedBox(height: 20),
            _buildDetailItem(Icons.attach_money_outlined, "Price",
                "\$${_currentCourse.price ?? 0}", theme,
                valueColor: theme.progressIndicatorTheme.color),
            const SizedBox(height: 20),
            _buildDetailItem(Icons.stacked_bar_chart, "Level",
                _currentCourse.level ?? "N/A", theme,
                valueColor: theme.iconTheme.color),
            const SizedBox(height: 25),
            const Divider(),
            if (_currentCourse.instructor != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle(Icons.person_outline, "Instructor", theme),
                  const SizedBox(height: 10),
                  Text(_currentCourse.instructor!.name ?? "N/A",
                      style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.iconTheme.color)),
                  Text(_currentCourse.instructor!.email ?? "N/A",
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.iconTheme.color)),
                  const SizedBox(height: 25),
                  const Divider(),
                ],
              ),
            _sectionTitle(Icons.play_circle_outline, "Videos", theme),
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
                    theme: theme,
                  );
                }).toList(),
              )
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Text(
                    "No videos available yet.",
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.iconTheme.color),
                  ),
                ),
              ),
            const SizedBox(height: 25),
            const Divider(),
            _buildDetailItem(
                Icons.people_outline,
                "Enrolled Students",
                "${_currentCourse.enrolledStudents?.length ?? 0} student(s) enrolled",
                theme),
            const SizedBox(height: 25),
            _buildDetailItem(Icons.access_time_outlined, "Created At",
                formatDate(_currentCourse.createdAt), theme),
            const SizedBox(height: 10),
            _buildDetailItem(Icons.update, "Updated At",
                formatDate(_currentCourse.updatedAt), theme),
            if (!isInstructor && !_isEnrolled) ...[
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: BlocConsumer<CartCubit, CartState>(
                  listener: (context, state) {
                    if (state is AddToCartSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(state.message),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating),
                      );
                    } else if (state is AddToCartError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(state.message),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating),
                      );
                    } else if (state is RemoveFromCartSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(state.message),
                            backgroundColor: Colors.orange,
                            behavior: SnackBarBehavior.floating),
                      );
                    } else if (state is RemoveFromCartError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(state.message),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating),
                      );
                    }
                  },
                  builder: (context, state) {
                    final cubit = context.read<CartCubit>();
                    final isInCart = cubit.currentCart?.items?.any(
                            (item) => item.courseId == _currentCourse.id) ??
                        false;
                    final isLoading = state is CartLoading;

                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isInCart
                            ? Colors.red.shade400
                            : theme.progressIndicatorTheme.color,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: isLoading
                          ? null
                          : () {
                              if (isInCart) {
                                cubit.removeFromCart(_currentCourse.id!);
                              } else {
                                cubit.addToCart(_currentCourse.id!);
                              }
                            },
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : Row(
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
                                  isInCart ? "Remove from Cart" : "Add to Cart",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.3,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVideoItem(
      {required String videoTitle,
      required String videoUrl,
      required bool isLocked,
      required ThemeData theme}) {
    return Card(
      elevation: isLocked ? 0 : 2,
      color: isLocked ? theme.dividerTheme.color : theme.cardTheme.color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isLocked
              ? theme.dividerTheme.color
              : theme.progressIndicatorTheme.color,
          child: Icon(
            isLocked ? Icons.lock_outline : Icons.play_arrow_rounded,
            color: theme.iconTheme.color,
          ),
        ),
        title: Text(
          videoTitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: theme.iconTheme.color),
        ),
        subtitle: isLocked
            ? Text(
                "Enroll to unlock",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: theme.iconTheme.color,
                ),
              )
            : null,
        trailing: isLocked
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.progressIndicatorTheme.color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Locked",
                  style: TextStyle(
                    color: theme.iconTheme.color,
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
                        const SnackBar(content: Text("Video URL is empty")));
                    return;
                  }
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => VideoPlayerScreen(url: videoUrl)));
                },
                child: Text(
                  "Watch",
                  style: TextStyle(
                    color: theme.iconTheme.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _sectionTitle(IconData icon, String title, ThemeData theme) {
    return Row(
      children: [
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
      IconData icon, String title, String value, ThemeData theme,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
