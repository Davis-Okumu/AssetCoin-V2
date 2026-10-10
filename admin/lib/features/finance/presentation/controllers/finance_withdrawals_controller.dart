import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/finance_withdrawal_model.dart';
import 'finance_overview_controller.dart';

final financeWithdrawalsControllerProvider =
    AsyncNotifierProvider<
      FinanceWithdrawalsController,
      List<FinanceWithdrawalModel>
    >(FinanceWithdrawalsController.new);

class FinanceWithdrawalsController
    extends AsyncNotifier<List<FinanceWithdrawalModel>> {
  String _searchQuery = '';
  String _statusFilter = 'all';

  String get searchQuery => _searchQuery;

  String get statusFilter => _statusFilter;

  @override
  Future<List<FinanceWithdrawalModel>> build() async {
    final repository = ref.read(adminFinanceRepositoryProvider);
    return repository.getWithdrawals();
  }

  List<FinanceWithdrawalModel> get filteredWithdrawals {
    final withdrawals = state.asData?.value ?? [];

    return withdrawals.where((withdrawal) {
      final transaction = withdrawal.transaction;

      final reference = transaction.reference.toLowerCase();
      final status = transaction.status.toLowerCase();
      final customerName = withdrawal.customerName.toLowerCase();

      final query = _searchQuery.trim().toLowerCase();

      final matchesSearch =
          query.isEmpty ||
          reference.contains(query) ||
          customerName.contains(query);

      final matchesStatus =
          _statusFilter == 'all' || status == _statusFilter.toLowerCase();

      return matchesSearch && matchesStatus;
    }).toList();
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    _notifyFilterChange();
  }

  void setStatusFilter(String value) {
    _statusFilter = value;
    _notifyFilterChange();
  }

  void clearFilters() {
    _searchQuery = '';
    _statusFilter = 'all';
    _notifyFilterChange();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => ref.read(adminFinanceRepositoryProvider).getWithdrawals(),
    );
  }

  void _notifyFilterChange() {
    final current = state.asData?.value;

    if (current != null) {
      // Publish a new list so widgets watching this provider rebuild.
      state = AsyncData(List<FinanceWithdrawalModel>.of(current));
    }
  }
}
