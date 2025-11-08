import 'package:codexa_mobile/Domain/entities/add_course_entity.dart';

class CourseInstructorModel extends CourseInstructorEntity {
  CourseInstructorModel({
    String? id,
    required String title,
    required String description,
    required String category,
    required String level,
    List<String>? tags,
    String? thumbnailUrl,
  }) : super(
          id: id,
          title: title,
          description: description,
          category: category,
          level: level,
          tags: tags,
          thumbnailUrl: thumbnailUrl,
        );

  // من JSON
  factory CourseInstructorModel.fromJson(Map<String, dynamic> json) {
    return CourseInstructorModel(
      id: json['id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      level: json['level'] as String,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      thumbnailUrl: json['thumbnail_url'] as String?,
    );
  }

  // لـ JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'level': level,
      'tags': tags,
      'thumbnail_url': thumbnailUrl,
    };
  }
}
