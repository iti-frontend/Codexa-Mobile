class CourseInstructorEntity {
  final String? id;
  final String? title;
  final String? description;
  final String? category;
  final String? level;
  final List<String>? tags;
  final String? thumbnailUrl;

  CourseInstructorEntity({
    this.id,
    this.title,
    this.description,
    this.category,
    this.level,
    this.tags,
    this.thumbnailUrl,
  });

  factory CourseInstructorEntity.fromJson(Map<String, dynamic> json) {
    return CourseInstructorEntity(
      id: json['id']?.toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      level: json['level'] ?? '',
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      thumbnailUrl: json['thumbnailUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title ?? '',
      'description': description ?? '',
      'category': category ?? '',
      'level': level ?? '',
      'tags': tags ?? [],
      'thumbnailUrl': thumbnailUrl ?? '',
    };
  }
}
