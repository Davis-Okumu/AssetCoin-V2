
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client_provider.dart';
import '../../domain/listing.dart';
import '../../domain/order.dart';
import '../../domain/token_holding.dart';
import '../../domain/trading_repository.dart';
import '../services/trading_api_service.dart';

/// Concrete implementation of [TradingRepository].
///
/// Responsibilities:
/// - Coordinate the Trading API service.
/// - Convert API payloads into Trading domain models.
/// - Preserve backend DECIMAL values as Strings.
/// - Normalize pagination responses.
/// - Keep presentation/controllers independent from HTTP details.
class TradingRepositoryImpl implements TradingRepository {
  final TradingApiService _apiService;

  TradingRepositoryImpl({
    required TradingApiService apiService,
  }) : _apiService = apiService;

  // ============================================================
  // MARKETPLACE
  // ============================================================

  @override
  Future<MarketplaceResult> getMarketplace({
    String? search,
    String? assetType,
    int page = 1,
    int limit = 20,
  }) async {
    final data = await _apiService.getMarketplace(
      search: search,
      assetType: assetType,
      page: page,
      limit: limit,
    );

    final map = _asMap(data);

    final listingsJson = _extractList(
      map,
      keys: const [
        'listings',
        'items',
        'results',
      ],
    );

    final listings = listingsJson
        .whereType<Map<String, dynamic>>()
        .map(Listing.fromJson)
        .toList();

    return MarketplaceResult(
      listings: listings,
      pagination: _parsePagination(
        map['pagination'],
        fallbackPage: page,
        fallbackLimit: limit,
        fallbackTotal: listings.length,
      ),
    );
  }

  @override
  Future<Listing> getListingDetails(int listingId) async {
    final data = await _apiService.getListingDetails(listingId);

    final map = _asMap(data);

    final listingJson = _extractObject(
      map,
      keys: const [
        'listing',
        'item',
        'result',
      ],
    );

    return Listing.fromJson(
      listingJson ?? map,
    );
  }

  // ============================================================
  // LISTINGS / SELL
  // ============================================================

  @override
  Future<Listing> createListing({
    required int tokenId,
    required String quantity,
    required String pricePerToken,
    String currency = 'KES',
  }) async {
    final data = await _apiService.createListing(
      tokenId: tokenId,
      quantity: quantity,
      pricePerToken: pricePerToken,
      currency: currency,
    );

    final map = _asMap(data);

    final listingJson = _extractObject(
      map,
      keys: const [
        'listing',
        'result',
      ],
    );

    if (listingJson == null) {
      throw const FormatException(
        'The server did not return the created listing.',
      );
    }

    return Listing.fromJson(listingJson);
  }

  @override
  Future<Listing> cancelListing(int listingId) async {
    final data = await _apiService.cancelListing(listingId);

    final map = _asMap(data);

    final listingJson = _extractObject(
      map,
      keys: const [
        'listing',
        'result',
      ],
    );

    if (listingJson == null) {
      throw const FormatException(
        'The server did not return the cancelled listing.',
      );
    }

    return Listing.fromJson(listingJson);
  }

  // ============================================================
  // BUY
  // ============================================================

  @override
  Future<BuyTokenResult> buyToken({
    required int listingId,
    required String quantity,
  }) async {
    final data = await _apiService.buyToken(
      listingId: listingId,
      quantity: quantity,
    );

    final map = _asMap(data);

    final orderJson = _extractObject(
      map,
      keys: const [
        'order',
        'buyOrder',
        'result',
      ],
    );

    if (orderJson == null) {
      throw const FormatException(
        'The server did not return the created buy order.',
      );
    }

    final order = TradingOrder.fromJson(orderJson);

    String? transactionReference;

    final directTransactionReference =
        _nullableString(map['transactionReference']);

    if (directTransactionReference != null) {
      transactionReference = directTransactionReference;
    } else {
      final transaction = map['transaction'];

      if (transaction is Map) {
        transactionReference = _nullableString(
          transaction['transactionReference'],
        );
      }
    }

    return BuyTokenResult(
      order: order,
      transactionReference: transactionReference,
      totalAmount:
          _nullableDecimal(map['totalAmount']) ??
          _nullableDecimal(order.totalAmount),
      currency:
          _nullableString(map['currency']) ??
          order.currency,
    );
  }

  // ============================================================
  // ORDERS
  // ============================================================

