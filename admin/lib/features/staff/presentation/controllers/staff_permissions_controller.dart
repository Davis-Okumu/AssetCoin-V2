import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/admin_staff_permission_model.dart';
import '../../data/models/admin_staff_role_model.dart';
import '../../data/repositories/admin_staff_repository.dart';

class StaffPermissionsState {
  const StaffPermissionsState({
    this.roles = const [],
    this.permissions = const [],
    this.selectedPermissionCodes = const {},
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
  });

  final List<AdminStaffRoleModel> roles;
  final List<AdminStaffPermissionModel> permissions;
  final Set<String> selectedPermissionCodes;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;

  StaffPermissionsState copyWith({
    List<AdminStaffRoleModel>? roles,
    List<AdminStaffPermissionModel>? permissions,
    Set<String>? selectedPermissionCodes,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return StaffPermissionsState(
      roles: roles ?? this.roles,
      permissions: permissions ?? this.permissions,
      selectedPermissionCodes:
          selectedPermissionCodes ?? this.selectedPermissionCodes,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

final staffPermissionsControllerProvider =
    NotifierProvider.family<
      StaffPermissionsController,
      StaffPermissionsState,
      int
    >(StaffPermissionsController.new);

class StaffPermissionsController extends Notifier<StaffPermissionsState> {
  // In Riverpod 3, family arguments are passed through the constructor.
  StaffPermissionsController(this.staffId);

  final int staffId;

  // A getter (not a late final field) because build() can run more than once.
  AdminStaffRepository get _repository =>
      ref.read(adminStaffRepositoryProvider);

  @override
  StaffPermissionsState build() {
    // Watch so the notifier rebuilds if the repository provider changes.
    ref.watch(adminStaffRepositoryProvider);

    // Defer the initial load: state can't be modified until build() returns.
    Future.microtask(loadPermissions);

    return const StaffPermissionsState();
  }

  Future<void> loadPermissions() async {
    if (!ref.mounted) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final results = await Future.wait<dynamic>([
        _repository.getRoles(),
        _repository.getPermissions(),
      ]);

      if (!ref.mounted) return;

      final roles = results[0] as List<AdminStaffRoleModel>;
      final permissions = results[1] as List<AdminStaffPermissionModel>;

      state = state.copyWith(
        roles: roles,
        permissions: permissions,
        selectedPermissionCodes: permissions
            .where((permission) => permission.isExplicitlyGranted)
            .map((permission) => permission.code)
            .toSet(),
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

  void togglePermission(String permissionCode, bool selected) {
    final updated = Set<String>.from(state.selectedPermissionCodes);

    if (selected) {
      updated.add(permissionCode);
    } else {
      updated.remove(permissionCode);
    }

    state = state.copyWith(selectedPermissionCodes: updated, clearError: true);
  }

  void selectAllPermissions() {
    state = state.copyWith(
      selectedPermissionCodes: state.permissions
          .map((permission) => permission.code)
          .toSet(),
      clearError: true,
    );
  }

  void clearSelectedPermissions() {
    state = state.copyWith(selectedPermissionCodes: const {}, clearError: true);
  }

  Future<bool> savePermissions() async {
    if (!ref.mounted) return false;

    state = state.copyWith(isSaving: true, clearError: true);

    try {
      // The backend expects permission IDs and accessType values of
      // "grant" or "deny", not permissionCode and effect.
      //
      // This controller currently represents selected permissions as grants.
      final overrides = state.permissions
          .where(
            (permission) =>
                state.selectedPermissionCodes.contains(permission.code),
          )
          .map(
            (permission) => <String, dynamic>{
              'permissionId': permission.id,
              'accessType': 'grant',
            },
          )
          .toList(growable: false);

      await _repository.updateStaffPermissions(
        staffId: staffId,
        overrides: overrides,
      );

      if (!ref.mounted) return false;

      state = state.copyWith(isSaving: false, clearError: true);

      await loadPermissions();
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
