
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/env.dart';
import '../storage/token_storage.dart';

class ApiClient {
  ApiClient({
    http.Client? client,
    TokenStorage? tokenStorage,
    this._onUnauthorized,
  })  : _client = client ?? http.Client(),
        _tokenStorage = tokenStorage ?? TokenStorage();

  final http.Client _client;
  final TokenStorage _tokenStorage;
  final Future<void> Function()? _onUnauthorized;

  bool _handlingUnauthorized = false;

  static const Duration _timeout = Duration(seconds: 15);

  Uri get _baseUri => Uri.parse(AppEnv.apiBaseUrl);

  // =========================
  // BUILD URI
  // =========================

  Uri _buildUri(String path) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';

    final parsedUri = Uri.parse(normalizedPath);

    return _baseUri.replace(
      path: parsedUri.path,
      query: parsedUri.hasQuery ? parsedUri.query : null,
    );
  }

  // =========================
  // HEALTH CHECK
  // =========================

  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await _client
          .get(_buildUri('/'))
          .timeout(_timeout);

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          return decoded;
        }

        throw const FormatException(
          'Unexpected API response format.',
        );
      }

      throw Exception(
        'API request failed with status: ${response.statusCode}',
      );
    } catch (_) {
      rethrow;
    }
  }

  // =========================
  // GET
  // =========================

  Future<http.Response> get(
    String path, {
    Map<String, String>? headers,
    bool authenticated = true,
  }) {
    return request(
      method: 'GET',
      path: path,
      headers: headers,
      authenticated: authenticated,
    );
  }

  // =========================
  // POST
  // =========================

  Future<http.Response> post(
    String path, {
    Map<String, String>? headers,
    Object? body,
    bool authenticated = true,
  }) {
    return request(
      method: 'POST',
      path: path,
      headers: headers,
      body: body,
      authenticated: authenticated,
    );
  }

  // =========================
  // PUT
  // =========================

  Future<http.Response> put(
    String path, {
    Map<String, String>? headers,
    Object? body,
    bool authenticated = true,
  }) {
    return request(
      method: 'PUT',
      path: path,
      headers: headers,
      body: body,
      authenticated: authenticated,
    );
  }

  // =========================
  // PATCH
  // =========================

  Future<http.Response> patch(
    String path, {
    Map<String, String>? headers,
    Object? body,
    bool authenticated = true,
  }) {
    return request(
      method: 'PATCH',
      path: path,
      headers: headers,
      body: body,
      authenticated: authenticated,
    );
  }

  // =========================
  // DELETE
  // =========================

  Future<http.Response> delete(
    String path, {
    Map<String, String>? headers,
    Object? body,
    bool authenticated = true,
  }) {
    return request(
      method: 'DELETE',
      path: path,
      headers: headers,
      body: body,
      authenticated: authenticated,
    );
  }

  // =========================
  // SHARED JSON REQUEST HANDLER
  // =========================

  Future<http.Response> request({
    required String method,
    required String path,
    Map<String, String>? headers,
    Object? body,
    bool authenticated = true,
  }) async {
    final request = http.Request(
      method,
      _buildUri(path),
    );

    request.headers.addAll({
      'Accept': 'application/json',
      if (body != null) 'Content-Type': 'application/json',
      ...?headers,
    });

    if (authenticated) {
      final token = await _tokenStorage.getToken();

      if (token == null || token.trim().isEmpty) {
        throw Exception('You are not authenticated.');
      }

      request.headers['Authorization'] = 'Bearer $token';
    }

    if (body != null) {
      request.body = body is String ? body : jsonEncode(body);
    }

    final streamedResponse = await _client
        .send(request)
        .timeout(_timeout);

    final response = await http.Response.fromStream(
      streamedResponse,
    );

    if (authenticated && response.statusCode == 401) {
      await _handleUnauthorized();
    }

    return response;
  }

  // =========================
  // MULTIPART FILE UPLOAD
  // =========================

  Future<http.Response> uploadMultipart({
    required String path,
    required List<http.MultipartFile> files,
    Map<String, String>? fields,
    Map<String, String>? headers,
    String method = 'POST',
    bool authenticated = true,
  }) async {
    final request = http.MultipartRequest(
      method,
      _buildUri(path),
    );

    request.headers.addAll({
      'Accept': 'application/json',
      ...?headers,
    });

    if (authenticated) {
      final token = await _tokenStorage.getToken();

      if (token == null || token.trim().isEmpty) {
        throw Exception('You are not authenticated.');
      }

      request.headers['Authorization'] = 'Bearer $token';
    }

    if (fields != null) {
      request.fields.addAll(fields);
    }

    request.files.addAll(files);

    final streamedResponse = await _client
        .send(request)
        .timeout(_timeout);

    final response = await http.Response.fromStream(
      streamedResponse,
    );

    if (authenticated && response.statusCode == 401) {
      await _handleUnauthorized();
    }

    return response;
  }

  // =========================
  // HANDLE EXPIRED SESSION
  // =========================

  Future<void> _handleUnauthorized() async {
    if (_handlingUnauthorized) {
      return;
    }

    _handlingUnauthorized = true;

    try {
      if (_onUnauthorized != null) {
        await _onUnauthorized();
      } else {
        await _tokenStorage.deleteToken();
      }
    } catch (_) {
      // Session cleanup must not cause the original
      // API response to fail with an unrelated exception.
    } finally {
      _handlingUnauthorized = false;
    }
  }

  // =========================
  // DISPOSE
  // =========================

  void dispose() {
    _client.close();
  }
}