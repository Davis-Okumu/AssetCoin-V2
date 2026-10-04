
import 'dart:convert';

import '../../../../core/network/api_client.dart';

/// Low-level HTTP service for the Trading feature.
///
/// Responsibilities:
/// - Call Trading backend endpoints through the shared ApiClient.
/// - Send authentication through ApiClient.
/// - Decode JSON responses.
/// - Validate the backend `{ success, message, data }` contract.
/// - Return the decoded `data` payload to the repository.
///
/// Financial/token values are intentionally kept as dynamic/string-compatible
/// JSON values here. The repository/domain layer preserves DECIMAL values as
/// Strings rather than converting them to Dart doubles.
class TradingApiService {
  final ApiClient _apiClient;

  TradingApiService({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  // ============================================================
  // MARKETPLACE
  // ============================================================

  /// Fetches marketplace listings.
  ///
  /// GET /api/trading/marketplace
  Future<dynamic> getMarketplace({
    String? search,
    String? assetType,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParameters = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (search != null && search.trim().isNotEmpty) {
      queryParameters['search'] = search.trim();
    }

    if (assetType != null && assetType.trim().isNotEmpty) {
      queryParameters['assetType'] = assetType.trim();
    }

    final path = _buildPath(
      '/api/trading/marketplace',
      queryParameters,
    );

    return _get(path);
  }

  /// Fetches one marketplace listing.
  ///
  /// GET /api/trading/listings/:id
  Future<dynamic> getListingDetails(int listingId) async {
    return _get('/api/trading/listings/$listingId');
  }

  // ============================================================
  // LISTINGS / SELL
  // ============================================================

  /// Creates a token sell listing.
  ///
  /// POST /api/trading/listings
  Future<dynamic> createListing({
    required int tokenId,
    required String quantity,
    required String pricePerToken,
    String currency = 'KES',
  }) async {
    return _post(
      '/api/trading/listings',
      body: {
        'tokenId': tokenId,
        'quantity': quantity,
        'pricePerToken': pricePerToken,
        'currency': currency,
      },
    );
  }

  /// Cancels an existing listing.
  ///
  /// PATCH /api/trading/listings/:id/cancel
  Future<dynamic> cancelListing(int listingId) async {
    return _patch(
      '/api/trading/listings/$listingId/cancel',
    );
  }

  // ============================================================
  // BUY
  // ============================================================

  /// Purchases tokens from a marketplace listing.
  ///
  /// POST /api/trading/orders/buy
  Future<dynamic> buyToken({
    required int listingId,
    required String quantity,
  }) async {
    return _post(
      '/api/trading/orders/buy',
      body: {
        'listingId': listingId,
        'quantity': quantity,
      },
    );
  }

  // ============================================================
  // ORDERS
  // ============================================================

  /// Fetches the authenticated user's trading orders.
  ///
  /// GET /api/trading/orders
  Future<dynamic> getOrders({
    int page = 1,
    int limit = 20,
    String? status,
    String? orderType,
  }) async {
    final queryParameters = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (status != null && status.trim().isNotEmpty) {
      queryParameters['status'] = status.trim();
    }

    if (orderType != null && orderType.trim().isNotEmpty) {
      queryParameters['orderType'] = orderType.trim();
    }

    final path = _buildPath(
      '/api/trading/orders',
      queryParameters,
    );

    return _get(path);
  }

  /// Fetches one authenticated user's order.
  ///
  /// GET /api/trading/orders/:id
  Future<dynamic> getOrderDetails(int orderId) async {
    return _get('/api/trading/orders/$orderId');
  }

  // ============================================================
  // HOLDINGS
  // ============================================================

  /// Fetches the authenticated user's token holdings.
  ///
  /// GET /api/trading/holdings
  Future<dynamic> getTokenHoldings({
    int page = 1,
    int limit = 20,
  }) async {
    final queryParameters = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    final path = _buildPath(
      '/api/trading/holdings',
      queryParameters,
    );

    return _get(path);
  }

  /// Fetches one token holding for the authenticated user.
  ///
  /// GET /api/trading/holdings/:tokenId
  Future<dynamic> getTokenHoldingDetails(int tokenId) async {
    return _get('/api/trading/holdings/$tokenId');
  }

  // ============================================================
  // HTTP HELPERS
  // ============================================================

  Future<dynamic> _get(String path) async {
    final response = await _apiClient.get(path);

    return _parseResponse(
      response,
      fallbackMessage: 'Failed to fetch trading data.',
    );
  }

  Future<dynamic> _post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await _apiClient.post(
      path,
      body: body,
    );

    return _parseResponse(
      response,
      fallbackMessage: 'Trading request failed.',
    );
  }

  Future<dynamic> _patch(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await _apiClient.patch(
      path,
      body: body,
    );

    return _parseResponse(
      response,
      fallbackMessage: 'Trading update failed.',
    );
  }

  // ============================================================
  // RESPONSE PARSING
  // ============================================================

  /// Validates the standard AssetCoin API response:
  ///
  /// {
  ///   "success": true,
  ///   "message": "...",
  ///   "data": ...
  /// }
  ///
  /// Only the `data` portion is returned.
  dynamic _parseResponse(
    dynamic response, {
    required String fallbackMessage,
  }) {
    final statusCode = response.statusCode;

    dynamic decoded;

    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      if (statusCode >= 200 && statusCode < 300) {
        throw const FormatException(
          'The server returned an invalid JSON response.',
        );
      }

      throw Exception(fallbackMessage);
    }

    if (decoded is! Map<String, dynamic>) {
      if (statusCode >= 200 && statusCode < 300) {
        throw const FormatException(
          'The server returned an invalid response format.',
        );
      }

      throw Exception(fallbackMessage);
    }

    final success = decoded['success'] == true;

    if (statusCode >= 200 &&
        statusCode < 300 &&
        success) {
      return decoded['data'];
    }

    final message = decoded['message']?.toString().trim();

    if (message != null && message.isNotEmpty) {
      throw Exception(message);
    }

    throw Exception(fallbackMessage);
  }

  // ============================================================
  // QUERY STRING
  // ============================================================

  String _buildPath(
    String basePath,
    Map<String, String> parameters,
  ) {
    if (parameters.isEmpty) {
      return basePath;
    }

    final query = parameters.entries
        .map(
          (entry) =>
              '${Uri.encodeQueryComponent(entry.key)}='
              '${Uri.encodeQueryComponent(entry.value)}',
        )
        .join('&');

    return '$basePath?$query';
  }
}
