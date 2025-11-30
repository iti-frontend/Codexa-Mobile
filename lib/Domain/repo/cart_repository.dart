import 'package:codexa_mobile/Domain/entities/cart_entity.dart';
import 'package:codexa_mobile/Domain/failures.dart';
import 'package:dartz/dartz.dart';

abstract class CartRepository {
  /// Add a course to cart
  Future<Either<Failures, String>> addToCart(String courseId);

  /// Get cart contents
  Future<Either<Failures, CartEntity>> getCart();

  /// Remove a course from cart
  Future<Either<Failures, String>> removeFromCart(String courseId);
}
