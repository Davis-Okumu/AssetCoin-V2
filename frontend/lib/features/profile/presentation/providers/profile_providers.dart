import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client_provider.dart';

import '../../data/models/active_sessions.dart';
import '../../data/models/kyc_status.dart';
import '../../data/models/kyc_submission.dart';
import '../../data/models/login_activity.dart';
import '../../data/models/profile_model.dart';
import '../../data/models/profile_settings.dart';

import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/profile_repository.dart';
import '../../data/models/security_settings.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);

  return ProfileRepositoryImpl(apiClient);
});

final profileProvider = FutureProvider<ProfileModel>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);

  return repository.getProfile();
});

final profileSettingsProvider =
    FutureProvider<ProfileSettings>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);

  return repository.getProfileSettings();
});

final securitySettingsProvider =
    FutureProvider<SecuritySettings>((ref) async {
  final repository =
      ref.watch(profileRepositoryProvider);

  return repository.getSecuritySettings();
});

final activeSessionsProvider =
    FutureProvider<List<ActiveSession>>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);

  return repository.getActiveSessions();
});

final loginActivityProvider =
    FutureProvider<List<LoginActivity>>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);

  return repository.getLoginActivity();
});

// =====================================================
// KYC PROVIDERS
// =====================================================

final kycStatusProvider =
    FutureProvider.autoDispose<KycStatus>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);

  return repository.getKycStatus();
});

final kycHistoryProvider =
    FutureProvider.autoDispose<List<KycSubmission>>(
  (ref) async {
    final repository = ref.watch(profileRepositoryProvider);

    return repository.getKycHistory();
  },
);

// =====================================================
// PROFILE ACTIONS
// =====================================================

final profileActionsProvider = Provider<ProfileActions>((ref) {
  final repository = ref.read(profileRepositoryProvider);

  return ProfileActions(
    repository: repository,
    ref: ref,
  );
});

class ProfileActions {
  ProfileActions({
    required this.repository,
    required this.ref,
  });

  final ProfileRepository repository;
  final Ref ref;

  // =====================================================
  // PROFILE
  // =====================================================

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
    String? email,
  }) async {
    await repository.updateProfile(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      email: email,
    );

    ref.invalidate(profileProvider);
  }

  Future<void> uploadProfilePhoto(
    String filePath,
  ) async {
    await repository.uploadProfilePhoto(filePath);

    ref.invalidate(profileProvider);
  }

  Future<void> removeProfilePhoto() async {
    await repository.removeProfilePhoto();

    ref.invalidate(profileProvider);
  }

  // =====================================================
  // KYC
  // =====================================================

  Future<KycStatus> submitKyc({
    required String idDocumentPath,
    required String selfiePath,
  }) async {
    final result = await repository.submitKyc(
      idDocumentPath: idDocumentPath,
      selfiePath: selfiePath,
    );

    ref.invalidate(kycStatusProvider);
    ref.invalidate(kycHistoryProvider);
    ref.invalidate(profileProvider);

    return result;
  }
    // =====================================================
  // SECURITY
  // =====================================================

  Future<SecuritySettings> updateSecuritySettings({
    bool? biometricEnabled,
    bool? loginNotificationEnabled,
  }) async {
    final result =
        await repository.updateSecuritySettings(
      biometricEnabled: biometricEnabled,
      loginNotificationEnabled:
          loginNotificationEnabled,
    );

    ref.invalidate(securitySettingsProvider);

    return result;
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    ref.invalidate(securitySettingsProvider);
    ref.invalidate(activeSessionsProvider);
    ref.invalidate(loginActivityProvider);
  }

  Future<void> revokeSession(
    int sessionId,
  ) async {
    await repository.revokeSession(sessionId);

    ref.invalidate(activeSessionsProvider);
    ref.invalidate(loginActivityProvider);
  }

  Future<void> revokeOtherSessions() async {
    await repository.revokeOtherSessions();

    ref.invalidate(activeSessionsProvider);
    ref.invalidate(loginActivityProvider);
  }

  Future<void> logout() async {
    await repository.logout();
  }
}