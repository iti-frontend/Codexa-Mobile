import 'package:codexa_mobile/Domain/entities/cart_entity.dart';

class CartDto extends CartEntity {
  CartDto({
    super.items,
    super.totalPrice,
  });

  factory CartDto.fromJson(Map<String, dynamic> json) {
    return CartDto(
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => CartItemDto.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalPrice: (json['totalPrice'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items?.map((item) => (item as CartItemDto).toJson()).toList(),
      'totalPrice': totalPrice,
    };
  }
}

class CartItemDto extends CartItemEntity {
  CartItemDto({
    super.courseId,
    super.title,
    super.description,
    super.price,
    super.category,
  });

  factory CartItemDto.fromJson(Map<String, dynamic> json) {
    return CartItemDto(
      courseId: json['courseId']?.toString(),
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      price: (json['price'] as num?)?.toDouble(),
      category: json['category']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'title': title,
      'description': description,
      'price': price,
      'category': category,
    };
  }
}
