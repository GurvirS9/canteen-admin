enum OrderStatus {
  pending,
  accepted,
  preparing,
  ready,
  completed,
  cancelled;

  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.accepted:
        return 'Accepted';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
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

  Map<String, dynamic> toJson() => {
    'menuItemId': menuItemId,
    'name': name,
    'quantity': quantity,
    'price': price,
  };

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    menuItemId: json['menuItemId'] as String,
    name: json['name'] as String,
    quantity: json['quantity'] as int,
    price: (json['price'] as num).toDouble(),
  );
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'items': items.map((e) => e.toJson()).toList(),
    'totalAmount': totalAmount,
    'status': status.name,
    'customerName': customerName,
    'customerPhone': customerPhone,
    'createdAt': createdAt.toIso8601String(),
    'slotId': slotId,
    'notes': notes,
  };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json['id'] as String,
    items: (json['items'] as List)
        .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
        .toList(),
    totalAmount: (json['totalAmount'] as num).toDouble(),
    status: OrderStatus.values.byName(json['status'] as String),
    customerName: json['customerName'] as String,
    customerPhone: json['customerPhone'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
    slotId: json['slotId'] as String?,
    notes: json['notes'] as String?,
  );
}
