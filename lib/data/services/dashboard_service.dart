import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:manager_app/data/models/dashboard_summary.dart';
import 'package:manager_app/data/models/order.dart';
import 'package:manager_app/core/utils/demo_data.dart';
import 'package:manager_app/data/services/api_config.dart';

class DashboardService {
  Future<DashboardSummary> fetchSummary() async {
    if (ApiConfig.isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 600));
      final orders = DemoData.orders;
      final completed = orders
          .where((o) => o.status == OrderStatus.completed)
          .toList();
      final active = orders
          .where(
            (o) =>
                o.status == OrderStatus.accepted ||
                o.status == OrderStatus.preparing ||
                o.status == OrderStatus.ready,
          )
          .toList();
      final pending = orders
          .where((o) => o.status == OrderStatus.pending)
          .toList();
      final cancelled = orders
          .where((o) => o.status == OrderStatus.cancelled)
          .toList();
      final revenue =
          completed.fold<double>(0, (sum, o) => sum + o.totalAmount) +
          active.fold<double>(0, (sum, o) => sum + o.totalAmount);

      return DashboardSummary(
        totalOrders: orders.length,
        revenue: revenue,
        activeOrders: active.length,
        completedOrders: completed.length,
        cancelledOrders: cancelled.length,
        pendingOrders: pending.length,
        popularItems: const [],
      );
    }

    final response = await http.get(Uri.parse(ApiConfig.url('/summary')));
    if (response.statusCode == 200) {
      return DashboardSummary.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to fetch dashboard summary');
  }
}
