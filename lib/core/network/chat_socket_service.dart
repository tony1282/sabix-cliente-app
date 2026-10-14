import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/io.dart';

class ChatSocketService {
  IOWebSocketChannel? _channel;

  void connect(String conversationId, String token, Function(dynamic) onMessageReceived) {
    disconnect();

    // Obtener la URL base definida en el .env
    final baseUrl = dotenv.env['BASE_URL'] ?? '';
    if (baseUrl.isEmpty || conversationId.isEmpty) {
      debugPrint('ChatSocketService: BASE_URL o conversationId vacíos');
      return;
    }

    // Construye la URI del WebSocket conservando host y puerto, y usa ws/wss
    // según el esquema de BASE_URL (igual que NotificationSocketService).
    final baseUri = Uri.parse(baseUrl);
    final wsUri = baseUri.replace(
      scheme: baseUri.scheme == 'https' ? 'wss' : 'ws',
      path: '/ws/chat/$conversationId/',
      queryParameters: {'token': token},
    );

    debugPrint('Conectando a WebSocket: $wsUri');

    try {
      _channel = IOWebSocketChannel.connect(wsUri);
      _channel?.stream.listen(
        (data) {
          debugPrint('WebSocket Evento Recibido: $data');
          try {
            final decoded = jsonDecode(data);
            onMessageReceived(decoded);
          } catch (_) {
            onMessageReceived(data);
          }
        },
        onError: (error) {
          debugPrint('WebSocket Error: $error');
        },
        onDone: () {
          debugPrint('WebSocket Conexión cerrada');
        },
      );
    } catch (e) {
      debugPrint('Excepción al conectar WebSocket: $e');
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }
}