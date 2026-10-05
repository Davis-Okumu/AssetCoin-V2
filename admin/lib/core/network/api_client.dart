import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/env.dart';
import '../storage/token_storage.dart';

/// Central HTTP client for the AssetCoin Admin Dashboard.
///
/// Responsibilities:
/// - Build API URLs from [AppEnv.apiBaseUrl].
/// - Attach the stored admin JWT automatically.
/// - Send JSON requests.
/// - Decode JSON responses.
/// - Provide consistent error handling.
/// - Allow repositories to use a single API client.
class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  // ============================================================
  // HEADERS
  // ============================================================

  Future<Map<String, String>> _buildHeaders({
    bool includeAuthorization = true,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuthorization) {
      final token = await TokenStorage.getToken();

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // ============================================================
  // URI
  // ============================================================

  Uri _buildUri(String path, {Map<String, dynamic>? queryParameters}) {
    final normalizedBaseUrl = AppEnv.apiBaseUrl.endsWith('/')
        ? AppEnv.apiBaseUrl.substring(0, AppEnv.apiBaseUrl.length - 1)
        : AppEnv.apiBaseUrl;

    final normalizedPath = path.startsWith('/') ? path : '/$path';

    final uri = Uri.parse('$normalizedBaseUrl$normalizedPath');

    if (queryParameters == null || queryParameters.isEmpty) {
      return uri;
    }

    final parameters = <String, String>{};

    for (final entry in queryParameters.entries) {
      final value = entry.value;

      if (value == null) {
        continue;
      }

      parameters[entry.key] = value.toString();
    }

    return uri.replace(queryParameters: parameters);
  }

  // ============================================================
  // RESPONSE DECODING
  // ============================================================

  dynamic _decodeResponseBody(http.Response response) {
    if (response.body.isEmpty) {
      return null;
    }

    try {
      return jsonDecode(response.body);
    } catch (_) {
      return response.body;
    }
  }

  // ============================================================
  // RESPONSE HANDLING
  // ============================================================

  dynamic _handleResponse(http.Response response) {
    final data = _decodeResponseBody(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    String message = 'Request failed with status code ${response.statusCode}.';

    if (data is Map<String, dynamic>) {
      final serverMessage = data['message'];

      if (serverMessage is String && serverMessage.trim().isNotEmpty) {
        message = serverMessage;
      }
    }

    throw ApiException(
      message: message,
      statusCode: response.statusCode,
      data: data,
    );
  }

  // ============================================================
  // GET
  // ============================================================

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool includeAuthorization = true,
  }) async {
    final uri = _buildUri(path, queryParameters: queryParameters);

    final headers = await _buildHeaders(
      includeAuthorization: includeAuthorization,
    );

    try {
      final response = await _client.get(uri, headers: headers);

      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException(
        message: 'Unable to connect to the server.',
        originalError: error,
      );
    }
  }

  // ============================================================
  // POST
  // ============================================================

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    bool includeAuthorization = true,
  }) async {
    final uri = _buildUri(path, queryParameters: queryParameters);

    final headers = await _buildHeaders(
      includeAuthorization: includeAuthorization,
    );

    try {
      final response = await _client.post(
        uri,
        headers: headers,
        body: body == null ? null : jsonEncode(body),
      );

      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException(
        message: 'Unable to connect to the server.',
        originalError: error,
      );
    }
  }

  // ============================================================
  // PUT
  // ============================================================

  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    bool includeAuthorization = true,
  }) async {
    final uri = _buildUri(path, queryParameters: queryParameters);

    final headers = await _buildHeaders(
      includeAuthorization: includeAuthorization,
    );

    try {
      final response = await _client.put(
        uri,
        headers: headers,
        body: body == null ? null : jsonEncode(body),
      );

      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException(
        message: 'Unable to connect to the server.',
        originalError: error,
      );
    }
  }

  // ============================================================
  // PATCH
  // ============================================================

  Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    bool includeAuthorization = true,
  }) async {
    final uri = _buildUri(path, queryParameters: queryParameters);

    final headers = await _buildHeaders(
      includeAuthorization: includeAuthorization,
    );

    try {
      final response = await _client.patch(
        uri,
        headers: headers,
        body: body == null ? null : jsonEncode(body),
      );

      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException(
        message: 'Unable to connect to the server.',
        originalError: error,
      );
    }
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    bool includeAuthorization = true,
  }) async {
    final uri = _buildUri(path, queryParameters: queryParameters);

    final headers = await _buildHeaders(
      includeAuthorization: includeAuthorization,
    );

    try {
      final response = await _client.delete(
        uri,
        headers: headers,
        body: body == null ? null : jsonEncode(body),
      );

      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException(
        message: 'Unable to connect to the server.',
        originalError: error,
      );
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  void dispose() {
    _client.close();
  }
}

// ================================================================
// API EXCEPTION
// ================================================================

/// Exception thrown when an API request fails.
class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.data,
    this.originalError,
  });

  final String message;
  final int? statusCode;
  final dynamic data;
  final Object? originalError;

  bool get isUnauthorized => statusCode == 401;

  bool get isForbidden => statusCode == 403;

  bool get isNotFound => statusCode == 404;

  bool get isValidationError => statusCode == 400;

  bool get isServerError => statusCode != null && statusCode! >= 500;

  @override
  String toString() {
    if (statusCode == null) {
      return message;
    }

    return '$message (HTTP $statusCode)';
  }
}
