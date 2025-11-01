import 'package:codexa_mobile/Data/api_manager/api_manager.dart';
import 'package:codexa_mobile/Data/constants/api_constants.dart';
import 'package:codexa_mobile/Data/models/courses_dto.dart';
import 'package:codexa_mobile/Domain/entities/courses_entity.dart';
import 'package:codexa_mobile/Domain/failures.dart';
import 'package:codexa_mobile/Domain/repo/get_courses_repo.dart';
import 'package:dartz/dartz.dart';

class CoursesRepoImpl implements GetCoursesRepo {
  final ApiManager apiManager;

  CoursesRepoImpl(this.apiManager);

  @override
  Future<Either<Failures, List<CourseEntity>>> getCourses() async {
    try {
      final response = await apiManager.getData(ApiConstants.coursesEndpoint);
      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> dataList = (data is Map && data['data'] != null)
            ? (data['data'] as List<dynamic>)
            : (data is List ? data : []);

        final List<CourseEntity> courses = dataList
            .map((item) => CoursesDto.fromJson(item as Map<String, dynamic>))
            .toList();
        return Right(courses);
      } else {
        return Left(Failures(
            errorMessage:
                response.data?['message']?.toString() ?? 'Server Error'));
      }
    } catch (e) {
      return Left(Failures(errorMessage: e.toString()));
    }
  }
}
