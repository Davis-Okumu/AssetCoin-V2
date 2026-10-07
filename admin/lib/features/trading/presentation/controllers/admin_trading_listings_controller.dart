import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/admin_trading_listing_model.dart';
import '../../data/repositories/admin_trading_repository.dart';
import 'admin_trading_overview_controller.dart';

final adminTradingListingsControllerProvider =
    AsyncNotifierProvider<
      AdminTradingListingsController,
      AdminTradingPaginatedResult<AdminTradingListingModel>
    >(AdminTradingListingsController.new);

class AdminTradingListingsController
    extends
        AsyncNotifier<AdminTradingPaginatedResult<AdminTradingListingModel>> {
  String? _search;
  String? _status;
  String? _listingType;

  int _page = 1;
  int _limit = 20;

  String? get searchQuery => _search;

  String? get statusFilter => _status;

  String? get listingTypeFilter => _listingType;

  int get currentPage => _page;

  int get pageSize => _limit;

  @override
  Future<AdminTradingPaginatedResult<AdminTradingListingModel>> build() {
    return _fetch();
  }

  Future<AdminTradingPaginatedResult<AdminTradingListingModel>> _fetch() {
    final repository = ref.read(adminTradingRepositoryProvider);

    return repository.getListings(
      search: _search,
      status: _status,
      listingType: _listingType,
      page: _page,
      limit: _limit,
    );
  }

  Future<void> _load({bool showLoading = true}) async {
    if (showLoading) {
      state = const AsyncLoading();
    }

    state = await AsyncValue.guard(_fetch);
  }

  Future<void> refresh() async {
    await _load();
  }

  Future<void> search(String? value) async {
    final normalizedValue = value?.trim();

    _search = normalizedValue == null || normalizedValue.isEmpty
        ? null
        : normalizedValue;

    _page = 1;

    await _load();
  }

  Future<void> setStatus(String? value) async {
    final normalizedValue = value?.trim();

    _status = normalizedValue == null || normalizedValue.isEmpty
        ? null
        : normalizedValue;

    _page = 1;

    await _load();
  }

  Future<void> setListingType(String? value) async {
    final normalizedValue = value?.trim();

    _listingType = normalizedValue == null || normalizedValue.isEmpty
        ? null
        : normalizedValue;

    _page = 1;

    await _load();
  }

  Future<void> clearFilters() async {
    _search = null;
    _status = null;
    _listingType = null;
    _page = 1;

    await _load();
  }

  Future<void> setPageSize(int limit) async {
    if (limit <= 0) {
      return;
    }

    _limit = limit;
    _page = 1;

    await _load();
  }

  Future<void> goToPage(int page) async {
    if (page < 1) {
      return;
    }

    final currentResult = state.value;

    if (currentResult != null && page > currentResult.totalPages) {
      return;
    }

    if (page == _page) {
      return;
    }

    _page = page;

    await _load();
  }

  Future<void> nextPage() async {
    final currentResult = state.value;

    if (currentResult == null || !currentResult.hasNextPage) {
      return;
    }

    _page = currentResult.page + 1;

    await _load();
  }

  Future<void> previousPage() async {
    final currentResult = state.value;

    if (currentResult == null || !currentResult.hasPreviousPage) {
      return;
    }

    _page = currentResult.page - 1;

    await _load();
  }

  Future<AdminTradingListingModel> suspendListing(
    int listingId, {
    String? reason,
  }) async {
    final repository = ref.read(adminTradingRepositoryProvider);

    final listing = await repository.suspendListing(listingId, reason: reason);

    await _load(showLoading: false);

    return listing;
  }

  Future<AdminTradingListingModel> reactivateListing(
    int listingId, {
    String? reason,
  }) async {
    final repository = ref.read(adminTradingRepositoryProvider);

    final listing = await repository.reactivateListing(
      listingId,
      reason: reason,
    );

    await _load(showLoading: false);

    return listing;
  }

  Future<AdminTradingListingModel?> findListing(int listingId) async {
    final repository = ref.read(adminTradingRepositoryProvider);

    try {
      return await repository.getListing(listingId);
    } catch (_) {
      return null;
    }
  }
}
