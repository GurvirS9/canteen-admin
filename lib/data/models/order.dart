enum OrderStatus {
  pending,
  preparing,
  ready,
  collected;

  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.collected:
        return 'Collected';
    }
  }

  /// The next valid status in the backend's linear flow.
  /// Returns null if this is the terminal status.
  OrderStatus? get nextStatus {
    switch (this) {
      case OrderStatus.pending:
        return OrderStatus.preparing;
      case OrderStatus.preparing:
        return OrderStatus.ready;
      case OrderStatus.ready:
        return OrderStatus.collected;
      case OrderStatus.collected:
        return null;
    }
  }
}

class OrderItem {
  final String menuItemId;
  final String name;
  final int quantity;
  final double price;

  const OrderItem({
    required this.menuItemId,
    required this.name,
    required this.quantity,
    required this.price,
  });

  double get total => quantity * price;

  Map<String, dynamic> toJson() {
    return {
      'menuItem': menuItemId,
      'quantity': quantity,
      'name': name,
      'price': price,
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    // Handle populated menuItem (object) or plain string id
    final menuItemField = json['menuItem'];
    String menuItemId = '';
    String name = json['name'] as String? ?? 'Unknown Item';
    double price = (json['price'] as num?)?.toDouble() ?? 0.0;

    if (menuItemField is Map<String, dynamic>) {
      // Populated: { _id: '...', name: '...', price: ... }
      menuItemId = menuItemField['_id']?.toString() ?? menuItemField['id']?.toString() ?? '';
      name = menuItemField['name'] as String? ?? name;
      price = (menuItemField['price'] as num?)?.toDouble() ?? price;
    } else if (menuItemField is String) {
      menuItemId = menuItemField;
    }

    // Also check menuItemId field for older formats
    if (menuItemId.isEmpty) {
      menuItemId = json['menuItemId'] as String? ?? '';
    }

    return OrderItem(
      menuItemId: menuItemId,
      name: name,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      price: price,
    );
  }
}

class Order {
  final String id;
  final List<OrderItem> items;
  final double totalAmount;
  final OrderStatus status;
  final String customerName;
  final String? customerPhone;
  final DateTime createdAt;
  final String? slotId;
  final String? notes;

  const Order({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.customerName,
    this.customerPhone,
    required this.createdAt,
    this.slotId,
    this.notes,
  });

  /// Short ID for display (last 6 hex characters of MongoDB ObjectID)
  String get shortId {
    final raw = id.replaceAll('-', '');
    return raw.length > 6 ? raw.substring(raw.length - 6).toUpperCase() : raw.toUpperCase();
  }

  Order copyWith({
    String? id,
    List<OrderItem>? items,
    double? totalAmount,
    OrderStatus? status,
    String? customerName,
    String? customerPhone,
    DateTime? createdAt,
    String? slotId,
    String? notes,
  }) {
    return Order(
      id: id ?? this.id,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      createdAt: createdAt ?? this.createdAt,
      slotId: slotId ?? this.slotId,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': customerName,
      'items': items.map((e) => e.toJson()).toList(),
      'slotId': slotId ?? '',
      'status': status.name,
      'totalAmount': totalAmount,
      'notes': notes,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    // Parse items — backend now returns full populated array
    List<OrderItem> parsedItems = [];
    final itemsField = json['items'];

    if (itemsField is List) {
      parsedItems = itemsField
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // Parse slotId — might be an object or a string
    String? slotId;
    final slotField = json['slotId'];
    if (slotField is Map<String, dynamic>) {
      slotId = slotField['_id']?.toString() ?? slotField['id']?.toString();
    } else if (slotField is String) {
      slotId = slotField;
    }

    // Parse customerName — backend now returns customerName directly
    // but userId might still be an object or string in some endpoints
    String customerName = 'Unknown Customer';
    final customerNameField = json['customerName'];
    if (customerNameField is String && customerNameField.isNotEmpty) {
      customerName = customerNameField;
    } else {
      final userIdField = json['userId'];
      if (userIdField is Map<String, dynamic>) {
        customerName = userIdField['name'] as String? ?? 'Unknown Customer';
      }
      // If it's just an ID string, keep fallback
    }

    // Parse totalAmount — prefer backend-calculated value, fallback to item sum
    double totalAmount = (json['totalAmount'] as num?)?.toDouble() ?? 0.0;
    if (totalAmount == 0.0 && parsedItems.isNotEmpty) {
      totalAmount = parsedItems.fold(0.0, (sum, item) => sum + item.total);
    }

    return Order(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      items: parsedItems,
      totalAmount: totalAmount,
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      customerName: customerName,
      customerPhone: json['customerPhone'] as String?,
      createdAt: _parseDateTime(json['createdAt'] ?? json['timestamp']),
      slotId: slotId,
      notes: json['notes'] as String?,
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}
