import 'package:codexa_mobile/Domain/entities/cart_entity.dart';
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

  CartEntity? _currentCart;
  CartEntity? get currentCart => _currentCart;

  /// Helper to calculate total price from items
  double _calculateTotalPrice(List<CartItemEntity>? items) {
    if (items == null || items.isEmpty) return 0.0;
    return items.fold(0.0, (sum, item) => sum + (item.price ?? 0.0));
  }

  /// Add a course to cart
  Future<void> addToCart(String courseId) async {
    print('🛒 [CART_CUBIT] addToCart called with courseId: $courseId');

    // Optimistic Update
    final previousCart = _currentCart;
    if (_currentCart != null) {
      final newItems = List<CartItemEntity>.from(_currentCart!.items ?? []);
      // Add a placeholder item
      newItems.add(
          CartItemEntity(courseId: courseId, title: 'Adding...', price: 0.0));
      // Recalculate total from items
      final newTotal = _calculateTotalPrice(newItems);
      _currentCart = CartEntity(items: newItems, totalPrice: newTotal);
      emit(CartLoaded(_currentCart!));
    } else {
      // If cart is null, we can't really optimistically add easily without more info,
      // but we can try to create a dummy cart.
      // For now, let's just emit loading if null.
      emit(CartLoading());
    }

    final result = await addToCartUseCase.call(courseId);

    result.fold(
      (failure) {
        print('❌ [CART_CUBIT] addToCart FAILED: ${failure.errorMessage}');
        // Revert
        _currentCart = previousCart;
        if (_currentCart != null) {
          emit(CartLoaded(_currentCart!));
        }
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
    // Only emit loading if we don't have data, or if we want to show loading indicator
    // But for badge update, we might want to keep showing data.
    // Let's emit loading only if _currentCart is null to avoid flickering?
    // Or just emit loading. The UI handles fallback.
    if (_currentCart == null) emit(CartLoading());

    final result = await getCartUseCase.call();

    result.fold(
      (failure) {
        print('❌ [CART_CUBIT] getCart FAILED: ${failure.errorMessage}');
        emit(CartError(failure.errorMessage));
      },
      (cart) {
        print('✅ [CART_CUBIT] getCart SUCCESS');
        print('📦 [CART_CUBIT] Cart items count: ${cart.items?.length ?? 0}');

        // Recalculate total from items to ensure accuracy
        final calculatedTotal = _calculateTotalPrice(cart.items);
        print('💰 [CART_CUBIT] Calculated total price: $calculatedTotal');

        // Create cart with recalculated total
        _currentCart =
            CartEntity(items: cart.items, totalPrice: calculatedTotal);
        emit(CartLoaded(_currentCart!));
      },
    );
  }

  /// Remove a course from cart
  Future<void> removeFromCart(String courseId) async {
    print('🛒 [CART_CUBIT] removeFromCart called with courseId: $courseId');

    // Optimistic Update
    final previousCart = _currentCart;
    if (_currentCart != null) {
      final newItems = List<CartItemEntity>.from(_currentCart!.items ?? []);
      newItems.removeWhere((item) => item.courseId == courseId);
      // Recalculate total from items
      final newTotal = _calculateTotalPrice(newItems);
      _currentCart = CartEntity(items: newItems, totalPrice: newTotal);
      emit(CartLoaded(_currentCart!));
    } else {
      emit(CartLoading());
    }

    final result = await removeFromCartUseCase.call(courseId);

    result.fold(
      (failure) {
        print('❌ [CART_CUBIT] removeFromCart FAILED: ${failure.errorMessage}');
        // Revert
        _currentCart = previousCart;
        if (_currentCart != null) {
          emit(CartLoaded(_currentCart!));
        }
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

  /// Reset cubit state - call this on logout
  void reset() {
    _currentCart = null;
    emit(CartInitial());
  }
}
