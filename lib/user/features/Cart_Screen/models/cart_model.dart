class CartItem {
  final String name;
  final String size;
  final double price;
  final String image;
  final String? color;
  final dynamic productId; // Changed to dynamic to handle both int and String
  int quantity;

  CartItem({
    this.color,
    required this.name,
    required this.size,
    required this.price,
    required this.image,
    required this.productId,
    this.quantity = 1,
  });
}