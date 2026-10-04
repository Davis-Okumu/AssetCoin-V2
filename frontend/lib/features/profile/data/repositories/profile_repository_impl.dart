
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../../core/network/api_client.dart';
import '../../domain/profile_repository.dart';
import '../models/active_sessions.dart';
import '../models/kyc_status.dart';
import '../models/kyc_submission.dart';
import '../models/login_activity.dart';
import '../models/profile_model.dart';
import '../models/profile_settings.dart';
import '../models/security_settings.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._apiClient);

  final ApiClient _apiClient;

  // =========================================================
  // PROFILE
  // =========================================================

  @override
  Future<ProfileModel> getProfile() async {
    final response = await _apiClient.get('/api/profile');

    return ProfileModel.fromJson(
      _extractProfileMap(response),
    );
  }

  @override
  Future<ProfileModel> updateProfile({
    required String firstName,
    required String lastName,
    String? email,
    required String phone,
  }) async {
    final response = await _apiClient.patch(
      '/api/profile',
      body: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
      },
    );

    return ProfileModel.fromJson(
      _extractProfileMap(response),
    );
  }

  @override
  Future<ProfileModel> uploadProfilePhoto(
    String filePath,
  ) async {
    final file = File(filePath);

    if (!await file.exists()) {
      throw const ProfileRepositoryException(
        'The selected profile photo could not be found.',
      );
    }

    final multipartFile =
        await http.MultipartFile.fromPath(
      'photo',
      file.path,
    );

    final response =
        await _apiClient.uploadMultipart(
      path: '/api/profile/photo',
      files: [multipartFile],
    );

    return ProfileModel.fromJson(
      _extractProfileMap(response),
    );
  }

  @override
  Future<ProfileModel> removeProfilePhoto() async {
    final response = await _apiClient.delete(
      '/api/profile/photo',
    );

    return ProfileModel.fromJson(
      _extractProfileMap(response),
    );
  }

  // =========================================================
  // PROFILE SETTINGS
  // =========================================================

  @override
  Future<ProfileSettings> getProfileSettings() async {
    final response = await _apiClient.get(
      '/api/profile/settings',
    );

    final data = _extractMap(response);
    final settings = data['settings'];

    if (settings is Map) {
      return ProfileSettings.fromJson(
        Map<String, dynamic>.from(settings),
      );
    }

    return ProfileSettings.fromJson(data);
  }

  @override
  Future<ProfileSettings> updateProfileSettings(
    ProfileSettings settings,
  ) async {
    final response = await _apiClient.patch(
      '/api/profile/settings',
      body: settings.toJson(),
    );

    final data = _extractMap(response);
    final updatedSettings = data['settings'];

    if (updatedSettings is Map) {
      return ProfileSettings.fromJson(
        Map<String, dynamic>.from(updatedSettings),
      );
    }

    return ProfileSettings.fromJson(data);
  }

  // =========================================================
  // SECURITY SETTINGS
  // =========================================================

  @override
  Future<SecuritySettings> getSecuritySettings() async {
    try {
      final response = await _apiClient.get(
        '/api/security/settings',
      );

      final data = _extractMap(response);

      final settings = data['settings'];

      if (settings is Map) {
        return SecuritySettings.fromJson(
          Map<String, dynamic>.from(settings),
        );
      }

      return SecuritySettings.fromJson(data);
    } catch (error) {
      if (error is ProfileRepositoryException) {
        rethrow;
      }

      throw ProfileRepositoryException(
        'Unable to retrieve security settings: $error',
      );
    }
  }

  @override
  Future<SecuritySettings> updateSecuritySettings({
    bool? biometricEnabled,
    bool? twoFactorEnabled,
    String? twoFactorMethod,
    bool? loginNotificationEnabled,
  }) async {
    try {
      final body = <String, dynamic>{};

      if (biometricEnabled != null) {
        body['biometricEnabled'] =
            biometricEnabled;
      }

      if (twoFactorEnabled != null) {
        body['twoFactorEnabled'] =
            twoFactorEnabled;
      }

      if (twoFactorMethod != null) {
        body['twoFactorMethod'] =
            twoFactorMethod;
      }

      if (loginNotificationEnabled != null) {
        body['loginNotificationEnabled'] =
            loginNotificationEnabled;
      }

      final response = await _apiClient.patch(
        '/api/security/settings',
        body: body,
      );

      final data = _extractMap(response);

      final settings = data['settings'];

      if (settings is Map) {
        return SecuritySettings.fromJson(
          Map<String, dynamic>.from(settings),
        );
      }

      return SecuritySettings.fromJson(data);
    } catch (error) {
      if (error is ProfileRepositoryException) {
        rethrow;
      }

      throw ProfileRepositoryException(
        'Unable to update security settings: $error',
      );
    }
  }

  // =========================================================
  // CHANGE PASSWORD
  // =========================================================

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _apiClient.post(
        '/api/auth/change-password',
        body: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
    } catch (error) {
      if (error is ProfileRepositoryException) {
        rethrow;
      }

      throw ProfileRepositoryException(
        'Unable to change your password: $error',
      );
    }
  }

  // =========================================================
  // SECURITY SESSIONS
  // =========================================================

  @override
  Future<List<ActiveSession>> getActiveSessions() async {
    final response = await _apiClient.get(
      '/api/security/sessions',
    );

    final list = _extractList(response);

    return list
        .whereType<Map<String, dynamic>>()
        .map(ActiveSession.fromJson)
        .toList();
  }

  @override
  Future<void> revokeSession(
    int sessionId,
  ) async {
    await _apiClient.delete(
      '/api/security/sessions/$sessionId',
    );
  }

  @override
  Future<void> revokeOtherSessions() async {
    await _apiClient.post(
      '/api/security/sessions/revoke-others',
    );
  }

  // =========================================================
  // LOGIN ACTIVITY
  // =========================================================

  @override
  Future<List<LoginActivity>> getLoginActivity() async {
    final response = await _apiClient.get(
      '/api/security/activity',
    );

    final list = _extractList(response);

    return list
        .whereType<Map<String, dynamic>>()
        .map(LoginActivity.fromJson)
        .toList();
  }

  // =========================================================
  // LOGOUT
  // =========================================================

  @override
  Future<void> logout() async {
    await _apiClient.post(
      '/api/auth/logout',
    );
  }

  // =========================================================
  // KYC
  // =========================================================

  @override
  Future<KycStatus> getKycStatus() async {
    try {
      final response = await _apiClient.get(
        '/api/kyc/status',
      );

      final data = _extractMap(response);

      final verification = data['verification'];

      if (verification is Map) {
        return KycStatus.fromJson(
          Map<String, dynamic>.from(
            verification,
          ),
        );
      }

      return KycStatus.fromJson(data);
    } catch (error) {
      if (error is ProfileRepositoryException) {
        rethrow;
      }

      throw ProfileRepositoryException(
        'Unable to retrieve KYC status: $error',
      );
    }
  }

  @override
  Future<List<KycSubmission>> getKycHistory() async {
    try {
      final response = await _apiClient.get(
        '/api/kyc/history',
      );

      final data = _extractMap(response);

      final history = data['history'];

      if (history is! List) {
        return const [];
      }

      return history
          .whereType<Map>()
          .map(
            (item) => KycSubmission.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    } catch (error) {
      if (error is ProfileRepositoryException) {
        rethrow;
      }

      throw ProfileRepositoryException(
        'Unable to retrieve KYC history: $error',
      );
    }
  }

  @override
  Future<KycStatus> submitKyc({
    required String idDocumentPath,
    required String selfiePath,
  }) async {
    try {
      final idDocumentFile =
          await http.MultipartFile.fromPath(
        'idDocument',
        idDocumentPath,
      );

      final selfieFile =
          await http.MultipartFile.fromPath(
        'selfie',
        selfiePath,
      );

      final response =
          await _apiClient.uploadMultipart(
        path: '/api/kyc/submit',
        files: [
          idDocumentFile,
          selfieFile,
        ],
      );

      final data = _extractMap(response);

      final submission = data['submission'];

      if (submission is Map) {
        final submissionMap =
            Map<String, dynamic>.from(
          submission,
        );

        return KycStatus.fromJson({
          ...submissionMap,
          'submissionId':
              submissionMap['submissionId'] ??
                  submissionMap['id'],
        });
      }

      return KycStatus.fromJson(data);
    } catch (error) {
      if (error is ProfileRepositoryException) {
        rethrow;
      }

      throw ProfileRepositoryException(
        'Unable to submit your KYC application: $error',
      );
    }
  }

  // =========================================================
  // RESPONSE HELPERS
  // =========================================================

  Map<String, dynamic> _extractProfileMap(
    dynamic response,
  ) {
    final data = _extractMap(response);
    final profile = data['profile'];

    if (profile is Map) {
      return Map<String, dynamic>.from(profile);
    }

    throw const ProfileRepositoryException(
      'The server response did not contain a valid profile.',
    );
  }

  Map<String, dynamic> _extractMap(
    dynamic response,
  ) {
    final decoded = _decodeResponse(response);

    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'];

      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }

      return decoded;
    }

    throw const ProfileRepositoryException(
      'The server returned an invalid response.',
    );
  }

  List<dynamic> _extractList(
    dynamic response,
  ) {
    final decoded = _decodeResponse(response);

    if (decoded is List) {
      return decoded;
    }

    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'];

      if (data is List) {
        return data;
      }

      final items = decoded['items'];

      if (items is List) {
        return items;
      }

      final sessions = decoded['sessions'];

      if (sessions is List) {
        return sessions;
      }

      final activity = decoded['activity'];

      if (activity is List) {
        return activity;
      }

      final history = decoded['history'];

      if (history is List) {
        return history;
      }
    }

    throw const ProfileRepositoryException(
      'The server returned an invalid list response.',
    );
  }


