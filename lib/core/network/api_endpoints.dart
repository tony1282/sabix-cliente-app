// lib/core/network/api_endpoints.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiEndpoints {
  static String get _baseUrl => dotenv.env['BASE_URL']!;
  static const String _apiVersion = '/api/v1';
  static String get _base => '$_baseUrl$_apiVersion';

  // ============================================
  // LOGIN - ESPECÍFICO POR APP
  // ============================================
  static String loginClient = '$_base/users/login/client/';
  static String loginDelivery = '$_base/users/login/delivery/';
  static String loginRestaurant = '$_base/users/login/restaurant/';
  static String loginAdmin = '$_base/users/login/admin/';
  static String loginRestaurantWeb = '$_base/users/login/restaurant-web/';

  // ============================================
  // REGISTRO
  // ============================================
  static String register = '$_base/users/register/';

  // ============================================
  // LOGOUT
  // ============================================
  static String logout = '$_base/users/logout/';

  // ============================================
  // REFRESH TOKEN
  // ============================================
  static String refreshToken = '$_base/users/token/refresh/';

  // ============================================
  // USER - PERFIL
  // ============================================
  static String profile = '$_base/users/profile/';
  static String updateProfile = '$_base/users/profile/';
  static String changePassword = '$_base/users/change-password/';

  // ============================================
  // ÓRDENES
  // ============================================
  static String createOrder = '$_base/orders/client/orders/'; // ← NUEVA RUTA
  static String myOrders = '$_base/orders/client/orders/';
  static String orderDetail(int orderId) =>
      '$_base/orders/client/orders/$orderId/';

  // ============================================
  // VALIDACIONES
  // ============================================
  static String checkUsername(String username) =>
      '$_base/users/check-username/?username=$username';
  static String checkEmail(String email) =>
      '$_base/users/check-email/?email=$email';

  // ============================================
  // PRODUCTOS - PÚBLICOS (PARA CLIENTE)
  // ============================================
  static String restaurantProducts(String restaurantId) =>
      '$_base/products/restaurants/$restaurantId/products/';

  static String searchProducts = '$_base/products/search/';

  static String restaurantCategories = '$_base/products/restaurant-categories/';

  static String productDetail(String productId) =>
      '$_base/products/products/$productId/';
}
