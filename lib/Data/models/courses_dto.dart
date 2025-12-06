import 'package:codexa_mobile/Data/models/instructor_dto.dart';
import 'package:codexa_mobile/Domain/entities/courses_entity.dart';

class CoursesDto extends CourseEntity {
  CoursesDto({
    super.id,
    super.title,
    super.description,
    super.price,
    super.category,
    super.level,
    super.instructor,
    super.enrolledStudents,
    super.videos,
    super.progress,
    super.createdAt,
    super.updatedAt,
    super.v,
    super.isFavourite,
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
      level: json['level']?.toString(),
      instructor: json['instructor'] != null
          ? (json['instructor'] is Map<String, dynamic>
              ? InstructorDto.fromJson(json['instructor'])
              : (json['instructor'] is String
                  ? InstructorDto.fromJson({'_id': json['instructor']})
                  : null))
          : null,
      enrolledStudents: (json['enrolledStudents'] as List<dynamic>?) ?? [],
      videos: (json['videos'] as List<dynamic>?) ?? [],
      progress: (json['progress'] as List<dynamic>?) ?? [],
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      v: json['__v'] is int
          ? json['__v'] as int
          : int.tryParse('${json['__v']}'),
      isFavourite: json['isFavourite'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'price': price ?? 0,
      'category': category,
      'level': level,
      'instructor': instructor is InstructorDto
          ? (instructor as InstructorDto).toJson()
          : null,
      'enrolledStudents': enrolledStudents,
      'videos': videos,
      'progress': progress,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
      'isFavourite': isFavourite,
    };
  }
}
