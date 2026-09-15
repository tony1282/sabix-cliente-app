import 'package:flutter/material.dart';
import 'package:sabix_cliente_app/models/order_model.dart';
import 'package:sabix_cliente_app/models/product_model.dart';
import 'package:sabix_cliente_app/models/cart_item_model.dart';
import 'package:sabix_cliente_app/core/network/api_client.dart';
import 'package:sabix_cliente_app/core/network/api_endpoints.dart';
import 'package:sabix_cliente_app/core/services/local_storage_service.dart';
// lib/core/providers/cart_provider.dart

class CartProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();
  final LocalStorageService _storage = LocalStorageService();

  List<CartItem> _items = [];
  bool _isLoading = false;
  String? _error;

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get total => _items.fold(
    0,
    (sum, item) => sum + (item.price * item.quantity),
  );

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  int? get restaurantId {
    if (_items.isEmpty) return null;
    return _items.first.restaurantId;
  }

  Future<void> loadCart() async {
    _isLoading = true;
    notifyListeners();
    await _loadFromLocal();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addItem(ProductModel product, {int quantity = 1}) async {
    if (_items.isNotEmpty && _items.first.restaurantId != product.restaurantId) {
      throw Exception('Solo puedes agregar productos del mismo restaurante');
    }
    final existingIndex = _items.indexWhere((i) => i.productId == product.id);
    if (existingIndex != -1) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(CartItem(
        productId: product.id,
        restaurantId: product.restaurantId,
        name: product.name,
        price: product.price,
        imageUrl: product.imageUrl,
        quantity: quantity,
      ));
    }
    await _saveToLocal();
    notifyListeners();
  }

  Future<void> removeItem(int productId) async {
    _items.removeWhere((i) => i.productId == productId);
    await _saveToLocal();
    notifyListeners();
  }

  Future<void> updateQuantity(int productId, int newQuantity) async {
    final index = _items.indexWhere((i) => i.productId == productId);
    if (index == -1) return;
    if (newQuantity <= 0) {
      await removeItem(productId);
      return;
    }
    _items[index].quantity = newQuantity;
    await _saveToLocal();
    notifyListeners();
  }

  Future<void> clearCart() async {
    _items.clear();
    await _saveToLocal();
    notifyListeners();
  }

  // --- CHECKOUT ---
  Future<bool> checkout(OrderCreateRequest orderRequest) async {
    if (_items.isEmpty) return false;

    try {
      _isLoading = true;
      notifyListeners();

      final response = await _api.post(
        ApiEndpoints.createOrder,
        data: orderRequest.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        await clearCart();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Error al crear el pedido: ${response.data}';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // --- Persistencia local ---
  Future<void> _saveToLocal() async {
    final json = _items.map((i) => i.toJson()).toList();
    await _storage.saveCart(json);
  }

  Future<void> _loadFromLocal() async {
    final json = await _storage.getCart();
    if (json != null) {
      _items = json.map((e) => CartItem.fromJson(e)).toList();
    } else {
      _items = [];
    }
  }
}