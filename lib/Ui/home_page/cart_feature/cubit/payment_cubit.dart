import 'package:codexa_mobile/Domain/usecases/payment/payment_usecases.dart';
import 'package:codexa_mobile/Ui/home_page/cart_feature/cubit/payment_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Cubit for managing payment flow state
class PaymentCubit extends Cubit<PaymentState> {
  final CreateCheckoutSessionUseCase createCheckoutSessionUseCase;
  final VerifyPaymentUseCase verifyPaymentUseCase;

  /// Store the current session ID for verification
  String? _currentSessionId;
  String? get currentSessionId => _currentSessionId;

  PaymentCubit({
    required this.createCheckoutSessionUseCase,
    required this.verifyPaymentUseCase,
  }) : super(PaymentInitial());

  /// Initiate payment by creating a Stripe checkout session
  ///
  /// [courseIds] - List of course IDs to purchase
  Future<void> initiatePayment(List<String> courseIds) async {
    if (courseIds.isEmpty) {
      emit(PaymentError('No courses selected for payment'));
      return;
    }

    print(
        '💳 [PAYMENT_CUBIT] Initiating payment for ${courseIds.length} courses');
    emit(PaymentLoading());

    final result =
        await createCheckoutSessionUseCase.call(courseIds: courseIds);

    result.fold(
      (failure) {
        print(
            '❌ [PAYMENT_CUBIT] Failed to create checkout session: ${failure.errorMessage}');
        emit(PaymentError(failure.errorMessage));
      },
      (session) {
        print('✅ [PAYMENT_CUBIT] Checkout session created');
        print('🔗 [PAYMENT_CUBIT] Session ID: ${session.sessionId}');
        _currentSessionId = session.sessionId;
        emit(CheckoutSessionCreated(session));
      },
    );
  }

  /// Handle payment success when returning from Stripe WebView
  ///
  /// Since the backend uses Stripe webhooks for enrollment,
  /// we don't need to call a verify endpoint. The webhook handles
  /// the enrollment automatically, so we just emit success here.
  ///
  /// [sessionId] - The Stripe session ID (for logging)
  void handlePaymentSuccess(String sessionId) {
    print('✅ [PAYMENT_CUBIT] Payment completed for session: $sessionId');
    print(
        'ℹ️  [PAYMENT_CUBIT] Backend webhook will handle enrollment automatically');

    // Emit success - courses will be refreshed by the UI
    emit(PaymentSuccess(
      enrolledCourseIds: [], // Webhook handles enrollment, we'll refresh courses
      message: 'Payment completed successfully!',
    ));
  }

  /// Verify payment completion with the backend (if endpoint exists)
  ///
  /// [sessionId] - The Stripe session ID to verify
  /// NOTE: This is currently not used since backend uses webhooks
  Future<void> verifyPayment(String sessionId) async {
    print('🔍 [PAYMENT_CUBIT] Verifying payment for session: $sessionId');
    emit(PaymentVerifying());

    final result = await verifyPaymentUseCase.call(sessionId: sessionId);

    result.fold(
      (failure) {
        print(
            '❌ [PAYMENT_CUBIT] Payment verification failed: ${failure.errorMessage}');
        emit(PaymentError(failure.errorMessage));
      },
      (paymentResult) {
        if (paymentResult.success) {
          print('✅ [PAYMENT_CUBIT] Payment verified successfully');
          print(
              '📚 [PAYMENT_CUBIT] Enrolled in ${paymentResult.enrolledCourseIds.length} courses');
          emit(PaymentSuccess(
            enrolledCourseIds: paymentResult.enrolledCourseIds,
            message: paymentResult.message,
          ));
        } else {
          print('❌ [PAYMENT_CUBIT] Payment not completed');
          emit(PaymentFailed(
              paymentResult.message ?? 'Payment was not completed'));
        }
      },
    );
  }

  /// Mark payment as cancelled by user
  void cancelPayment() {
    print('🚫 [PAYMENT_CUBIT] Payment cancelled by user');
    _currentSessionId = null;
    emit(PaymentCancelled());
  }

  /// Reset to initial state
  void reset() {
    print('🔄 [PAYMENT_CUBIT] Resetting payment state');
    _currentSessionId = null;
    emit(PaymentInitial());
  }
}
