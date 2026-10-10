import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/finance_transaction_model.dart';
import 'finance_overview_controller.dart';

final financeTransactionsControllerProvider =
    AsyncNotifierProvider<
      FinanceTransactionsController,
      List<FinanceTransactionModel>
    >(FinanceTransactionsController.new);

class FinanceTransactionsController
    extends AsyncNotifier<List<FinanceTransactionModel>> {
  static const String allStatuses = 'all';

  String _searchQuery = '';
  String? _typeFilter;
  String _statusFilter = allStatuses;

  String get searchQuery => _searchQuery;
  String? get typeFilter => _typeFilter;
  String get statusFilter => _statusFilter;

  @override
  Future<List<FinanceTransactionModel>> build() async {
    return ref.read(adminFinanceRepositoryProvider).getTransactions();
  }

  /// Returns the loaded transactions matching the current filters.
  List<FinanceTransactionModel> get filteredTransactions {
    final transactions = state.asData?.value ?? <FinanceTransactionModel>[];

    return transactions.where((transaction) {
      final model = transaction.transaction;

      final matchesSearch =
          _searchQuery.isEmpty ||
          model.reference.toLowerCase().contains(_searchQuery) ||
          model.type.toLowerCase().contains(_searchQuery) ||
          model.status.toLowerCase().contains(_searchQuery) ||
          transaction.customerName.toLowerCase().contains(_searchQuery);

      final matchesType =
          _typeFilter == null ||
          _typeFilter!.isEmpty ||
          model.type.toLowerCase() == _typeFilter!.toLowerCase();

      final matchesStatus =
          _statusFilter == allStatuses ||
          model.status.toLowerCase() == _statusFilter.toLowerCase();

      return matchesSearch && matchesType && matchesStatus;
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.trim().toLowerCase();
    _refreshFilterState();
  }

  void setTypeFilter(String? type) {
    _typeFilter = type;
    _refreshFilterState();
  }

  void setStatusFilter(String? status) {
    _statusFilter = (status == null || status.isEmpty) ? allStatuses : status;
    _refreshFilterState();
  }

  void clearFilters() {
    _searchQuery = '';
    _typeFilter = null;
    _statusFilter = allStatuses;
    _refreshFilterState();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => ref.read(adminFinanceRepositoryProvider).getTransactions(),
    );
  }

  /// Re-emits the current data as a new list instance so watchers rebuild
  /// and re-read [filteredTransactions]. Does nothing while loading or in error.
  void _refreshFilterState() {
    final current = state.asData?.value;
    if (current == null) return;

    state = AsyncData(List<FinanceTransactionModel>.of(current));
  }
}
