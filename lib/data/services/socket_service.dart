import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:manager_app/core/constants/app_constants.dart';
import 'package:manager_app/core/utils/logger.dart';

/// Singleton Socket.IO client for real-time order notifications in the manager app.
class SocketService {
  static const String _tag = 'SocketService';

  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  io.Socket? _socket;
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

  /// Connect to the backend Socket.IO server.
  Future<void> connect() async {
    if (_socket != null && _isConnected) {
      AppLogger.d(_tag, 'Already connected, skipping');
      return;
    }

    String? token;
    try {
      token = await FirebaseAuth.instance.currentUser?.getIdToken();
    } catch (e) {
      AppLogger.w(_tag, 'Could not get Firebase token for socket: $e');
    }

    final socketUrl = AppConstants.socketUrl;
    AppLogger.i(_tag, 'Connecting to $socketUrl');

    _socket = io.io(
      socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .setAuth({'token': token ?? ''})
          .build(),
    );

    _socket!.onConnect((_) {
      _isConnected = true;
      AppLogger.i(_tag, 'Connected (id: ${_socket!.id})');
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      AppLogger.w(_tag, 'Disconnected');
    });

    _socket!.onConnectError((err) {
      _isConnected = false;
      AppLogger.e(_tag, 'Connection error: $err');
    });

    _socket!.on('orderCreated', (data) {
      AppLogger.d(_tag, 'orderCreated event: $data');
      if (data is Map<String, dynamic>) {
        _orderCreatedController.add(data);
      } else if (data is Map) {
        _orderCreatedController.add(Map<String, dynamic>.from(data));
      }
    });

    _socket!.on('orderUpdated', (data) {
      AppLogger.d(_tag, 'orderUpdated event: $data');
      if (data is Map<String, dynamic>) {
        _orderUpdatedController.add(data);
      } else if (data is Map) {
        _orderUpdatedController.add(Map<String, dynamic>.from(data));
      }
    });

    _socket!.on('orderDeleted', (data) {
      AppLogger.d(_tag, 'orderDeleted event: $data');
      if (data is Map<String, dynamic>) {
        _orderDeletedController.add(data);
      } else if (data is Map) {
        _orderDeletedController.add(Map<String, dynamic>.from(data));
      }
    });

    _socket!.connect();
  }

  /// Disconnect from the server (e.g. on logout).
  void disconnect() {
    AppLogger.i(_tag, 'Disconnecting');
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
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
