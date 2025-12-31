import 'package:codexa_mobile/Domain/entities/payment_entity.dart';
import 'package:codexa_mobile/Domain/failures.dart';
import 'package:codexa_mobile/Domain/repo/payment_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case for creating a Stripe Checkout Session
class CreateCheckoutSessionUseCase {
  final PaymentRepository repository;

  CreateCheckoutSessionUseCase(this.repository);

  /// Creates a checkout session for the given course IDs
  ///
  /// Returns [CheckoutSessionEntity] containing the Stripe checkout URL
  Future<Either<Failures, CheckoutSessionEntity>> call({
    required List<String> courseIds,
  }) async {
    return await repository.createCheckoutSession(courseIds: courseIds);
  }
}

/// Use case for verifying payment success
class VerifyPaymentUseCase {
  final PaymentRepository repository;

  VerifyPaymentUseCase(this.repository);

  /// Verifies payment completion with the backend
  ///
  /// Returns [PaymentResultEntity] with success status and enrolled courses
  Future<Either<Failures, PaymentResultEntity>> call({
    required String sessionId,
  }) async {
    return await repository.verifyPayment(sessionId: sessionId);
  }
}
