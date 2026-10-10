import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:admin/core/network/api_client_provider.dart';

import '../../data/datasources/admin_finance_api.dart';
import '../../data/models/finance_overview_model.dart';
import '../../data/repositories/admin_finance_repository.dart';

/// Provides the Finance API datasource.
final adminFinanceApiProvider = Provider<AdminFinanceApi>((ref) {
  final apiClient = ref.read(apiClientProvider);

  return AdminFinanceApi(apiClient);
});

/// Provides the admin Finance repository.
final adminFinanceRepositoryProvider = Provider<AdminFinanceRepository>((ref) {
  final api = ref.read(adminFinanceApiProvider);

  return AdminFinanceRepository(api);
});

/// Provides the Finance overview controller.
final financeOverviewControllerProvider =
    AsyncNotifierProvider<FinanceOverviewController, FinanceOverviewModel>(
      FinanceOverviewController.new,
    );

class FinanceOverviewController extends AsyncNotifier<FinanceOverviewModel> {
  @override
  Future<FinanceOverviewModel> build() async {
    final repository = ref.read(adminFinanceRepositoryProvider);

    return repository.getOverview();
  }

  /// Reloads the overview while exposing loading and error states.
  Future<void> refresh() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() {
      return ref.read(adminFinanceRepositoryProvider).getOverview();
    });
  }
}
