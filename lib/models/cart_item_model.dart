class CartItem {
  final int productId;
  final int restaurantId; // ← Necesario para el checkout
  final String name;
  final double price;
  final String? imageUrl;
  int quantity;

  CartItem({
    required this.productId,
    required this.restaurantId,
    required this.name,
    required this.price,
    this.imageUrl,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'restaurant_id': restaurantId,
    'name': name,
    'price': price,
    'image_url': imageUrl,
    'quantity': quantity,
  };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    productId: json['product_id'],
    restaurantId: json['restaurant_id'],
    name: json['name'],
    price: (json['price'] as num).toDouble(),
    imageUrl: json['image_url'],
    quantity: json['quantity'] ?? 1,
  );
}
