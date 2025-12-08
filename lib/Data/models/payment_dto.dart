import 'package:codexa_mobile/Domain/entities/payment_entity.dart';

/// DTO for Stripe Checkout Session response
class CheckoutSessionDto extends CheckoutSessionEntity {
  CheckoutSessionDto({
    required super.sessionId,
    required super.checkoutUrl,
  });

  factory CheckoutSessionDto.fromJson(Map<String, dynamic> json) {
    return CheckoutSessionDto(
      sessionId: json['sessionId']?.toString() ?? json['id']?.toString() ?? '',
      checkoutUrl: json['url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'url': checkoutUrl,
    };
  }
}

/// DTO for Payment Verification response
class PaymentVerificationDto extends PaymentResultEntity {
  PaymentVerificationDto({
    required super.success,
    super.message,
    required super.enrolledCourseIds,
  });

  factory PaymentVerificationDto.fromJson(Map<String, dynamic> json) {
    print('🔍 [PAYMENT_DTO] Parsing verification response: $json');

    // Parse enrolled courses - could be list of strings, list of objects, or null
    List<String> courseIds = [];

    try {
      final enrolledData = json['enrolledCourses'];
      if (enrolledData != null) {
        if (enrolledData is List) {
          courseIds = enrolledData
              .map((c) {
                if (c is String) return c;
                if (c is Map<String, dynamic>) {
                  return c['_id']?.toString() ?? c['id']?.toString() ?? '';
                }
                return c.toString();
              })
              .where((id) => id.isNotEmpty)
              .toList()
              .cast<String>();
        } else if (enrolledData is String) {
          // Single course ID as string
          courseIds = [enrolledData];
        }
      }
    } catch (e) {
      print('⚠️ [PAYMENT_DTO] Error parsing enrolledCourses: $e');
    }

    // Handle success field - could be bool or string
    bool isSuccess = false;
    try {
      final successData = json['success'];
      if (successData is bool) {
        isSuccess = successData;
      } else if (successData is String) {
        isSuccess = successData.toLowerCase() == 'true';
      }
    } catch (e) {
      print('⚠️ [PAYMENT_DTO] Error parsing success: $e');
    }

    print(
        '✅ [PAYMENT_DTO] Parsed - success: $isSuccess, courseIds: $courseIds');

    return PaymentVerificationDto(
      success: isSuccess,
      message: json['message']?.toString(),
      enrolledCourseIds: courseIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'enrolledCourses': enrolledCourseIds,
    };
  }
}
