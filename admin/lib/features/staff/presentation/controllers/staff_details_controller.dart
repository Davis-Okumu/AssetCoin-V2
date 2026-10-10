import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/admin_staff_model.dart';
import '../../data/repositories/admin_staff_repository.dart';

class StaffDetailsState {
  const StaffDetailsState({
    this.staff,
    this.activity = const [],
    this.sessions = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
  });

  final AdminStaffModel? staff;
  final List<Map<String, dynamic>> activity;
  final List<Map<String, dynamic>> sessions;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;

  StaffDetailsState copyWith({
    AdminStaffModel? staff,
    List<Map<String, dynamic>>? activity,
    List<Map<String, dynamic>>? sessions,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return StaffDetailsState(
      staff: staff ?? this.staff,
      activity: activity ?? this.activity,
      sessions: sessions ?? this.sessions,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

final staffDetailsControllerProvider =
    NotifierProvider.family<StaffDetailsController, StaffDetailsState, int>(
      StaffDetailsController.new,
    );

class StaffDetailsController extends Notifier<StaffDetailsState> {
  // In Riverpod 3, family arguments are passed through the constructor.
  StaffDetailsController(this.staffId);

  final int staffId;

  // A getter (not a `late final` field) because build() can run more than once.
  AdminStaffRepository get _repository =>
      ref.read(adminStaffRepositoryProvider);

  @override
  StaffDetailsState build() {
    // Watch so the notifier rebuilds if the repository provider changes.
    ref.watch(adminStaffRepositoryProvider);

    // Defer the initial load: state can't be modified until build() returns.
    Future.microtask(loadDetails);

    return const StaffDetailsState();
  }

  Future<void> loadDetails() async {
    if (!ref.mounted) return;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final results = await Future.wait<dynamic>([
        _repository.getStaffDetails(staffId),
        _repository.getStaffActivity(staffId: staffId),
        _repository.getStaffSessions(staffId: staffId),
      ]);

      if (!ref.mounted) return;
      state = state.copyWith(
        staff: results[0] as AdminStaffModel,
        activity: results[1] as List<Map<String, dynamic>>,
        sessions: results[2] as List<Map<String, dynamic>>,
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

  Future<bool> updateStaff(Map<String, dynamic> body) async {
    state = state.copyWith(isSaving: true, clearError: true);

    try {
      final updatedStaff = await _repository.updateStaff(
        staffId: staffId,
        body: body,
      );

      if (!ref.mounted) return false;
      state = state.copyWith(
        staff: updatedStaff,
        isSaving: false,
        clearError: true,
      );

      await loadDetails();
      return true;
    } catch (error) {
      if (!ref.mounted) return false;
      state = state.copyWith(
        isSaving: false,
        errorMessage: _readableError(error),
      );

      return false;
    }
  }

  Future<bool> updatePermissions(List<Map<String, dynamic>> overrides) async {
    state = state.copyWith(isSaving: true, clearError: true);

    try {
      await _repository.updateStaffPermissions(
        staffId: staffId,
        overrides: overrides,
      );

      await loadDetails();
      return true;
    } catch (error) {
      if (!ref.mounted) return false;
      state = state.copyWith(
        isSaving: false,
        errorMessage: _readableError(error),
      );

      return false;
    } finally {
      if (ref.mounted) {
        state = state.copyWith(isSaving: false);
      }
    }
  }

  Future<bool> revokeSession(int sessionId) async {
    state = state.copyWith(isSaving: true, clearError: true);

    try {
      await _repository.revokeStaffSession(
        staffId: staffId,
        sessionId: sessionId,
      );

      final sessions = await _repository.getStaffSessions(staffId: staffId);

      if (!ref.mounted) return false;
      state = state.copyWith(
        sessions: sessions,
        isSaving: false,
        clearError: true,
      );

      return true;
    } catch (error) {
      if (!ref.mounted) return false;
      state = state.copyWith(
        isSaving: false,
        errorMessage: _readableError(error),
      );

      return false;
    }
  }

  String _readableError(Object error) {
    final message = error.toString();

    return message.startsWith('Exception: ')
        ? message.substring('Exception: '.length)
        : message;
  }
}
