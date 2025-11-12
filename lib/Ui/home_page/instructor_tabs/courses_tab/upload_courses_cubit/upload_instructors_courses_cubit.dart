import 'dart:io';

import 'package:codexa_mobile/Domain/entities/courses_entity.dart';
import 'package:codexa_mobile/Domain/failures.dart';
import 'package:codexa_mobile/Domain/usecases/courses/update_course_videos_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:codexa_mobile/Domain/usecases/courses/add_course_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/courses/delete_course_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/courses/get_courses_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/courses/update_course_usecase.dart';
import 'upload_instructor_courses_state.dart';

class InstructorCoursesCubit extends Cubit<InstructorCoursesState> {
  final GetCoursesUseCase getCoursesUseCase;
  final AddCourseUseCase addCourseUseCase;
  final UpdateCourseUseCase updateCourseUseCase;
  final DeleteCourseUseCase deleteCourseUseCase;
  final UploadVideosUseCase uploadVideosUseCase;

  InstructorCoursesCubit(
      {required this.getCoursesUseCase,
      required this.addCourseUseCase,
      required this.updateCourseUseCase,
      required this.deleteCourseUseCase,
      required this.uploadVideosUseCase})
      : super(InstructorCoursesInitial());

  Future<void> fetchCourses() async {
    emit(InstructorCoursesLoading());
    final result = await getCoursesUseCase.instructorCall();
    result.fold(
      (failure) => emit(InstructorCoursesError(failure.errorMessage)),
      (courses) => emit(InstructorCoursesLoaded(courses)),
    );
  }

  Future<void> addCourse(CourseEntity course) async {
    emit(InstructorCoursesLoading());
    final result = await addCourseUseCase(course);
    result.fold(
      (failure) => emit(CourseOperationError(failure.errorMessage)),
      (_) => emit(CourseOperationSuccess('Course added successfully')),
    );
    await fetchCourses();
  }

  Future<void> updateCourse(CourseEntity course) async {
    emit(InstructorCoursesLoading());
    final result = await updateCourseUseCase(course);
    result.fold(
      (failure) => emit(CourseOperationError(failure.errorMessage)),
      (_) => emit(CourseOperationSuccess('Course updated successfully')),
    );
    await fetchCourses();
  }

  Future<void> deleteCourse(String id) async {
    if (id.isEmpty) {
      emit(CourseOperationError('Invalid course id'));
      return;
    }

    emit(InstructorCoursesLoading());
    final result = await deleteCourseUseCase(id);
    result.fold(
      (failure) => emit(CourseOperationError(failure.errorMessage)),
      (_) => emit(CourseOperationSuccess('Course deleted successfully')),
    );
    await fetchCourses();
  }

  Future<Either<Failures, List<String>>> uploadVideos(
      String id, List<File> files) async {
    emit(InstructorCoursesLoading());
    final result = await uploadVideosUseCase(id, files);
    result.fold(
      (failure) => emit(CourseOperationError(failure.errorMessage)),
      (_) => emit(CourseOperationSuccess('Videos uploaded successfully')),
    );
    return result;
  }
}
