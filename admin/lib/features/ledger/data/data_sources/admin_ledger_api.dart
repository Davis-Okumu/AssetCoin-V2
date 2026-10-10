import '../../../../core/network/api_client.dart';

class AdminLedgerApi {
  AdminLedgerApi(this._client);

  final ApiClient _client;

  static const String _basePath = '/api/admin/ledger';

  Future<Map<String, dynamic>> getOverview() async {
    return _extractMap(await _client.get('$_basePath/overview'));
  }

  Future<AdminLedgerApiListResponse> getEntries({
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
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _client.get(
      '$_basePath/entries',
      queryParameters: _buildQuery({
        'search': search,
        'entryType': entryType,
        'assetType': assetType,
        'userId': userId,
        'walletId': walletId,
        'tokenId': tokenId,
        'transactionId': transactionId,
        'currency': currency,
        'startDate': startDate,
        'endDate': endDate,
        'page': page.toString(),
        'limit': limit.toString(),
      }),
    );

    return _extractListResponse(response, 'items', 'entries');
  }

  Future<Map<String, dynamic>> getEntry(int id) async {
    return _extractMap(await _client.get('$_basePath/entries/$id'));
  }

  Future<Map<String, dynamic>> getHashInspection(int id) async {
    return _extractMap(
      await _client.get('$_basePath/entries/$id/hash-inspection'),
    );
  }

  Future<Map<String, dynamic>> getAuditOverview() async {
    return _extractMap(await _client.get('$_basePath/audit/overview'));
  }

  Future<AdminLedgerApiListResponse> getAuditLogs({
    String? search,
    String? entityType,
    String? action,
    String? userId,
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _client.get(
      '$_basePath/audit/logs',
      queryParameters: _buildQuery({
        'search': search,
        'entityType': entityType,
        'action': action,
        'userId': userId,
        'startDate': startDate,
        'endDate': endDate,
        'page': page.toString(),
        'limit': limit.toString(),
      }),
    );

    return _extractListResponse(response, 'items', 'logs');
  }

  Future<Map<String, dynamic>> getAuditLog(int id) async {
    return _extractMap(await _client.get('$_basePath/audit/logs/$id'));
  }

  Map<String, String> _buildQuery(Map<String, String?> values) {
    return {
      for (final entry in values.entries)
        if (entry.value != null && entry.value!.trim().isNotEmpty)
          entry.key: entry.value!.trim(),
    };
  }

  Map<String, dynamic> _extractMap(dynamic response) {
    if (response is Map<String, dynamic>) {
      final data = response['data'];

      if (data is Map<String, dynamic>) {
        return data;
      }

      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }

      return response;
    }

    if (response is Map) {
      final map = Map<String, dynamic>.from(response);
      final data = map['data'];

      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }

      return map;
    }

    return <String, dynamic>{};
  }

  AdminLedgerApiListResponse _extractListResponse(
    dynamic response,
    String primaryKey,
    String fallbackKey,
  ) {
    final data = _extractMap(response);

    final rawItems = data[primaryKey] ?? data[fallbackKey];
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

    return AdminLedgerApiListResponse(
      items: items,
      page: _asInt(pagination['page'] ?? data['page'], fallback: 1),
      limit: _asInt(pagination['limit'] ?? data['limit'], fallback: 20),
      total: _asInt(pagination['total'] ?? data['total']),
      totalPages: _asInt(pagination['totalPages']),
    );
  }

  int _asInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}

class AdminLedgerApiListResponse {
  const AdminLedgerApiListResponse({
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
