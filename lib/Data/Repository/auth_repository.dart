import 'package:codexa_mobile/Data/api_manager/api_manager.dart';
import 'package:codexa_mobile/Data/constants/api_constants.dart';
import 'package:codexa_mobile/Data/models/instructor_dto.dart';
import 'package:codexa_mobile/Data/models/student_dto.dart';
import 'package:codexa_mobile/Domain/entities/instructor_entity.dart';
import 'package:codexa_mobile/Domain/entities/student_entity.dart';
import 'package:codexa_mobile/Domain/failures.dart';
import 'package:codexa_mobile/Domain/repo/auth_repo.dart';
import 'package:dart_either/dart_either.dart';

class AuthRepoImpl implements AuthRepo {
  final ApiManager apiManager;

  AuthRepoImpl(this.apiManager);

  // ================== Instructor ==================
  @override
  Future<Either<Failures, InstructorEntity>> loginInstructor({
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiManager.postData(
        ApiConstants.instructorEndpointLogin,
        body: {"email": email, "password": password},
      );

      if (response.statusCode == 200) {
        final dto = InstructorUserDto.fromJson(response.data);
        if (dto.instructor != null) return Right(dto.instructor!);
        return Left(Failures(errorMessage: "Instructor data missing"));
      } else {
        return Left(
            Failures(errorMessage: response.data['message'] ?? 'Server Error'));
      }
    } catch (e) {
      return Left(Failures(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failures, InstructorEntity>> registerInstructor({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiManager.postData(
        ApiConstants.instructorEndpointRegister,
        body: {"name": name, "email": email, "password": password},
      );

      if (response.statusCode == 200) {
        final dto = InstructorUserDto.fromJson(response.data);
        if (dto.instructor != null) return Right(dto.instructor!);
        return Left(Failures(errorMessage: "Instructor data missing"));
      } else {
        return Left(
            Failures(errorMessage: response.data['message'] ?? 'Server Error'));
      }
    } catch (e) {
      return Left(Failures(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failures, InstructorEntity>> socialLoginInstructor({
    required String token,
  }) async {
    try {
      final response = await apiManager.postData(
        ApiConstants.instructorEndpointSocial,
        body: { "token": token},
      );

      if (response.statusCode == 200) {
        final dto = InstructorUserDto.fromJson(response.data);
        if (dto.instructor != null) return Right(dto.instructor!);
        return Left(Failures(errorMessage: "Instructor data missing"));
      } else {
        return Left(
            Failures(errorMessage: response.data['message'] ?? 'Server Error'));
      }
    } catch (e) {
      return Left(Failures(errorMessage: e.toString()));
    }
  }

  // ================== Student ==================
  @override
  Future<Either<Failures, StudentEntity>> loginStudent({
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiManager.postData(
        ApiConstants.studentEndpointLogin,
        body: {"email": email, "password": password},
      );

      if (response.statusCode == 200) {
        final dto = StudentUserDto.fromJson(response.data);
        if (dto.student != null) return Right(dto.student!);
        return Left(Failures(errorMessage: "Student data missing"));
      } else {
        return Left(
            Failures(errorMessage: response.data['message'] ?? 'Server Error'));
      }
    } catch (e) {
      return Left(Failures(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failures, StudentEntity>> registerStudent({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiManager.postData(
        ApiConstants.studentEndpointRegister,
        body: {"name": name, "email": email, "password": password},
      );

      if (response.statusCode == 200) {
        final dto = StudentUserDto.fromJson(response.data);
        if (dto.student != null) return Right(dto.student!);
        return Left(Failures(errorMessage: "Student data missing"));
      } else {
        return Left(
            Failures(errorMessage: response.data['message'] ?? 'Server Error'));
      }
    } catch (e) {
      return Left(Failures(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failures, StudentEntity>> socialLoginStudent({
    required String token,
  }) async {
    try {
      final response = await apiManager.postData(
        ApiConstants.studentEndpointSocial,
        body: { "token": token},
      );

      if (response.statusCode == 200) {
        final dto = StudentUserDto.fromJson(response.data);
        if (dto.student != null) return Right(dto.student!);
        return Left(Failures(errorMessage: "Student data missing"));
      } else {
        return Left(
            Failures(errorMessage: response.data['message'] ?? 'Server Error'));
      }
    } catch (e) {
      return Left(Failures(errorMessage: e.toString()));
    }
  }
}
