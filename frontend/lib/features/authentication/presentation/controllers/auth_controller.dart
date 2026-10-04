
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/user_model.dart';
import '../../data/models/password_reset_response_model.dart';
import '../providers/auth_providers.dart';

final authControllerProvider =
    AsyncNotifierProvider<AuthController, UserModel?>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<UserModel?> {
  late final _repository = ref.read(authRepositoryProvider);

  bool _isRefreshingSession = false;

  // RESTORE SESSION WHEN THE PROVIDER STARTS
  @override
  Future<UserModel?> build() async {
    return _repository.restoreSession();
  }

  // LOGIN
  Future<void> login({
    required String identifier,
    required String password,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => _repository.login(
        identifier: identifier,
        password: password,
      ),
    );
  }

  // REGISTER
  Future<void> register({
    required String firstName,
    required String lastName,
    required String phone,
    String? email,
    required String nationalId,
    required String password,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => _repository.register(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        email: email,
        nationalId: nationalId,
        password: password,
      ),
    );
  }

  // REFRESH SESSION WHEN THE APP RESUMES
  Future<void> refreshSession() async {
    // Avoid refreshing when the user is not authenticated.
    final currentUser = state.asData?.value;

    if (currentUser == null) return;

    // Prevent multiple simultaneous refresh requests.
    if (_isRefreshingSession) return;

    _isRefreshingSession = true;

    try {
      final refreshedUser = await _repository.restoreSession();

      // Update the authentication state without showing loading.
      state = AsyncData(refreshedUser);
    } catch (_) {
      // Preserve the current session during temporary
      // network or server failures.
    } finally {
      _isRefreshingSession = false;
    }
  }

  // LOGOUT
// LOGOUT
Future<void> logout() async {
  try {
    await _repository.logout();
  } finally {
    // Always clear the authenticated UI state.
    state = const AsyncData(null);
  }
}

  // HANDLE EXPIRED SESSION
Future<void> handleSessionExpired() async {
  if (state.asData?.value == null) {
    return;
  }

  try {
    await _repository.logout();
  } finally {
    state = const AsyncData(null);
  }
}

  // FORGOT PASSWORD
  Future<PasswordResetResponseModel> forgotPassword({
    required String email,
  }) async {
    return _repository.forgotPassword(
      email: email,
    );
  }

  // RESET PASSWORD
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await _repository.resetPassword(
      token: token,
      newPassword: newPassword,
    );
  }
  // CHANGE PASSWORD
Future<void> changePassword({
  required String currentPassword,
  required String newPassword,
}) async {
  await _repository.changePassword(
    currentPassword: currentPassword,
    newPassword: newPassword,
  );

  // The backend has revoked the session.
  // Clear the authenticated user from Riverpod.
  state = const AsyncData(null);
}
}