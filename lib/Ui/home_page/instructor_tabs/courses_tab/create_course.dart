import 'dart:io';

import 'package:codexa_mobile/Domain/entities/courses_entity.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/courses_tab/upload_courses_cubit/upload_instructors_courses_cubit.dart';
import 'package:flutter/material.dart';
import 'package:codexa_mobile/Ui/utils/theme/app_colors.dart';
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
                  if (double.tryParse(val) == null) return 'Enter valid number';
                  return null;
                },
                keyboardType: TextInputType.number,
                  theme: theme),
              const SizedBox(height: 15),

              // Videos Upload
              Text(
                "Videos",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: theme.iconTheme.color,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: selectedVideos
                    .map((file) => Chip(
                          label: Text(file.path.split('/').last),
                          deleteIcon: const Icon(Icons.close),
                          onDeleted: () {
                            setState(() => selectedVideos.remove(file));
                          },
                        ))
                    .toList(),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: Text("Select Videos",style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.progressIndicatorTheme.color,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                  foregroundColor: Colors.white
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
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.progressIndicatorTheme.color,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
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
                                SnackBar(content: Text(failure.errorMessage)),
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
                  child: const Text(
                    'Save Course',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.3,
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
    ThemeData? theme
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) Icon(icon, color: theme!.iconTheme.color, size: 22),
            if (icon != null) const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: theme!.iconTheme.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          keyboardType: keyboardType,
          style: TextStyle(
            fontSize: 16,
            backgroundColor: theme?.progressIndicatorTheme.color,
              color: theme.iconTheme.color
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black26),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: theme!.progressIndicatorTheme.color ?? Colors.blueAccent, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
