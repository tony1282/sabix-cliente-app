import '../network/api_client.dart';
import 'package:flutter/material.dart';
import '../network/api_endpoints.dart';
import '../../models/order_model.dart';

class OrderProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();

  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // --- Obtener todos los pedidos del cliente ---
  Future<void> fetchOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.get(ApiEndpoints.myOrders);
      if (response.statusCode == 200) {
        final data = response.data;
        final list = data is List ? data : (data['results'] ?? []);
        _orders = (list as List).map((e) => Order.fromJson(e)).toList();
      } else {
        _error = 'Error al cargar pedidos: ${response.data}';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Obtener detalle de un pedido ---
  Future<Order?> fetchOrderDetail(int orderId) async {
    try {
      final response = await _api.get(ApiEndpoints.orderDetail(orderId));
      if (response.statusCode == 200) {
        return Order.fromJson(response.data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // --- Filtrar pedidos por estado ---
  List<Order> getOrdersByStatus(String? status) {
    if (status == null || status == 'Todos') return _orders;
    return _orders.where((Order o) => o.status == status).toList();
  }
}
