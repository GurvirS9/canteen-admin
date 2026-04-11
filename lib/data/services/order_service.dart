import 'dart:convert';
import 'package:manager_app/data/models/order.dart';
import 'package:manager_app/core/constants/app_constants.dart';
import 'package:manager_app/data/services/http_client.dart';
import 'package:manager_app/core/utils/logger.dart';

class OrderService {
  static const String _tag = 'OrderService';
  final HttpClient _api = HttpClient();

  Future<List<Order>> fetchAll({OrderStatus? statusFilter, String? shopId}) async {
    AppLogger.i(_tag, 'fetchAll() statusFilter=${statusFilter?.name ?? 'none'} shopId=${shopId ?? 'all'}');

    String endpoint = AppConstants.ordersEndpoint;
    final queryParams = <String, String>{};
    if (shopId != null) queryParams['shopId'] = shopId;

    if (statusFilter != null) {
      if (statusFilter == OrderStatus.pending ||
          statusFilter == OrderStatus.preparing ||
          statusFilter == OrderStatus.ready) {
        endpoint = AppConstants.activeOrdersEndpoint;
      } else {
        queryParams['status'] = statusFilter.name;
      }
    }

    if (queryParams.isNotEmpty) {
      final query = queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');
      endpoint += '?$query';
    }

    final response = await _api.get(endpoint);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      final orders = data.map((e) => Order.fromJson(e)).toList();
      AppLogger.i(_tag, 'fetchAll() parsed ${orders.length} orders');
      return orders;
    }
    AppLogger.e(_tag, 'fetchAll() failed with status ${response.statusCode}');
    throw Exception('Failed to fetch orders (${response.statusCode})');
  }

  Future<Order> updateStatus(String orderId, OrderStatus newStatus) async {
    AppLogger.i(_tag, 'updateStatus() $orderId → ${newStatus.name}');
    final response = await _api.patch(
      AppConstants.orderStatusEndpoint(orderId),
      body: {'status': newStatus.name},
    );
    if (response.statusCode == 200) {
      final updated = Order.fromJson(jsonDecode(response.body));
      AppLogger.i(_tag, 'updateStatus() updated: ${updated.id} → ${updated.status.name}');
      return updated;
    }
    AppLogger.e(_tag, 'updateStatus() failed with status ${response.statusCode}');
    throw Exception('Failed to update order status (${response.statusCode})');
  }

  Future<Order> createOrder(Order order) async {
    AppLogger.i(_tag, 'createOrder()');
    final response = await _api.post(
      AppConstants.ordersEndpoint,
      body: order.toJson(),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      final created = Order.fromJson(jsonDecode(response.body));
      AppLogger.i(_tag, 'createOrder() order created: ${created.id}');
      return created;
    }
    AppLogger.e(_tag, 'createOrder() failed with status ${response.statusCode}');
    throw Exception('Failed to create order (${response.statusCode})');
  }

  Future<void> deleteOrder(String id) async {
    AppLogger.i(_tag, 'deleteOrder() $id');
    final response = await _api.delete(AppConstants.orderEndpoint(id));
    if (response.statusCode != 200 && response.statusCode != 204) {
      AppLogger.e(_tag, 'deleteOrder() failed with status ${response.statusCode}');
      throw Exception('Failed to delete order (${response.statusCode})');
    }
    AppLogger.i(_tag, 'deleteOrder() $id deleted');
  }
}
