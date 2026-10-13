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

    // Limpieza de esquemas (http:// o https://) y barras finales para extraer solo el host
    final cleanHost = baseUrl
        .replaceAll('https://', '')
        .replaceAll('http://', '')
        .split('/')[0]
        .split(':')[0];

    final wsUrl = 'wss://$cleanHost/ws/chat/$conversationId/?token=$token';

    debugPrint('Conectando a WebSocket: $wsUrl');

    try {
      _channel = IOWebSocketChannel.connect(Uri.parse(wsUrl));
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