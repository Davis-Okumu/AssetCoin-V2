import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/finance_wallet_model.dart';
import 'finance_overview_controller.dart';

final financeWalletsControllerProvider =
    AsyncNotifierProvider<FinanceWalletsController, List<FinanceWalletModel>>(
      FinanceWalletsController.new,
    );

class FinanceWalletsController extends AsyncNotifier<List<FinanceWalletModel>> {
  static const String allStatuses = 'all';

  String _searchQuery = '';
  String _statusFilter = allStatuses;
  String? _currencyFilter;

  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;
  String? get currencyFilter => _currencyFilter;

  @override
  Future<List<FinanceWalletModel>> build() async {
    return ref.read(adminFinanceRepositoryProvider).getWallets();
  }

  /// Returns the currently loaded wallets matching the active filters.
  List<FinanceWalletModel> get filteredWallets {
    final wallets = state.asData?.value ?? <FinanceWalletModel>[];

    return wallets.where((wallet) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          wallet.customerName.toLowerCase().contains(_searchQuery) ||
          wallet.walletAddress.toLowerCase().contains(_searchQuery) ||
          wallet.currency.toLowerCase().contains(_searchQuery) ||
          wallet.userId.toString().contains(_searchQuery);

      final matchesStatus =
          _statusFilter == allStatuses ||
          wallet.status.toLowerCase() == _statusFilter.toLowerCase();

      final matchesCurrency =
          _currencyFilter == null ||
          _currencyFilter!.isEmpty ||
          wallet.currency.toLowerCase() == _currencyFilter!.toLowerCase();

      return matchesSearch && matchesStatus && matchesCurrency;
    }).toList();
  }

  /// Updates the local search filter.
  void setSearchQuery(String query) {
    _searchQuery = query.trim().toLowerCase();
    _publishCurrentData();
  }

  /// Updates the wallet status filter.
  void setStatusFilter(String? status) {
    _statusFilter = (status == null || status.isEmpty) ? allStatuses : status;
    _publishCurrentData();
  }

  /// Updates the currency filter.
  void setCurrencyFilter(String? currency) {
    _currencyFilter = currency;
    _publishCurrentData();
  }

  /// Clears all local filters.
  void clearFilters() {
    _searchQuery = '';
    _statusFilter = allStatuses;
    _currencyFilter = null;
    _publishCurrentData();
  }

  /// Reloads the wallet list from the backend.
  Future<void> refresh() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => ref.read(adminFinanceRepositoryProvider).getWallets(),
    );
  }

  /// Re-emits the current data as a new list instance so watchers rebuild
  /// and re-read [filteredWallets]. The original list is not modified.
  /// Does nothing while loading or in error.
  void _publishCurrentData() {
    final current = state.asData?.value;
    if (current == null) return;

    state = AsyncData(List<FinanceWalletModel>.of(current));
  }
}
