import '../../../../core/network/api_client.dart';

class AdminStaffApi {
  AdminStaffApi(this._apiClient);

  final ApiClient _apiClient;

  static const String _basePath = 'api/admin/staff';

  Future<dynamic> getOverview() {
    return _apiClient.get('$_basePath/overview');
  }

  Future<dynamic> getStaff({
    String? search,
    String? status,
    String? role,
    int page = 1,
    int limit = 20,
  }) {
    final queryParameters = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      if (status != null && status.trim().isNotEmpty) 'status': status.trim(),
      if (role != null && role.trim().isNotEmpty) 'role': role.trim(),
    };

    return _apiClient.get(_basePath, queryParameters: queryParameters);
  }

  Future<dynamic> getStaffDetails(int staffId) {
    return _apiClient.get('$_basePath/$staffId');
  }

  Future<dynamic> getRoles() {
    return _apiClient.get('$_basePath/roles');
  }

  Future<dynamic> getPermissions() {
    return _apiClient.get('$_basePath/permissions');
  }

  Future<dynamic> createStaff({required Map<String, dynamic> body}) {
    return _apiClient.post(_basePath, body: body);
  }

  Future<dynamic> updateStaff({
    required int staffId,
    required Map<String, dynamic> body,
  }) {
    return _apiClient.patch('$_basePath/$staffId', body: body);
  }

  Future<dynamic> updateStaffStatus({
    required int staffId,
    required String status,
  }) {
    return _apiClient.patch(
      '$_basePath/$staffId/status',
      body: {'status': status},
    );
  }

  Future<dynamic> updateStaffPermissions({
    required int staffId,
    required List<Map<String, dynamic>> overrides,
  }) {
    return _apiClient.put(
      '$_basePath/$staffId/permissions',
      body: {'overrides': overrides},
    );
  }

  Future<dynamic> removeStaffPermissionOverride({
    required int staffId,
    required int permissionId,
  }) {
    return _apiClient.delete('$_basePath/$staffId/permissions/$permissionId');
  }

  Future<dynamic> getStaffActivity({
    required int staffId,
    int page = 1,
    int limit = 20,
  }) {
    return _apiClient.get(
      '$_basePath/$staffId/activity',
      queryParameters: {'page': page, 'limit': limit},
    );
  }

  Future<dynamic> getStaffSessions({
    required int staffId,
    int page = 1,
    int limit = 20,
  }) {
    return _apiClient.get(
      '$_basePath/$staffId/sessions',
      queryParameters: {'page': page, 'limit': limit},
    );
  }

  Future<dynamic> revokeStaffSession({
    required int staffId,
    required int sessionId,
  }) {
    return _apiClient.post('$_basePath/$staffId/sessions/$sessionId/revoke');
  }
}
