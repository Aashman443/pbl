class CartItems {
  final String name;
  final String brand;
  final String size;
  final double price;
  final String image;
  final dynamic productId;
  int quantity;

  CartItems({
    required this.name,
    required this.brand,
    required this.size,
    required this.price,
    required this.image,
    required this.productId,
    this.quantity = 1,
  });
}
