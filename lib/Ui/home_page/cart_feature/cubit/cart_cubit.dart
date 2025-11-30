import 'package:codexa_mobile/Domain/usecases/cart/cart_usecases.dart';
import 'package:codexa_mobile/Ui/home_page/cart_feature/cubit/cart_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CartCubit extends Cubit<CartState> {
  final AddToCartUseCase addToCartUseCase;
  final GetCartUseCase getCartUseCase;
  final RemoveFromCartUseCase removeFromCartUseCase;

  CartCubit({
    required this.addToCartUseCase,
    required this.getCartUseCase,
    required this.removeFromCartUseCase,
  }) : super(CartInitial());

  /// Add a course to cart
  Future<void> addToCart(String courseId) async {
    print('🛒 [CART_CUBIT] addToCart called with courseId: $courseId');
    emit(CartLoading());

    final result = await addToCartUseCase.call(courseId);

    result.fold(
      (failure) {
        print('❌ [CART_CUBIT] addToCart FAILED: ${failure.errorMessage}');
        emit(AddToCartError(failure.errorMessage));
      },
      (message) {
        print('✅ [CART_CUBIT] addToCart SUCCESS: $message');
        emit(AddToCartSuccess(message));
        // Refresh cart after adding
        print('🔄 [CART_CUBIT] Refreshing cart...');
        getCart();
      },
    );
  }

  /// Get cart contents
  Future<void> getCart() async {
    print('🛒 [CART_CUBIT] getCart called');
    emit(CartLoading());

    final result = await getCartUseCase.call();

    result.fold(
      (failure) {
        print('❌ [CART_CUBIT] getCart FAILED: ${failure.errorMessage}');
        emit(CartError(failure.errorMessage));
      },
      (cart) {
        print('✅ [CART_CUBIT] getCart SUCCESS');
        print('📦 [CART_CUBIT] Cart items count: ${cart.items?.length ?? 0}');
        print('💰 [CART_CUBIT] Total price: ${cart.totalPrice}');
        emit(CartLoaded(cart));
      },
    );
  }

  /// Remove a course from cart
  Future<void> removeFromCart(String courseId) async {
    print('🛒 [CART_CUBIT] removeFromCart called with courseId: $courseId');

    final result = await removeFromCartUseCase.call(courseId);

    result.fold(
      (failure) {
        print('❌ [CART_CUBIT] removeFromCart FAILED: ${failure.errorMessage}');
        emit(RemoveFromCartError(failure.errorMessage));
      },
      (message) {
        print('✅ [CART_CUBIT] removeFromCart SUCCESS: $message');
        emit(RemoveFromCartSuccess(message));
        // Refresh cart after removing
        print('🔄 [CART_CUBIT] Refreshing cart...');
        getCart();
      },
    );
  }
}
