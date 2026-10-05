import '../../../../core/network/api_client.dart';
import '../models/admin_user_list_model.dart';
import '../models/user_details_model.dart';
import '../models/user_session_model.dart';

class UsersRepository {
  UsersRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  // =========================================================
  // LIST USERS
  // =========================================================

  Future<AdminUserListModel> getUsers({
    int page = 1,
    int limit = 20,
    String? search,
    String? accountStatus,
    String? kycStatus,
    String? role,
    String? createdFrom,
    String? createdTo,
    String sortBy = 'createdAt',
    String sortOrder = 'DESC',
  }) async {
    final data = await _apiClient.get(
      '/api/admin/users',
      queryParameters: {
        'page': page,
        'limit': limit,
        'search': search,
        'accountStatus': accountStatus,
        'kycStatus': kycStatus,
        'role': role,
        'createdFrom': createdFrom,
        'createdTo': createdTo,
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      },
    );

    return AdminUserListModel.fromJson(_extractData(data));
  }

  // =========================================================
  // GET USER
  // =========================================================

  Future<UserDetailsModel> getUser(int userId) async {
    final data = await _apiClient.get('/api/admin/users/$userId');

    return UserDetailsModel.fromJson(_extractData(data));
  }

  // =========================================================
  // GET USER ACTIVITY
  // =========================================================

  Future<UserActivityModel> getUserActivity(
    int userId, {
    int limit = 20,
  }) async {
    final data = await _apiClient.get(
      '/api/admin/users/$userId/activity',
      queryParameters: {'limit': limit},
    );

    return UserActivityModel.fromJson(_extractData(data));
  }

  // =========================================================
  // UPDATE USER
  // =========================================================

  Future<UserDetailsModel> updateUser({
    required int userId,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
  }) async {
    final body = <String, dynamic>{};

    if (firstName != null) {
      body['firstName'] = firstName;
    }

    if (lastName != null) {
      body['lastName'] = lastName;
    }

    if (email != null) {
      body['email'] = email;
    }

    if (phone != null) {
      body['phone'] = phone;
    }

    final data = await _apiClient.patch('/api/admin/users/$userId', body: body);

    return UserDetailsModel.fromJson(_extractData(data));
  }

  // =========================================================
  // CHANGE USER STATUS
  // =========================================================

  Future<UserDetailsModel> changeUserStatus({
    required int userId,
    required String accountStatus,
    String? reason,
  }) async {
    final data = await _apiClient.patch(
      '/api/admin/users/$userId/status',
      body: {
        'accountStatus': accountStatus,
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      },
    );

    return UserDetailsModel.fromJson(_extractData(data));
  }

  // =========================================================
  // CREATE USER
  // =========================================================

  Future<Map<String, dynamic>> createUser({
    required String firstName,
    required String lastName,
    required String phone,
    String? email,
    required String nationalId,
    required String password,
  }) async {
    final data = await _apiClient.post(
      '/api/admin/users',
      body: {
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
        'nationalId': nationalId,
        'password': password,
      },
    );

    return _extractData(data);
  }

  // =========================================================
  // RESPONSE DATA
  // =========================================================

  Map<String, dynamic> _extractData(dynamic response) {
    if (response is! Map) {
      throw const ApiException(
        message: 'Invalid response received from the server.',
      );
    }

    final data = response['data'];

    if (data is! Map) {
      throw const ApiException(
        message: 'The server returned an invalid data response.',
      );
    }

    return Map<String, dynamic>.from(data);
  }
}
