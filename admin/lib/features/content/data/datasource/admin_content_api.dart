import '../../../../core/network/api_client.dart';

/// API datasource for AssetCoin Admin Content Management.
///
/// Responsibilities:
/// - Retrieve content management overview statistics.
/// - List announcements, news, and publications.
/// - Retrieve individual content records.
/// - Create and update content.
/// - Publish and archive content.
/// - Delete content when permitted by the backend.
/// - Normalize API responses for repositories.
///
/// All requests use the shared ApiClient for authentication,
/// JSON decoding, and consistent error handling.
class AdminContentApi {
  AdminContentApi(this._client);

  final ApiClient _client;

  static const String _basePath = '/api/admin/content';

  static const Set<String> supportedContentTypes = {
    'announcements',
    'news',
    'publications',
  };

  // ============================================================
  // OVERVIEW
  // ============================================================

  /// Retrieves overview statistics for all content types.
  ///
  /// Expected endpoint:
  /// GET /api/admin/content/overview
  Future<Map<String, dynamic>> getOverview() async {
    final response = await _client.get('$_basePath/overview');

    return _extractMap(response);
  }

  // ============================================================
  // CONTENT LIST
  // ============================================================

  /// Retrieves a paginated list of content records.
  ///
  /// Supported content types:
  /// - announcements
  /// - news
  /// - publications
  ///
  /// Optional filters include status, category, and search.
  ///
  /// Expected endpoint:
  /// GET /api/admin/content/:type
  Future<AdminContentApiListResponse> getContent({
    required String type,
    String? status,
    String? category,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    _validateContentType(type);

    final response = await _client.get(
      '$_basePath/$type',
      queryParameters: _buildQuery({
        'status': status,
        'category': category,
        'search': search,
        'page': page.toString(),
        'limit': limit.toString(),
      }),
    );

    return _extractListResponse(response);
  }

  // ============================================================
  // CONTENT DETAILS
  // ============================================================

  /// Retrieves a single content record.
  ///
  /// Expected endpoint:
  /// GET /api/admin/content/:type/:id
  Future<Map<String, dynamic>> getContentDetails({
    required String type,
    required int id,
  }) async {
    _validateContentType(type);
    _validateId(id);

    final response = await _client.get('$_basePath/$type/$id');

    return _extractMap(response);
  }

  // ============================================================
  // CREATE CONTENT
  // ============================================================

  /// Creates a new content record.
  ///
  /// The record should normally be created as a draft.
  ///
  /// Expected endpoint:
  /// POST /api/admin/content/:type
  Future<Map<String, dynamic>> createContent({
    required String type,
    required Map<String, dynamic> data,
  }) async {
    _validateContentType(type);

    final response = await _client.post('$_basePath/$type', body: data);

    return _extractMap(response);
  }

  // ============================================================
  // UPDATE CONTENT
  // ============================================================

  /// Updates an existing content record.
  ///
  /// Expected endpoint:
  /// PATCH /api/admin/content/:type/:id
  Future<Map<String, dynamic>> updateContent({
    required String type,
    required int id,
    required Map<String, dynamic> data,
  }) async {
    _validateContentType(type);
    _validateId(id);

    final response = await _client.patch('$_basePath/$type/$id', body: data);

    return _extractMap(response);
  }

  // ============================================================
  // PUBLISH CONTENT
  // ============================================================

  /// Publishes a content record.
  ///
  /// Publishing permissions and status transitions are enforced
  /// by the backend.
  ///
  /// Expected endpoint:
  /// POST /api/admin/content/:type/:id/publish
  Future<Map<String, dynamic>> publishContent({
    required String type,
    required int id,
  }) async {
    _validateContentType(type);
    _validateId(id);

    final response = await _client.post(
      '$_basePath/$type/$id/publish',
      body: <String, dynamic>{},
    );

    return _extractMap(response);
  }

  // ============================================================
  // ARCHIVE CONTENT
  // ============================================================

  /// Archives an existing content record.
  ///
  /// Expected endpoint:
  /// POST /api/admin/content/:type/:id/archive
  Future<Map<String, dynamic>> archiveContent({
    required String type,
    required int id,
  }) async {
    _validateContentType(type);
    _validateId(id);

    final response = await _client.post(
      '$_basePath/$type/$id/archive',
      body: <String, dynamic>{},
    );

    return _extractMap(response);
  }

  // ============================================================
  // DELETE CONTENT
  // ============================================================

  /// Deletes a content record.
  ///
  /// The backend must authorize the request and record the
  /// operation in the administrative audit log.
  ///
  /// Expected endpoint:
  /// DELETE /api/admin/content/:type/:id
  Future<Map<String, dynamic>> deleteContent({
    required String type,
    required int id,
  }) async {
    _validateContentType(type);
    _validateId(id);

    final response = await _client.delete('$_basePath/$type/$id');

    return _extractMap(response);
  }

  // ============================================================
  // QUERY PARAMETERS
  // ============================================================

  Map<String, String> _buildQuery(Map<String, String?> values) {
    return {
      for (final entry in values.entries)
        if (entry.value != null && entry.value!.trim().isNotEmpty)
          entry.key: entry.value!.trim(),
    };
  }

  // ============================================================
  // RESPONSE EXTRACTION
  // ============================================================

  /// Extracts a data object from common API response formats.
  ///
  /// Supports:
  /// { "data": { ... } }
  /// { "data": { "item": { ... } } }
  /// { "data": { "content": { ... } } }
  /// { ... }
  Map<String, dynamic> _extractMap(dynamic response) {
    if (response is! Map) {
      return <String, dynamic>{};
    }

    final map = Map<String, dynamic>.from(response);
    final data = map['data'];

    if (data is Map) {
      final dataMap = Map<String, dynamic>.from(data);

      final nestedItem =
          dataMap['item'] ?? dataMap['content'] ?? dataMap['record'];

      if (nestedItem is Map) {
        return Map<String, dynamic>.from(nestedItem);
      }

      return dataMap;
    }

    return map;
  }

  /// Extracts content items and pagination metadata.
  ///
  /// Supports common response formats:
  /// { "data": [ ... ] }
  /// { "data": { "items": [ ... ], "pagination": { ... } } }
  /// { "data": { "announcements": [ ... ] } }
  /// { "data": { "news": [ ... ] } }
  /// { "data": { "publications": [ ... ] } }
  AdminContentApiListResponse _extractListResponse(dynamic response) {
    final data = _extractMap(response);

    dynamic rawItems =
        data['items'] ??
        data['announcements'] ??
        data['news'] ??
        data['publications'] ??
        data['content'];

    // Some endpoints return the list directly in the data property.
    if (rawItems == null && response is Map) {
      final rawData = response['data'];

      if (rawData is List) {
        rawItems = rawData;
      }
    }

    final items = rawItems is List
        ? rawItems
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList()
        : <Map<String, dynamic>>[];

    final rawPagination = data['pagination'];
    final pagination = rawPagination is Map
        ? Map<String, dynamic>.from(rawPagination)
        : <String, dynamic>{};

    return AdminContentApiListResponse(
      items: items,
      page: _asInt(pagination['page'] ?? data['page'], fallback: 1),
      limit: _asInt(pagination['limit'] ?? data['limit'], fallback: 20),
      total: _asInt(
        pagination['total'] ?? data['total'],
        fallback: items.length,
      ),
      totalPages: _asInt(
        pagination['totalPages'] ?? data['totalPages'],
        fallback: 1,
      ),
    );
  }

  // ============================================================
  // VALIDATION
  // ============================================================

  void _validateContentType(String type) {
    if (!supportedContentTypes.contains(type)) {
      throw ArgumentError.value(
        type,
        'type',
        'Supported types are: '
            '${supportedContentTypes.join(', ')}.',
      );
    }
  }

  void _validateId(int id) {
    if (id <= 0) {
      throw ArgumentError.value(
        id,
        'id',
        'The content ID must be greater than zero.',
      );
    }
  }

  int _asInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}

// ================================================================
// CONTENT LIST RESPONSE
// ================================================================

/// Normalized paginated response for admin content lists.
class AdminContentApiListResponse {
  const AdminContentApiListResponse({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final List<Map<String, dynamic>> items;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  bool get hasNextPage => page < totalPages;

  bool get hasPreviousPage => page > 1;

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;
}
