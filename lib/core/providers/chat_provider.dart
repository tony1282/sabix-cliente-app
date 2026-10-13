import 'package:flutter/material.dart';
import 'package:sabix_cliente_app/core/network/chat_socket_service.dart';
import 'package:sabix_cliente_app/core/services/chat_service.dart';
import 'package:sabix_cliente_app/models/chat_message_model.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService;
  final ChatSocketService _socketService = ChatSocketService();

  List<ConversationModel> _conversations = [];
  List<ChatMessageModel> _messages = [];
  int _totalUnread = 0;
  bool _isLoading = false;

  List<ConversationModel> get conversations => _conversations;
  List<ChatMessageModel> get messages => _messages;
  int get totalUnread => _totalUnread;
  bool get isLoading => _isLoading;

  ChatProvider(this._chatService);

  /// Carga lista de conversaciones (`ChatListScreen`)
  Future<void> fetchConversations() async {
    _isLoading = true;
    notifyListeners();

    try {
      _conversations = await _chatService.getConversations();
      _totalUnread = await _chatService.getTotalUnread();
    } catch (e) {
      debugPrint("Error al cargar conversaciones: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Abrir chat por Order ID (`OrderDetailScreen` -> `ChatScreen`)
  Future<ConversationModel?> getOrCreateByOrder(String orderId) async {
    try {
      return await _chatService.getConversationByOrder(orderId);
    } catch (e) {
      debugPrint("Error al obtener conversación por orden: $e");
      return null;
    }
  }

  /// Cargar mensajes e iniciar WebSocket (`ChatScreen`)
  Future<void> initChatScreen(
      String conversationId, String jwtToken, String currentUserId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Obtener historial de mensajes vía REST API
      _messages = await _chatService.getMessages(conversationId, currentUserId);
    } catch (e) {
      debugPrint("Error al obtener mensajes: $e");
      _messages = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    // 2. Conectar WebSocket para mensajes en tiempo real
    try {
      _socketService.connect(conversationId, jwtToken, (event) {
        if (event is Map && event['event'] == 'new_message' && event['data'] != null) {
          final newMsg = ChatMessageModel.fromJson(event['data'], currentUserId);

          // Si el mensaje existía temporalmente o ya estaba por REST, actualiza o añade sin duplicar
          final index = _messages.indexWhere((m) => m.id.toString() == newMsg.id.toString());
          if (index != -1) {
            _messages[index] = newMsg;
          } else {
            _messages.add(newMsg);
          }
          notifyListeners();
        }
      });
    } catch (e) {
      debugPrint("Error al conectar WebSocket: $e");
    }
  }

  /// Enviar mensaje vía API REST con UI optimista
  Future<void> sendTextMessage(
      String conversationId, String content, String currentUserId) async {
    final cleanContent = content.trim();
    if (cleanContent.isEmpty) return;

    // 1. Identificador temporal como String
    final tempIdString = DateTime.now().millisecondsSinceEpoch.toString();

    final tempMessage = ChatMessageModel(
      id: tempIdString,
      conversationId: conversationId,
      senderId: currentUserId,
      content: cleanContent,
      messageType: 'text',
      createdAt: DateTime.now(),
      isMe: true,
    );

    _messages.add(tempMessage);
    notifyListeners();

    // 2. Petición HTTP al backend
    try {
      final sentMsg = await _chatService.sendMessage(
        conversationId: conversationId,
        content: cleanContent,
        currentUserId: currentUserId,
      );

      if (sentMsg != null) {
        final tempIndex = _messages.indexWhere((m) => m.id.toString() == tempIdString);
        if (tempIndex != -1) {
          _messages[tempIndex] = sentMsg;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint("Error al enviar mensaje vía REST: $e");
    }
  }

  /// Solicitar soporte
  Future<bool> requestSupport(String conversationId, String reason) async {
    try {
      return await _chatService.requestSupport(conversationId, reason);
    } catch (e) {
      debugPrint("Error al solicitar soporte: $e");
      return false;
    }
  }

  /// Desconecta el socket y limpia el estado de mensajes
  void leaveChatScreen() {
    try {
      _socketService.disconnect();
    } catch (e) {
      debugPrint("Error al desconectar WebSocket: $e");
    }
    _messages = [];
  }
}