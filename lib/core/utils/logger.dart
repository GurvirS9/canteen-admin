import 'dart:developer' as developer;

import 'package:manager_app/presentation/providers/debug_provider.dart';

/// Structured logger for advanced logcat output.
///
/// Uses `dart:developer` log() which maps directly to Android logcat
/// with proper tag filtering and log-level support.
///
/// Call [init] once after the Riverpod tree is built to enable in-app
/// error capture for the debug overlay.
///
/// Filter in logcat:  `adb logcat -s CanteenManager`
class AppLogger {
  static const String _appTag = 'CanteenManager';

  /// Optional reference to [DebugNotifier] for in-app error display.
  static DebugNotifier? _debugNotifier;

  /// Link the logger to a [DebugNotifier] so error-level logs are
  /// captured in memory and can be shown on-screen.
  static void init(DebugNotifier notifier) {
    _debugNotifier = notifier;
  }

  // ── Log levels (mapped to dart:developer levels) ──────────────
  // 0    = FINEST / VERBOSE
  // 500  = FINE / DEBUG
  // 800  = INFO
  // 900  = WARNING
  // 1000 = SEVERE / ERROR
  // 1200 = SHOUT / WTF

  /// Verbose / debug message
  static void d(String tag, String message) {
    _log(500, tag, message);
  }

  /// Informational
  static void i(String tag, String message) {
    _log(800, tag, message);
  }

  /// Warning
  static void w(String tag, String message) {
    _log(900, tag, '⚠️ $message');
  }

  /// Error (with optional error object & stack trace)
  static void e(String tag, String message, [Object? error, StackTrace? stack]) {
    _log(1000, tag, '❌ $message', error, stack);
  }

  /// Network request logging
  static void network(String method, String url, {int? statusCode, String? body}) {
    final buffer = StringBuffer()
      ..write('[$method] $url');
    if (statusCode != null) buffer.write(' → $statusCode');
    if (body != null && body.length <= 500) {
      buffer.write('\n    body: $body');
    } else if (body != null) {
      buffer.write('\n    body: ${body.substring(0, 500)}… (${body.length} chars)');
    }
    _log(800, 'Network', buffer.toString());
  }

  /// Lifecycle event (provider init, dispose, state change)
  static void lifecycle(String tag, String event) {
    _log(500, tag, '🔄 $event');
  }

  /// Performance marker
  static void perf(String tag, String operation, Duration elapsed) {
    _log(800, tag, '⏱️ $operation took ${elapsed.inMilliseconds}ms');
  }

  // ── Internal ──────────────────────────────────────────────────

  static void _log(int level, String tag, String message,
      [Object? error, StackTrace? stack]) {
    developer.log(
      message,
      name: '$_appTag/$tag',
      level: level,
      error: error,
      stackTrace: stack,
    );

    // Push error-level logs to DebugNotifier for on-screen display
    if (level >= 1000 && _debugNotifier != null) {
      _debugNotifier!.addError(tag, message, error, stack);
    }
  }
}
