
import '../../../../core/network/api_client.dart';

class AdminTradingApi {
  AdminTradingApi(this._client);

  final ApiClient _client;

  static const String _basePath = '/api/admin/trading';

  Future<Map<String, dynamic>> getOverview() async {
    final response = await _client.get(
      '$_basePath/overview',
    );

    return _extractMap(response);
  }

  Future<AdminTradingListResponse> getListings({
    String? search,
    String? status,
    String? listingType,
    int page = 1,
    int limit = 20,
  }) async {
    final query = <String, String>{};

    if (search != null && search.isNotEmpty) {
      query['search'] = search;
    }

    if (status != null && status.isNotEmpty) {
      query['status'] = status;
    }

    if (listingType != null && listingType.isNotEmpty) {
      query['listingType'] = listingType;
    }

    query['page'] = page.toString();
    query['limit'] = limit.toString();

    final response = await _client.get(
      '$_basePath/listings',
      queryParameters: query,
    );

    return _extractListResponse(
      response,
      listKey: 'listings',
    );
  }

  Future<Map<String, dynamic>> getListing(int id) async {
    final response = await _client.get(
      '$_basePath/listings/$id',
    );

    return _extractMap(response);
  }

  Future<Map<String, dynamic>> suspendListing(
    int id, {
    String? reason,
  }) async {
    final response = await _client.patch(
      '$_basePath/listings/$id/suspend',
      body: {
        if (reason != null && reason.isNotEmpty)
          'reason': reason,
      },
    );

    return _extractMap(response);
  }

  Future<Map<String, dynamic>> reactivateListing(
    int id, {
    String? reason,
  }) async {
    final response = await _client.patch(
      '$_basePath/listings/$id/reactivate',
      body: {
        if (reason != null && reason.isNotEmpty)
          'reason': reason,
      },
    );

    return _extractMap(response);
  }

  Future<AdminTradingListResponse> getOrders({
    String? search,
    String? status,
    String? orderType,
    int page = 1,
    int limit = 20,
  }) async {
    final query = <String, String>{};

    if (search != null && search.isNotEmpty) {
      query['search'] = search;
    }

    if (status != null && status.isNotEmpty) {
      query['status'] = status;
    }

    if (orderType != null && orderType.isNotEmpty) {
      query['orderType'] = orderType;
    }

    query['page'] = page.toString();
    query['limit'] = limit.toString();

    final response = await _client.get(
      '$_basePath/orders',
      queryParameters: query,
    );

    return _extractListResponse(
      response,
      listKey: 'orders',
    );
  }

  Future<Map<String, dynamic>> getOrder(int id) async {
    final response = await _client.get(
      '$_basePath/orders/$id',
    );

    return _extractMap(response);
  }

  Future<AdminTradingListResponse> getTrades({
    String? search,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final query = <String, String>{};

    if (search != null && search.isNotEmpty) {
      query['search'] = search;
    }

    if (status != null && status.isNotEmpty) {
      query['status'] = status;
    }

    query['page'] = page.toString();
    query['limit'] = limit.toString();

    final response = await _client.get(
      '$_basePath/trades',
      queryParameters: query,
    );

    return _extractListResponse(
      response,
      listKey: 'trades',
    );
  }

  Future<Map<String, dynamic>> getTrade(int id) async {
    final response = await _client.get(
      '$_basePath/trades/$id',
    );

    return _extractMap(response);
  }

  Future<AdminTradingListResponse> getDisputes({
    String? search,
    String? status,
    String? priority,
    int page = 1,
    int limit = 20,
  }) async {
    final query = <String, String>{};

    if (search != null && search.isNotEmpty) {
      query['search'] = search;
    }

    if (status != null && status.isNotEmpty) {
      query['status'] = status;
    }

    if (priority != null && priority.isNotEmpty) {
      query['priority'] = priority;
    }

    query['page'] = page.toString();
    query['limit'] = limit.toString();

    final response = await _client.get(
      '$_basePath/disputes',
      queryParameters: query,
    );

    return _extractListResponse(
      response,
      listKey: 'disputes',
    );
  }

  Future<Map<String, dynamic>> getDispute(int id) async {
    final response = await _client.get(
      '$_basePath/disputes/$id',
    );

    return _extractMap(response);
  }

  Future<Map<String, dynamic>> createDispute(
    Map<String, dynamic> body,
  ) async {
    final response = await _client.post(
      '$_basePath/disputes',
      body: body,
    );

    return _extractMap(response);
  }

  Future<Map<String, dynamic>> assignDispute(
    int id, {
    required int assignedTo,
  }) async {
    final response = await _client.patch(
      '$_basePath/disputes/$id/assign',
      body: {
        'assignedTo': assignedTo,
      },
    );

    return _extractMap(response);
  }

  Future<Map<String, dynamic>> updateDispute(
    int id, {
    String? status,
    String? priority,
    String? resolutionNotes,
  }) async {
    final response = await _client.patch(
      '$_basePath/disputes/$id',
      body: {
        if (status != null) 'status': status,
        if (priority != null) 'priority': priority,
        if (resolutionNotes != null)
          'resolutionNotes': resolutionNotes,
      },
    );

    return _extractMap(response);
  }

  Map<String, dynamic> _extractMap(
    dynamic response,
  ) {
    if (response is! Map<String, dynamic>) {
      throw const ApiException(
        message: 'Invalid server response.',
      );
    }

    final data = response['data'];

    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    return response;
  }

  AdminTradingListResponse _extractListResponse(
    dynamic response, {
    required String listKey,
  }) {
    if (response is! Map<String, dynamic>) {
      throw const ApiException(
        message: 'Invalid server response.',
      );
    }

    dynamic data = response['data'];

    if (data == null) {
      data = response;
    }

    if (data is! Map) {
      return const AdminTradingListResponse(
        items: [],
        pagination: null,
      );
    }

    final map = Map<String, dynamic>.from(data);

    final rawItems = map[listKey];

    final items = rawItems is List
        ? rawItems
              .whereType<Map>()
              .map(
                (item) => Map<String, dynamic>.from(item),
              )
              .toList()
        : <Map<String, dynamic>>[];

    final rawPagination = map['pagination'];

    Map<String, dynamic>? pagination;

    if (rawPagination is Map) {
      pagination = Map<String, dynamic>.from(
        rawPagination,
      );
    }

    return AdminTradingListResponse(
      items: items,
      pagination: pagination,
    );
  }
}

class AdminTradingListResponse {
  const AdminTradingListResponse({
    required this.items,
    required this.pagination,
  });

  final List<Map<String, dynamic>> items;
  final Map<String, dynamic>? pagination;

  int get page {
    final value = pagination?['page'];

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        1;
  }

  int get limit {
    final value = pagination?['limit'];

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        20;
  }

  int get total {
    final value = pagination?['total'];

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  int get totalPages {
    final value = pagination?['totalPages'];

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  bool get hasNextPage => page < totalPages;

  bool get hasPreviousPage => page > 1;
}