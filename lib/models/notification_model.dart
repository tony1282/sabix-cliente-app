class NotificationModel {
  final int id;
  final int? userId;
  final int? orderId;
  final String type;
  final String typeDisplay;
  final String title;
  final String message;
  final Map<String, dynamic> data;
  final bool isRead;
  final bool isArchived;
  final int priority;
  final String priorityDisplay;
  final DateTime? createdAt;
  final DateTime? readAt;
  final DateTime? expiresAt;
  final String? timeAgo;
  final bool isExpired;

  const NotificationModel({
    required this.id,
    this.userId,
    this.orderId,
    required this.type,
    required this.typeDisplay,
    required this.title,
    required this.message,
    this.data = const {},
    this.isRead = false,
    this.isArchived = false,
    this.priority = 0,
    this.priorityDisplay = '',
    this.createdAt,
    this.readAt,
    this.expiresAt,
    this.timeAgo,
    this.isExpired = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final data = rawData is Map
        ? Map<String, dynamic>.from(rawData)
        : <String, dynamic>{};

    int? parseInt(dynamic value) {
      if (value is int) return value;
      return int.tryParse(value?.toString() ?? '');
    }

    final orderFromData = parseInt(data['order_id']);

    return NotificationModel(
      id: parseInt(json['id']) ?? 0,
      userId: parseInt(json['user']),
      orderId: parseInt(json['order']) ?? orderFromData,
      type: json['type']?.toString() ?? 'system',
      typeDisplay:
          json['type_display']?.toString() ?? json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Notificación',
      message: json['message']?.toString() ?? '',
      data: data,
      isRead: json['is_read'] == true,
      isArchived: json['is_archived'] == true,
      priority: parseInt(json['priority']) ?? 0,
      priorityDisplay: json['priority_display']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      readAt: DateTime.tryParse(json['read_at']?.toString() ?? ''),
      expiresAt: DateTime.tryParse(json['expires_at']?.toString() ?? ''),
      timeAgo: json['time_ago']?.toString(),
      isExpired: json['is_expired'] == true,
    );
  }

  NotificationModel copyWith({
    bool? isRead,
    DateTime? readAt,
  }) {
    return NotificationModel(
      id: id,
      userId: userId,
      orderId: orderId,
      type: type,
      typeDisplay: typeDisplay,
      title: title,
      message: message,
      data: data,
      isRead: isRead ?? this.isRead,
      isArchived: isArchived,
      priority: priority,
      priorityDisplay: priorityDisplay,
      createdAt: createdAt,
      readAt: readAt ?? this.readAt,
      expiresAt: expiresAt,
      timeAgo: timeAgo,
      isExpired: isExpired,
    );
  }
}
