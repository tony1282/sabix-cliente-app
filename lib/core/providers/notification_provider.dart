import 'package:flutter/material.dart';

import '../../models/notification_model.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../services/notification_socket_service.dart';

class NotificationProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();
  final NotificationSocketService _socket = NotificationSocketService();

  final List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;
  int? _initializedUserId;

  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;
  bool get hasUnread => _unreadCount > 0;

  NotificationProvider() {
    _api.init();
  }

  Future<void> initialize(int userId) async {
    if (_initializedUserId == userId && _socket.isConnected) {
      return;
    }

    _initializedUserId = userId;

    await Future.wait([
      fetchNotifications(),
      fetchUnreadCount(),
    ]);

    await _socket.connect(
      userId: userId,
      onMessage: _handleSocketMessage,
    );
  }

  Future<void> fetchNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.get(ApiEndpoints.notifications);
      final raw = response.data;

      List<dynamic> items = [];
      if (raw is List) {
        items = raw;
      } else if (raw is Map && raw['results'] is List) {
        items = raw['results'] as List;
      }

      _notifications
        ..clear()
        ..addAll(
          items
              .whereType<Map>()
              .map(
                (item) => NotificationModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              ),
        );
    } catch (e) {
      _error = 'No se pudieron cargar las notificaciones';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUnreadCount() async {
    try {
      final response = await _api.get(ApiEndpoints.unreadNotificationCount);
      final raw = response.data;

      if (raw is Map) {
        _unreadCount = _toInt(raw['count']) ?? 0;
        notifyListeners();
      }
    } catch (_) {
      // El historial puede seguir mostrándose aunque falle el contador.
    }
  }

  Future<bool> markAsRead(int notificationId) async {
    try {
      final response = await _api.post(
        ApiEndpoints.markNotificationRead(notificationId),
      );
      final raw = response.data;

      final index = _notifications.indexWhere(
        (notification) => notification.id == notificationId,
      );

      if (index != -1) {
        NotificationModel updated = _notifications[index].copyWith(
          isRead: true,
          readAt: DateTime.now(),
        );

        if (raw is Map && raw['notification'] is Map) {
          updated = NotificationModel.fromJson(
            Map<String, dynamic>.from(raw['notification'] as Map),
          );
        }

        _notifications[index] = updated;
      }

      if (raw is Map) {
        _unreadCount =
            _toInt(raw['unread_count']) ??
            (_unreadCount > 0 ? _unreadCount - 1 : 0);
      } else if (_unreadCount > 0) {
        _unreadCount--;
      }

      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      await _api.post(ApiEndpoints.markAllNotificationsRead);

      for (var i = 0; i < _notifications.length; i++) {
        if (!_notifications[i].isRead) {
          _notifications[i] = _notifications[i].copyWith(
            isRead: true,
            readAt: DateTime.now(),
          );
        }
      }

      _unreadCount = 0;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> refresh() async {
    await Future.wait([
      fetchNotifications(),
      fetchUnreadCount(),
    ]);
  }

  void _handleSocketMessage(Map<String, dynamic> message) {
    final type = message['type']?.toString();

    if (type == 'unread_count') {
      _unreadCount = _toInt(message['count']) ?? _unreadCount;
      notifyListeners();
      return;
    }

    if (type != 'notification' || message['data'] is! Map) {
      return;
    }

    final notification = NotificationModel.fromJson(
      Map<String, dynamic>.from(message['data'] as Map),
    );

    if (notification.id == 0) {
      return;
    }

    final index = _notifications.indexWhere(
      (item) => item.id == notification.id,
    );

    if (index == -1) {
      _notifications.insert(0, notification);
      if (!notification.isRead) {
        _unreadCount++;
      }
    } else {
      _notifications[index] = notification;
    }

    notifyListeners();
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  @override
  void dispose() {
    _socket.dispose();
    super.dispose();
  }
}
