import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/finance_overview_model.dart';
import '../../data/repositories/admin_finance_repository.dart';
import 'finance_overview_controller.dart';

/// Provides the overall finance dashboard state.
final financeControllerProvider =
    AsyncNotifierProvider<FinanceController, FinanceOverviewModel>(
      FinanceController.new,
    );

class FinanceController extends AsyncNotifier<FinanceOverviewModel> {
  @override
  Future<FinanceOverviewModel> build() async {
    final AdminFinanceRepository repository = ref.read(
      adminFinanceRepositoryProvider,
    );

    return repository.getOverview();
  }

  /// Reloads the finance overview from the backend.
  Future<void> refresh() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => ref.read(adminFinanceRepositoryProvider).getOverview(),
    );
  }
}