dynamic _decodeResponse(dynamic response) {
  // Handle the HTTP response returned by ApiClient.
  if (response is http.Response) {
    final statusCode = response.statusCode;
    final body = response.body.trim();

    // Check HTTP status before attempting normal parsing.
    if (statusCode < 200 || statusCode >= 300) {
      String message =
          'The server returned an error (HTTP $statusCode).';

      if (body.isNotEmpty) {
        try {
          final errorData = jsonDecode(body);

          if (errorData is Map) {
            final serverMessage = errorData['message'];

            if (serverMessage != null &&
                serverMessage.toString().trim().isNotEmpty) {
              message = serverMessage.toString();
            }
          }
        } catch (_) {
          // Keep the default HTTP error message.
        }
      }

      throw ProfileRepositoryException(message);
    }

    if (body.isEmpty) {
      throw const ProfileRepositoryException(
        'The server returned an empty response.',
      );
    }

    try {
      return jsonDecode(body);
    } catch (_) {
      throw const ProfileRepositoryException(
        'The server returned invalid JSON.',
      );
    }
  }

  // Preserve support for responses already supplied as strings.
  if (response is String) {
    try {
      return jsonDecode(response);
    } catch (_) {
      throw const ProfileRepositoryException(
        'The server returned invalid JSON.',
      );
    }
  }

  // Allow already-decoded JSON objects and lists.
  return response;
}
}

class ProfileRepositoryException
    implements Exception {
  const ProfileRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}