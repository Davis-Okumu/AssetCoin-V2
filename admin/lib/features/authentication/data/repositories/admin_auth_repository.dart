import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/config/env.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/admin_user.dart';
import '../models/admin_user_model.dart';

class AdminAuthRepository {
  AdminAuthRepository({
    http.Client? client,
  }) : _client = client ?? http.Client();

  final http.Client _client;

  // =========================================================
  // LOGIN
  // =========================================================

  Future<AdminUser?> login({
    required String identifier,
    required String password,
  }) async {
    final uri = Uri.parse(
      '${AppEnv.adminAuthBaseUrl}/login',
    );

    try {
      final response = await _client
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'identifier': identifier,
              'password': password,
            }),
          )
          .timeout(
            const Duration(seconds: 15),
          );

      final data = _decodeResponse(response);

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw Exception(
          data['message']?.toString() ??
              'Administrator login failed.',
        );
      }

      final token = data['token']?.toString();

      final adminJson = data['admin'];

      if (token == null || token.isEmpty) {
        throw Exception(
          'Login succeeded but the server did not return an authentication token.',
        );
      }

      if (adminJson is! Map<String, dynamic>) {
        throw Exception(
          'Login succeeded but administrator information was missing.',
        );
      }

      // Store the JWT locally so the session can be restored
      // when the admin application is refreshed.
      await TokenStorage.saveToken(token);

      return AdminUserModel.fromJson(
        adminJson,
      );
    } on http.ClientException catch (error) {
      throw Exception(
        'Unable to connect to the AssetCoin server. '
        'Please make sure the backend is running.\n$error',
      );
    } catch (error) {
      if (error is Exception) {
        rethrow;
      }

      throw Exception(
        'Administrator login failed.',
      );
    }
  }

  // =========================================================
  // GET CURRENT ADMIN
  // =========================================================

  Future<AdminUser?> getCurrentAdmin() async {
    final token = await TokenStorage.getToken();

    // No stored token means there is no active admin session.
    if (token == null || token.isEmpty) {
      return null;
    }

    final uri = Uri.parse(
      '${AppEnv.adminAuthBaseUrl}/me',
    );

    try {
      final response = await _client
          .get(
            uri,
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(
            const Duration(seconds: 15),
          );

      final data = _decodeResponse(response);

      if (response.statusCode == 401 ||
          response.statusCode == 403) {
        await TokenStorage.clearToken();

        return null;
      }

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw Exception(
          data['message']?.toString() ??
              'Unable to restore administrator session.',
        );
      }

      final adminJson = data['admin'];

      if (adminJson is! Map<String, dynamic>) {
        await TokenStorage.clearToken();

        return null;
      }

      return AdminUserModel.fromJson(
        adminJson,
      );
    } on http.ClientException catch (error) {
      throw Exception(
        'Unable to connect to the AssetCoin server.\n$error',
      );
    } catch (error) {
      if (error is Exception) {
        rethrow;
      }

      throw Exception(
        'Unable to restore administrator session.',
      );
    }
  }

  // =========================================================
  // LOGOUT
  // =========================================================

  Future<void> logout() async {
    final token = await TokenStorage.getToken();

    try {
      if (token != null && token.isNotEmpty) {
        final uri = Uri.parse(
          '${AppEnv.adminAuthBaseUrl}/logout',
        );

        await _client
            .post(
              uri,
              headers: {
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
              },
            )
            .timeout(
              const Duration(seconds: 15),
            );
      }
    } finally {
      // Always remove the local token, even if the server
      // cannot be reached.
      await TokenStorage.clearToken();
    }
  }

  // =========================================================
  // RESPONSE DECODER
  // =========================================================

  Map<String, dynamic> _decodeResponse(
    http.Response response,
  ) {
    if (response.body.isEmpty) {
      return {};
    }

    try {
      final decoded = jsonDecode(
        response.body,
      );

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {};
    } catch (_) {
      return {};
    }
  }
}