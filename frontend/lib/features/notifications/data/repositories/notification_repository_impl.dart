import 'dart:convert';

import '../../../../core/network/api_client.dart';
import '../../domain/notification.dart';
import '../../domain/notification_preference.dart';
import '../../domain/notification_repository.dart';

class NotificationRepositoryImpl
    implements NotificationRepository {
  final ApiClient _apiClient;

  NotificationRepositoryImpl({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  // =====================================================
  // GET NOTIFICATIONS
  // =====================================================

  @override
  Future<List<AppNotification>> getNotifications({
    String? status,
    String? type,
    int limit = 30,
    int offset = 0,
  }) async {
    final queryParameters = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
    };

    if (status != null) {
      queryParameters['status'] = status;
    }

    if (type != null) {
      queryParameters['type'] = type;
    }

    final uri = Uri(
      path: '/api/notifications',
      queryParameters: queryParameters,
    );

    final response = await _apiClient.get(uri.toString());
    final decoded = _decodeResponse(response.body);

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        decoded['message'] as String? ??
            'Unable to retrieve notifications.',
      );
    }

    final data = decoded['data'];

    if (data is! List) {
      throw const FormatException(
        'Invalid notifications response.',
      );
    }

    return data.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException(
          'Invalid notification item.',
        );
      }

      return AppNotification.fromJson(item);
    }).toList();
  }

  // =====================================================
  // GET SINGLE NOTIFICATION
  // =====================================================

  @override
  Future<AppNotification> getNotification(int id) async {
    final response = await _apiClient.get(
      '/api/notifications/$id',
    );

    final decoded = _decodeResponse(response.body);

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        decoded['message'] as String? ??
            'Unable to retrieve notification.',
      );
    }

    final data = decoded['data'];

    if (data is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid notification response.',
      );
    }

    return AppNotification.fromJson(data);
  }

  // =====================================================
  // MARK ONE NOTIFICATION AS VIEWED
  // =====================================================

  @override
  Future<void> markNotificationAsViewed(int id) async {
    final response = await _apiClient.patch(
      '/api/notifications/$id/read',
      body: {},
    );

    final decoded = _decodeResponse(response.body);

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        decoded['message'] as String? ??
            'Unable to update notification.',
      );
    }
  }

  // =====================================================
  // MARK ALL NOTIFICATIONS AS VIEWED
  // =====================================================

  @override
  Future<int> markAllNotificationsAsViewed() async {
    final response = await _apiClient.patch(
      '/api/notifications/read-all',
      body: {},
    );

    final decoded = _decodeResponse(response.body);

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        decoded['message'] as String? ??
            'Unable to update notifications.',
      );
    }

    final data = decoded['data'];

    if (data is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid mark-all response.',
      );
    }

    return int.parse(
      data['updatedCount'].toString(),
    );
  }

  // =====================================================
  // GET NOTIFICATION PREFERENCES
  // =====================================================

  @override
  Future<List<NotificationPreference>>
      getNotificationPreferences() async {
    final response = await _apiClient.get(
      '/api/notifications/preferences',
    );

    final decoded = _decodeResponse(response.body);

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        decoded['message'] as String? ??
            'Unable to retrieve notification preferences.',
      );
    }

    final data = decoded['data'];

    if (data is! List) {
      throw const FormatException(
        'Invalid notification preferences response.',
      );
    }

    return data.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException(
          'Invalid notification preference item.',
        );
      }

      return NotificationPreference.fromJson(item);
    }).toList();
  }

  // =====================================================
  // UPDATE NOTIFICATION PREFERENCES
  // =====================================================

  @override
  Future<List<NotificationPreference>>
      updateNotificationPreferences(
    List<NotificationPreference> preferences,
  ) async {
    final response = await _apiClient.patch(
      '/api/notifications/preferences',
      body: {
        'preferences': preferences
            .map((preference) => preference.toJson())
            .toList(),
      },
    );

    final decoded = _decodeResponse(response.body);

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        decoded['message'] as String? ??
            'Unable to update notification preferences.',
      );
    }

    final data = decoded['data'];

    if (data is! List) {
      throw const FormatException(
        'Invalid updated notification preferences response.',
      );
    }

    return data.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException(
          'Invalid notification preference item.',
        );
      }

      return NotificationPreference.fromJson(item);
    }).toList();
  }

  // =====================================================
  // RESPONSE DECODER
  // =====================================================

  Map<String, dynamic> _decodeResponse(String body) {
    final dynamic decoded;

    try {
      decoded = jsonDecode(body);
    } catch (_) {
      throw const FormatException(
        'The server returned an invalid JSON response.',
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'Unexpected server response format.',
      );
    }

    return decoded;
  }
}