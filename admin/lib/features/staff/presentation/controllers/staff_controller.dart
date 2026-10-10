import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/admin_staff_model.dart';
import '../../data/models/admin_staff_overview_model.dart';
import '../../data/repositories/admin_staff_repository.dart';

class StaffState {
  const StaffState({
    this.overview,
    this.staff = const [],
    this.search = '',
    this.statusFilter,
    this.roleFilter,
    this.isLoading = false,
    this.errorMessage,
  });

  final AdminStaffOverviewModel? overview;
  final List<AdminStaffModel> staff;
  final String search;
  final String? statusFilter;
  final String? roleFilter;
  final bool isLoading;
  final String? errorMessage;

  StaffState copyWith({
    AdminStaffOverviewModel? overview,
    List<AdminStaffModel>? staff,
    String? search,
    String? statusFilter,
    String? roleFilter,
    bool? isLoading,
    String? errorMessage,
    bool clearStatusFilter = false,
    bool clearRoleFilter = false,
    bool clearError = false,
  }) {
    return StaffState(
      overview: overview ?? this.overview,
      staff: staff ?? this.staff,
      search: search ?? this.search,
      statusFilter: clearStatusFilter
          ? null
          : statusFilter ?? this.statusFilter,
      roleFilter: clearRoleFilter ? null : roleFilter ?? this.roleFilter,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

final staffControllerProvider = NotifierProvider<StaffController, StaffState>(
  StaffController.new,
);

class StaffController extends Notifier<StaffState> {
  // A getter (not a `late final` field) because build() can run more than once.
  AdminStaffRepository get _repository =>
      ref.read(adminStaffRepositoryProvider);

  @override
  StaffState build() {
    // Watch so the notifier rebuilds if the repository provider changes.
    ref.watch(adminStaffRepositoryProvider);

    // Defer the initial load: state can't be modified until build() returns.
    Future.microtask(loadStaff);

    return const StaffState();
  }

  Future<void> loadStaff() async {
    if (!ref.mounted) return;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final results = await Future.wait<dynamic>([
        _repository.getOverview(),
        _repository.getStaff(
          search: state.search,
          status: state.statusFilter,
          role: state.roleFilter,
        ),
      ]);

      if (!ref.mounted) return;
      state = state.copyWith(
        overview: results[0] as AdminStaffOverviewModel,
        staff: results[1] as List<AdminStaffModel>,
        isLoading: false,
        clearError: true,
      );
    } catch (error) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: _readableError(error),
      );
    }
  }

  Future<void> refresh() => loadStaff();

  Future<void> searchStaff(String value) async {
    state = state.copyWith(search: value);
    await loadStaff();
  }

  Future<void> filterByStatus(String? value) async {
    state = state.copyWith(
      statusFilter: value,
      clearStatusFilter: value == null || value.isEmpty,
    );
    await loadStaff();
  }

  Future<void> filterByRole(String? value) async {
    state = state.copyWith(
      roleFilter: value,
      clearRoleFilter: value == null || value.isEmpty,
    );
    await loadStaff();
  }

  Future<void> clearFilters() async {
    state = state.copyWith(
      search: '',
      clearStatusFilter: true,
      clearRoleFilter: true,
    );
    await loadStaff();
  }

  Future<void> updateStatus({
    required int staffId,
    required String status,
  }) async {
    try {
      await _repository.updateStaffStatus(staffId: staffId, status: status);

      await loadStaff();
    } catch (error) {
      if (!ref.mounted) return;
      state = state.copyWith(errorMessage: _readableError(error));
    }
  }

  String _readableError(Object error) {
    final message = error.toString();

    return message.startsWith('Exception: ')
        ? message.substring('Exception: '.length)
        : message;
  }
}
