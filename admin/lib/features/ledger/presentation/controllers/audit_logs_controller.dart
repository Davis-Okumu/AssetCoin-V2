import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/admin_audit_log_model.dart';
import '../../data/repositories/admin_ledger_repository.dart';
import 'ledger_overview_controller.dart';

final auditLogsControllerProvider =
    AsyncNotifierProvider<
      AuditLogsController,
      AdminLedgerPaginatedResult<AdminAuditLogModel>
    >(AuditLogsController.new);

class AuditLogsController
    extends AsyncNotifier<AdminLedgerPaginatedResult<AdminAuditLogModel>> {
  String? _search;
  String? _entityType;
  String? _action;
  String? _userId;
  String? _startDate;
  String? _endDate;

  int _page = 1;
  int _limit = 20;

  @override
  Future<AdminLedgerPaginatedResult<AdminAuditLogModel>> build() {
    return _loadLogs();
  }

  Future<AdminLedgerPaginatedResult<AdminAuditLogModel>> _loadLogs() {
    final repository = ref.read(adminLedgerRepositoryProvider);

    return repository.getAuditLogs(
      search: _search,
      entityType: _entityType,
      action: _action,
      userId: _userId,
      startDate: _startDate,
      endDate: _endDate,
      page: _page,
      limit: _limit,
    );
  }

  Future<Map<String, dynamic>> loadAuditOverview() {
    return ref.read(adminLedgerRepositoryProvider).getAuditOverview();
  }

  Future<AdminAuditLogModel> getLogDetails(int id) {
    return ref.read(adminLedgerRepositoryProvider).getAuditLog(id);
  }

  Future<void> applyFilters({
    String? search,
    String? entityType,
    String? action,
    String? userId,
    String? startDate,
    String? endDate,
  }) async {
    _search = _clean(search);
    _entityType = _clean(entityType);
    _action = _clean(action);
    _userId = _clean(userId);
    _startDate = _clean(startDate);
    _endDate = _clean(endDate);
    _page = 1;

    await _reload();
  }

  Future<void> clearFilters() async {
    _search = null;
    _entityType = null;
    _action = null;
    _userId = null;
    _startDate = null;
    _endDate = null;
    _page = 1;

    await _reload();
  }

  Future<void> search(String value) async {
    _search = _clean(value);
    _page = 1;
    await _reload();
  }

  Future<void> goToPage(int page) async {
    if (page < 1 || page == _page) return;

    _page = page;
    await _reload();
  }

  Future<void> nextPage() async {
    final current = state.value;
    if (current == null || !current.hasNextPage) return;

    _page = current.page + 1;
    await _reload();
  }

  Future<void> previousPage() async {
    final current = state.value;
    if (current == null || !current.hasPreviousPage) return;

    _page = current.page - 1;
    await _reload();
  }

  Future<void> changePageSize(int limit) async {
    if (limit < 1 || limit == _limit) return;

    _limit = limit;
    _page = 1;
    await _reload();
  }

  Future<void> refresh() async {
    await _reload();
  }

  Future<void> _reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadLogs);
  }

  String? _clean(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}
