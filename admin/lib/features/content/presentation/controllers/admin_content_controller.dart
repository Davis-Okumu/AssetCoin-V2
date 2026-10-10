import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client_provider.dart';
import '../../data/datasource/admin_content_api.dart';
import '../../data/models/admin_content_model.dart';
import '../../data/repositories/admin_content_repository.dart';

// ================================================================
// PROVIDERS
// ================================================================

/// Provides the content API datasource.
final adminContentApiProvider = Provider<AdminContentApi>((ref) {
  return AdminContentApi(ref.watch(apiClientProvider));
});

/// Provides the content repository.
final adminContentRepositoryProvider = Provider<AdminContentRepository>((ref) {
  return AdminContentRepository(ref.watch(adminContentApiProvider));
});

/// Provides the state and actions for Content Management.
final adminContentControllerProvider =
    AsyncNotifierProvider<AdminContentController, AdminContentState>(
      AdminContentController.new,
    );

// ================================================================
// CONTENT STATE
// ================================================================

class AdminContentState {
  const AdminContentState({
    required this.overview,
    required this.items,
    required this.type,
    this.status,
    this.category,
    this.search = '',
    this.page = 1,
    this.limit = 20,
    this.total = 0,
    this.totalPages = 1,
  });

  final AdminContentOverview overview;
  final List<AdminContentModel> items;
  final String type;
  final String? status;
  final String? category;
  final String search;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  bool get hasNextPage => page < totalPages;

  bool get hasPreviousPage => page > 1;

  AdminContentState copyWith({
    AdminContentOverview? overview,
    List<AdminContentModel>? items,
    String? type,
    String? status,
    String? category,
    String? search,
    int? page,
    int? limit,
    int? total,
    int? totalPages,
    bool clearStatus = false,
    bool clearCategory = false,
  }) {
    return AdminContentState(
      overview: overview ?? this.overview,
      items: items ?? this.items,
      type: type ?? this.type,
      status: clearStatus ? null : status ?? this.status,
      category: clearCategory ? null : category ?? this.category,
      search: search ?? this.search,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      total: total ?? this.total,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}

// ================================================================
// CONTROLLER
// ================================================================

class AdminContentController extends AsyncNotifier<AdminContentState> {
  static const String defaultContentType = 'announcements';

  AdminContentRepository get _repository =>
      ref.read(adminContentRepositoryProvider);

  @override
  Future<AdminContentState> build() async {
    final overview = await _repository.getOverview();

    final response = await _repository.getContent(
      type: defaultContentType,
      page: 1,
      limit: 20,
    );

    return AdminContentState(
      overview: overview,
      items: response.items,
      type: defaultContentType,
      page: response.page,
      limit: response.limit,
      total: response.total,
      totalPages: response.totalPages,
    );
  }

  // ============================================================
  // LOAD AND FILTER CONTENT
  // ============================================================

  Future<void> loadContent({
    String? type,
    String? status,
    String? category,
    String? search,
    int? page,
    int? limit,
    bool clearStatus = false,
    bool clearCategory = false,
  }) async {
    final current = state.value;

    if (current == null) return;

    final selectedType = type ?? current.type;
    final selectedStatus = clearStatus ? null : status ?? current.status;
    final selectedCategory = clearCategory
        ? null
        : category ?? current.category;
    final selectedSearch = search ?? current.search;
    final selectedPage =
        page ??
        (type != null ||
                status != null ||
                category != null ||
                search != null ||
                clearStatus ||
                clearCategory
            ? 1
            : current.page);
    final selectedLimit = limit ?? current.limit;

    // Keep the existing screen visible while a filter is loading.
    state = AsyncData(
      current.copyWith(
        type: selectedType,
        status: selectedStatus,
        category: selectedCategory,
        search: selectedSearch,
        page: selectedPage,
        limit: selectedLimit,
        clearStatus: clearStatus,
        clearCategory: clearCategory,
      ),
    );

    try {
      final response = await _repository.getContent(
        type: selectedType,
        status: selectedStatus,
        category: selectedCategory,
        search: selectedSearch,
        page: selectedPage,
        limit: selectedLimit,
      );

      final latest = state.value;
      if (latest == null) return;

      // Avoid displaying stale results if another request has
      // changed the active filters while this request was running.
      if (latest.type != selectedType ||
          latest.status != selectedStatus ||
          latest.category != selectedCategory ||
          latest.search != selectedSearch ||
          latest.page != selectedPage) {
        return;
      }

      state = AsyncData(
        latest.copyWith(
          items: response.items,
          page: response.page,
          limit: response.limit,
          total: response.total,
          totalPages: response.totalPages,
        ),
      );
    } catch (error, stackTrace) {
      final latest = state.value;

      if (latest != null) {
        state = AsyncError(error, stackTrace);
      }
      rethrow;
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refresh() async {
    final current = state.value;

    if (current == null) {
      ref.invalidateSelf();
      await future;
      return;
    }

    final overview = await _repository.getOverview();

    await loadContent(
      type: current.type,
      status: current.status,
      category: current.category,
      search: current.search,
      page: current.page,
      limit: current.limit,
      clearStatus: current.status == null,
      clearCategory: current.category == null,
    );

    final latest = state.value;

    if (latest != null) {
      state = AsyncData(latest.copyWith(overview: overview));
    }
  }

  // ============================================================
  // CREATE
  // ============================================================

  Future<AdminContentModel> createContent({
    required String type,
    required Map<String, dynamic> data,
  }) async {
    final created = await _repository.createContent(type: type, data: data);

    await refresh();

    return created;
  }

  // ============================================================
  // UPDATE
  // ============================================================

  Future<AdminContentModel> updateContent({
    required String type,
    required int id,
    required Map<String, dynamic> data,
  }) async {
    final updated = await _repository.updateContent(
      type: type,
      id: id,
      data: data,
    );

    await refresh();

    return updated;
  }

  // ============================================================
  // PUBLISH
  // ============================================================

  Future<AdminContentModel> publishContent({
    required String type,
    required int id,
  }) async {
    final published = await _repository.publishContent(type: type, id: id);

    await refresh();

    return published;
  }

  // ============================================================
  // ARCHIVE
  // ============================================================

  Future<AdminContentModel> archiveContent({
    required String type,
    required int id,
  }) async {
    final archived = await _repository.archiveContent(type: type, id: id);

    await refresh();

    return archived;
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> deleteContent({required String type, required int id}) async {
    await _repository.deleteContent(type: type, id: id);

    await refresh();
  }

  // ============================================================
  // PAGINATION
  // ============================================================

  Future<void> nextPage() async {
    final current = state.value;

    if (current == null || !current.hasNextPage) return;

    await loadContent(page: current.page + 1);
  }

  Future<void> previousPage() async {
    final current = state.value;

    if (current == null || !current.hasPreviousPage) return;

    await loadContent(page: current.page - 1);
  }

  Future<void> changePageSize(int limit) async {
    if (limit <= 0) return;

    await loadContent(limit: limit, page: 1);
  }
}
