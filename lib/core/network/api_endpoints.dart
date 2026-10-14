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
  // NOTIFICACIONES
  // ============================================
  static String notifications = '$_base/notifications/';
  static String unreadNotifications = '$_base/notifications/unread/';
  static String unreadNotificationCount = '$_base/notifications/unread/count/';
  static String notificationDetail(int id) => '$_base/notifications/$id/';
  static String markNotificationRead(int id) =>
      '$_base/notifications/$id/read/';
  static String markAllNotificationsRead = '$_base/notifications/read-all/';

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

  // ============================================
  // CHAT - CONVERSACIONES Y MENSAJES
  // ============================================
  static String conversations = '$_base/chat/conversations/';

  static String conversationByOrder(String orderId) =>
      '$_base/chat/conversations/by-order/$orderId/';

  static String messages(String conversationId) =>
      '$_base/chat/conversations/$conversationId/messages/';

  static String sendMessage(String conversationId) =>
      '$_base/chat/conversations/$conversationId/messages/';

  static String markAsRead(String conversationId, String messageId) =>
      '$_base/chat/conversations/$conversationId/messages/$messageId/read/';

  static String totalUnread = '$_base/chat/conversations/unread-count/';

  static String requestSupport(String conversationId) =>
      '$_base/chat/conversations/$conversationId/request-support/';

  static String closeConversation(String conversationId) =>
      '$_base/chat/conversations/$conversationId/close/';
}
