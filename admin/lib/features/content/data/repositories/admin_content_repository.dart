import '../datasource/admin_content_api.dart';
import '../models/admin_content_model.dart';

/// Repository for AssetCoin Admin Content Management.
///
/// Keeps API communication separate from content models and
/// presentation logic.
class AdminContentRepository {
  AdminContentRepository(this._api);

  final AdminContentApi _api;

  // ============================================================
  // OVERVIEW
  // ============================================================

  Future<AdminContentOverview> getOverview() async {
    final response = await _api.getOverview();

    return AdminContentOverview.fromJson(response);
  }

  // ============================================================
  // CONTENT LIST
  // ============================================================

  Future<AdminContentRepositoryListResponse> getContent({
    required String type,
    String? status,
    String? category,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _api.getContent(
      type: type,
      status: status,
      category: category,
      search: search,
      page: page,
      limit: limit,
    );

    final items = response.items
        .map((item) => AdminContentModel.fromJson(item, type: type))
        .toList();

    return AdminContentRepositoryListResponse(
      items: items,
      page: response.page,
      limit: response.limit,
      total: response.total,
      totalPages: response.totalPages,
    );
  }

  // ============================================================
  // CONTENT DETAILS
  // ============================================================

  Future<AdminContentModel> getContentDetails({
    required String type,
    required int id,
  }) async {
    final response = await _api.getContentDetails(type: type, id: id);

    return AdminContentModel.fromJson(response, type: type);
  }

  // ============================================================
  // CREATE CONTENT
  // ============================================================

  Future<AdminContentModel> createContent({
    required String type,
    required Map<String, dynamic> data,
  }) async {
    final response = await _api.createContent(type: type, data: data);

    return AdminContentModel.fromJson(_unwrapContent(response), type: type);
  }

  // ============================================================
  // UPDATE CONTENT
  // ============================================================

  Future<AdminContentModel> updateContent({
    required String type,
    required int id,
    required Map<String, dynamic> data,
  }) async {
    final response = await _api.updateContent(type: type, id: id, data: data);

    return AdminContentModel.fromJson(_unwrapContent(response), type: type);
  }

  // ============================================================
  // PUBLISH CONTENT
  // ============================================================

  Future<AdminContentModel> publishContent({
    required String type,
    required int id,
  }) async {
    final response = await _api.publishContent(type: type, id: id);

    return AdminContentModel.fromJson(_unwrapContent(response), type: type);
  }

  // ============================================================
  // ARCHIVE CONTENT
  // ============================================================

  Future<AdminContentModel> archiveContent({
    required String type,
    required int id,
  }) async {
    final response = await _api.archiveContent(type: type, id: id);

    return AdminContentModel.fromJson(_unwrapContent(response), type: type);
  }

  // ============================================================
  // DELETE CONTENT
  // ============================================================

  Future<void> deleteContent({required String type, required int id}) async {
    await _api.deleteContent(type: type, id: id);
  }

  // ============================================================
  // RESPONSE NORMALIZATION
  // ============================================================

  /// Normalizes a content response that may be wrapped in
  /// `item`, `content`, or `record`.
  ///
  /// The API datasource already unwraps the top-level `data`
  /// property, so this helper handles the returned content map.
  Map<String, dynamic> _unwrapContent(Map<String, dynamic> response) {
    final nested =
        response['item'] ?? response['content'] ?? response['record'];

    if (nested is Map) {
      return Map<String, dynamic>.from(nested);
    }

    return response;
  }
}

// ================================================================
// CONTENT LIST RESPONSE
// ================================================================

/// Typed, paginated content list returned by the repository.
class AdminContentRepositoryListResponse {
  const AdminContentRepositoryListResponse({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final List<AdminContentModel> items;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  bool get hasNextPage => page < totalPages;

  bool get hasPreviousPage => page > 1;

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;
}
