import 'package:codexa_mobile/Ui/home_page/instructor_tabs/courses_tab/create_course.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/courses_tab/upload_courses_cubit/upload_instructor_courses_state.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/courses_tab/upload_courses_cubit/upload_instructors_courses_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_details.dart';
import 'package:codexa_mobile/Ui/utils/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class CoursesInstructorTab extends StatelessWidget {
  const CoursesInstructorTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const _CoursesInstructorView();
  }
}

class _CoursesInstructorView extends StatelessWidget {
  const _CoursesInstructorView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: CustomButton(
            text: "Create new Course",
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
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: BlocBuilder<InstructorCoursesCubit, InstructorCoursesState>(
              builder: (context, state) {
                if (state is InstructorCoursesLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is InstructorCoursesError) {
                  return Center(
                    child: Text(
                      'Error: ${state.message}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                } else if (state is InstructorCoursesLoaded) {
                  if (state.courses.isEmpty) {
                    return const Center(child: Text('No courses yet'));
                  }
                  return ListView.separated(
                    itemCount: state.courses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final course = state.courses[index];
                      return Slidable(
                        key: ValueKey(course.id ?? index),
                        startActionPane: ActionPane(
                          motion: const DrawerMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) {
                                final cubit =
                                    context.read<InstructorCoursesCubit>();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider.value(
                                      value: cubit,
                                      child: AddEditCourseScreen(
                                        cubit: cubit,
                                        course: course,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              icon: Icons.edit,
                              label: 'Edit',
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                topLeft: Radius.circular(12),
                              ),
                            ),
                            SlidableAction(
                              onPressed: (context) {
                                final id = course.id;
                                if (id != null && id.isNotEmpty) {
                                  context
                                      .read<InstructorCoursesCubit>()
                                      .deleteCourse(id);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Error: Invalid course ID')),
                                  );
                                }
                              },
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Delete',
                              borderRadius: const BorderRadius.only(
                                bottomRight: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                            ),
                          ],
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CourseDetails(course: course),
                              ),
                            );
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  const Icon(Icons.drag_handle,
                                      color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          course.title?.isNotEmpty == true
                                              ? course.title!
                                              : 'Untitled',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          course.category?.isNotEmpty == true
                                              ? course.category!
                                              : 'No category',
                                          style: const TextStyle(
                                              color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ],
    );
  }
}
