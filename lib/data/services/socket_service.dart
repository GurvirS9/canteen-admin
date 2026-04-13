import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:manager_app/core/utils/logger.dart';

/// Singleton Supabase Realtime listener for real-time order notifications
/// in the manager app. Replaces the old Socket.IO implementation.
class SocketService {
  static const String _tag = 'SocketService';

  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  RealtimeChannel? _channel;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  // ── Streams for order events ─────────────────────────────────
  final _orderCreatedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _orderUpdatedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _orderDeletedController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get onOrderCreated =>
      _orderCreatedController.stream;
  Stream<Map<String, dynamic>> get onOrderUpdated =>
      _orderUpdatedController.stream;
  Stream<Map<String, dynamic>> get onOrderDeleted =>
      _orderDeletedController.stream;

  /// Subscribe to Supabase Realtime changes on the `orders` table.
  Future<void> connect() async {
    if (_channel != null && _isConnected) {
      AppLogger.d(_tag, 'Already connected, skipping');
      return;
    }

    AppLogger.i(_tag, 'Subscribing to Supabase Realtime orders channel');

    _channel = Supabase.instance.client
        .channel('public:orders')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'orders',
          callback: (payload) {
            AppLogger.d(_tag, 'orderCreated event: ${payload.newRecord}');
            _orderCreatedController.add(
                Map<String, dynamic>.from(payload.newRecord));
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'orders',
          callback: (payload) {
            AppLogger.d(_tag, 'orderUpdated event: ${payload.newRecord}');
            _orderUpdatedController.add(
                Map<String, dynamic>.from(payload.newRecord));
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'orders',
          callback: (payload) {
            AppLogger.d(_tag, 'orderDeleted event: ${payload.oldRecord}');
            _orderDeletedController.add(
                Map<String, dynamic>.from(payload.oldRecord));
          },
        )
        .subscribe((status, [err]) {
          if (status == RealtimeSubscribeStatus.subscribed) {
            _isConnected = true;
            AppLogger.i(_tag, 'Realtime subscribed ✅');
          } else if (status == RealtimeSubscribeStatus.channelError ||
              status == RealtimeSubscribeStatus.timedOut) {
            _isConnected = false;
            AppLogger.e(_tag, 'Realtime error: $status — $err');
          } else if (status == RealtimeSubscribeStatus.closed) {
            _isConnected = false;
            AppLogger.w(_tag, 'Realtime channel closed');
          }
        });
  }

  /// Unsubscribe from Realtime (e.g. on logout).
  void disconnect() {
    AppLogger.i(_tag, 'Unsubscribing from Realtime');
    _channel?.unsubscribe();
    _channel = null;
    _isConnected = false;
  }

  /// Dispose all resources.
  void dispose() {
    disconnect();
    _orderCreatedController.close();
    _orderUpdatedController.close();
    _orderDeletedController.close();
  }
}
