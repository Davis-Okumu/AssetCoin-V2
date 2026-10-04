import 'dart:convert';

import '../../../../core/network/api_client.dart';
import '../../domain/home_repository.dart';
import '../../domain/home_summary.dart';

class HomeRepositoryImpl implements HomeRepository {
  final ApiClient _apiClient;

  HomeRepositoryImpl({
    required this._apiClient,
  });

  @override
  Future<HomeSummary> getHomeSummary() async {
    final response = await _apiClient.get('/api/home');

    final dynamic decodedResponse;

    try {
      decodedResponse = jsonDecode(response.body);
    } catch (_) {
      throw const FormatException(
        'The server returned an invalid JSON response.',
      );
    }

    if (decodedResponse is! Map<String, dynamic>) {
      throw const FormatException(
        'Unexpected Home API response format.',
      );
    }

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      final message =
          decodedResponse['message'] as String? ??
              'Unable to retrieve Home data.';

      throw Exception(message);
    }

    final data = decodedResponse['data'];

    if (data is! Map<String, dynamic>) {
      throw const FormatException(
        'Home data is missing or invalid.',
      );
    }

    return HomeSummary.fromJson(data);
  }
}

