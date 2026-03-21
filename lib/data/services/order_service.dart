import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:manager_app/data/models/order.dart';
import 'package:manager_app/core/utils/demo_data.dart';
import 'package:manager_app/data/services/api_config.dart';

class OrderService {
  List<Order>? _demoOrders;

  List<Order> get _orders {
    _demoOrders ??= List.from(DemoData.orders);
    return _demoOrders!;
  }

  Future<List<Order>> fetchAll({OrderStatus? statusFilter}) async {
    if (ApiConfig.isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (statusFilter != null) {
        return _orders.where((o) => o.status == statusFilter).toList();
      }
      return List.from(_orders);
    }

    String url = ApiConfig.url('/orders');
    if (statusFilter != null) {
      url += '?status=${statusFilter.name}';
    }
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Order.fromJson(e)).toList();
    }
    throw Exception('Failed to fetch orders');
  }

  Future<Order> updateStatus(String orderId, OrderStatus newStatus) async {
    if (ApiConfig.isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 400));
      final idx = _orders.indexWhere((o) => o.id == orderId);
      if (idx != -1) {
        _orders[idx] = _orders[idx].copyWith(status: newStatus);
        return _orders[idx];
      }
      throw Exception('Order not found');
    }

    final response = await http.patch(
      Uri.parse(ApiConfig.url('/orders/$orderId')),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': newStatus.name}),
    );
    if (response.statusCode == 200) {
      return Order.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to update order status');
  }

  Future<Order> createOrder(Order order) async {
    if (ApiConfig.isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 400));
      final newOrder = order.copyWith(
        id: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
        status: OrderStatus.pending,
      );
      _orders.insert(0, newOrder);
      return newOrder;
    }

    final response = await http.post(
      Uri.parse(ApiConfig.url('/orders')),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(order.toJson()),
    );
    if (response.statusCode == 201) {
      return Order.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create order');
  }
}
