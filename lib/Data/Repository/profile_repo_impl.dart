import 'package:codexa_mobile/Data/api_manager/api_manager.dart';
import 'package:codexa_mobile/Data/constants/api_constants.dart';
import 'package:codexa_mobile/Data/models/instructor_dto.dart';
import 'package:codexa_mobile/Data/models/student_dto.dart';
import 'package:codexa_mobile/Domain/entities/instructor_entity.dart';
import 'package:codexa_mobile/Domain/entities/student_entity.dart';
import 'package:codexa_mobile/Domain/failures.dart';
import 'package:codexa_mobile/Domain/repo/profile_repo.dart';
import 'package:dartz/dartz.dart';
import 'dart:io';

import 'package:dio/dio.dart';

class ProfileRepoImpl implements ProfileRepo {
  final ApiManager apiManager;

  ProfileRepoImpl(this.apiManager);

  @override
  Future<Either<Failures, StudentEntity>> updateStudentProfile(
      StudentEntity student,
      ) async {
    try {
      print('🌐 Calling API for student profile update...');
      print('🔗 Endpoint: ${ApiConstants.studentEndpointProfile}');

      // Check if we have a local file to upload
      File? imageFile;
      if (student.profileImage != null && student.profileImage!.startsWith('/')) {
        imageFile = File(student.profileImage!);
        print('📤 Found local image file to upload: ${imageFile.path}');
      }

      Response response;

      if (imageFile != null) {
        // Use multipart PUT for image upload
        print('🔄 Using multipart PUT for image upload');
        response = await apiManager.putMultipartData(  // Use the new PUT method
          ApiConstants.studentEndpointProfile,
          file: imageFile,
          fileFieldName: 'profileImage',
          fields: {
            "name": student.name ?? '',
            "email": student.email ?? '',
          },
        );
      } else {
        // Use regular PUT for text-only update
        print('🔄 Using regular PUT for text-only update');
        response = await apiManager.putData(
          ApiConstants.studentEndpointProfile,
          body: {
            "name": student.name,
            "email": student.email,
            "profileImage": student.profileImage,
          },
        );
      }

      print('📡 API Response Status: ${response.statusCode}');
      print('📡 API Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('student')) {
            print('✅ Response has student field');
            final studentData = responseData['student'];
            if (studentData is Map<String, dynamic>) {
              final updatedStudentDto = StudentDto.fromJson(studentData);
              return Right(updatedStudentDto.toEntity(student.token));
            } else {
              return Left(Failures(errorMessage: 'Student data is not a Map'));
            }
          } else {
            print('❌ Response missing student field. Available keys: ${responseData.keys}');
            return Left(Failures(errorMessage: 'Response missing student data'));
          }
        } else {
          return Left(Failures(errorMessage: 'Invalid response format'));
        }
      } else if (response.statusCode == 404) {
        return Left(Failures(errorMessage: 'Student not found'));
      } else {
        String errorMessage = 'Failed to update profile: ${response.statusCode}';

        // Handle HTML error response
        if (response.data is String && (response.data as String).contains('<html>')) {
          errorMessage = 'Server error: Invalid endpoint or method';
        } else if (response.data is Map<String, dynamic>) {
          final errorData = response.data as Map<String, dynamic>;
          errorMessage = errorData['message']?.toString() ?? errorMessage;
        }

        return Left(Failures(errorMessage: errorMessage));
      }
    } catch (e, stackTrace) {
      print('💥 API call failed: $e');
      print('📋 Stack trace: $stackTrace');
      return Left(Failures(errorMessage: 'Network error: $e'));
    }
  }

  @override
  Future<Either<Failures, InstructorEntity>> updateInstructorProfile(
      InstructorEntity instructor,
      ) async {
    try {
      print('🌐 Calling API for instructor profile update...');
      print('🔗 Endpoint: ${ApiConstants.instructorEndpointProfile}');

      // Check if we have a local file to upload
      File? imageFile;
      if (instructor.profileImage != null && instructor.profileImage!.startsWith('/')) {
        imageFile = File(instructor.profileImage!);
        print('📤 Found local image file to upload: ${imageFile.path}');
      }

      Response response;

      if (imageFile != null) {
        // Use multipart PUT for image upload
        print('🔄 Using multipart PUT for image upload');
        response = await apiManager.putMultipartData(  // Use the new PUT method
          ApiConstants.instructorEndpointProfile,
          file: imageFile,
          fileFieldName: 'profileImage',
          fields: {
            "name": instructor.name ?? '',
            "email": instructor.email ?? '',
          },
        );
      } else {
        // Use regular PUT for text-only update
        print('🔄 Using regular PUT for text-only update');
        response = await apiManager.putData(
          ApiConstants.instructorEndpointProfile,
          body: {
            "name": instructor.name,
            "email": instructor.email,
            "profileImage": instructor.profileImage,
          },
        );
      }

      print('📡 API Response Status: ${response.statusCode}');
      print('📡 API Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('instructor')) {
            print('✅ Response has instructor field');
            final instructorData = responseData['instructor'];
            if (instructorData is Map<String, dynamic>) {
              final updatedInstructorDto = InstructorDto.fromJson(instructorData);
              return Right(updatedInstructorDto.toEntity(instructor.token));
            } else {
              return Left(Failures(errorMessage: 'Instructor data is not a Map'));
            }
          } else {
            print('❌ Response missing instructor field. Available keys: ${responseData.keys}');
            return Left(Failures(errorMessage: 'Response missing instructor data'));
          }
        } else {
          return Left(Failures(errorMessage: 'Invalid response format'));
        }
      } else if (response.statusCode == 404) {
        return Left(Failures(errorMessage: 'Instructor not found'));
      } else {
        String errorMessage = 'Failed to update profile: ${response.statusCode}';

        // Handle HTML error response
        if (response.data is String && (response.data as String).contains('<html>')) {
          errorMessage = 'Server error: Invalid endpoint or method';
        } else if (response.data is Map<String, dynamic>) {
          final errorData = response.data as Map<String, dynamic>;
          errorMessage = errorData['message']?.toString() ?? errorMessage;
        }

        return Left(Failures(errorMessage: errorMessage));
      }
    } catch (e, stackTrace) {
      print('💥 API call failed: $e');
      print('📋 Stack trace: $stackTrace');
      return Left(Failures(errorMessage: 'Network error: $e'));
    }
  }
}