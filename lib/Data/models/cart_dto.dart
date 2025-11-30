import 'package:codexa_mobile/Domain/entities/cart_entity.dart';

class CartDto extends CartEntity {
  CartDto({
    super.items,
    super.totalPrice,
  });

  factory CartDto.fromJson(Map<String, dynamic> json) {
    print('🔍 [CART_DTO] Parsing cart JSON: $json');
    
    // Try different field names for items
    List<dynamic>? itemsList = json['items'] as List<dynamic>?;
    itemsList ??= json['courses'] as List<dynamic>?;
    itemsList ??= json['cartItems'] as List<dynamic>?;
    itemsList ??= json['data'] as List<dynamic>?;
    
    print('🔍 [CART_DTO] Items list found: ${itemsList?.length ?? 0} items');
    
    // Try different field names for total price
    double? totalPrice = (json['totalPrice'] as num?)?.toDouble();
    totalPrice ??= (json['total'] as num?)?.toDouble();
    totalPrice ??= (json['totalAmount'] as num?)?.toDouble();
    totalPrice ??= (json['price'] as num?)?.toDouble();
    
    print('🔍 [CART_DTO] Total price: $totalPrice');
    
    return CartDto(
      items: itemsList
          ?.map((item) {
            try {
              if (item is Map<String, dynamic>) {
                return CartItemDto.fromJson(item);
              } else if (item is Map) {
                return CartItemDto.fromJson(Map<String, dynamic>.from(item));
              }
              return null;
            } catch (e) {
              print('⚠️ [CART_DTO] Error parsing item: $item, Error: $e');
              return null;
            }
          })
          .whereType<CartItemDto>()
          .toList(),
      totalPrice: totalPrice,
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
    print('🔍 [CART_ITEM_DTO] Parsing item: $json');
    
    // Try different field names for courseId
    String? courseId = json['courseId']?.toString();
    courseId ??= json['_id']?.toString();
    courseId ??= json['id']?.toString();
    courseId ??= json['course']?['_id']?.toString();
    courseId ??= json['course']?['id']?.toString();
    
    // Try different field names for title
    String? title = json['title']?.toString();
    title ??= json['name']?.toString();
    title ??= json['course']?['title']?.toString();
    title ??= json['course']?['name']?.toString();
    
    // Try different field names for description
    String? description = json['description']?.toString();
    description ??= json['course']?['description']?.toString();
    
    // Try different field names for price
    double? price = (json['price'] as num?)?.toDouble();
    price ??= (json['course']?['price'] as num?)?.toDouble();
    price ??= (json['amount'] as num?)?.toDouble();
    
    // Try different field names for category
    String? category = json['category']?.toString();
    category ??= json['course']?['category']?.toString();
    
    print('🔍 [CART_ITEM_DTO] Parsed - ID: $courseId, Title: $title, Price: $price');
    
    return CartItemDto(
      courseId: courseId,
      title: title,
      description: description,
      price: price,
      category: category,
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
