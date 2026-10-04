
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/route_guards.dart';
import '../../../../core/router/route_names.dart';

import '../../../authentication/presentation/providers/auth_providers.dart';

final splashControllerProvider =
    AsyncNotifierProvider<SplashController, String>(
  SplashController.new,
);

class SplashController extends AsyncNotifier<String> {
  @override
  Future<String> build() async {
    // Display the splash screen for 2 seconds.
    await Future<void>.delayed(
      const Duration(seconds: 2),
    );

    // Get the existing authentication repository.
    final authRepository = ref.read(authRepositoryProvider);

    // Check whether the user has a valid authenticated session.
    final isAuthenticated =
        await RouteGuards.isAuthenticated(authRepository);

    // Navigate based on authentication status.
    if (isAuthenticated) {
      return RouteNames.home;
    }

    return RouteNames.login;
  }
}
