import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/admin_auth_repository.dart';
import '../../domain/admin_user.dart';

final adminAuthRepositoryProvider = Provider<AdminAuthRepository>(
  (ref) => AdminAuthRepository(),
);

final adminAuthControllerProvider =
    AsyncNotifierProvider<AdminAuthController, AdminUser?>(
  AdminAuthController.new,
);

class AdminAuthController extends AsyncNotifier<AdminUser?> {
  late final AdminAuthRepository _repository;

  @override
  Future<AdminUser?> build() async {
    _repository = ref.read(
      adminAuthRepositoryProvider,
    );

    return _repository.getCurrentAdmin();
  }

  // =========================================================
  // LOGIN
  // =========================================================

  Future<bool> login({
    required String identifier,
    required String password,
  }) async {
    state = const AsyncLoading();

    final result = await AsyncValue.guard(
      () => _repository.login(
        identifier: identifier,
        password: password,
      ),
    );

    state = result;

    return result.hasValue &&
        result.value != null;
  }

  // =========================================================
  // LOGOUT
  // =========================================================

  Future<void> logout() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () async {
        await _repository.logout();

        return null;
      },
    );
  }

  // =========================================================
  // REFRESH SESSION
  // =========================================================

  Future<void> refreshSession() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => _repository.getCurrentAdmin(),
    );
  }

  // =========================================================
  // AUTHENTICATION STATE
  // =========================================================

  bool get isAuthenticated {
    return state.value != null;
  }

  AdminUser? get currentAdmin {
    return state.value;
  }
}