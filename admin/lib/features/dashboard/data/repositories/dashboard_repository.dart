import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_client_provider.dart';
import '../models/dashboard_model.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(ref.read(apiClientProvider));
});

class DashboardRepository {
  DashboardRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<DashboardModel> getDashboard() async {
    final response = await _apiClient.get(
      '/api/admin/dashboard',
      includeAuthorization: true,
    );

    if (response is! Map) {
      throw const FormatException('Invalid dashboard response.');
    }

    final payload = Map<String, dynamic>.from(response);

    if (payload['success'] != true) {
      throw Exception(
        payload['message']?.toString() ??
            'Unable to load administrator dashboard.',
      );
    }

    final data = payload['data'];

    if (data is! Map) {
      throw const FormatException(
        'Dashboard data is missing from the response.',
      );
    }

    return DashboardModel.fromJson(Map<String, dynamic>.from(data));
  }
}
