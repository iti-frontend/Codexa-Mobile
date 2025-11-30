import 'package:codexa_mobile/Domain/entities/instructor_entity.dart';

class CourseEntity {
  final String? id;
  final String? title;
  final String? description;
  final int? price;
  final String? category;
  final String? level;
  final InstructorEntity? instructor;
  final List<dynamic>? enrolledStudents;
  final List<dynamic>? videos;
  final List<dynamic>? progress;
  final String? createdAt;
  final String? updatedAt;
  final int? v;
  final bool? isFavourite;

  CourseEntity({
    this.id,
    this.title,
    this.description,
    this.price,
    this.category,
    this.level,
    this.instructor,
    this.enrolledStudents,
    this.videos,
    this.progress,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.isFavourite,
  });

  CourseEntity copyWith({
    String? id,
    String? title,
    String? description,
    int? price,
    String? category,
    String? level,
    InstructorEntity? instructor,
    List<dynamic>? enrolledStudents,
    List<dynamic>? videos,
    List<dynamic>? progress,
    String? createdAt,
    String? updatedAt,
    int? v,
    bool? isFavourite,
  }) {
    return CourseEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      level: level ?? this.level,
      instructor: instructor ?? this.instructor,
      enrolledStudents: enrolledStudents ?? this.enrolledStudents,
      videos: videos ?? this.videos,
      progress: progress ?? this.progress,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      v: v ?? this.v,
      isFavourite: isFavourite ?? this.isFavourite,
    );
  }
}
