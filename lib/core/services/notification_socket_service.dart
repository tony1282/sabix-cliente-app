import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'local_storage_service.dart';

class NotificationSocketService {
  WebSocket? _socket;
  StreamSubscription<dynamic>? _subscription;
  Timer? _reconnectTimer;

  int? _userId;
  bool _shouldReconnect = false;
  void Function(Map<String, dynamic> data)? _onMessage;

  bool get isConnected => _socket?.readyState == WebSocket.open;

  Future<void> connect({
    required int userId,
    required void Function(Map<String, dynamic> data) onMessage,
  }) async {
    _userId = userId;
    _onMessage = onMessage;
    _shouldReconnect = true;

    await _closeCurrent();
    await _open();
  }

  Future<void> _open() async {
    if (!_shouldReconnect || _userId == null) return;

    final token = await LocalStorageService().getToken();
    final baseUrl = dotenv.env['BASE_URL'];

    if (token == null || token.isEmpty || baseUrl == null || baseUrl.isEmpty) {
      return;
    }

    try {
      final baseUri = Uri.parse(baseUrl);
      final wsUri = baseUri.replace(
        scheme: baseUri.scheme == 'https' ? 'wss' : 'ws',
        path: '/ws/notifications/$_userId/',
        queryParameters: {'token': token},
      );

      final socket = await WebSocket.connect(wsUri.toString());
      _socket = socket;

      _subscription = socket.listen(
        (event) {
          try {
            final decoded = jsonDecode(event.toString());
            if (decoded is Map) {
              _onMessage?.call(Map<String, dynamic>.from(decoded));
            }
          } catch (_) {
            // Ignorar mensajes que no tengan el formato JSON esperado.
          }
        },
        onDone: _scheduleReconnect,
        onError: (_) => _scheduleReconnect(),
        cancelOnError: true,
      );
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (!_shouldReconnect) return;

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      _closeCurrent().then((_) => _open());
    });
  }

  Future<void> _closeCurrent() async {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    await _subscription?.cancel();
    _subscription = null;

    final socket = _socket;
    _socket = null;
    if (socket != null) {
      try {
        await socket.close();
      } catch (_) {}
    }
  }

  Future<void> disconnect() async {
    _shouldReconnect = false;
    await _closeCurrent();
  }

  Future<void> dispose() async {
    await disconnect();
    _onMessage = null;
    _userId = null;
  }
}
