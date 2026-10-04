
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/trading_repository_impl.dart';
import '../../domain/listing.dart';
import '../../domain/trading_repository.dart';

class MarketplaceState {
  final List<Listing> listings;
  final Pagination pagination;
  final String search;
  final String? assetType;

  const MarketplaceState({
    required this.listings,
    required this.pagination,
    this.search = '',
    this.assetType,
  });

  const MarketplaceState.initial()
      : listings = const [],
        pagination = const Pagination(
          page: 1,
          limit: 20,
          total: 0,
          totalPages: 0,
        ),
        search = '',
        assetType = null;

  bool get hasListings => listings.isNotEmpty;

  bool get hasNextPage => pagination.hasNextPage;

  bool get hasPreviousPage => pagination.hasPreviousPage;

  MarketplaceState copyWith({
    List<Listing>? listings,
    Pagination? pagination,
    String? search,
    String? assetType,
    bool clearAssetType = false,
  }) {
    return MarketplaceState(
      listings: listings ?? this.listings,
      pagination: pagination ?? this.pagination,
      search: search ?? this.search,
      assetType: clearAssetType
          ? null
          : assetType ?? this.assetType,
    );
  }
}

class MarketplaceController
    extends AsyncNotifier<MarketplaceState> {
  late final TradingRepository _repository;

  static const int _pageSize = 20;

  @override
  Future<MarketplaceState> build() async {
    _repository = ref.watch(
      TradingRepositoryImpl.provider,
    );

    return _loadMarketplace(
      search: '',
      assetType: null,
      page: 1,
    );
  }

  Future<MarketplaceState> _loadMarketplace({
    required String search,
    required String? assetType,
    required int page,
  }) async {
    final result = await _repository.getMarketplace(
      search: _normalizeSearch(search),
      assetType: _normalizeAssetType(assetType),
      page: page,
      limit: _pageSize,
    );

    return MarketplaceState(
      listings: result.listings,
      pagination: result.pagination,
      search: search,
      assetType: assetType,
    );
  }

  Future<void> refreshMarketplace() async {
    final currentState = state.value;

    final search = currentState?.search ?? '';
    final assetType = currentState?.assetType;

    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => _loadMarketplace(
        search: search,
        assetType: assetType,
        page: 1,
      ),
    );
  }

  Future<void> search(String value) async {
    final currentState = state.value;

    final assetType = currentState?.assetType;

    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => _loadMarketplace(
        search: value,
        assetType: assetType,
        page: 1,
      ),
    );
  }

  Future<void> setAssetType(String? assetType) async {
    final currentState = state.value;

    final search = currentState?.search ?? '';

    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => _loadMarketplace(
        search: search,
        assetType: _normalizeAssetType(assetType),
        page: 1,
      ),
    );
  }

  Future<void> clearFilters() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => _loadMarketplace(
        search: '',
        assetType: null,
        page: 1,
      ),
    );
  }

  Future<void> loadNextPage() async {
    final currentState = state.value;

    if (currentState == null) {
      return;
    }

    if (!currentState.hasNextPage) {
      return;
    }

    final nextPage =
        currentState.pagination.page + 1;

    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => _loadMarketplace(
        search: currentState.search,
        assetType: currentState.assetType,
        page: nextPage,
      ),
    );
  }

  Future<void> loadPreviousPage() async {
    final currentState = state.value;

    if (currentState == null) {
      return;
    }

    if (!currentState.hasPreviousPage) {
      return;
    }

    final previousPage =
        currentState.pagination.page - 1;

    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => _loadMarketplace(
        search: currentState.search,
        assetType: currentState.assetType,
        page: previousPage,
      ),
    );
  }

  Future<Listing> getListingDetails(
    int listingId,
  ) async {
    return _repository.getListingDetails(listingId);
  }

  String _normalizeSearch(String value) {
    final normalized = value.trim();

    return normalized.isEmpty ? '' : normalized;
  }

  String? _normalizeAssetType(String? value) {
    if (value == null) {
      return null;
    }

    final normalized = value.trim().toLowerCase();

    if (normalized.isEmpty || normalized == 'all') {
      return null;
    }

    return normalized;
  }
}

final marketplaceControllerProvider =
    AsyncNotifierProvider<
      MarketplaceController,
      MarketplaceState
    >(
      MarketplaceController.new,
    );
