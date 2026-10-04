import '../data/models/active_sessions.dart';
import '../data/models/kyc_status.dart';
import '../data/models/kyc_submission.dart';
import '../data/models/login_activity.dart';
import '../data/models/profile_model.dart';
import '../data/models/profile_settings.dart';
import '../data/models/security_settings.dart';

abstract interface class ProfileRepository {
  Future<ProfileModel> getProfile();

  Future<ProfileModel> updateProfile({
    required String firstName,
    required String lastName,
    String? email,
    required String phone,
  });

  Future<ProfileModel> uploadProfilePhoto(
    String filePath,
  );

  Future<ProfileModel> removeProfilePhoto();

  Future<ProfileSettings> getProfileSettings();

  Future<ProfileSettings> updateProfileSettings(
    ProfileSettings settings,
  );

  Future<List<ActiveSession>> getActiveSessions();

  Future<void> revokeSession(int sessionId);

  Future<void> revokeOtherSessions();

  Future<List<LoginActivity>> getLoginActivity();

  Future<void> logout();

  // =====================================================
  // KYC
  // =====================================================

  Future<KycStatus> getKycStatus();

  Future<List<KycSubmission>> getKycHistory();

  Future<KycStatus> submitKyc({
    required String idDocumentPath,
    required String selfiePath,
  });
   Future<SecuritySettings> getSecuritySettings();

  Future<SecuritySettings> updateSecuritySettings({
    bool? biometricEnabled,
    bool? twoFactorEnabled,
    String? twoFactorMethod,
    bool? loginNotificationEnabled,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}