import 'package:codexa_mobile/Ui/home_page/instructor_tabs/courses_tab/upload_courses_cubit/upload_instructors_courses_cubit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:codexa_mobile/Domain/entities/add_course_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ===================== Add/Edit Course Screen =====================
class AddEditCourseScreen extends StatefulWidget {
  final CourseInstructorEntity? course;
  final InstructorUploadCoursesCubit cubit;

  const AddEditCourseScreen({super.key, required this.cubit, this.course});

  @override
  State<AddEditCourseScreen> createState() => _AddEditCourseScreenState();
}

class _AddEditCourseScreenState extends State<AddEditCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _categoryController;
  late TextEditingController _descriptionController;
  late TextEditingController _levelController;
  late TextEditingController _tagsController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.course?.title ?? '');
    _categoryController =
        TextEditingController(text: widget.course?.category ?? '');
    _descriptionController =
        TextEditingController(text: widget.course?.description ?? '');
    _levelController = TextEditingController(text: widget.course?.level ?? '');
    _tagsController =
        TextEditingController(text: widget.course?.tags?.join(', ') ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _levelController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = widget.cubit;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course == null ? 'Create Course' : 'Edit Course'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter title' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _levelController,
                decoration: const InputDecoration(labelText: 'Level'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (comma separated)',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newCourse = CourseInstructorEntity(
                      id: widget.course?.id,
                      title: _titleController.text.trim(),
                      category: _categoryController.text.trim(),
                      description: _descriptionController.text.trim(),
                      level: _levelController.text.trim(),
                      tags: _tagsController.text
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList(),
                      thumbnailUrl: widget.course?.thumbnailUrl ?? '',
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
                    widget.course == null ? 'Create Course' : 'Update Course'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
