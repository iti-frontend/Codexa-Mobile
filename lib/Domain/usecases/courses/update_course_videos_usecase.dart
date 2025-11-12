import 'dart:io';
import 'package:codexa_mobile/Domain/repo/add_course_repo.dart';
import 'package:dartz/dartz.dart';
import 'package:codexa_mobile/Domain/failures.dart';

class UploadVideosUseCase {
  final CourseInstructorRepo repo;

  UploadVideosUseCase(this.repo);

  Future<Either<Failures, List<String>>> call(
      String id, List<File> files) async {
    return await repo.uploadVideos(id, files);
  }
}
