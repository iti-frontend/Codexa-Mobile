class CartEntity {
  final List<CartItemEntity>? items;
  final double? totalPrice;

  CartEntity({
    this.items,
    this.totalPrice,
  });
}

class CartItemEntity {
  final String? courseId;
  final String? title;
  final String? description;
  final double? price;
  final String? category;

  CartItemEntity({
    this.courseId,
    this.title,
    this.description,
    this.price,
    this.category,
  });
}
