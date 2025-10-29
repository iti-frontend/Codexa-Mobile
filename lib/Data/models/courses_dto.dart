import 'package:codexa_mobile/Data/models/instructor_dto.dart';
import 'package:codexa_mobile/Domain/entities/courses_entity.dart';

class CoursesDto extends CourseEntity {
  CoursesDto({
    super.id,
    super.title,
    super.description,
    super.price,
    super.category,
    super.instructor,
    super.enrolledStudents,
    super.videos,
    super.progress,
    super.createdAt,
    super.updatedAt,
    super.v,
  });

  factory CoursesDto.fromJson(Map<String, dynamic> json) {
    return CoursesDto(
      id: json['_id']?.toString(),
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      price: json['price'] is int
          ? json['price'] as int
          : int.tryParse('${json['price']}'),
      category: json['category']?.toString(),
      instructor: json['instructor'] != null
          ? InstructorDto.fromJson(json['instructor'])
          : null,
      enrolledStudents: (json['enrolledStudents'] as List<dynamic>?) ?? [],
      videos: (json['videos'] as List<dynamic>?) ?? [],
      progress: (json['progress'] as List<dynamic>?) ?? [],
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      v: json['__v'] is int
          ? json['__v'] as int
          : int.tryParse('${json['__v']}'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'price': price,
      'category': category,
      'instructor': instructor is InstructorDto
          ? (instructor as InstructorDto).toJson()
          : null,
      'enrolledStudents': enrolledStudents,
      'videos': videos,
      'progress': progress,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
    };
  }
}