  @override
  Future<OrdersResult> getOrders({
    int page = 1,
    int limit = 20,
    String? status,
    String? orderType,
  }) async {
    final data = await _apiService.getOrders(
      page: page,
      limit: limit,
      status: status,
      orderType: orderType,
    );

    final map = _asMap(data);

    final ordersJson = _extractList(
      map,
      keys: const [
        'orders',
        'items',
        'results',
      ],
    );

    final orders = ordersJson
        .whereType<Map<String, dynamic>>()
        .map(TradingOrder.fromJson)
        .toList();

    return OrdersResult(
      orders: orders,
      pagination: _parsePagination(
        map['pagination'],
        fallbackPage: page,
        fallbackLimit: limit,
        fallbackTotal: orders.length,
      ),
    );
  }

  @override
  Future<TradingOrder> getOrderDetails(int orderId) async {
    final data = await _apiService.getOrderDetails(orderId);

    final map = _asMap(data);

    final orderJson = _extractObject(
      map,
      keys: const [
        'order',
        'result',
      ],
    );

    return TradingOrder.fromJson(
      orderJson ?? map,
    );
  }

  // ============================================================
  // HOLDINGS
  // ============================================================

  @override
  Future<TokenHoldingsResult> getTokenHoldings({
    int page = 1,
    int limit = 20,
  }) async {
    final data = await _apiService.getTokenHoldings(
      page: page,
      limit: limit,
    );

    final map = _asMap(data);

    final holdingsJson = _extractList(
      map,
      keys: const [
        'holdings',
        'items',
        'results',
      ],
    );

    final holdings = holdingsJson
        .whereType<Map<String, dynamic>>()
        .map(TokenHolding.fromJson)
        .toList();

    return TokenHoldingsResult(
      holdings: holdings,
      pagination: _parsePagination(
        map['pagination'],
        fallbackPage: page,
        fallbackLimit: limit,
        fallbackTotal: holdings.length,
      ),
    );
  }

  @override
  Future<TokenHolding> getTokenHoldingDetails(int tokenId) async {
    final data = await _apiService.getTokenHoldingDetails(tokenId);

    final map = _asMap(data);

    final holdingJson = _extractObject(
      map,
      keys: const [
        'holding',
        'tokenHolding',
        'result',
      ],
    );

    return TokenHolding.fromJson(
      holdingJson ?? map,
    );
  }

  // ============================================================
  // RIVERPOD PROVIDER
  // ============================================================

  /// Provides the Trading repository using the application's
  /// existing shared ApiClient.
  ///
  /// The ApiClient is responsible for:
  ///
  /// - API base URL
  /// - JWT retrieval
  /// - Authorization header
  /// - request timeout
  /// - 401 handling
  /// - session expiration
  /// - HTTP communication
  static final provider = Provider<TradingRepository>((ref) {
    final apiClient = ref.watch(apiClientProvider);

    final apiService = TradingApiService(
      apiClient: apiClient,
    );

    return TradingRepositoryImpl(
      apiService: apiService,
    );
  });

  // ============================================================
  // JSON HELPERS
  // ============================================================

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    throw const FormatException(
      'The server returned an invalid trading data object.',
    );
  }

  List<dynamic> _extractList(
    Map<String, dynamic> map, {
    required List<String> keys,
  }) {
    for (final key in keys) {
      final value = map[key];

      if (value is List) {
        return value;
      }
    }

    return const [];
  }

  Map<String, dynamic>? _extractObject(
    Map<String, dynamic> map, {
    required List<String> keys,
  }) {
    for (final key in keys) {
      final value = map[key];

      if (value is Map<String, dynamic>) {
        return value;
      }

      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }
    }

    return null;
  }

  // ============================================================
  // PAGINATION
  // ============================================================

  Pagination _parsePagination(
    dynamic value, {
    required int fallbackPage,
    required int fallbackLimit,
    required int fallbackTotal,
  }) {
    if (value is Map<String, dynamic>) {
      return Pagination.fromJson(value);
    }

    if (value is Map) {
      return Pagination.fromJson(
        Map<String, dynamic>.from(value),
      );
    }

    final totalPages = fallbackTotal == 0
        ? 0
        : (fallbackTotal / fallbackLimit).ceil();

    return Pagination(
      page: fallbackPage,
      limit: fallbackLimit,
      total: fallbackTotal,
      totalPages: totalPages,
    );
  }

  // ============================================================
  // VALUE HELPERS
  // ============================================================

  String? _nullableString(dynamic value) {
    if (value == null) {
      return null;
    }

    final result = value.toString().trim();

    if (result.isEmpty) {
      return null;
    }

    return result;
  }

  /// Keeps DECIMAL values as strings.
  ///
  /// Do not convert financial values to double here.
  String? _nullableDecimal(dynamic value) {
    if (value == null) {
      return null;
    }

    return value.toString();
  }
}
