import 'package:codexa_mobile/Domain/entities/instructor_entity.dart';

class CourseEntity {
  final String? id;
  final String? title;
  final String? description;
  final int? price;
  final String? category;
  final InstructorEntity? instructor;
  final List<dynamic>? enrolledStudents;
  final List<dynamic>? videos;
  final List<dynamic>? progress;
  final String? createdAt;
  final String? updatedAt;
  final int? v;

  CourseEntity({
    this.id,
    this.title,
    this.description,
    this.price,
    this.category,
    this.instructor,
    this.enrolledStudents,
    this.videos,
    this.progress,
    this.createdAt,
    this.updatedAt,
    this.v,
  });
}
