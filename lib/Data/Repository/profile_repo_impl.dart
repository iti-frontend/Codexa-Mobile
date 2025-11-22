import 'package:codexa_mobile/Data/api_manager/api_manager.dart';
import 'package:codexa_mobile/Data/constants/api_constants.dart';
import 'package:codexa_mobile/Data/models/instructor_dto.dart';
import 'package:codexa_mobile/Data/models/student_dto.dart';
import 'package:codexa_mobile/Domain/entities/instructor_entity.dart';
import 'package:codexa_mobile/Domain/entities/student_entity.dart';
import 'package:codexa_mobile/Domain/failures.dart';
import 'package:codexa_mobile/Domain/repo/profile_repo.dart';
import 'package:dartz/dartz.dart';

class ProfileRepoImpl implements ProfileRepo {
  final ApiManager apiManager;

  ProfileRepoImpl(this.apiManager);

  @override
  Future<Either<Failures, StudentEntity>> updateProfile({
    required StudentEntity student,
  }) async {
    try {
      final response = await apiManager.putData(
        ApiConstants.studentEndpointProfile(student.id!),
        body: {
          "name": student.name,
          "email": student.email,
          "profileImage": student.profileImage,
        },
      );

      if (response.statusCode == 200) {
        final updatedStudentDto =
            StudentDto.fromJson(response.data['data'] as Map<String, dynamic>);
        return Right(updatedStudentDto.toEntity(student.token));
      } else {
        return Left(Failures(
          errorMessage: response.data?['message']?.toString() ?? 'Server Error',
        ));
      }
    } catch (e) {
      return Left(Failures(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failures, InstructorEntity>> updateInstructorProfile(
      InstructorEntity instructor) async {
    try {
      final response = await apiManager.putData(
        ApiConstants.instructorEndpointProfile(instructor.id!),
        body: {
          "name": instructor.name,
          "email": instructor.email,
          "profileImage": instructor.profileImage,
        },
      );

      if (response.statusCode == 200) {
        final updatedInstructorDto = InstructorDto.fromJson(
            response.data['data'] as Map<String, dynamic>);
        return Right(updatedInstructorDto.toEntity(instructor.token));
      } else {
        return Left(Failures(
          errorMessage: response.data?['message']?.toString() ?? 'Server Error',
        ));
      }
    } catch (e) {
      return Left(Failures(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failures, StudentEntity>> updateStudentProfile(
    StudentEntity student,
  ) async {
    try {
      final response = await apiManager.putData(
        ApiConstants.studentEndpointProfile(student.id!),
        body: {
          "name": student.name,
          "email": student.email,
          "profileImage": student.profileImage,
        },
      );

      if (response.statusCode == 200) {
        final updatedStudentDto =
            StudentDto.fromJson(response.data['data'] as Map<String, dynamic>);
        return Right(updatedStudentDto.toEntity(student.token));
      } else {
        return Left(Failures(
          errorMessage: response.data?['message']?.toString() ?? 'Server Error',
        ));
      }
    } catch (e) {
      return Left(Failures(errorMessage: e.toString()));
    }
  }
}
