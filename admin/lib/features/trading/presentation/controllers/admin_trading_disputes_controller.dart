import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/admin_trading_dispute_model.dart';
import '../../data/repositories/admin_trading_repository.dart';
import 'admin_trading_overview_controller.dart';

final adminTradingDisputesControllerProvider =
    AsyncNotifierProvider<
      AdminTradingDisputesController,
      AdminTradingPaginatedResult<AdminTradingDisputeModel>
    >(AdminTradingDisputesController.new);

class AdminTradingDisputesController
    extends
        AsyncNotifier<AdminTradingPaginatedResult<AdminTradingDisputeModel>> {
  String? _search;
  String? _status;
  String? _priority;

  int _page = 1;
  int _limit = 20;

  String? get searchQuery => _search;

  String? get statusFilter => _status;

  String? get priorityFilter => _priority;

  int get currentPage => _page;

  int get pageSize => _limit;

  @override
  Future<AdminTradingPaginatedResult<AdminTradingDisputeModel>> build() {
    return _fetch();
  }

  Future<AdminTradingPaginatedResult<AdminTradingDisputeModel>> _fetch() {
    final repository = ref.read(adminTradingRepositoryProvider);

    return repository.getDisputes(
      search: _search,
      status: _status,
      priority: _priority,
      page: _page,
      limit: _limit,
    );
  }

  Future<void> _load({bool showLoading = true}) async {
    if (showLoading) {
      state = const AsyncLoading();
    }

    state = await AsyncValue.guard(_fetch);
  }

  Future<void> refresh() async {
    await _load();
  }

  Future<void> search(String? value) async {
    final normalizedValue = value?.trim();

    _search = normalizedValue == null || normalizedValue.isEmpty
        ? null
        : normalizedValue;

    _page = 1;

    await _load();
  }

  Future<void> setStatus(String? value) async {
    final normalizedValue = value?.trim();

    _status = normalizedValue == null || normalizedValue.isEmpty
        ? null
        : normalizedValue;

    _page = 1;

    await _load();
  }

  Future<void> setPriority(String? value) async {
    final normalizedValue = value?.trim();

    _priority = normalizedValue == null || normalizedValue.isEmpty
        ? null
        : normalizedValue;

    _page = 1;

    await _load();
  }

  Future<void> clearFilters() async {
    _search = null;
    _status = null;
    _priority = null;
    _page = 1;

    await _load();
  }

  Future<void> setPageSize(int limit) async {
    if (limit <= 0) {
      return;
    }

    _limit = limit;
    _page = 1;

    await _load();
  }

  Future<void> goToPage(int page) async {
    if (page < 1) {
      return;
    }

    final currentResult = state.value;

    if (currentResult != null && page > currentResult.totalPages) {
      return;
    }

    if (page == _page) {
      return;
    }

    _page = page;

    await _load();
  }

  Future<void> nextPage() async {
    final currentResult = state.value;

    if (currentResult == null || !currentResult.hasNextPage) {
      return;
    }

    _page = currentResult.page + 1;

    await _load();
  }

  Future<void> previousPage() async {
    final currentResult = state.value;

    if (currentResult == null || !currentResult.hasPreviousPage) {
      return;
    }

    _page = currentResult.page - 1;

    await _load();
  }

  Future<AdminTradingDisputeModel> getDetails(int disputeId) async {
    final repository = ref.read(adminTradingRepositoryProvider);

    final dispute = await repository.getDispute(disputeId);

    return dispute;
  }

  Future<AdminTradingDisputeModel?> findDispute(int disputeId) async {
    try {
      return await getDetails(disputeId);
    } catch (_) {
      return null;
    }
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
    final repository = ref.read(adminTradingRepositoryProvider);

    final dispute = await repository.createDispute(
      transactionId: transactionId,
      orderId: orderId,
      listingId: listingId,
      raisedBy: raisedBy,
      againstUserId: againstUserId,
      disputeType: disputeType,
      priority: priority,
      reason: reason,
      description: description,
    );

    await _load(showLoading: false);

    return dispute;
  }

  Future<AdminTradingDisputeModel> assignDispute(
    int disputeId, {
    required int assignedTo,
  }) async {
    final repository = ref.read(adminTradingRepositoryProvider);

    final dispute = await repository.assignDispute(
      disputeId,
      assignedTo: assignedTo,
    );

    await _load(showLoading: false);

    return dispute;
  }

  Future<AdminTradingDisputeModel> updateDispute(
    int disputeId, {
    String? status,
    String? priority,
    String? resolutionNotes,
  }) async {
    final repository = ref.read(adminTradingRepositoryProvider);

    final dispute = await repository.updateDispute(
      disputeId,
      status: status,
      priority: priority,
      resolutionNotes: resolutionNotes,
    );

    await _load(showLoading: false);

    return dispute;
  }
}
