import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/admin_ledger_entry_model.dart';
import '../../data/repositories/admin_ledger_repository.dart';
import 'ledger_overview_controller.dart';

final ledgerEntriesControllerProvider =
    AsyncNotifierProvider<
      LedgerEntriesController,
      AdminLedgerPaginatedResult<AdminLedgerEntryModel>
    >(LedgerEntriesController.new);

class LedgerEntriesController
    extends AsyncNotifier<AdminLedgerPaginatedResult<AdminLedgerEntryModel>> {
  String? _search;
  String? _entryType;
  String? _assetType;
  String? _userId;
  String? _walletId;
  String? _tokenId;
  String? _transactionId;
  String? _currency;
  String? _startDate;
  String? _endDate;

  int _page = 1;
  int _limit = 20;

  @override
  Future<AdminLedgerPaginatedResult<AdminLedgerEntryModel>> build() {
    return _loadEntries();
  }

  Future<AdminLedgerPaginatedResult<AdminLedgerEntryModel>> _loadEntries() {
    final repository = ref.read(adminLedgerRepositoryProvider);

    return repository.getEntries(
      search: _search,
      entryType: _entryType,
      assetType: _assetType,
      userId: _userId,
      walletId: _walletId,
      tokenId: _tokenId,
      transactionId: _transactionId,
      currency: _currency,
      startDate: _startDate,
      endDate: _endDate,
      page: _page,
      limit: _limit,
    );
  }

  Future<void> applyFilters({
    String? search,
    String? entryType,
    String? assetType,
    String? userId,
    String? walletId,
    String? tokenId,
    String? transactionId,
    String? currency,
    String? startDate,
    String? endDate,
  }) async {
    _search = _clean(search);
    _entryType = _clean(entryType);
    _assetType = _clean(assetType);
    _userId = _clean(userId);
    _walletId = _clean(walletId);
    _tokenId = _clean(tokenId);
    _transactionId = _clean(transactionId);
    _currency = _clean(currency);
    _startDate = _clean(startDate);
    _endDate = _clean(endDate);
    _page = 1;

    await _reload();
  }

  Future<void> clearFilters() async {
    _search = null;
    _entryType = null;
    _assetType = null;
    _userId = null;
    _walletId = null;
    _tokenId = null;
    _transactionId = null;
    _currency = null;
    _startDate = null;
    _endDate = null;
    _page = 1;

    await _reload();
  }

  Future<void> search(String value) async {
    _search = _clean(value);
    _page = 1;
    await _reload();
  }

  Future<void> goToPage(int page) async {
    if (page < 1 || page == _page) return;

    _page = page;
    await _reload();
  }

  Future<void> nextPage() async {
    final current = state.value;
    if (current == null || !current.hasNextPage) return;

    _page = current.page + 1;
    await _reload();
  }

  Future<void> previousPage() async {
    final current = state.value;
    if (current == null || !current.hasPreviousPage) return;

    _page = current.page - 1;
    await _reload();
  }

  Future<void> changePageSize(int limit) async {
    if (limit < 1 || limit == _limit) return;

    _limit = limit;
    _page = 1;
    await _reload();
  }

  Future<void> refresh() async {
    await _reload();
  }

  Future<void> _reload() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(_loadEntries);
  }

  String? _clean(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}
