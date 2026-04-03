class PopularItem {
  final String name;
  final int orderCount;

  const PopularItem({required this.name, required this.orderCount});

  factory PopularItem.fromJson(Map<String, dynamic> json) => PopularItem(
    name: json['name'] as String? ?? 'Unknown',
    orderCount: (json['sold'] as num?)?.toInt() ?? (json['orderCount'] as num?)?.toInt() ?? 0,
  );
}

class SlotStat {
  final String startTime;
  final String endTime;
  final int currentOrders;
  final int maxCapacity;

  const SlotStat({
    required this.startTime,
    required this.endTime,
    required this.currentOrders,
    required this.maxCapacity,
  });

  factory SlotStat.fromJson(Map<String, dynamic> json) => SlotStat(
    startTime: json['startTime'] as String? ?? '',
    endTime: json['endTime'] as String? ?? '',
    currentOrders: (json['currentOrders'] as num?)?.toInt() ?? 0,
    maxCapacity: (json['maxCapacity'] as num?)?.toInt() ?? 0,
  );
}

class DashboardSummary {
  final int totalOrders;
  final double revenue;
  final int activeOrders;
  final int completedOrders;
  final int cancelledOrders;
  final int pendingOrders;
  final List<PopularItem> popularItems;
  final List<SlotStat> slotStats;

  const DashboardSummary({
    required this.totalOrders,
    this.revenue = 0,
    this.activeOrders = 0,
    this.completedOrders = 0,
    this.cancelledOrders = 0,
    this.pendingOrders = 0,
    this.popularItems = const [],
    this.slotStats = const [],
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    // Parse topItems / popularItems
    List<PopularItem> items = [];
    if (json['topItems'] is List) {
      items = (json['topItems'] as List)
          .map((e) => PopularItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (json['popularItems'] is List) {
      items = (json['popularItems'] as List)
          .map((e) => PopularItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // Parse slotStats
    List<SlotStat> slots = [];
    if (json['slotStats'] is List) {
      slots = (json['slotStats'] as List)
          .map((e) => SlotStat.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // Derive active orders from slotStats if not provided directly
    final activeFromSlots = slots.fold<int>(0, (sum, s) => sum + s.currentOrders);

    return DashboardSummary(
      totalOrders: (json['totalOrders'] as num?)?.toInt() ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
      activeOrders: (json['activeOrders'] as num?)?.toInt() ?? activeFromSlots,
      completedOrders: (json['completedOrders'] as num?)?.toInt() ?? 0,
      cancelledOrders: (json['cancelledOrders'] as num?)?.toInt() ?? 0,
      pendingOrders: (json['pendingOrders'] as num?)?.toInt() ?? 0,
      popularItems: items,
      slotStats: slots,
    );
  }
}
