// lib/core/services/chat_service.dart
import 'package:sabix_cliente_app/core/network/api_client.dart';
import 'package:sabix_cliente_app/core/network/api_endpoints.dart';
import 'package:sabix_cliente_app/models/chat_message_model.dart';

class ChatService {
  final ApiClient _apiClient;

  ChatService(this._apiClient);

  /// 1. Listar conversaciones del cliente
  Future<List<ConversationModel>> getConversations() async {
    final response = await _apiClient.get(ApiEndpoints.conversations);
    if (response.statusCode == 200 && response.data != null) {
      final List list = (response.data is Map && response.data.containsKey('results'))
          ? response.data['results']
          : (response.data is List ? response.data : []);
      return list.map((json) => ConversationModel.fromJson(json)).toList();
    }
    return [];
  }

  /// 3. Obtener conversación asociada a un pedido
  Future<ConversationModel?> getConversationByOrder(String orderId) async {
    final response = await _apiClient.get(ApiEndpoints.conversationByOrder(orderId));
    if (response.statusCode == 200) {
      return ConversationModel.fromJson(response.data);
    }
    return null;
  }

  /// 4. Listar mensajes de una conversación
  Future<List<ChatMessageModel>> getMessages(String conversationId, String currentUserId) async {
    final response = await _apiClient.get(ApiEndpoints.messages(conversationId));
    if (response.statusCode == 200 && response.data != null) {
      final List list = (response.data is Map && response.data.containsKey('results'))
          ? response.data['results']
          : (response.data is List ? response.data : []);
      return list.map((json) => ChatMessageModel.fromJson(json, currentUserId)).toList();
    }
    return [];
  }

  /// 5. Enviar mensaje por API REST
  Future<ChatMessageModel?> sendMessage({
    required String conversationId,
    required String content,
    String messageType = 'text',
    required String currentUserId,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.sendMessage(conversationId),
      data: {
        'content': content,
        'message_type': messageType,
      },
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return ChatMessageModel.fromJson(response.data, currentUserId);
    }
    return null;
  }

  /// 7. Marcar mensaje como leído
  Future<void> markAsRead(String conversationId, String msgId) async {
    await _apiClient.post(ApiEndpoints.markAsRead(conversationId, msgId));
  }

  /// 10. Total no leídos
  Future<int> getTotalUnread() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.totalUnread);
      if (response.statusCode == 200 && response.data is Map) {
        return response.data['unread_count'] ?? 0;
      }
    } catch (_) {}
    return 0;
  }

  /// 11. Solicitar soporte
  Future<bool> requestSupport(String conversationId, String reason, {String priority = 'medium'}) async {
    final response = await _apiClient.post(
      ApiEndpoints.requestSupport(conversationId),
      data: {'reason': reason, 'priority': priority},
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  /// 12. Cerrar conversación
  Future<bool> closeConversation(String conversationId, {String? reason}) async {
    final response = await _apiClient.post(
      ApiEndpoints.closeConversation(conversationId),
      data: {'reason': reason},
    );
    return response.statusCode == 200;
  }
}