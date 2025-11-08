import 'package:codexa_mobile/Domain/entities/add_course_entity.dart';

abstract class CourseInstructorRepo {
  Future<void> addCourse(CourseInstructorEntity course);
  Future<List<CourseInstructorEntity>> getMyCourses();
  Future<CourseInstructorEntity> getCourseById(String id);
  Future<void> updateCourse(CourseInstructorEntity course);
  Future<void> deleteCourse(String id);
}
