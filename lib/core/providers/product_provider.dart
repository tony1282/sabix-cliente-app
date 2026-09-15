import '../network/api_client.dart';
import 'package:flutter/material.dart';
import '../network/api_endpoints.dart';
import '../../models/product_model.dart'; // ✅ Importa RestaurantCategoryModel

class ProductProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  List<ProductModel> _products = [];
  List<RestaurantCategoryModel> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ProductModel> get products => _products;
  List<RestaurantCategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ProductProvider() {
    _apiClient.init();
  }

  Future<void> fetchRestaurantProducts(String restaurantId) async {
    _setLoading(true);
    _clearError();
    try {
      final response = await _apiClient.get(
        ApiEndpoints.restaurantProducts(restaurantId),
      );
      if (response.statusCode == 200) {
        final data = response.data;
        final list = data is List ? data : (data['results'] ?? []);
        _products = (list as List)
            .map((e) => ProductModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      _setError('Error al cargar productos');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> searchProducts(String query) async {
    _setLoading(true);
    _clearError();
    try {
      final response = await _apiClient.get(
        ApiEndpoints.searchProducts,
        params: {'q': query},
      );
      if (response.statusCode == 200) {
        final data = response.data;
        final list = data is List ? data : (data['results'] ?? []);
        _products = (list as List)
            .map((e) => ProductModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      _setError('Error al buscar productos');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchCategories() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.restaurantCategories);
      if (response.statusCode == 200) {
        final data = response.data;
        final list = data is List ? data : (data['results'] ?? []);
        _categories = (list as List)
            .map((e) => RestaurantCategoryModel.fromJson(e))
            .toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
