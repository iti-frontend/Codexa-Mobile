import 'package:codexa_mobile/Domain/entities/payment_entity.dart';
import 'package:codexa_mobile/Domain/failures.dart';
import 'package:dartz/dartz.dart';

/// Repository interface for payment operations
abstract class PaymentRepository {
  /// Create a Stripe Checkout Session
  ///
  /// Returns [CheckoutSessionEntity] containing sessionId and checkout URL
  Future<Either<Failures, CheckoutSessionEntity>> createCheckoutSession({
    required List<String> courseIds,
  });

  /// Verify payment success with the backend
  ///
  /// Returns [PaymentResultEntity] with success status and enrolled courses
  Future<Either<Failures, PaymentResultEntity>> verifyPayment({
    required String sessionId,
  });
}
