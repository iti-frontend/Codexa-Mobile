import 'package:codexa_mobile/Data/api_manager/api_manager.dart';
import 'package:codexa_mobile/Data/constants/api_constants.dart';
import 'package:codexa_mobile/Data/models/cart_dto.dart';
import 'package:codexa_mobile/Domain/entities/cart_entity.dart';
import 'package:codexa_mobile/Domain/failures.dart';
import 'package:codexa_mobile/Domain/repo/cart_repository.dart';
import 'package:dartz/dartz.dart';

class CartRepositoryImpl implements CartRepository {
  final ApiManager apiManager;

  CartRepositoryImpl(this.apiManager);

  @override
  Future<Either<Failures, String>> addToCart(String courseId) async {
    try {
      print('🌐 [CART_REPO] addToCart API call started');
      print('📤 [CART_REPO] Endpoint: ${ApiConstants.addToCart}');
      print('📤 [CART_REPO] Body: {courseId: $courseId}');

      final response = await apiManager.postData(
        ApiConstants.addToCart,
        body: {'courseId': courseId},
      );

      print('📥 [CART_REPO] Response Status: ${response.statusCode}');
      print('📥 [CART_REPO] Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final message =
            response.data['message'] ?? 'Added to cart successfully';
        print('✅ [CART_REPO] addToCart SUCCESS: $message');
        return Right(message);
      } else {
        final errorMsg =
            response.data?['message']?.toString() ?? 'Failed to add to cart';
        print('❌ [CART_REPO] addToCart FAILED: $errorMsg');
        return Left(Failures(errorMessage: errorMsg));
      }
    } catch (e) {
      print('💥 [CART_REPO] addToCart EXCEPTION: $e');
      return Left(Failures(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failures, CartEntity>> getCart() async {
    try {
      print('🌐 [CART_REPO] getCart API call started');
      print('📤 [CART_REPO] Endpoint: ${ApiConstants.getCart}');

      final response = await apiManager.getData(ApiConstants.getCart);

      print('📥 [CART_REPO] Response Status: ${response.statusCode}');
      print('📥 [CART_REPO] Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final cartDto = CartDto.fromJson(response.data);
        print('✅ [CART_REPO] getCart SUCCESS');
        print('📦 [CART_REPO] Items: ${cartDto.items?.length ?? 0}');
        print('💰 [CART_REPO] Total: ${cartDto.totalPrice}');
        return Right(cartDto);
      } else {
        final errorMsg =
            response.data?['message']?.toString() ?? 'Failed to get cart';
        print('❌ [CART_REPO] getCart FAILED: $errorMsg');
        return Left(Failures(errorMessage: errorMsg));
      }
    } catch (e) {
      print('💥 [CART_REPO] getCart EXCEPTION: $e');
      return Left(Failures(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failures, String>> removeFromCart(String courseId) async {
    try {
      print('🌐 [CART_REPO] removeFromCart API call started');
      print(
          '📤 [CART_REPO] Endpoint: ${ApiConstants.removeFromCart(courseId)}');

      final response = await apiManager.deleteData(
        ApiConstants.removeFromCart(courseId),
      );

      print('📥 [CART_REPO] Response Status: ${response.statusCode}');
      print('📥 [CART_REPO] Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final message =
            response.data['message'] ?? 'Removed from cart successfully';
        print('✅ [CART_REPO] removeFromCart SUCCESS: $message');
        return Right(message);
      } else {
        final errorMsg = response.data?['message']?.toString() ??
            'Failed to remove from cart';
        print('❌ [CART_REPO] removeFromCart FAILED: $errorMsg');
        return Left(Failures(errorMessage: errorMsg));
      }
    } catch (e) {
      print('💥 [CART_REPO] removeFromCart EXCEPTION: $e');
      return Left(Failures(errorMessage: e.toString()));
    }
  }
}
