
import 'listing.dart';
import 'order.dart';
import 'token_holding.dart';

/// Repository contract for the Trading feature.
///
/// The presentation layer should depend on this abstraction rather
/// than communicating with the API service directly.
abstract class TradingRepository {
  // ============================================================
  // MARKETPLACE
  // ============================================================

  /// Retrieves marketplace listings.
  ///
  /// Only active and partially-filled sell listings are returned
  /// by the backend marketplace endpoint.
  Future<MarketplaceResult> getMarketplace({
    String? search,
    String? assetType,
    int page = 1,
    int limit = 20,
  });

  /// Retrieves the details of a single active marketplace listing.
  Future<Listing> getListingDetails(int listingId);

  // ============================================================
  // LISTINGS / SELL
  // ============================================================

  /// Creates a new sell listing for a token.
  ///
  /// The backend validates that:
  /// - the asset belongs to the authenticated user
  /// - the asset is tokenized
  /// - the token is active
  /// - the user has enough unlocked tokens
  Future<Listing> createListing({
    required int tokenId,
    required String quantity,
    required String pricePerToken,
    String currency = 'KES',
  });

  /// Cancels an active or partially-filled listing owned by
  /// the authenticated user.
  Future<Listing> cancelListing(int listingId);

  // ============================================================
  // BUY
  // ============================================================

  /// Purchases tokens from an active marketplace listing.
  ///
  /// The backend performs the complete transaction atomically:
  /// - buyer wallet debit
  /// - seller wallet credit
  /// - buyer holding update
  /// - seller holding update
  /// - listing update
  /// - order creation
  /// - transaction creation
  /// - ledger entries
  Future<BuyTokenResult> buyToken({
    required int listingId,
    required String quantity,
  });

  // ============================================================
  // ORDERS
  // ============================================================

  /// Retrieves the authenticated user's trading orders.
  Future<OrdersResult> getOrders({
    int page = 1,
    int limit = 20,
    String? status,
    String? orderType,
  });

  /// Retrieves one order belonging to the authenticated user.
  Future<TradingOrder> getOrderDetails(int orderId);

  // ============================================================
  // HOLDINGS
  // ============================================================

  /// Retrieves all token holdings belonging to the authenticated user.
  Future<TokenHoldingsResult> getTokenHoldings({
    int page = 1,
    int limit = 20,
  });

  /// Retrieves one token holding by token ID.
  Future<TokenHolding> getTokenHoldingDetails(int tokenId);
}

// ================================================================
// MARKETPLACE RESULT
// ================================================================

class MarketplaceResult {
  final List<Listing> listings;
  final Pagination pagination;

  const MarketplaceResult({
    required this.listings,
    required this.pagination,
  });
}

// ================================================================
// ORDERS RESULT
// ================================================================

class OrdersResult {
  final List<TradingOrder> orders;
  final Pagination pagination;

  const OrdersResult({
    required this.orders,
    required this.pagination,
  });
}

// ================================================================
// TOKEN HOLDINGS RESULT
// ================================================================

class TokenHoldingsResult {
  final List<TokenHolding> holdings;
  final Pagination pagination;

  const TokenHoldingsResult({
    required this.holdings,
    required this.pagination,
  });
}

// ================================================================
// BUY RESULT
// ================================================================

class BuyTokenResult {
  final TradingOrder order;
  final String? transactionReference;
  final String? totalAmount;
  final String? currency;

  const BuyTokenResult({
    required this.order,
    this.transactionReference,
    this.totalAmount,
    this.currency,
  });
}

// ================================================================
// PAGINATION
// ================================================================

class Pagination {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const Pagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: _parseInt(json['page'], fallback: 1),
      limit: _parseInt(json['limit'], fallback: 20),
      total: _parseInt(json['total']),
      totalPages: _parseInt(json['totalPages']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'total': total,
      'totalPages': totalPages,
    };
  }

  bool get hasNextPage => page < totalPages;

  bool get hasPreviousPage => page > 1;

  static int _parseInt(
    dynamic value, {
    int fallback = 0,
  }) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
