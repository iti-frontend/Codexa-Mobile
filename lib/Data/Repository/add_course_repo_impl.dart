import 'package:codexa_mobile/Data/constants/api_constants.dart';
import 'package:codexa_mobile/Domain/entities/add_course_entity.dart';
import 'package:codexa_mobile/Domain/repo/add_course_repo.dart';
import '../api_manager/api_manager.dart';

class CourseInstructorRepoImpl implements CourseInstructorRepo {
  final ApiManager apiManager;

  CourseInstructorRepoImpl({required this.apiManager});

  @override
  Future<void> addCourse(CourseInstructorEntity course) async {
    final body = {
      'title': course.title,
      'description': course.description,
      'category': course.category,
      'level': course.level,
      'tags': course.tags,
      'thumbnail_url': course.thumbnailUrl,
    };
    await apiManager.postData(ApiConstants.coursesEndpoint, body: body);
  }

  @override
  Future<List<CourseInstructorEntity>> getMyCourses() async {
    final response =
        await apiManager.getData(ApiConstants.coursesInstructorEndpoint);
    final data = response.data as List;
    return data
        .map((e) => CourseInstructorEntity(
              id: e['id'],
              title: e['title'],
              description: e['description'],
              category: e['category'],
              level: e['level'],
              tags: List<String>.from(e['tags'] ?? []),
              thumbnailUrl: e['thumbnail_url'],
            ))
        .toList();
  }

  @override
  Future<CourseInstructorEntity> getCourseById(String id) async {
    final response =
        await apiManager.getData(ApiConstants.courseInstructorById(id));
    final e = response.data;
    return CourseInstructorEntity(
      id: e['id'],
      title: e['title'],
      description: e['description'],
      category: e['category'],
      level: e['level'],
      tags: List<String>.from(e['tags'] ?? []),
      thumbnailUrl: e['thumbnail_url'],
    );
  }

  @override
  Future<void> updateCourse(CourseInstructorEntity course) async {
    final body = {
      'title': course.title,
      'description': course.description,
      'category': course.category,
      'level': course.level,
      'tags': course.tags,
      'thumbnail_url': course.thumbnailUrl,
    };
    await apiManager.putData(ApiConstants.courseInstructorById(course.id!),
        body: body);
  }

  @override
  Future<void> deleteCourse(String id) async {
    if (id.isEmpty) {
      return;
    }

    try {
      final response =
          await apiManager.deleteData(ApiConstants.courseInstructorById(id));
      print(
          'Delete response: ${response.statusCode} ${response.data}'); // Debug print
    } catch (e) {
      print('Delete failed: $e');
    }
  }
}
