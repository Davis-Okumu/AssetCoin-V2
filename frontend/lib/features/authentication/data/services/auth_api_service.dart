
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/config/env.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';
import '../models/password_reset_response_model.dart';


  class ApiException implements Exception {
  const ApiException({
    required this.message,
    required this.statusCode,
  });

  final String message;
  final int statusCode;

  @override
  String toString() => message;
}

class AuthApiService {
  final http.Client _client;

  AuthApiService({http.Client? client})
      : _client = client ?? http.Client();

  String get _baseUrl => AppEnv.apiBaseUrl;

  // REGISTER
  Future<AuthResponseModel> register({
    required String firstName,
    required String lastName,
    required String phone,
    String? email,
    required String nationalId,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/auth/register'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'email': email,
        'nationalId': nationalId,
        'password': password,
      }),
    );

    return _handleAuthResponse(response);
  }

  // LOGIN
  Future<AuthResponseModel> login({
    required String identifier,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/auth/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'identifier': identifier,
        'password': password,
      }),
    );

    return _handleAuthResponse(response);
  }

  // FORGOT PASSWORD
  Future<PasswordResetResponseModel> forgotPassword({
    required String email,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/auth/forgot-password'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
      }),
    );

    final Map<String, dynamic> responseData =
        jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        responseData['success'] == true) {
      final data =
          responseData['data'] as Map<String, dynamic>?;

      return PasswordResetResponseModel(
        message: responseData['message'] as String? ?? '',
        resetToken: data?['resetToken'] as String?,
      );
    }

    throw Exception(
      responseData['message'] ??
          'Unable to process your password reset request.',
    );
  }

  // RESET PASSWORD
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/auth/reset-password'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'token': token,
        'newPassword': newPassword,
      }),
    );

    final Map<String, dynamic> responseData =
        jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        responseData['success'] == true) {
      return;
    }

    throw Exception(
      responseData['message'] ??
          'Unable to reset your password.',
    );
  }


  // LOGOUT
  Future<void> logout(String token) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/auth/logout'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({}),
    );

    final Map<String, dynamic> responseData =
        jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        responseData['success'] == true) {
      return;
    }

    throw ApiException(
      message: responseData['message'] ??
          'Unable to complete logout.',
      statusCode: response.statusCode,
    );
  }

  // CHANGE PASSWORD
  Future<void> changePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/auth/change-password'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );

    final Map<String, dynamic> responseData =
        jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        responseData['success'] == true) {
      return;
    }

    throw ApiException(
      message: responseData['message'] ??
          'Unable to change your password.',
      statusCode: response.statusCode,
    );
  }
  // GET CURRENT USER
Future<UserModel> getCurrentUser(String token) async {
  final response = await _client.get(
    Uri.parse('$_baseUrl/api/auth/me'),
    headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  final Map<String, dynamic> responseData =
      jsonDecode(response.body) as Map<String, dynamic>;

  if (response.statusCode >= 200 &&
      response.statusCode < 300 &&
      responseData['success'] == true) {
    return UserModel.fromJson(
      responseData['data']['user'] as Map<String, dynamic>,
    );
  }

  throw ApiException(
    message: responseData['message'] ??
        'Unable to retrieve user profile.',
    statusCode: response.statusCode,
  );
}

  // SHARED AUTH RESPONSE HANDLER
  AuthResponseModel _handleAuthResponse(http.Response response) {
    final Map<String, dynamic> responseData =
        jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        responseData['success'] == true) {
      return AuthResponseModel.fromJson(
        responseData['data'] as Map<String, dynamic>,
      );
    }

    throw Exception(
      responseData['message'] ?? 'Authentication request failed.',
    );
  }

  // DISPOSE
  void dispose() {
    _client.close();
  }
}
