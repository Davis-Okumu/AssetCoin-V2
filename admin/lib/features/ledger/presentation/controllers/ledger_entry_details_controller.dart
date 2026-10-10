import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/admin_ledger_entry_model.dart';
import '../../data/repositories/admin_ledger_repository.dart';
import 'ledger_overview_controller.dart';

final ledgerEntryDetailsControllerProvider =
    AsyncNotifierProvider.family<
      LedgerEntryDetailsController,
      AdminLedgerEntryModel,
      int
    >(LedgerEntryDetailsController.new);

class LedgerEntryDetailsController
    extends AsyncNotifier<AdminLedgerEntryModel> {
  LedgerEntryDetailsController(this.entryId);

  final int entryId;

  AdminLedgerRepository get _repository =>
      ref.read(adminLedgerRepositoryProvider);

  @override
  Future<AdminLedgerEntryModel> build() {
    return _repository.getEntry(entryId);
  }

  Future<Map<String, dynamic>> loadHashInspection() {
    return _repository.getHashInspection(entryId);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
