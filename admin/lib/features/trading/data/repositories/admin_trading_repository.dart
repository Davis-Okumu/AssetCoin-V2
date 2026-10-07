import '../datasources/admin_trading_api.dart';
import '../models/admin_trading_dispute_model.dart';
import '../models/admin_trading_listing_model.dart';
import '../models/admin_trading_order_model.dart';
import '../models/admin_trading_overview_model.dart';
import '../models/admin_trading_trade_model.dart';

class AdminTradingRepository {
  AdminTradingRepository(this._api);

  final AdminTradingApi _api;

  Future<AdminTradingOverviewModel> getOverview() async {
    final response = await _api.getOverview();

    return AdminTradingOverviewModel.fromJson(response);
  }

  Future<AdminTradingPaginatedResult<AdminTradingListingModel>> getListings({
    String? search,
    String? status,
    String? listingType,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _api.getListings(
      search: search,
      status: status,
      listingType: listingType,
      page: page,
      limit: limit,
    );

    return AdminTradingPaginatedResult(
      items: response.items
          .map((item) => AdminTradingListingModel.fromJson(item))
          .toList(),
      page: response.page,
      limit: response.limit,
      total: response.total,
      totalPages: response.totalPages,
    );
  }

  Future<AdminTradingListingModel> getListing(int id) async {
    final response = await _api.getListing(id);

    return AdminTradingListingModel.fromJson(response);
  }

  Future<AdminTradingListingModel> suspendListing(
    int id, {
    String? reason,
  }) async {
    final response = await _api.suspendListing(id, reason: reason);

    return AdminTradingListingModel.fromJson(response);
  }

  Future<AdminTradingListingModel> reactivateListing(
    int id, {
    String? reason,
  }) async {
    final response = await _api.reactivateListing(id, reason: reason);

    return AdminTradingListingModel.fromJson(response);
  }

  Future<AdminTradingPaginatedResult<AdminTradingOrderModel>> getOrders({
    String? search,
    String? status,
    String? orderType,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _api.getOrders(
      search: search,
      status: status,
      orderType: orderType,
      page: page,
      limit: limit,
    );

    return AdminTradingPaginatedResult(
      items: response.items
          .map((item) => AdminTradingOrderModel.fromJson(item))
          .toList(),
      page: response.page,
      limit: response.limit,
      total: response.total,
      totalPages: response.totalPages,
    );
  }

  Future<AdminTradingOrderModel> getOrder(int id) async {
    final response = await _api.getOrder(id);

    return AdminTradingOrderModel.fromJson(response);
  }

  Future<AdminTradingPaginatedResult<AdminTradingTradeModel>> getTrades({
    String? search,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _api.getTrades(
      search: search,
      status: status,
      page: page,
      limit: limit,
    );

    return AdminTradingPaginatedResult(
      items: response.items
          .map((item) => AdminTradingTradeModel.fromJson(item))
          .toList(),
      page: response.page,
      limit: response.limit,
      total: response.total,
      totalPages: response.totalPages,
    );
  }

  Future<AdminTradingTradeModel> getTrade(int id) async {
    final response = await _api.getTrade(id);

    return AdminTradingTradeModel.fromJson(response);
  }

  Future<AdminTradingPaginatedResult<AdminTradingDisputeModel>> getDisputes({
    String? search,
    String? status,
    String? priority,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _api.getDisputes(
      search: search,
      status: status,
      priority: priority,
      page: page,
      limit: limit,
    );

    return AdminTradingPaginatedResult(
      items: response.items
          .map((item) => AdminTradingDisputeModel.fromJson(item))
          .toList(),
      page: response.page,
      limit: response.limit,
      total: response.total,
      totalPages: response.totalPages,
    );
  }

  Future<AdminTradingDisputeModel> getDispute(int id) async {
    final response = await _api.getDispute(id);

    return AdminTradingDisputeModel.fromJson(response);
  }

  Future<AdminTradingDisputeModel> createDispute({
    int? transactionId,
    int? orderId,
    int? listingId,
    required int raisedBy,
    int? againstUserId,
    String disputeType = 'trade',
    String priority = 'normal',
    required String reason,
    String? description,
  }) async {
    final response = await _api.createDispute({
      if (transactionId != null) 'transactionId': transactionId,
      if (orderId != null) 'orderId': orderId,
      if (listingId != null) 'listingId': listingId,
      'raisedBy': raisedBy,
      if (againstUserId != null) 'againstUserId': againstUserId,
      'disputeType': disputeType,
      'priority': priority,
      'reason': reason,
      if (description != null && description.trim().isNotEmpty)
        'description': description.trim(),
    });

    return AdminTradingDisputeModel.fromJson(response);
  }

  Future<AdminTradingDisputeModel> assignDispute(
    int id, {
    required int assignedTo,
  }) async {
    final response = await _api.assignDispute(id, assignedTo: assignedTo);

    return AdminTradingDisputeModel.fromJson(response);
  }

  Future<AdminTradingDisputeModel> updateDispute(
    int id, {
    String? status,
    String? priority,
    String? resolutionNotes,
  }) async {
    final response = await _api.updateDispute(
      id,
      status: status,
      priority: priority,
      resolutionNotes: resolutionNotes,
    );

    return AdminTradingDisputeModel.fromJson(response);
  }
}

class AdminTradingPaginatedResult<T> {
  const AdminTradingPaginatedResult({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final List<T> items;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  bool get hasNextPage => page < totalPages;

  bool get hasPreviousPage => page > 1;

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;
}
