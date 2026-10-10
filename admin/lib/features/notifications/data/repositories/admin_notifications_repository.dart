import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_client_provider.dart';
import '../models/admin_notification_model.dart';

final adminNotificationsRepositoryProvider =
    Provider<AdminNotificationsRepository>((ref) {
      return AdminNotificationsRepository(ref.read(apiClientProvider));
    });

class AdminNotificationsRepository {
  AdminNotificationsRepository(this._api);

  final ApiClient _api;

  // ============================================================
  // BACKEND ROUTE
  // ============================================================

  static const String _basePath = '/api/admin/notifications';

  // ============================================================
  // RESPONSE HELPERS
  // ============================================================

  Map<String, dynamic> _map(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }

    return <String, dynamic>{};
  }

  Map<String, dynamic> _data(dynamic response) {
    final root = _map(response);
    final data = root['data'];

    return data is Map ? _map(data) : root;
  }

  void _ensureSuccess(dynamic response) {
    final root = _map(response);

    if (root['success'] == false) {
      throw ApiException(
        message:
            root['message']?.toString() ?? 'The notification request failed.',
      );
    }
  }

  // ============================================================
  // OVERVIEW
  // GET /api/admin/notifications/overview
  // ============================================================

  Future<AdminNotificationOverview> getOverview() async {
    try {
      final response = await _api.get('$_basePath/overview');

      _ensureSuccess(response);

      final data = _data(response);

      final overviewJson = data['overview'] is Map
          ? _map(data['overview'])
          : data;

      return AdminNotificationOverview.fromJson(overviewJson);
    } catch (error) {
      throw Exception('Unable to load notification overview: $error');
    }
  }

  // ============================================================
  // LIST NOTIFICATIONS
  // GET /api/admin/notifications
  // ============================================================

  Future<List<AdminNotificationModel>> getNotifications({
    String? type,
    String? status,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParameters = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (type != null && type != 'all') 'type': type,
      if (status != null && status != 'all') 'status': status,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
    };

    try {
      final response = await _api.get(
        _basePath,
        queryParameters: queryParameters,
      );

      _ensureSuccess(response);

      final data = _data(response);

      final rawItems =
          data['items'] ??
          data['notifications'] ??
          (data['data'] is List ? data['data'] : null);

      if (rawItems is! List) {
        return <AdminNotificationModel>[];
      }

      return rawItems
          .whereType<Map>()
          .map((item) => AdminNotificationModel.fromJson(_map(item)))
          .toList();
    } catch (error) {
      throw Exception('Unable to load notifications: $error');
    }
  }

  // ============================================================
  // MARK NOTIFICATION AS READ
  // PATCH /api/admin/notifications/:id/read
  // ============================================================

  Future<void> markAsRead(int id) async {
    try {
      final response = await _api.patch(
        '$_basePath/$id/read',
        body: <String, dynamic>{},
      );

      _ensureSuccess(response);
    } catch (error) {
      throw Exception('Unable to mark notification as read: $error');
    }
  }

  // ============================================================
  // ARCHIVE NOTIFICATION
  // PATCH /api/admin/notifications/:id/archive
  // ============================================================

  Future<void> archive(int id) async {
    try {
      final response = await _api.patch(
        '$_basePath/$id/archive',
        body: <String, dynamic>{},
      );

      _ensureSuccess(response);
    } catch (error) {
      throw Exception('Unable to archive notification: $error');
    }
  }
}
