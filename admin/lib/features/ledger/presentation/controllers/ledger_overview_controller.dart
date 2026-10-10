import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client_provider.dart';
import '../../data/data_sources/admin_ledger_api.dart';
import '../../data/models/admin_ledger_overview_model.dart';
import '../../data/repositories/admin_ledger_repository.dart';

final adminLedgerApiProvider = Provider<AdminLedgerApi>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AdminLedgerApi(apiClient);
});

final adminLedgerRepositoryProvider = Provider<AdminLedgerRepository>((ref) {
  final api = ref.watch(adminLedgerApiProvider);
  return AdminLedgerRepository(api);
});

final ledgerOverviewControllerProvider =
    AsyncNotifierProvider<LedgerOverviewController, AdminLedgerOverviewModel>(
      LedgerOverviewController.new,
    );

class LedgerOverviewController extends AsyncNotifier<AdminLedgerOverviewModel> {
  @override
  Future<AdminLedgerOverviewModel> build() async {
    final repository = ref.read(adminLedgerRepositoryProvider);
    return repository.getOverview();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
