import 'package:codexa_mobile/Data/api_manager/api_manager.dart';
import 'package:codexa_mobile/Data/constants/api_constants.dart';
import 'package:codexa_mobile/Data/models/payment_dto.dart';
import 'package:codexa_mobile/Domain/entities/payment_entity.dart';
import 'package:codexa_mobile/Domain/failures.dart';
import 'package:codexa_mobile/Domain/repo/payment_repository.dart';
import 'package:dartz/dartz.dart';

/// Implementation of PaymentRepository
class PaymentRepositoryImpl implements PaymentRepository {
  final ApiManager apiManager;

  PaymentRepositoryImpl(this.apiManager);

  @override
  Future<Either<Failures, CheckoutSessionEntity>> createCheckoutSession({
    required List<String> courseIds,
  }) async {
    try {
      print('💳 [PAYMENT_REPO] createCheckoutSession started');
      print(
          '📤 [PAYMENT_REPO] Endpoint: ${ApiConstants.createCheckoutSession}');
      print('📤 [PAYMENT_REPO] Course IDs: $courseIds');

      final response = await apiManager.postData(
        ApiConstants.createCheckoutSession,
        body: {
          'courseIds': courseIds,
        },
      );

      print('📥 [PAYMENT_REPO] Response Status: ${response.statusCode}');
      print('📥 [PAYMENT_REPO] Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dto = CheckoutSessionDto.fromJson(response.data);
        print('✅ [PAYMENT_REPO] Checkout session created successfully');
        print('🔗 [PAYMENT_REPO] Session ID: ${dto.sessionId}');
        print('🔗 [PAYMENT_REPO] Checkout URL: ${dto.checkoutUrl}');
        return Right(dto);
      } else {
        // Handle error responses - response.data might be HTML or JSON
        String errorMsg = 'Failed to create checkout session';
        if (response.data is Map<String, dynamic>) {
          errorMsg = response.data['message']?.toString() ?? errorMsg;
        } else if (response.statusCode == 404) {
          errorMsg = 'Checkout endpoint not found (404)';
        }
        print(
            '❌ [PAYMENT_REPO] createCheckoutSession FAILED: $errorMsg (Status: ${response.statusCode})');
        return Left(Failures(errorMessage: errorMsg));
      }
    } catch (e) {
      print('💥 [PAYMENT_REPO] createCheckoutSession EXCEPTION: $e');
      return Left(Failures(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failures, PaymentResultEntity>> verifyPayment({
    required String sessionId,
  }) async {
    try {
      print('🔍 [PAYMENT_REPO] verifyPayment started');
      print('📤 [PAYMENT_REPO] Endpoint: ${ApiConstants.verifyPayment}');
      print('📤 [PAYMENT_REPO] Session ID: $sessionId');

      final response = await apiManager.postData(
        ApiConstants.verifyPayment,
        body: {
          'sessionId': sessionId,
        },
      );

      print('📥 [PAYMENT_REPO] Response Status: ${response.statusCode}');
      print(
          '📥 [PAYMENT_REPO] Response Data Type: ${response.data.runtimeType}');
      print('📥 [PAYMENT_REPO] Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Ensure we have a Map to parse
        Map<String, dynamic> jsonData;
        if (response.data is Map<String, dynamic>) {
          jsonData = response.data;
        } else if (response.data is String) {
          // If it's a string, try to decode it
          try {
            jsonData = Map<String, dynamic>.from(
                (response.data as String).isEmpty
                    ? {'success': true, 'enrolledCourses': []}
                    : {'success': true, 'message': response.data});
          } catch (_) {
            jsonData = {'success': true, 'enrolledCourses': []};
          }
        } else {
          jsonData = {'success': true, 'enrolledCourses': []};
        }

        final dto = PaymentVerificationDto.fromJson(jsonData);
        print('✅ [PAYMENT_REPO] Payment verification completed');
        print('📊 [PAYMENT_REPO] Success: ${dto.success}');
        print('📚 [PAYMENT_REPO] Enrolled Courses: ${dto.enrolledCourseIds}');
        return Right(dto);
      } else {
        // Handle error responses - response.data might be HTML or JSON
        String errorMsg = 'Failed to verify payment';
        if (response.data is Map<String, dynamic>) {
          errorMsg = response.data['message']?.toString() ?? errorMsg;
        } else if (response.statusCode == 404) {
          errorMsg =
              'Payment verification endpoint not found. Contact support.';
        }
        print(
            '❌ [PAYMENT_REPO] verifyPayment FAILED: $errorMsg (Status: ${response.statusCode})');
        return Left(Failures(errorMessage: errorMsg));
      }
    } catch (e) {
      print('💥 [PAYMENT_REPO] verifyPayment EXCEPTION: $e');
      return Left(Failures(errorMessage: e.toString()));
    }
  }
}
