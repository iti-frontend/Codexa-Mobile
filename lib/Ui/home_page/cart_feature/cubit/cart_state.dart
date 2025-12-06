import 'package:codexa_mobile/Domain/entities/cart_entity.dart';

abstract class CartState {}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final CartEntity cart;

  CartLoaded(this.cart);
}

class CartError extends CartState {
  final String message;

  CartError(this.message);
}

class AddToCartSuccess extends CartState {
  final String message;

  AddToCartSuccess(this.message);
}

class AddToCartError extends CartState {
  final String message;

  AddToCartError(this.message);
}

class RemoveFromCartSuccess extends CartState {
  final String message;

  RemoveFromCartSuccess(this.message);
}

class RemoveFromCartError extends CartState {
  final String message;

  RemoveFromCartError(this.message);
}
