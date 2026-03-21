class PopularItem {
  final String name;
  final int orderCount;

  const PopularItem({required this.name, required this.orderCount});
}

class DashboardSummary {
  final int totalOrders;
  final double revenue;
  final int activeOrders;
  final int completedOrders;
  final int cancelledOrders;
  final int pendingOrders;
  final List<PopularItem> popularItems;

  const DashboardSummary({
    required this.totalOrders,
    required this.revenue,
    required this.activeOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.pendingOrders,
    this.popularItems = const [],
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) =>
      DashboardSummary(
        totalOrders: json['totalOrders'] as int? ?? 0,
        revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
        activeOrders: json['activeOrders'] as int? ?? 0,
        completedOrders: json['completedOrders'] as int? ?? 0,
        cancelledOrders: json['cancelledOrders'] as int? ?? 0,
        pendingOrders: json['pendingOrders'] as int? ?? 0,
      );
}
