import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/finance_deposit_model.dart';
import 'finance_overview_controller.dart';

final financeDepositsControllerProvider =
    AsyncNotifierProvider<FinanceDepositsController, List<FinanceDepositModel>>(
      FinanceDepositsController.new,
    );

class FinanceDepositsController
    extends AsyncNotifier<List<FinanceDepositModel>> {
  static const String allStatuses = 'all';

  String _searchQuery = '';
  String _statusFilter = allStatuses;

  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;

  @override
  Future<List<FinanceDepositModel>> build() async {
    return ref.read(adminFinanceRepositoryProvider).getDeposits();
  }

  /// Returns deposits matching the active filters.
  List<FinanceDepositModel> get filteredDeposits {
    final deposits = state.asData?.value ?? <FinanceDepositModel>[];

    return deposits.where((deposit) {
      final transaction = deposit.transaction;

      final matchesSearch =
          _searchQuery.isEmpty ||
          transaction.reference.toLowerCase().contains(_searchQuery) ||
          deposit.customerName.toLowerCase().contains(_searchQuery) ||
          transaction.status.toLowerCase().contains(_searchQuery);

      final matchesStatus =
          _statusFilter == allStatuses ||
          transaction.status.toLowerCase() == _statusFilter.toLowerCase();

      return matchesSearch && matchesStatus;
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.trim().toLowerCase();
    _notifyFilterChange();
  }

  void setStatusFilter(String? status) {
    _statusFilter = (status == null || status.isEmpty) ? allStatuses : status;
    _notifyFilterChange();
  }

  void clearFilters() {
    _searchQuery = '';
    _statusFilter = allStatuses;
    _notifyFilterChange();
  }

  /// Reloads deposits from the backend.
  Future<void> refresh() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => ref.read(adminFinanceRepositoryProvider).getDeposits(),
    );
  }

  /// Re-emits the current data as a new list instance so watchers rebuild
  /// and re-read [filteredDeposits]. Does nothing while loading or in error.
  void _notifyFilterChange() {
    final current = state.asData?.value;
    if (current == null) return;

    state = AsyncData(List<FinanceDepositModel>.of(current));
  }
}
