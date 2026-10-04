
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/asset.dart';
import '../providers/asset_providers.dart';

class AssetsController extends AsyncNotifier<List<Asset>> {
  static const int _pageSize = 20;

  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  String? _search;
  String? _category;

  int _requestVersion = 0;

  @override
  Future<List<Asset>> build() async {
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    _search = null;
    _category = null;

    return _fetchAssets(page: 1);
  }

  // =========================
  // FETCH ASSETS
  // =========================

  Future<List<Asset>> _fetchAssets({
    required int page,
  }) async {
    final repository = ref.read(assetRepositoryProvider);

    return repository.getPublishedAssets(
      search: _search,
      category: _category,
      page: page,
      limit: _pageSize,
    );
  }

  // =========================
  // REFRESH MARKETPLACE
  // =========================

  Future<void> refreshAssets() async {
    await _loadFirstPage();
  }

  // =========================
  // SEARCH ASSETS
  // =========================

  Future<void> searchAssets(String search) async {
    _search = search.trim().isEmpty ? null : search.trim();

    await _loadFirstPage();
  }

  // =========================
  // FILTER BY CATEGORY
  // =========================

  Future<void> filterByCategory(String? category) async {
    _category = category == null ||
            category.trim().isEmpty ||
            category.toLowerCase() == 'all'
        ? null
        : category.trim();

    await _loadFirstPage();
  }

  // =========================
  // LOAD FIRST PAGE
  // =========================

  Future<void> _loadFirstPage() async {
    final requestVersion = ++_requestVersion;

    _currentPage = 1;
    _hasMore = true;

    state = const AsyncLoading();

    try {
      final assets = await _fetchAssets(page: 1);

      if (requestVersion != _requestVersion) return;

      _currentPage = 1;
      _hasMore = assets.length == _pageSize;

      state = AsyncData(assets);
    } catch (error, stackTrace) {
      if (requestVersion != _requestVersion) return;

      state = AsyncError(error, stackTrace);
    }
  }

  // =========================
  // LOAD MORE ASSETS
  // =========================

  Future<void> loadMoreAssets() async {
    if (_isLoadingMore || !_hasMore || state.isLoading) {
      return;
    }

    final currentAssets = state.asData?.value;

    if (currentAssets == null) return;

    _isLoadingMore = true;

    final nextPage = _currentPage + 1;
    final requestVersion = _requestVersion;

    try {
      final newAssets = await _fetchAssets(page: nextPage);

      if (requestVersion != _requestVersion) return;

      final existingIds = currentAssets.map((asset) => asset.id).toSet();

      final uniqueAssets = newAssets
          .where((asset) => !existingIds.contains(asset.id))
          .toList();

      _currentPage = nextPage;
      _hasMore = newAssets.length == _pageSize;

      state = AsyncData([
        ...currentAssets,
        ...uniqueAssets,
      ]);
    } catch (error, stackTrace) {
      if (requestVersion == _requestVersion) {
        state = AsyncError(error, stackTrace);
      }
    } finally {
      _isLoadingMore = false;
    }
  }

  // =========================
  // CURRENT FILTERS
  // =========================

  String? get currentSearch => _search;

  String? get currentCategory => _category;

  bool get hasMore => _hasMore;

  bool get isLoadingMore => _isLoadingMore;
}

// =========================
// RIVERPOD PROVIDER
// =========================

final assetsControllerProvider =
    AsyncNotifierProvider<AssetsController, List<Asset>>(
  AssetsController.new,
);