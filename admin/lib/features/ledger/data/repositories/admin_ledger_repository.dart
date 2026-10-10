

import '../data_sources/admin_ledger_api.dart';
import '../models/admin_audit_log_model.dart';
import '../models/admin_ledger_entry_model.dart';
import '../models/admin_ledger_overview_model.dart';

class AdminLedgerRepository {
  AdminLedgerRepository(this._api);

  final AdminLedgerApi _api;

  Future<AdminLedgerOverviewModel> getOverview() async {
    final response = await _api.getOverview();
    return AdminLedgerOverviewModel.fromJson(response);
  }

  Future<AdminLedgerPaginatedResult<AdminLedgerEntryModel>> getEntries({
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
    final response = await _api.getEntries(
      search: search,
      entryType: entryType,
      assetType: assetType,
      userId: userId,
      walletId: walletId,
      tokenId: tokenId,
      transactionId: transactionId,
      currency: currency,
      startDate: startDate,
      endDate: endDate,
      page: page,
      limit: limit,
    );

    return AdminLedgerPaginatedResult(
      items: response.items.map(AdminLedgerEntryModel.fromJson).toList(),
      page: response.page,
      limit: response.limit,
      total: response.total,
      totalPages: response.totalPages,
    );
  }

  Future<AdminLedgerEntryModel> getEntry(int id) async {
    final response = await _api.getEntry(id);
    return AdminLedgerEntryModel.fromJson(response);
  }

  Future<Map<String, dynamic>> getHashInspection(int id) async {
    return _api.getHashInspection(id);
  }

  Future<Map<String, dynamic>> getAuditOverview() async {
    return _api.getAuditOverview();
  }

  Future<AdminLedgerPaginatedResult<AdminAuditLogModel>> getAuditLogs({
    String? search,
    String? entityType,
    String? action,
    String? userId,
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _api.getAuditLogs(
      search: search,
      entityType: entityType,
      action: action,
      userId: userId,
      startDate: startDate,
      endDate: endDate,
      page: page,
      limit: limit,
    );

    return AdminLedgerPaginatedResult(
      items: response.items.map(AdminAuditLogModel.fromJson).toList(),
      page: response.page,
      limit: response.limit,
      total: response.total,
      totalPages: response.totalPages,
    );
  }

  Future<AdminAuditLogModel> getAuditLog(int id) async {
    final response = await _api.getAuditLog(id);
    return AdminAuditLogModel.fromJson(response);
  }
}

class AdminLedgerPaginatedResult<T> {
  const AdminLedgerPaginatedResult({
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
