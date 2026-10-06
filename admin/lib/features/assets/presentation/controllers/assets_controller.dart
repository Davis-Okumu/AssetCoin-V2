import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/admin_asset_list_model.dart';
import '../../data/repositories/assets_repository.dart';

final assetsControllerProvider =
    AsyncNotifierProvider<AssetsController, AdminAssetListModel>(
      AssetsController.new,
    );

class AssetsController extends AsyncNotifier<AdminAssetListModel> {
  AssetsRepository get _repository => ref.read(assetsRepositoryProvider);

  int _page = 1;

  int get page => _page;

  final int _limit = 20;

  String _search = '';

  String? _status;

  String? _assetType;

  @override
  Future<AdminAssetListModel> build() => _load();

  Future<AdminAssetListModel> _load() {
    return _repository.getAssets(
      page: _page,
      limit: _limit,
      search: _search,
      status: _status,
      assetType: _assetType,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(_load);
  }

  Future<void> setSearch(String value) async {
    _search = value.trim();
    _page = 1;

    await refresh();
  }

  Future<void> setStatus(String? value) async {
    _status = value;
    _page = 1;

    await refresh();
  }

  Future<void> setAssetType(String? value) async {
    _assetType = value;
    _page = 1;

    await refresh();
  }

  Future<void> nextPage() async {
    final current = state.value; // was valueOrNull

    if (current == null) {
      return;
    }

    if (_page >= current.pagination.totalPages) {
      return;
    }

    _page++;

    await refresh();
  }

  Future<void> previousPage() async {
    if (_page <= 1) {
      return;
    }

    _page--;

    await refresh();
  }

  Future<void> goToPage(int page) async {
    if (page < 1) {
      return;
    }

    final current = state.value; // was valueOrNull

    if (current != null &&
        current.pagination.totalPages > 0 &&
        page > current.pagination.totalPages) {
      return;
    }

    _page = page;

    await refresh();
  }

  void clearFilters() {
    _search = '';
    _status = null;
    _assetType = null;
    _page = 1;

    refresh();
  }
}
