class ChatMessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final String messageType; // 'text', 'image', 'file', 'location'
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? metadata;
  final bool isMe;

  ChatMessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    this.messageType = 'text',
    required this.createdAt,
    this.isRead = false,
    this.metadata,
    required this.isMe,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json, String currentUserId) {
    // 1. Extrae senderId soportando enteros, Strings o un objeto `sender: {'id': ...}`
    String extractedSenderId = '';
    if (json['sender_id'] != null) {
      extractedSenderId = json['sender_id'].toString();
    } else if (json['sender'] != null) {
      if (json['sender'] is Map) {
        extractedSenderId = (json['sender']['id'] ?? '').toString();
      } else {
        extractedSenderId = json['sender'].toString();
      }
    }

    final cleanCurrentUserId = currentUserId.trim();
    final cleanSenderId = extractedSenderId.trim();

    // 2. Determina si el mensaje fue enviado por el usuario actual
    final bool calculatedIsMe = cleanSenderId.isNotEmpty && cleanSenderId == cleanCurrentUserId;

    return ChatMessageModel(
      id: json['id']?.toString() ?? '',
      conversationId: json['conversation']?.toString() ?? json['conversation_id']?.toString() ?? '',
      senderId: cleanSenderId,
      content: json['content'] ?? '',
      messageType: json['message_type'] ?? 'text',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      isRead: json['is_read'] ?? false,
      metadata: json['metadata'],
      isMe: calculatedIsMe,
    );
  }
}

class ConversationModel {
  final String id;
  final String orderId;
  final String title;
  final String? lastMessage;
  final int unreadCount;
  final String status; // 'active', 'closed'

  ConversationModel({
    required this.id,
    required this.orderId,
    required this.title,
    this.lastMessage,
    this.unreadCount = 0,
    required this.status,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    String? messageContent;
    if (json['last_message'] != null) {
      if (json['last_message'] is Map) {
        messageContent = json['last_message']['content'];
      } else if (json['last_message'] is String) {
        messageContent = json['last_message'];
      }
    }

    return ConversationModel(
      id: json['id']?.toString() ?? '',
      orderId: json['order_id']?.toString() ?? json['order']?.toString() ?? '',
      title: json['title'] ?? 'Conversación',
      lastMessage: messageContent,
      unreadCount: json['unread_count'] ?? 0,
      status: json['status'] ?? 'active',
    );
  }
}