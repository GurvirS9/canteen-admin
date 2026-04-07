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

  bool get isCurrent {
    final now = DateTime.now();
    final today = now.toIso8601String().split('T')[0];
    if (date != null && date != today) return false;

    try {
      final start = _parseTime(startTime);
      final end = _parseTime(endTime);
      final nowMins = now.hour * 60 + now.minute;
      return nowMins >= start && nowMins < end;
    } catch (_) {
      return false;
    }
  }

  bool get isUpcoming {
    final now = DateTime.now();
    final today = now.toIso8601String().split('T')[0];
    if (date != null && date != today) return false;

    try {
      final start = _parseTime(startTime);
      final nowMins = now.hour * 60 + now.minute;
      return start > nowMins;
    } catch (_) {
      return false;
    }
  }

  bool get isPassed {
    final now = DateTime.now();
    final today = now.toIso8601String().split('T')[0];
    if (date != null && date != today) return false;

    try {
      final end = _parseTime(endTime);
      final nowMins = now.hour * 60 + now.minute;
      return end <= nowMins;
    } catch (_) {
      return false;
    }
  }

  int _parseTime(String time) {
    // Handles formats like "13:20", "01:20 PM", "1:20 PM"
    final parts = time.split(' ');
    if (parts.length == 1) {
      final t = parts[0].split(':');
      return int.parse(t[0]) * 60 + int.parse(t[1]);
    } else {
      final t = parts[0].split(':');
      int h = int.parse(t[0]);
      int m = int.parse(t[1]);
      if (parts[1].toUpperCase() == 'PM' && h < 12) h += 12;
      if (parts[1].toUpperCase() == 'AM' && h == 12) h = 0;
      return h * 60 + m;
    }
  }

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
    isOpen: json['status'] != null ? json['status'] != 'closed' : (json['isOpen'] as bool? ?? true),
    maxOrders: (json['maxCapacity'] as num?)?.toInt() ?? json['maxOrders'] as int? ?? 50,
    currentOrders: (json['currentOrders'] as num?)?.toInt() ?? 0,
    date: json['date'] as String?,
  );
}
