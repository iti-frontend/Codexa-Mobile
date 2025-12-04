import 'dart:io';

import 'package:codexa_mobile/Domain/entities/courses_entity.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/courses_tab/upload_courses_cubit/upload_instructors_courses_cubit.dart';
import 'package:codexa_mobile/Ui/utils/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class AddEditCourseScreen extends StatefulWidget {
  final CourseEntity? course;
  final InstructorCoursesCubit cubit;

  const AddEditCourseScreen({super.key, required this.cubit, this.course});

  @override
  State<AddEditCourseScreen> createState() => _AddEditCourseScreenState();
}

class _AddEditCourseScreenState extends State<AddEditCourseScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _categoryController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;

  // Video files selected
  List<File> selectedVideos = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.course?.title ?? '');
    _categoryController =
        TextEditingController(text: widget.course?.category ?? '');
    _descriptionController =
        TextEditingController(text: widget.course?.description ?? '');
    _priceController =
        TextEditingController(text: widget.course?.price?.toString() ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  /// Get button color based on theme mode
  /// Light: Brown-ish (using AppColorsLight palette)
  /// Dark: Green (AppColorsDark.accentGreen)
  Color _getButtonColor(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    if (isDark) {
      return AppColorsDark.accentGreen;
    } else {
      return AppColorsLight.accentBlue; // Using blue as brown alternative
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = widget.cubit;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course == null ? 'Create Course' : 'Edit Course'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: theme.iconTheme.color,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Title
              _buildInputField(
                  controller: _titleController,
                  label: "Title",
                  icon: Icons.title,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Enter title' : null,
                  theme: theme),
              const SizedBox(height: 15),

              // Category
              _buildInputField(
                  controller: _categoryController,
                  label: "Category",
                  icon: Icons.category_outlined,
                  theme: theme),
              const SizedBox(height: 15),

              // Description
              _buildInputField(
                  controller: _descriptionController,
                  label: "Description",
                  icon: Icons.article_outlined,
                  maxLines: 4,
                  theme: theme),
              const SizedBox(height: 15),

              // Price
              _buildInputField(
                  controller: _priceController,
                  label: "Price (\$)",
                  icon: Icons.attach_money_outlined,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Enter price';
                    if (double.tryParse(val) == null)
                      return 'Enter valid number';
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  theme: theme),
              const SizedBox(height: 15),

              // Videos Upload
              Text(
                "Videos",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: selectedVideos
                    .map((file) => Container(
                          decoration: BoxDecoration(
                            color: _getButtonColor(theme).withOpacity(0.15),
                            border: Border.all(
                              color: _getButtonColor(theme).withOpacity(0.3),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Chip(
                            label: Text(
                              file.path.split('/').last,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                            ),
                            deleteIcon: Icon(
                              Icons.close,
                              color: _getButtonColor(theme),
                              size: 18,
                            ),
                            onDeleted: () {
                              setState(() => selectedVideos.remove(file));
                            },
                            backgroundColor: Colors.transparent,
                            side: BorderSide.none,
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: const Text("Select Videos"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getButtonColor(theme).withOpacity(0.15),
                  foregroundColor: _getButtonColor(theme),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: _getButtonColor(theme).withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  elevation: 0,
                ),
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.video,
                    allowMultiple: true,
                  );
                  if (result != null) {
                    setState(() {
                      selectedVideos.addAll(
                        result.paths.map((path) => File(path!)),
                      );
                    });
                  }
                },
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getButtonColor(theme),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    shadowColor: _getButtonColor(theme).withOpacity(0.4),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      List<String> videoUrls =
                          (widget.course?.videos?.cast<String>()) ?? [];
                      if (selectedVideos.isNotEmpty) {
                        final result = await cubit.uploadVideos(
                            widget.course!.id ?? '', selectedVideos);
                        result.fold(
                          (failure) {
                            final messenger =
                                ScaffoldMessenger.maybeOf(context);
                            if (messenger != null) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(failure.errorMessage),
                                  backgroundColor: Colors.red.shade400,
                                ),
                              );
                            }
                          },
                          (urls) async {
                            videoUrls = urls;
                            await cubit.uploadVideosUseCase(
                                widget.course!.id ?? '', selectedVideos);
                          },
                        );
                      }

                      final newCourse = CourseEntity(
                        id: widget.course?.id,
                        title: _titleController.text.trim(),
                        category: _categoryController.text.trim(),
                        description: _descriptionController.text.trim(),
                        price: _priceController.text.isNotEmpty
                            ? int.parse(_priceController.text.trim())
                            : 0,
                        videos: videoUrls,
                        enrolledStudents: widget.course?.enrolledStudents ?? [],
                        instructor: widget.course?.instructor,
                        createdAt: widget.course?.createdAt,
                        updatedAt: widget.course?.updatedAt,
                        v: widget.course?.v,
                      );

                      if (widget.course == null) {
                        cubit.addCourse(newCourse);
                      } else {
                        cubit.updateCourse(newCourse);
                      }

                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    widget.course == null ? 'Create Course' : 'Update Course',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    int maxLines = 1,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    ThemeData? theme,
  }) {
    final isDark = theme?.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null)
              Icon(
                icon,
                color: theme?.colorScheme.primary,
                size: 22,
              ),
            if (icon != null) const SizedBox(width: 8),
            Text(
              label,
              style: theme?.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          keyboardType: keyboardType,
          style: theme?.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodyMedium?.color,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.white.withOpacity(0.8),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.2),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: theme?.colorScheme.primary ?? Colors.blueAccent,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.red.shade400,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.red.shade400,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            errorStyle: TextStyle(
              color: Colors.red.shade400,
              fontSize: 12,
            ),
            hintStyle: TextStyle(
              color: isDark
                  ? Colors.white.withOpacity(0.5)
                  : Colors.grey.withOpacity(0.7),
            ),
          ),
        ),
      ],
    );
  }
}
