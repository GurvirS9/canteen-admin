import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A single captured error entry for the debug overlay.
class DebugErrorEntry {
  final DateTime timestamp;
  final String tag;
  final String message;
  final String? error;
  final String? stackTrace;

  const DebugErrorEntry({
    required this.timestamp,
    required this.tag,
    required this.message,
    this.error,
    this.stackTrace,
  });

  String get shortTimestamp =>
      '${timestamp.hour.toString().padLeft(2, '0')}:'
      '${timestamp.minute.toString().padLeft(2, '0')}:'
      '${timestamp.second.toString().padLeft(2, '0')}';
}

/// Stores debug mode toggle and an in-memory ring buffer of recent errors.
class DebugNotifier extends ChangeNotifier {
  static const int _maxEntries = 50;

  bool _debugMode = false;
  final List<DebugErrorEntry> _errors = [];

  bool get debugMode => _debugMode;
  List<DebugErrorEntry> get errors => List.unmodifiable(_errors);
  bool get hasErrors => _errors.isNotEmpty;

  void toggleDebugMode() {
    _debugMode = !_debugMode;
    notifyListeners();
  }

  void setDebugMode(bool value) {
    _debugMode = value;
    notifyListeners();
  }

  /// Called by [AppLogger] when an error-level message is logged.
  void addError(String tag, String message, [Object? error, StackTrace? stack]) {
    final entry = DebugErrorEntry(
      timestamp: DateTime.now(),
      tag: tag,
      message: message,
      error: error?.toString(),
      stackTrace: stack?.toString().split('\n').take(8).join('\n'),
    );

    _errors.insert(0, entry);
    if (_errors.length > _maxEntries) {
      _errors.removeRange(_maxEntries, _errors.length);
    }
    notifyListeners();
  }

  void clearErrors() {
    _errors.clear();
    notifyListeners();
  }
}

final debugProvider = ChangeNotifierProvider<DebugNotifier>((ref) {
  return DebugNotifier();
});
