import 'dart:async';
import 'dart:convert';
import 'dart:io' as dart_io;
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:manager_app/core/constants/app_constants.dart';
import 'package:manager_app/core/utils/logger.dart';

/// Centralised HTTP layer for all API calls.
///
/// Provides GET / POST / PUT / PATCH / DELETE helpers with:
///  • Firebase Auth token injection (Authorization header)
///  • Self-signed certificate handling (dev)
///  • Configurable timeouts
///  • Structured logging via [AppLogger]
class HttpClient {
  static const String _tag = 'HttpClient';

  // ── Singleton ─────────────────────────────────────────────────
  static final HttpClient _instance = HttpClient._internal();
  factory HttpClient() => _instance;
  HttpClient._internal() {
    AppLogger.lifecycle(_tag, 'Singleton instance created');
  }

  /// Custom HTTP client that trusts self-signed certs (dev only)
  http.Client get _client {
    final ioClient = dart_io.HttpClient()
      ..badCertificateCallback = (cert, host, port) => true;
    return IOClient(ioClient);
  }

  Uri _uri(String endpoint) =>
      Uri.parse('${AppConstants.baseUrl}$endpoint');

  /// Build headers with Content-Type and Firebase Auth token.
  /// Tries a force-refreshed Firebase ID token first; falls back to the
  /// backend's dev-bypass key if no user is signed in.
  Future<Map<String, String>> _headers() async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    try {
      final user = firebase.FirebaseAuth.instance.currentUser;
      if (user != null) {
        // forceRefresh: true ensures we never send an expired token
        final token = await user.getIdToken(true);
        if (token != null && token.isNotEmpty) {
          headers['Authorization'] = 'Bearer $token';
          AppLogger.d(_tag, '_headers() Firebase token attached (force-refreshed)');
          return headers;
        }
      }
    } catch (e) {
      AppLogger.w(_tag, '_headers() Firebase token failed: $e — falling back to dev key');
    }
    // Fallback: use the backend's Swagger dev-key bypass (dev/test only)
    headers['Authorization'] = 'Bearer ${AppConstants.devAuthKey}';
    AppLogger.w(_tag, '_headers() Using dev auth key fallback');
    return headers;
  }

  // ── HTTP Helpers ──────────────────────────────────────────────

  /// Shared GET helper
  Future<http.Response> get(String endpoint) async {
    final url = _uri(endpoint).toString();
    AppLogger.network('GET', url);
    final stopwatch = Stopwatch()..start();
    final client = _client;
    final headers = await _headers();
    try {
      final response = await client
          .get(_uri(endpoint), headers: headers)
          .timeout(Duration(seconds: AppConstants.apiTimeout));
      stopwatch.stop();
      AppLogger.network('GET', url,
          statusCode: response.statusCode, body: response.body);
      AppLogger.perf(_tag, 'GET $endpoint', stopwatch.elapsed);
      return response;
    } on TimeoutException {
      stopwatch.stop();
      AppLogger.e(_tag, 'GET $endpoint TIMED OUT after ${AppConstants.apiTimeout}s');
      rethrow;
    } on dart_io.SocketException catch (e) {
      stopwatch.stop();
      AppLogger.e(_tag, 'GET $endpoint SOCKET ERROR: $e');
      rethrow;
    } catch (e, stack) {
      stopwatch.stop();
      AppLogger.e(_tag, 'GET $endpoint FAILED', e, stack);
      rethrow;
    } finally {
      client.close();
    }
  }

  /// Shared POST helper
  Future<http.Response> post(String endpoint, {Map<String, dynamic>? body}) async {
    final url = _uri(endpoint).toString();
    AppLogger.network('POST', url, body: body != null ? json.encode(body) : null);
    final stopwatch = Stopwatch()..start();
    final client = _client;
    final headers = await _headers();
    try {
      final response = await client
          .post(
            _uri(endpoint),
            headers: headers,
            body: body != null ? json.encode(body) : null,
          )
          .timeout(Duration(seconds: AppConstants.apiTimeout));
      stopwatch.stop();
      AppLogger.network('POST', url,
          statusCode: response.statusCode, body: response.body);
      AppLogger.perf(_tag, 'POST $endpoint', stopwatch.elapsed);
      return response;
    } on TimeoutException {
      stopwatch.stop();
      AppLogger.e(_tag, 'POST $endpoint TIMED OUT after ${AppConstants.apiTimeout}s');
      rethrow;
    } on dart_io.SocketException catch (e) {
      stopwatch.stop();
      AppLogger.e(_tag, 'POST $endpoint SOCKET ERROR: $e');
      rethrow;
    } catch (e, stack) {
      stopwatch.stop();
      AppLogger.e(_tag, 'POST $endpoint FAILED', e, stack);
      rethrow;
    } finally {
      client.close();
    }
  }

  /// Shared PUT helper
  Future<http.Response> put(String endpoint, {Map<String, dynamic>? body}) async {
    final url = _uri(endpoint).toString();
    AppLogger.network('PUT', url, body: body != null ? json.encode(body) : null);
    final stopwatch = Stopwatch()..start();
    final client = _client;
    final headers = await _headers();
    try {
      final response = await client
          .put(
            _uri(endpoint),
            headers: headers,
            body: body != null ? json.encode(body) : null,
          )
          .timeout(Duration(seconds: AppConstants.apiTimeout));
      stopwatch.stop();
      AppLogger.network('PUT', url,
          statusCode: response.statusCode, body: response.body);
      AppLogger.perf(_tag, 'PUT $endpoint', stopwatch.elapsed);
      return response;
    } on TimeoutException {
      stopwatch.stop();
      AppLogger.e(_tag, 'PUT $endpoint TIMED OUT after ${AppConstants.apiTimeout}s');
      rethrow;
    } on dart_io.SocketException catch (e) {
      stopwatch.stop();
      AppLogger.e(_tag, 'PUT $endpoint SOCKET ERROR: $e');
      rethrow;
    } catch (e, stack) {
      stopwatch.stop();
      AppLogger.e(_tag, 'PUT $endpoint FAILED', e, stack);
      rethrow;
    } finally {
      client.close();
    }
  }

  /// Shared PATCH helper
  Future<http.Response> patch(String endpoint, {Map<String, dynamic>? body}) async {
    final url = _uri(endpoint).toString();
    AppLogger.network('PATCH', url, body: body != null ? json.encode(body) : null);
    final stopwatch = Stopwatch()..start();
    final client = _client;
    final headers = await _headers();
    try {
      final response = await client
          .patch(
            _uri(endpoint),
            headers: headers,
            body: body != null ? json.encode(body) : null,
          )
          .timeout(Duration(seconds: AppConstants.apiTimeout));
      stopwatch.stop();
      AppLogger.network('PATCH', url,
          statusCode: response.statusCode, body: response.body);
      AppLogger.perf(_tag, 'PATCH $endpoint', stopwatch.elapsed);
      return response;
    } on TimeoutException {
      stopwatch.stop();
      AppLogger.e(_tag, 'PATCH $endpoint TIMED OUT after ${AppConstants.apiTimeout}s');
      rethrow;
    } on dart_io.SocketException catch (e) {
      stopwatch.stop();
      AppLogger.e(_tag, 'PATCH $endpoint SOCKET ERROR: $e');
      rethrow;
    } catch (e, stack) {
      stopwatch.stop();
      AppLogger.e(_tag, 'PATCH $endpoint FAILED', e, stack);
      rethrow;
    } finally {
      client.close();
    }
  }

  /// Shared DELETE helper
  Future<http.Response> delete(String endpoint) async {
    final url = _uri(endpoint).toString();
    AppLogger.network('DELETE', url);
    final stopwatch = Stopwatch()..start();
    final client = _client;
    final headers = await _headers();
    try {
      final response = await client
          .delete(_uri(endpoint), headers: headers)
          .timeout(Duration(seconds: AppConstants.apiTimeout));
      stopwatch.stop();
      AppLogger.network('DELETE', url,
          statusCode: response.statusCode, body: response.body);
      AppLogger.perf(_tag, 'DELETE $endpoint', stopwatch.elapsed);
      return response;
    } on TimeoutException {
      stopwatch.stop();
      AppLogger.e(_tag, 'DELETE $endpoint TIMED OUT after ${AppConstants.apiTimeout}s');
      rethrow;
    } on dart_io.SocketException catch (e) {
      stopwatch.stop();
      AppLogger.e(_tag, 'DELETE $endpoint SOCKET ERROR: $e');
      rethrow;
    } catch (e, stack) {
      stopwatch.stop();
      AppLogger.e(_tag, 'DELETE $endpoint FAILED', e, stack);
      rethrow;
    } finally {
      client.close();
    }
  }

  /// POST multipart/form-data — used when uploading images with form fields.
  /// [fields] are plain text fields, [filePath] is the local absolute path
  /// to the image file (field name on server is 'image').
  Future<http.Response> postMultipart(
    String endpoint, {
    required Map<String, String> fields,
    String? filePath,
  }) async {
    final url = _uri(endpoint).toString();
    AppLogger.network('POST (multipart)', url, body: fields.toString());
    final stopwatch = Stopwatch()..start();

    // Build auth headers (without Content-Type — multipart sets its own)
    final authHeaders = <String, String>{};
    try {
      final user = firebase.FirebaseAuth.instance.currentUser;
      if (user != null) {
        final token = await user.getIdToken(true);
        if (token != null && token.isNotEmpty) {
          authHeaders['Authorization'] = 'Bearer $token';
          AppLogger.d(_tag, 'postMultipart() Firebase token attached (force-refreshed)');
        }
      }
    } catch (e) {
      AppLogger.w(_tag, 'postMultipart() Firebase token failed: $e — falling back to dev key');
    }
    if (!authHeaders.containsKey('Authorization')) {
      authHeaders['Authorization'] = 'Bearer ${AppConstants.devAuthKey}';
      AppLogger.w(_tag, 'postMultipart() Using dev auth key fallback');
    }

    final request = http.MultipartRequest('POST', _uri(endpoint))
      ..headers.addAll(authHeaders)
      ..fields.addAll(fields);

    if (filePath != null && filePath.isNotEmpty) {
      try {
        request.files.add(await http.MultipartFile.fromPath('image', filePath));
      } catch (e) {
        AppLogger.e(_tag, 'Failed to attach file $filePath: $e');
      }
    }

    try {
      final streamedResponse = await request
          .send()
          .timeout(Duration(seconds: AppConstants.apiTimeout));
      final response = await http.Response.fromStream(streamedResponse);
      stopwatch.stop();
      AppLogger.network('POST (multipart)', url,
          statusCode: response.statusCode, body: response.body);
      AppLogger.perf(_tag, 'POST multipart $endpoint', stopwatch.elapsed);
      return response;
    } on TimeoutException {
      stopwatch.stop();
      AppLogger.e(_tag, 'POST multipart $endpoint TIMED OUT');
      rethrow;
    } on dart_io.SocketException catch (e) {
      stopwatch.stop();
      AppLogger.e(_tag, 'POST multipart $endpoint SOCKET ERROR: $e');
      rethrow;
    } catch (e, stack) {
      stopwatch.stop();
      AppLogger.e(_tag, 'POST multipart $endpoint FAILED', e, stack);
      rethrow;
    }
  }

  /// PUT multipart/form-data — used when updating an item and optionally
  /// changing its image file.
  Future<http.Response> putMultipart(
    String endpoint, {
    required Map<String, String> fields,
    String? filePath,
  }) async {
    final url = _uri(endpoint).toString();
    AppLogger.network('PUT (multipart)', url, body: fields.toString());
    final stopwatch = Stopwatch()..start();

    final authHeaders = <String, String>{};
    try {
      final user = firebase.FirebaseAuth.instance.currentUser;
      if (user != null) {
        final token = await user.getIdToken(true);
        if (token != null && token.isNotEmpty) {
          authHeaders['Authorization'] = 'Bearer $token';
          AppLogger.d(_tag, 'putMultipart() Firebase token attached (force-refreshed)');
        }
      }
    } catch (e) {
      AppLogger.w(_tag, 'putMultipart() Firebase token failed: $e — falling back to dev key');
    }
    if (!authHeaders.containsKey('Authorization')) {
      authHeaders['Authorization'] = 'Bearer ${AppConstants.devAuthKey}';
      AppLogger.w(_tag, 'putMultipart() Using dev auth key fallback');
    }

    final request = http.MultipartRequest('PUT', _uri(endpoint))
      ..headers.addAll(authHeaders)
      ..fields.addAll(fields);

    if (filePath != null && filePath.isNotEmpty) {
      try {
        request.files.add(await http.MultipartFile.fromPath('image', filePath));
      } catch (e) {
        AppLogger.e(_tag, 'Failed to attach file $filePath: $e');
      }
    }

    try {
      final streamedResponse = await request
          .send()
          .timeout(Duration(seconds: AppConstants.apiTimeout));
      final response = await http.Response.fromStream(streamedResponse);
      stopwatch.stop();
      AppLogger.network('PUT (multipart)', url,
          statusCode: response.statusCode, body: response.body);
      AppLogger.perf(_tag, 'PUT multipart $endpoint', stopwatch.elapsed);
      return response;
    } on TimeoutException {
      stopwatch.stop();
      AppLogger.e(_tag, 'PUT multipart $endpoint TIMED OUT');
      rethrow;
    } on dart_io.SocketException catch (e) {
      stopwatch.stop();
      AppLogger.e(_tag, 'PUT multipart $endpoint SOCKET ERROR: $e');
      rethrow;
    } catch (e, stack) {
      stopwatch.stop();
      AppLogger.e(_tag, 'PUT multipart $endpoint FAILED', e, stack);
      rethrow;
    }
  }
}

