import 'package:codexa_mobile/Domain/entities/courses_entity.dart';

abstract class InstructorCoursesState {}

class InstructorCoursesInitial extends InstructorCoursesState {}

class InstructorCoursesLoading extends InstructorCoursesState {}

class InstructorCoursesLoaded extends InstructorCoursesState {
  final List<CourseEntity> courses;
  InstructorCoursesLoaded(this.courses);
}

class InstructorCoursesError extends InstructorCoursesState {
  final String message;
  InstructorCoursesError(this.message);
}

class CourseOperationSuccess extends InstructorCoursesState {
  final String message;
  CourseOperationSuccess(this.message);
}

class CourseCreatedSuccess extends InstructorCoursesState {
  final CourseEntity course;
  CourseCreatedSuccess(this.course);
}

class CourseOperationError extends InstructorCoursesState {
  final String message;
  CourseOperationError(this.message);
}
