/// Entity representing a Stripe Checkout Session
class CheckoutSessionEntity {
  final String sessionId;
  final String checkoutUrl;

  CheckoutSessionEntity({
    required this.sessionId,
    required this.checkoutUrl,
  });
}

/// Entity representing the result of payment verification
class PaymentResultEntity {
  final bool success;
  final String? message;
  final List<String> enrolledCourseIds;

  PaymentResultEntity({
    required this.success,
    this.message,
    required this.enrolledCourseIds,
  });
}
