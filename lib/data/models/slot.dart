class Slot {
  final String id;
  final String label;
  final String startTime;
  final String endTime;
  final bool isOpen;
  final int maxOrders;
  final int currentOrders;
  final String? date;

  const Slot({
    required this.id,
    required this.label,
    required this.startTime,
    required this.endTime,
    this.isOpen = true,
    this.maxOrders = 50,
    this.currentOrders = 0,
    this.date,
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
    String? date,
  }) {
    return Slot(
      id: id ?? this.id,
      label: label ?? this.label,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isOpen: isOpen ?? this.isOpen,
      maxOrders: maxOrders ?? this.maxOrders,
      currentOrders: currentOrders ?? this.currentOrders,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date ?? DateTime.now().toIso8601String().split('T')[0],
    'startTime': startTime,
    'endTime': endTime,
    'maxCapacity': maxOrders,
    'currentOrders': currentOrders,
    'status': isOpen ? 'open' : 'closed',
  };

  factory Slot.fromJson(Map<String, dynamic> json) => Slot(
    id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
    label: json['label'] as String? ?? '${json['startTime']} - ${json['endTime']}',
    startTime: json['startTime'] as String? ?? '',
    endTime: json['endTime'] as String? ?? '',
    isOpen: (json['status'] as String?) == 'open' || (json['isOpen'] as bool? ?? true),
    maxOrders: (json['maxCapacity'] as num?)?.toInt() ?? json['maxOrders'] as int? ?? 50,
    currentOrders: (json['currentOrders'] as num?)?.toInt() ?? 0,
    date: json['date'] as String?,
  );
}
