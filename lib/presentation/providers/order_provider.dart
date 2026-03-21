import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manager_app/data/models/order.dart';
import 'package:manager_app/data/services/order_service.dart';

final orderServiceProvider = Provider<OrderService>((ref) => OrderService());

final orderFilterProvider = StateProvider<OrderStatus?>((ref) => null);

final orderProvider =
    StateNotifierProvider<OrderNotifier, AsyncValue<List<Order>>>((ref) {
      return OrderNotifier(ref.read(orderServiceProvider));
    });

class OrderNotifier extends StateNotifier<AsyncValue<List<Order>>> {
  final OrderService _service;

  OrderNotifier(this._service) : super(const AsyncLoading()) {
    fetchAll();
  }

  Future<void> fetchAll({OrderStatus? statusFilter}) async {
    state = const AsyncLoading();
    try {
      final orders = await _service.fetchAll(statusFilter: statusFilter);
      // Sort: newest first
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      state = AsyncData(orders);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateStatus(String orderId, OrderStatus newStatus) async {
    try {
      final updated = await _service.updateStatus(orderId, newStatus);
      final currentOrders = state.valueOrNull ?? [];
      state = AsyncData(
        currentOrders.map((o) => o.id == updated.id ? updated : o).toList(),
      );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> createOrder(Order order) async {
    try {
      final created = await _service.createOrder(order);
      final currentOrders = state.valueOrNull ?? [];
      state = AsyncData([created, ...currentOrders]);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
