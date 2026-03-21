class Slot {
  final String id;
  final String label;
  final String startTime;
  final String endTime;
  final bool isOpen;
  final int maxOrders;
  final int currentOrders;

  const Slot({
    required this.id,
    required this.label,
    required this.startTime,
    required this.endTime,
    this.isOpen = true,
    this.maxOrders = 50,
    this.currentOrders = 0,
  });

  double get fillPercentage =>
      maxOrders > 0 ? (currentOrders / maxOrders).clamp(0.0, 1.0) : 0.0;

  Slot copyWith({
    String? id,
    String? label,
    String? startTime,
    String? endTime,
    bool? isOpen,
    int? maxOrders,
    int? currentOrders,
  }) {
    return Slot(
      id: id ?? this.id,
      label: label ?? this.label,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isOpen: isOpen ?? this.isOpen,
      maxOrders: maxOrders ?? this.maxOrders,
      currentOrders: currentOrders ?? this.currentOrders,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'startTime': startTime,
    'endTime': endTime,
    'isOpen': isOpen,
    'maxOrders': maxOrders,
    'currentOrders': currentOrders,
  };

  factory Slot.fromJson(Map<String, dynamic> json) => Slot(
    id: json['id'] as String,
    label: json['label'] as String,
    startTime: json['startTime'] as String,
    endTime: json['endTime'] as String,
    isOpen: json['isOpen'] as bool? ?? true,
    maxOrders: json['maxOrders'] as int? ?? 50,
    currentOrders: json['currentOrders'] as int? ?? 0,
  );
}
