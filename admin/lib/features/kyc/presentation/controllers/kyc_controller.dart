import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/admin_kyc_application.dart';
import '../../data/models/admin_kyc_stats.dart';
import '../../data/repositories/admin_kyc_repository.dart';

final kycControllerProvider =
    AsyncNotifierProvider<KycController, KycControllerState>(KycController.new);

class KycControllerState {
  const KycControllerState({
    required this.applications,
    required this.pagination,
    required this.stats,
    this.status,
    this.search,
    this.assignedTo,
  });

  final List<AdminKycApplication> applications;
  final AdminKycPagination pagination;
  final AdminKycStats stats;

  final String? status;
  final String? search;
  final int? assignedTo;

  KycControllerState copyWith({
    List<AdminKycApplication>? applications,
    AdminKycPagination? pagination,
    AdminKycStats? stats,
    String? status,
    String? search,
    int? assignedTo,
    bool clearStatus = false,
    bool clearSearch = false,
    bool clearAssignedTo = false,
  }) {
    return KycControllerState(
      applications: applications ?? this.applications,
      pagination: pagination ?? this.pagination,
      stats: stats ?? this.stats,
      status: clearStatus ? null : (status ?? this.status),
      search: clearSearch ? null : (search ?? this.search),
      assignedTo: clearAssignedTo ? null : (assignedTo ?? this.assignedTo),
    );
  }
}

class KycController extends AsyncNotifier<KycControllerState> {
  late AdminKycRepository _repository;

  @override
  Future<KycControllerState> build() async {
    _repository = ref.watch(adminKycRepositoryProvider);

    return _loadData(status: null, search: null, assignedTo: null, page: 1);
  }

  Future<KycControllerState> _loadData({
    required String? status,
    required String? search,
    required int? assignedTo,
    required int page,
  }) async {
    final results = await Future.wait([
      _repository.getApplications(
        status: status,
        search: search,
        assignedTo: assignedTo,
        page: page,
        limit: 20,
      ),
      _repository.getStats(),
    ]);

    final applications = results[0] as AdminKycApplicationList;

    final stats = results[1] as AdminKycStats;

    return KycControllerState(
      applications: applications.applications,
      pagination: applications.pagination,
      stats: stats,
      status: status,
      search: search,
      assignedTo: assignedTo,
    );
  }

  Future<void> refresh() async {
    final current = state.value;

    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => _loadData(
        status: current?.status,
        search: current?.search,
        assignedTo: current?.assignedTo,
        page: current?.pagination.page ?? 1,
      ),
    );
  }

  Future<void> loadPage(int page) async {
    final current = state.value;

    if (current == null) {
      return;
    }

    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => _loadData(
        status: current.status,
        search: current.search,
        assignedTo: current.assignedTo,
        page: page,
      ),
    );
  }

  Future<void> filterByStatus(String? status) async {
    final current = state.value;

    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => _loadData(
        status: status,
        search: current?.search,
        assignedTo: current?.assignedTo,
        page: 1,
      ),
    );
  }

  Future<void> searchApplications(String search) async {
    final current = state.value;

    final normalizedSearch = search.trim();

    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => _loadData(
        status: current?.status,
        search: normalizedSearch.isEmpty ? null : normalizedSearch,
        assignedTo: current?.assignedTo,
        page: 1,
      ),
    );
  }

  Future<void> filterByAssignedTo(int? adminId) async {
    final current = state.value;

    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => _loadData(
        status: current?.status,
        search: current?.search,
        assignedTo: adminId,
        page: 1,
      ),
    );
  }

  Future<void> clearFilters() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => _loadData(status: null, search: null, assignedTo: null, page: 1),
    );
  }
}
