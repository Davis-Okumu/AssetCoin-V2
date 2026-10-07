import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../data/datasources/admin_trading_api.dart';
import '../../data/models/admin_trading_overview_model.dart';
import '../../data/repositories/admin_trading_repository.dart';

final adminTradingOverviewControllerProvider =
    AsyncNotifierProvider<
      AdminTradingOverviewController,
      AdminTradingOverviewModel
    >(AdminTradingOverviewController.new);

class AdminTradingOverviewController
    extends AsyncNotifier<AdminTradingOverviewModel> {
  @override
  Future<AdminTradingOverviewModel> build() async {
    final repository = ref.read(adminTradingRepositoryProvider);

    return repository.getOverview();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(adminTradingRepositoryProvider);

      return repository.getOverview();
    });
  }
}

final adminTradingRepositoryProvider = Provider<AdminTradingRepository>((ref) {
  final apiClient = ref.read(adminTradingApiClientProvider);

  return AdminTradingRepository(AdminTradingApi(apiClient));
});

final adminTradingApiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient();

  ref.onDispose(client.dispose);

  return client;
});
