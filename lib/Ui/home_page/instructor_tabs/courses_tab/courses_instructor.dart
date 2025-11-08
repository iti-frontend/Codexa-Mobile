import 'package:codexa_mobile/Ui/home_page/instructor_tabs/courses_tab/create_course.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:codexa_mobile/Data/api_manager/api_manager.dart';
import 'package:codexa_mobile/Data/Repository/courses_repository.dart';
import 'package:codexa_mobile/Data/Repository/add_course_repo_impl.dart';
import 'package:codexa_mobile/Domain/usecases/courses/get_courses_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/courses/add_course_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/courses/update_course_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/courses/delete_course_usecase.dart';
import 'package:codexa_mobile/Ui/utils/provider_ui/auth_provider.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/courses_tab/upload_courses_cubit/upload_instructors_courses_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/courses_tab/upload_courses_cubit/upload_instructor_courses_state.dart';

// ===================== Courses Tab =====================
class CoursesInstructorTab extends StatelessWidget {
  const CoursesInstructorTab({super.key});

  @override
  Widget build(BuildContext context) {
    final token = Provider.of<UserProvider>(context, listen: false).token;
    if (token == null || token.isEmpty) {
      return const Center(child: Text('No token found! Please login again.'));
    }

    final apiManager = ApiManager(token: token);
    final coursesRepo = CoursesRepoImpl(apiManager);
    final courseInstructorRepo =
        CourseInstructorRepoImpl(apiManager: apiManager);

    return BlocProvider(
      create: (_) => InstructorUploadCoursesCubit(
        getCoursesUseCase: GetCoursesUseCase(coursesRepo),
        addCourseUseCase: AddCourseUseCase(courseInstructorRepo),
        updateCourseUseCase: UpdateCourseUseCase(courseInstructorRepo),
        deleteCourseUseCase: DeleteCourseUseCase(courseInstructorRepo),
      )..fetchCourses(),
      child: const _CoursesInstructorView(),
    );
  }
}

// ===================== Courses View =====================
class _CoursesInstructorView extends StatelessWidget {
  const _CoursesInstructorView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: ElevatedButton(
            onPressed: () {
              final cubit = context.read<InstructorUploadCoursesCubit>();
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
            child: const Text('Create Course'),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: BlocBuilder<InstructorUploadCoursesCubit,
                InstructorCoursesState>(
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
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final course = state.courses[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(course.title?.isNotEmpty == true
                                      ? course.title!
                                      : 'Untitled'),
                                  Text(course.category?.isNotEmpty == true
                                      ? course.category!
                                      : 'No category'),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () {
                                      final cubit = context
                                          .read<InstructorUploadCoursesCubit>();
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
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () {
                                      final id = course.id;
                                      print(
                                          'Attempting to delete course id: $id'); // Debug print
                                      if (id != null && id.isNotEmpty) {
                                        context
                                            .read<
                                                InstructorUploadCoursesCubit>()
                                            .deleteCourse(id);
                                      } else {
                                        print(
                                            'Error: course id is null or empty!');
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
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
