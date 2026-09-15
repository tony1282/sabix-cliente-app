// =============================================
// MODELOS PARA ENVIAR DATOS AL BACKEND (CREAR PEDIDO)
// =============================================

class OrderCreateRequest {
  final int restaurant;
  final List<OrderItemRequest> items;
  final String deliveryAddress;
  final double? deliveryLat;
  final double? deliveryLng;
  final String? deliveryNotes;
  final String paymentMethod;
  final String? notes;

  OrderCreateRequest({
    required this.restaurant,
    required this.items,
    required this.deliveryAddress,
    this.deliveryLat,
    this.deliveryLng,
    this.deliveryNotes,
    this.paymentMethod = 'cash',
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'restaurant': restaurant,
    'items': items.map((i) => i.toJson()).toList(),
    'delivery_address': deliveryAddress,
    if (deliveryLat != null) 'delivery_lat': deliveryLat,
    if (deliveryLng != null) 'delivery_lng': deliveryLng,
    if (deliveryNotes != null && deliveryNotes!.isNotEmpty)
      'delivery_notes': deliveryNotes,
    'payment_method': paymentMethod,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
  };
}

class OrderItemRequest {
  final int productId;
  final int quantity;
  final String? notes;

  OrderItemRequest({
    required this.productId,
    required this.quantity,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'quantity': quantity,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
  };
}

// =============================================
// MODELOS PARA RECIBIR DATOS DEL BACKEND (HISTORIAL)
// =============================================

class Order {
  final int id;
  final int client;
  final String clientName;
  final int restaurant;
  final String restaurantName;
  final int? deliveryPerson;
  final String? deliveryPersonName;
  final String status;
  final String statusDisplay;
  final double total;
  final double deliveryFee;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int estimatedDeliveryTime;
  final bool isPaid;
  final int totalItems;

  // Detalle
  final double? subtotal;
  final String? deliveryAddress;
  final double? deliveryLat;
  final double? deliveryLng;
  final String? deliveryNotes;
  final String? paymentMethod;
  final String? paymentId;
  final String? notes;
  final DateTime? confirmedAt;
  final DateTime? preparingAt;
  final DateTime? readyAt;
  final DateTime? inDeliveryAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final List<OrderItem>? items;
  final Map<String, dynamic>? tracking;
  final int? clientRating;
  final String? clientComment;

  Order({
    required this.id,
    required this.client,
    required this.clientName,
    required this.restaurant,
    required this.restaurantName,
    this.deliveryPerson,
    this.deliveryPersonName,
    required this.status,
    required this.statusDisplay,
    required this.total,
    required this.deliveryFee,
    required this.createdAt,
    required this.updatedAt,
    required this.estimatedDeliveryTime,
    required this.isPaid,
    required this.totalItems,
    this.subtotal,
    this.deliveryAddress,
    this.deliveryLat,
    this.deliveryLng,
    this.deliveryNotes,
    this.paymentMethod,
    this.paymentId,
    this.notes,
    this.confirmedAt,
    this.preparingAt,
    this.readyAt,
    this.inDeliveryAt,
    this.deliveredAt,
    this.cancelledAt,
    this.items,
    this.tracking,
    this.clientRating,
    this.clientComment,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final isDetail = json.containsKey('items');

    return Order(
      id: json['id'],
      client: json['client'],
      clientName: json['client_name'] ?? '',
      restaurant: json['restaurant'],
      restaurantName: json['restaurant_name'] ?? '',
      deliveryPerson: json['delivery_person'],
      deliveryPersonName: json['delivery_person_name'],
      status: json['status'] ?? 'pending',
      statusDisplay: json['status_display'] ?? 'Pendiente',
      total: double.tryParse(json['total'].toString()) ?? 0.0,
      deliveryFee: double.tryParse(json['delivery_fee'].toString()) ?? 0.0,
      createdAt: DateTime.tryParse(json['created_at']) ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']) ?? DateTime.now(),
      estimatedDeliveryTime: json['estimated_delivery_time'] ?? 30,
      isPaid: json['is_paid'] ?? false,
      totalItems: json['total_items'] ?? 0,
      subtotal: isDetail ? double.tryParse(json['subtotal'].toString()) : null,
      deliveryAddress: json['delivery_address'],
      deliveryLat: double.tryParse(json['delivery_lat']?.toString() ?? ''),
      deliveryLng: double.tryParse(json['delivery_lng']?.toString() ?? ''),
      deliveryNotes: json['delivery_notes'],
      paymentMethod: json['payment_method'],
      paymentId: json['payment_id'],
      notes: json['notes'],
      confirmedAt: json['confirmed_at'] != null
          ? DateTime.tryParse(json['confirmed_at'])
          : null,
      preparingAt: json['preparing_at'] != null
          ? DateTime.tryParse(json['preparing_at'])
          : null,
      readyAt: json['ready_at'] != null
          ? DateTime.tryParse(json['ready_at'])
          : null,
      inDeliveryAt: json['in_delivery_at'] != null
          ? DateTime.tryParse(json['in_delivery_at'])
          : null,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.tryParse(json['delivered_at'])
          : null,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.tryParse(json['cancelled_at'])
          : null,
      items: isDetail && json['items'] != null
          ? (json['items'] as List).map((e) => OrderItem.fromJson(e)).toList()
          : null,
      tracking: json['tracking'],
      clientRating: json['client_rating'],
      clientComment: json['client_comment'],
    );
  }
}

class OrderItem {
  final int id;
  final int product;
  final String productName;
  final double productPrice;
  final int quantity;
  final double total;
  final Map<String, dynamic> selectedOptions;
  final String? notes;

  OrderItem({
    required this.id,
    required this.product,
    required this.productName,
    required this.productPrice,
    required this.quantity,
    required this.total,
    this.selectedOptions = const {},
    this.notes,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    id: json['id'],
    product: json['product'],
    productName: json['product_name'] ?? '',
    productPrice: double.tryParse(json['product_price'].toString()) ?? 0.0,
    quantity: json['quantity'] ?? 1,
    total: double.tryParse(json['total'].toString()) ?? 0.0,
    selectedOptions: json['selected_options'] ?? {},
    notes: json['notes'],
  );
}
