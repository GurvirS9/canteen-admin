import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manager_app/data/models/order.dart';
import 'package:manager_app/data/services/order_service.dart';
import 'package:manager_app/data/services/socket_service.dart';
import 'package:manager_app/core/utils/logger.dart';

final orderServiceProvider = Provider<OrderService>((ref) => OrderService());

final orderFilterProvider = StateProvider<OrderStatus?>((ref) => null);

final socketServiceProvider = Provider<SocketService>((ref) {
  final service = SocketService();
  ref.onDispose(() => service.disconnect());
  return service;
});

final orderProvider =
    StateNotifierProvider<OrderNotifier, AsyncValue<List<Order>>>((ref) {
      return OrderNotifier(
        ref.read(orderServiceProvider),
        ref.read(socketServiceProvider),
      );
    });

class OrderNotifier extends StateNotifier<AsyncValue<List<Order>>> {
  static const String _tag = 'OrderNotifier';
  final OrderService _service;
  final SocketService _socketService;
  StreamSubscription<Map<String, dynamic>>? _createdSub;
  StreamSubscription<Map<String, dynamic>>? _updatedSub;

  OrderNotifier(this._service, this._socketService)
      : super(const AsyncLoading()) {
    _initSocket();
    fetchAll();
  }

  Future<void> _initSocket() async {
    try {
      await _socketService.connect();
      _listenToSocketEvents();
      AppLogger.i(_tag, 'Socket connected and listeners attached');
    } catch (e) {
      AppLogger.e(_tag, 'Failed to connect socket: $e');
    }
  }

  void _listenToSocketEvents() {
    _createdSub?.cancel();
    _updatedSub?.cancel();

    _createdSub = _socketService.onOrderCreated.listen((data) {
      AppLogger.d(_tag, 'orderCreated socket event: ${data['id']}');
      try {
        final order = Order.fromJson(data);
        final currentOrders = state.valueOrNull ?? [];
        // Don't add duplicates
        if (currentOrders.any((o) => o.id == order.id)) return;
        state = AsyncData([order, ...currentOrders]);
        AppLogger.i(_tag, 'Added new order from socket: ${order.id} (${order.customerName})');
      } catch (e) {
        AppLogger.e(_tag, 'Failed to parse orderCreated event: $e');
      }
    });

    _updatedSub = _socketService.onOrderUpdated.listen((data) {
      final orderId = (data['id'] ?? data['_id'] ?? '').toString();
      final newStatus = data['status'] as String?;
      AppLogger.d(_tag, 'orderUpdated socket event: $orderId → $newStatus');

      if (orderId.isEmpty || newStatus == null) return;

      final currentOrders = state.valueOrNull ?? [];
      final idx = currentOrders.indexWhere((o) => o.id == orderId);
      if (idx == -1) return;

      final parsed = OrderStatus.values.firstWhere(
        (e) => e.name == newStatus,
        orElse: () => OrderStatus.pending,
      );

      if (currentOrders[idx].status == parsed) return;

      final updated = List<Order>.from(currentOrders);
      updated[idx] = updated[idx].copyWith(status: parsed);
      state = AsyncData(updated);
      AppLogger.i(_tag, 'Updated order $orderId status to ${parsed.name} via socket');
    });
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

  /// Optimistic update: reflects status change immediately in the UI,
  /// then confirms with the backend. Reverts if the request fails.
  Future<void> updateStatus(String orderId, OrderStatus newStatus) async {
    final currentOrders = state.valueOrNull ?? [];
    final idx = currentOrders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return;

    // Save previous state for rollback
    final previousState = state;

    // Optimistic: apply instantly
    final optimistic = List<Order>.from(currentOrders);
    optimistic[idx] = optimistic[idx].copyWith(status: newStatus);
    state = AsyncData(optimistic);
    AppLogger.d(_tag, 'Optimistic update: $orderId → ${newStatus.name}');

    try {
      final updated = await _service.updateStatus(orderId, newStatus);
      // Merge in the server-confirmed version (may have richer data)
      final confirmed = List<Order>.from(state.valueOrNull ?? optimistic);
      final confirmedIdx = confirmed.indexWhere((o) => o.id == updated.id);
      if (confirmedIdx != -1) {
        confirmed[confirmedIdx] = updated;
        state = AsyncData(confirmed);
      }
      AppLogger.i(_tag, 'Confirmed status update: $orderId → ${newStatus.name}');
    } catch (e, st) {
      // Rollback to previous state on failure
      state = previousState;
      AppLogger.e(_tag, 'Failed to update status, rolling back: $e');
      rethrow;
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

  @override
  void dispose() {
    _createdSub?.cancel();
    _updatedSub?.cancel();
    super.dispose();
  }
}
