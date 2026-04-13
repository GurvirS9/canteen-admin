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
  static const int _onboardingTriggerCount = 10;

  bool _debugMode = false;
  int _toggleCount = 0;
  final List<DebugErrorEntry> _errors = [];

  /// Optional callback — set by the profile screen to re-launch onboarding.
  VoidCallback? onOnboardingTrigger;

  /// Fired after every 5 toggles (but before 10) so the UI can show a hint.
  ValueChanged<int>? onToggleCountChanged;

  bool get debugMode => _debugMode;
  List<DebugErrorEntry> get errors => List.unmodifiable(_errors);
  bool get hasErrors => _errors.isNotEmpty;
  int get toggleCount => _toggleCount;

  /// Toggles debug mode and counts towards the onboarding Easter egg.
  void toggleDebugMode() {
    _debugMode = !_debugMode;
    _toggleCount++;
    onToggleCountChanged?.call(_toggleCount);
    if (_toggleCount >= _onboardingTriggerCount) {
      _toggleCount = 0;
      onOnboardingTrigger?.call();
    }
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
