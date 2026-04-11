import 'dart:convert';
import 'package:manager_app/data/models/order.dart';
import 'package:manager_app/core/constants/app_constants.dart';
import 'package:manager_app/data/services/http_client.dart';
import 'package:manager_app/core/utils/logger.dart';

class OrderService {
  static const String _tag = 'OrderService';
  final HttpClient _api = HttpClient();

  /// Fetch orders for the manager's shop.
  ///
  /// [shopId]  — scopes results to a specific shop (required for managers).
  /// [statusFilter] — optional client-side filter applied after fetch.
  ///   Active statuses (pending / preparing / ready) use [AppConstants.activeOrdersEndpoint]
  ///   so the manager only sees in-flight orders.
  Future<List<Order>> fetchAll({OrderStatus? statusFilter, String? shopId}) async {
    AppLogger.i(_tag, 'fetchAll() statusFilter=${statusFilter?.name ?? 'none'} shopId=${shopId ?? 'all'}');

    // Build query params
    final queryParams = <String, String>{};
    if (shopId != null) queryParams['shopId'] = shopId;

    // Decide endpoint — use the dedicated active-orders endpoint only when
    // explicitly filtering for active (pending/preparing/ready) states so the
    // list stays focused. For terminal statuses or no filter, use the main
    // orders endpoint with an optional status query param.
    String endpoint;
    if (statusFilter != null &&
        (statusFilter == OrderStatus.pending ||
            statusFilter == OrderStatus.preparing ||
            statusFilter == OrderStatus.ready)) {
      endpoint = AppConstants.activeOrdersEndpoint;
    } else {
      endpoint = AppConstants.ordersEndpoint;
      if (statusFilter != null) {
        queryParams['status'] = statusFilter.name;
      }
    }

    if (queryParams.isNotEmpty) {
      final query = queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');
      endpoint += '?$query';
    }

    final response = await _api.get(endpoint);
    if (response.statusCode == 200) {
      final dynamic decoded = jsonDecode(response.body);
      // Active-orders endpoint returns { total, queue: [...] }
      // Main orders endpoint returns a flat array
      final List rawList = decoded is Map ? (decoded['queue'] as List? ?? []) : decoded as List;
      final orders = rawList.map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();
      AppLogger.i(_tag, 'fetchAll() parsed ${orders.length} orders');
      return orders;
    }
    AppLogger.e(_tag, 'fetchAll() failed with status ${response.statusCode}');
    throw Exception('Failed to fetch orders (${response.statusCode})');
  }

  /// Fetch the real-time queue: all pending/preparing/ready orders (public).
  /// Returns orders enriched with `queuePosition` and `estimatedReady`.
  Future<List<Order>> fetchQueue({String? shopId}) async {
    AppLogger.i(_tag, 'fetchQueue() shopId=${shopId ?? 'all'}');
    String endpoint = AppConstants.queueEndpoint;
    if (shopId != null) endpoint += '?shopId=$shopId';

    final response = await _api.get(endpoint);
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final List rawList = body['queue'] as List? ?? [];
      final orders = rawList.map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();
      AppLogger.i(_tag, 'fetchQueue() parsed ${orders.length} queued orders');
      return orders;
    }
    AppLogger.e(_tag, 'fetchQueue() failed with status ${response.statusCode}');
    throw Exception('Failed to fetch queue (${response.statusCode})');
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
