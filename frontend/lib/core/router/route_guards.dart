import '../../features/authentication/data/repositories/auth_repository.dart';

class RouteGuards {
  const RouteGuards._();

  static Future<bool> isAuthenticated(
    AuthRepository repository,
  ) async {
    try {
      final user = await repository.restoreSession();

      return user != null;
    } catch (_) {
      return false;
    }
  }
}
