import 'package:codexa_mobile/Domain/entities/cart_entity.dart';
import 'package:codexa_mobile/Domain/failures.dart';
import 'package:codexa_mobile/Domain/repo/cart_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case for adding a course to cart
class AddToCartUseCase {
  final CartRepository repository;

  AddToCartUseCase(this.repository);

  Future<Either<Failures, String>> call(String courseId) async {
    return await repository.addToCart(courseId);
  }
}

/// Use case for getting cart contents
class GetCartUseCase {
  final CartRepository repository;

  GetCartUseCase(this.repository);

  Future<Either<Failures, CartEntity>> call() async {
    return await repository.getCart();
  }
}

/// Use case for removing a course from cart
class RemoveFromCartUseCase {
  final CartRepository repository;

  RemoveFromCartUseCase(this.repository);

  Future<Either<Failures, String>> call(String courseId) async {
    return await repository.removeFromCart(courseId);
  }
}
