// lib/models/product_model.dart

class RestaurantCategoryModel {
  final int id;
  final String name;
  final String? description;

  RestaurantCategoryModel({
    required this.id,
    required this.name,
    this.description,
  });

  factory RestaurantCategoryModel.fromJson(Map<String, dynamic> json) =>
      RestaurantCategoryModel(
        id: json['id'],
        name: json['name'] ?? '',
        description: json['description'],
      );
}

class ProductModel {
  final int id;
  final int restaurantId;
  final String restaurantName;
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;
  final bool isAvailable;
  final int? categoryId;
  final String? categoryName;

  ProductModel({
    required this.id,
    required this.restaurantId,
    required this.restaurantName,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    required this.isAvailable,
    this.categoryId,
    this.categoryName,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    id: json['id'],
    restaurantId: json['restaurant'] ?? json['restaurant_id'] ?? 0,
    restaurantName: json['restaurant_name'] ?? '',
    name: json['name'] ?? '',
    description: json['description'],
    price: double.tryParse(json['price'].toString()) ?? 0.0,
    imageUrl: json['image'] ?? json['image_url'],
    isAvailable: json['is_available'] ?? true,
    categoryId: json['category'],
    categoryName: json['category_name'],
  );
}
