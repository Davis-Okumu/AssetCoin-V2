
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/authentication/presentation/controllers/auth_controller.dart';
import '../../features/authentication/presentation/providers/auth_providers.dart';
import 'api_client.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final apiClient = ApiClient(
    tokenStorage: ref.watch(tokenStorageProvider),

    onUnauthorized: () async {
      await ref
          .read(authControllerProvider.notifier)
          .handleSessionExpired();
    },
  );

  ref.onDispose(apiClient.dispose);

  return apiClient;
});