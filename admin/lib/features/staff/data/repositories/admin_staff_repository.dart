import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../datasources/admin_staff_api.dart';
import '../models/admin_staff_model.dart';
import '../models/admin_staff_overview_model.dart';
import '../models/admin_staff_permission_model.dart';
import '../models/admin_staff_role_model.dart';

final adminStaffApiProvider = Provider<AdminStaffApi>((ref) {
  return AdminStaffApi(ApiClient());
});

final adminStaffRepositoryProvider = Provider<AdminStaffRepository>((ref) {
  return AdminStaffRepository(ref.watch(adminStaffApiProvider));
});

class AdminStaffRepository {
  AdminStaffRepository(this._api);

  final AdminStaffApi _api;

  Future<AdminStaffOverviewModel> getOverview() async {
    final response = await _api.getOverview();
    final data = _extractData(response);

    return AdminStaffOverviewModel.fromJson(data);
  }

  Future<List<AdminStaffModel>> getStaff({
    String? search,
    String? status,
    String? role,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _api.getStaff(
      search: search,
      status: status,
      role: role,
      page: page,
      limit: limit,
    );

    final data = _extractData(response);
    final items = _extractList(data, const [
      'staff',
      'items',
      'results',
      'users',
    ]);

    return items
        .whereType<Map>()
        .map(
          (item) => AdminStaffModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);
  }

  Future<AdminStaffModel> getStaffDetails(int staffId) async {
    final response = await _api.getStaffDetails(staffId);
    final data = _extractData(response);

    final staffData = data['staff'] is Map
        ? Map<String, dynamic>.from(data['staff'] as Map)
        : data;

    return AdminStaffModel.fromJson(staffData);
  }

  Future<List<AdminStaffRoleModel>> getRoles() async {
    final response = await _api.getRoles();
    final data = _extractData(response);
    final items = _extractList(data, const ['roles', 'items', 'results']);

    return items
        .whereType<Map>()
        .map(
          (item) =>
              AdminStaffRoleModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);
  }

  Future<List<AdminStaffPermissionModel>> getPermissions() async {
    final response = await _api.getPermissions();
    final data = _extractData(response);
    final items = _extractList(data, const ['permissions', 'items', 'results']);

    return items
        .whereType<Map>()
        .map(
          (item) => AdminStaffPermissionModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList(growable: false);
  }

  Future<AdminStaffModel> createStaff(Map<String, dynamic> body) async {
    final response = await _api.createStaff(body: body);
    final data = _extractData(response);

    final staffData = data['staff'] is Map
        ? Map<String, dynamic>.from(data['staff'] as Map)
        : data;

    return AdminStaffModel.fromJson(staffData);
  }

  Future<AdminStaffModel> updateStaff({
    required int staffId,
    required Map<String, dynamic> body,
  }) async {
    final response = await _api.updateStaff(staffId: staffId, body: body);

    final data = _extractData(response);

    final staffData = data['staff'] is Map
        ? Map<String, dynamic>.from(data['staff'] as Map)
        : data;

    return AdminStaffModel.fromJson(staffData);
  }

  Future<void> updateStaffStatus({
    required int staffId,
    required String status,
  }) async {
    await _api.updateStaffStatus(staffId: staffId, status: status);
  }

  Future<void> updateStaffPermissions({
    required int staffId,
    required List<Map<String, dynamic>> overrides,
  }) async {
    await _api.updateStaffPermissions(staffId: staffId, overrides: overrides);
  }

  Future<void> removeStaffPermissionOverride({
    required int staffId,
    required int permissionId,
  }) async {
    await _api.removeStaffPermissionOverride(
      staffId: staffId,
      permissionId: permissionId,
    );
  }

  Future<List<Map<String, dynamic>>> getStaffActivity({
    required int staffId,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _api.getStaffActivity(
      staffId: staffId,
      page: page,
      limit: limit,
    );

    final data = _extractData(response);
    final items = _extractList(data, const [
      'activity',
      'activities',
      'items',
      'results',
    ]);

    return items
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  Future<List<Map<String, dynamic>>> getStaffSessions({
    required int staffId,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _api.getStaffSessions(
      staffId: staffId,
      page: page,
      limit: limit,
    );

    final data = _extractData(response);
    final items = _extractList(data, const ['sessions', 'items', 'results']);

    return items
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  Future<void> revokeStaffSession({
    required int staffId,
    required int sessionId,
  }) async {
    await _api.revokeStaffSession(staffId: staffId, sessionId: sessionId);
  }

  Map<String, dynamic> _extractData(dynamic response) {
    if (response is Map<String, dynamic>) {
      final data = response['data'];

      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }

      if (data is List) {
        return {'items': data};
      }

      return response;
    }

    if (response is Map) {
      return Map<String, dynamic>.from(response);
    }

    throw const FormatException('Unexpected staff API response format.');
  }

  List<dynamic> _extractList(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];

      if (value is List) {
        return value;
      }
    }

    // Some endpoints may return the collection directly as `data`.
    if (data['items'] is List) {
      return data['items'] as List;
    }

    return const [];
  }
}
