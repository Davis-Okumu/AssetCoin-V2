import '../../../../core/storage/token_storage.dart';

import '../models/auth_response_model.dart';
import '../models/password_reset_response_model.dart';
import '../models/user_model.dart';
import '../services/auth_api_service.dart';

class AuthRepository {
  final AuthApiService _apiService;
  final TokenStorage _tokenStorage;

  AuthRepository({
    AuthApiService? apiService,
    TokenStorage? tokenStorage,
  })  : _apiService = apiService ?? AuthApiService(),
        _tokenStorage = tokenStorage ?? TokenStorage();

  // =========================
  // REGISTER
  // =========================

  Future<UserModel> register({
    required String firstName,
    required String lastName,
    required String phone,
    String? email,
    required String nationalId,
    required String password,
  }) async {
    final AuthResponseModel response =
        await _apiService.register(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      email: email,
      nationalId: nationalId,
      password: password,
    );

    await _tokenStorage.saveToken(response.token);

    return response.user;
  }

  // =========================
  // LOGIN
  // =========================

  Future<UserModel> login({
    required String identifier,
    required String password,
  }) async {
    final AuthResponseModel response =
        await _apiService.login(
      identifier: identifier,
      password: password,
    );

    await _tokenStorage.saveToken(response.token);

    return response.user;
  }

  // =========================
  // RESTORE SESSION
  // =========================

  Future<UserModel?> restoreSession() async {
    final token = await _tokenStorage.getToken();

    if (token == null || token.trim().isEmpty) {
      return null;
    }

    try {
      return await _apiService.getCurrentUser(token);
    } on ApiException catch (error) {
      if (error.statusCode == 401) {
        await _tokenStorage.deleteToken();
        return null;
      }

      rethrow;
    }
  }

  // =========================
  // GET CURRENT USER
  // =========================

  Future<UserModel> getCurrentUser() async {
    final token = await _tokenStorage.getToken();

    if (token == null || token.trim().isEmpty) {
      throw Exception('You are not authenticated.');
    }

    return _apiService.getCurrentUser(token);
  }

  // =========================
  // FORGOT PASSWORD
  // =========================

  Future<PasswordResetResponseModel> forgotPassword({
    required String email,
  }) async {
    return _apiService.forgotPassword(
      email: email,
    );
  }

  // =========================
  // RESET PASSWORD
  // =========================

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    return _apiService.resetPassword(
      token: token,
      newPassword: newPassword,
    );
  }
  
  // CHANGE PASSWORD
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final token = await _tokenStorage.getToken();

    if (token == null || token.trim().isEmpty) {
      throw Exception('You are not authenticated.');
    }

    // The backend validates the current password and changes it.
    // It also revokes all active sessions.
    await _apiService.changePassword(
      token: token,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    // The old JWT is no longer valid after a successful change.
    await _tokenStorage.deleteToken();
  }

  // =========================
  // LOGOUT
  // =========================


  // LOGOUT
  Future<void> logout() async {
    try {
      final token = await _tokenStorage.getToken();

      if (token != null && token.trim().isNotEmpty) {
        try {
          await _apiService.logout(token);
        } catch (_) {
          // Local logout must still happen if the server
          // cannot be reached or the session has expired.
        }
      }
    } finally {
      await _tokenStorage.deleteToken();
    }
  }
}