import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';

/// Provides the shared [ApiClient] instance for the
/// AssetCoin Admin Dashboard.
///
/// Repositories should depend on this provider instead of
/// creating their own HTTP clients.
final apiClientProvider = Provider<ApiClient>((ref) {
  final apiClient = ApiClient();

  ref.onDispose(apiClient.dispose);

  return apiClient;
});
