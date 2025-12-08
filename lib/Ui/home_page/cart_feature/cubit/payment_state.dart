import 'package:codexa_mobile/Domain/entities/payment_entity.dart';

/// Base class for all payment states
abstract class PaymentState {}

/// Initial state - no payment action taken
class PaymentInitial extends PaymentState {}

/// Loading state while creating checkout session
class PaymentLoading extends PaymentState {}

/// Checkout session created successfully, ready to open Stripe
class CheckoutSessionCreated extends PaymentState {
  final CheckoutSessionEntity session;

  CheckoutSessionCreated(this.session);
}

/// Loading state while verifying payment with backend
class PaymentVerifying extends PaymentState {}

/// Payment completed and verified successfully
class PaymentSuccess extends PaymentState {
  final List<String> enrolledCourseIds;
  final String? message;

  PaymentSuccess({
    required this.enrolledCourseIds,
    this.message,
  });
}

/// Payment verification returned failure
class PaymentFailed extends PaymentState {
  final String message;

  PaymentFailed(this.message);
}

/// User cancelled the payment
class PaymentCancelled extends PaymentState {}

/// Error occurred during payment process
class PaymentError extends PaymentState {
  final String message;

  PaymentError(this.message);
}
