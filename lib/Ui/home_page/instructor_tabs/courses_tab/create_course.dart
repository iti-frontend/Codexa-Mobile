import 'dart:io';

import 'package:codexa_mobile/Domain/entities/courses_entity.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/courses_tab/upload_courses_cubit/upload_instructor_courses_state.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/courses_tab/upload_courses_cubit/upload_instructors_courses_cubit.dart';
import 'package:codexa_mobile/Ui/utils/theme/app_colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:codexa_mobile/localization/localization_service.dart';
import 'package:codexa_mobile/generated/l10n.dart' as generated;

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

  String? _selectedLevel;
  final List<String> _levels = ['Beginner', 'Intermediate', 'Advanced'];

  late LocalizationService _localizationService;
  late generated.S _translations;

  // Video files selected
  List<File> selectedVideos = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeLocalization();

    _titleController = TextEditingController(text: widget.course?.title ?? '');
    _categoryController =
        TextEditingController(text: widget.course?.category ?? '');
    _descriptionController =
        TextEditingController(text: widget.course?.description ?? '');
    _priceController =
        TextEditingController(text: widget.course?.price?.toString() ?? '');

    // Initialize level if editing
    _selectedLevel = widget.course?.level;
    if (_selectedLevel != null && !_levels.contains(_selectedLevel)) {
      // Handle case where level from backend might not match hardcoded list
      _levels.add(_selectedLevel!);
    }
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
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _localizationService.removeListener(_onLocaleChanged);
    super.dispose();
  }

  Color _getButtonColor(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return isDark ? AppColorsDark.accentGreen : AppColorsLight.accentBlue;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRTL = _localizationService.isRTL();

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: BlocListener<InstructorCoursesCubit, InstructorCoursesState>(
        bloc: widget.cubit,
        listener: (context, state) {
          if (state is InstructorCoursesLoading) {
            setState(() => _isLoading = true);
          } else if (state is CourseCreatedSuccess) {
            // Course Created! Now Upload Videos if any
            if (selectedVideos.isNotEmpty) {
              _uploadVideos(state.course.id!);
            } else {
              _finishSuccess('Course created successfully');
            }
          } else if (state is CourseOperationSuccess) {
            _finishSuccess(state.message);
          } else if (state is InstructorCoursesError) {
            _finishError(state.message);
          } else if (state is CourseOperationError) {
            _finishError(state.message);
          }
        },
        child: Stack(
          children: [
            Scaffold(
              appBar: AppBar(
                title: Text(widget.course == null
                    ? _translations.createCourse
                    : _translations.editCourse),
                backgroundColor: Colors.transparent,
                elevation: 0,
                foregroundColor: theme.iconTheme.color,
                leading: IconButton(
                  icon: Icon(isRTL ? Icons.arrow_forward : Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              body: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      // Title
                      _buildInputField(
                          controller: _titleController,
                          label: _translations.title,
                          icon: Icons.title,
                          validator: (val) => val == null || val.isEmpty
                              ? _translations.enterTitle
                              : null,
                          theme: theme,
                          isRTL: isRTL),
                      const SizedBox(height: 15),

                      // Category
                      _buildInputField(
                          controller: _categoryController,
                          label: _translations.category,
                          icon: Icons.category_outlined,
                          theme: theme,
                          isRTL: isRTL),
                      const SizedBox(height: 15),

                      // Level Dropdown
                      _buildDropdownField(theme, isRTL),
                      const SizedBox(height: 15),

                      // Description
                      _buildInputField(
                          controller: _descriptionController,
                          label: _translations.description,
                          icon: Icons.article_outlined,
                          maxLines: 4,
                          theme: theme,
                          isRTL: isRTL),
                      const SizedBox(height: 15),

                      // Price
                      _buildInputField(
                          controller: _priceController,
                          label: _translations.priceDollar,
                          icon: Icons.attach_money_outlined,
                          validator: (val) {
                            if (val == null || val.isEmpty)
                              return _translations.enterPrice;
                            if (double.tryParse(val) == null)
                              return _translations.enterValidNumber;
                            return null;
                          },
                          keyboardType: TextInputType.number,
                          theme: theme,
                          isRTL: isRTL),
                      const SizedBox(height: 15),

                      // Videos Upload Section
                      _buildVideoSection(theme, isRTL),
                      const SizedBox(height: 32),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _getButtonColor(theme),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _isLoading ? null : _onSubmit,
                          child: Text(
                            widget.course == null
                                ? _translations.createCourse
                                : _translations.updateCourse,
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_isLoading) _buildLoadingOverlay(theme),
          ],
        ),
      ),
    );
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      final newCourseData = CourseEntity(
        id: widget.course?.id,
        title: _titleController.text.trim(),
        category: _categoryController.text.trim(),
        description: _descriptionController.text.trim(),
        price: _priceController.text.isNotEmpty
            ? int.parse(_priceController.text.trim())
            : 0,
        level: _selectedLevel,
        videos: widget.course?.videos ?? [], // Existing videos
        enrolledStudents: widget.course?.enrolledStudents ?? [],
      );

      if (widget.course == null) {
        // Create Mode
        widget.cubit.addCourse(newCourseData);
        // Video upload will trigger in listener after CourseCreatedSuccess
      } else {
        // Edit Mode
        if (selectedVideos.isNotEmpty) {
          _uploadVideos(widget.course!.id!);
        }
        widget.cubit.updateCourse(newCourseData);
      }
    }
  }

  void _uploadVideos(String courseId) {
    // Show a specific "Uploading" state if desired, but general loading is fine
    widget.cubit.uploadVideos(courseId, selectedVideos);
  }

  void _finishSuccess(String message) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  void _finishError(String message) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildLoadingOverlay(ThemeData theme) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: _getButtonColor(theme)),
              const SizedBox(height: 16),
              Text(
                "Processing...",
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(ThemeData theme, bool isRTL) {
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment:
          isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          "Level", // TODO: Add translation
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedLevel,
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.white.withOpacity(0.8),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          hint: Text('Select Level'),
          items: _levels.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (val) {
            setState(() {
              _selectedLevel = val;
            });
          },
        ),
      ],
    );
  }

  Widget _buildVideoSection(ThemeData theme, bool isRTL) {
    return Column(
      crossAxisAlignment:
          isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          _translations.videos,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: selectedVideos
              .map((file) => Chip(
                    label: Text(file.path.split('/').last),
                    onDeleted: () =>
                        setState(() => selectedVideos.remove(file)),
                  ))
              .toList(),
        ),
        const SizedBox(height: 14),
        ElevatedButton.icon(
          icon: const Icon(Icons.upload_file),
          label: Text(_translations.selectVideos),
          style: ElevatedButton.styleFrom(
            backgroundColor: _getButtonColor(theme).withOpacity(0.15),
            foregroundColor: _getButtonColor(theme),
          ),
          onPressed: () async {
            final result = await FilePicker.platform.pickFiles(
              type: FileType.video,
              allowMultiple: true,
            );
            if (result != null) {
              setState(() {
                selectedVideos.addAll(result.paths.map((path) => File(path!)));
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    int maxLines = 1,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    required ThemeData theme,
    required bool isRTL,
  }) {
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment:
          isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          children: isRTL
              ? [
                  Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (icon != null) const SizedBox(width: 8),
                  if (icon != null)
                    Icon(
                      icon,
                      color: theme.colorScheme.primary,
                      size: 22,
                    ),
                ]
              : [
                  if (icon != null)
                    Icon(
                      icon,
                      color: theme.colorScheme.primary,
                      size: 22,
                    ),
                  if (icon != null) const SizedBox(width: 8),
                  Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
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
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          textAlign: isRTL ? TextAlign.right : TextAlign.left,
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.white.withOpacity(0.8),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
