
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/network/api_client.dart';
import '../../domain/asset.dart';
import '../../domain/asset_category.dart';
import '../../domain/asset_repository.dart';
import '../../domain/asset_submission.dart';

class AssetRepositoryImpl implements AssetRepository {
  AssetRepositoryImpl(this._apiClient);

  final ApiClient _apiClient;

  // =========================
  // RESPONSE HELPERS
  // =========================

  Map<String, dynamic> _decodeResponse(http.Response response) {
    dynamic decoded;

    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw Exception('The server returned an invalid response.');
    }

    if (decoded is! Map) {
      throw Exception('Unexpected server response format.');
    }

    final data = Map<String, dynamic>.from(decoded);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        data['message']?.toString() ??
            'Request failed with status ${response.statusCode}.',
      );
    }

    if (data['success'] == false) {
      throw Exception(
        data['message']?.toString() ??
            'The request could not be completed.',
      );
    }

    return data;
  }

  List<dynamic> _extractList(Map<String, dynamic> response) {
    final data = response['data'];

    if (data is List) {
      return data;
    }

    return [];
  }

  Map<String, dynamic> _extractObject(
    Map<String, dynamic> response,
  ) {
    final data = response['data'];

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    throw Exception('The server returned an unexpected data format.');
  }

  // =========================
  // PUBLISHED MARKETPLACE
  // =========================

  @override
  Future<List<Asset>> getPublishedAssets({
    String? search,
    String? category,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParameters = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (search != null && search.trim().isNotEmpty) {
      queryParameters['search'] = search.trim();
    }

    if (category != null &&
        category.trim().isNotEmpty &&
        category.toLowerCase() != 'all') {
      queryParameters['category'] = category.trim();
    }

    final uri = Uri(
      path: '/api/assets',
      queryParameters: queryParameters,
    );

    final response = await _apiClient.get(
      uri.toString(),
      authenticated: false,
    );

    final result = _decodeResponse(response);

    return _extractList(result)
        .whereType<Map>()
        .map(
          (item) => Asset.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  // =========================
  // ASSET DETAILS
  // =========================

  @override
  Future<Asset> getAssetDetails(int assetId) async {
    final response = await _apiClient.get(
      '/api/assets/$assetId',
      authenticated: false,
    );

    final result = _decodeResponse(response);

    return Asset.fromJson(_extractObject(result));
  }

  // =========================
  // ASSET CATEGORIES
  // =========================

  @override
  Future<List<AssetCategory>> getAssetCategories() async {
    final response = await _apiClient.get(
      '/api/assets/categories',
      authenticated: false,
    );

    final result = _decodeResponse(response);

    return _extractList(result)
        .whereType<Map>()
        .map(
          (item) => AssetCategory.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  // =========================
  // MARKET STATISTICS
  // =========================

  @override
  Future<Map<String, dynamic>> getMarketStats() async {
    final response = await _apiClient.get(
      '/api/assets/market-stats',
      authenticated: false,
    );

    final result = _decodeResponse(response);

    return _extractObject(result);
  }

  // =========================
  // MY SUBMISSIONS
  // =========================

  @override
  Future<List<AssetSubmission>> getMySubmissions() async {
    final response = await _apiClient.get(
      '/api/assets/my-submissions',
    );

    final result = _decodeResponse(response);

    return _extractList(result)
        .whereType<Map>()
        .map(
          (item) => AssetSubmission.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  // =========================
  // MY SUBMISSION DETAILS
  // =========================

  @override
  Future<Map<String, dynamic>> getMySubmissionDetails(
    int assetId,
  ) async {
    final response = await _apiClient.get(
      '/api/assets/my-submissions/$assetId',
    );

    final result = _decodeResponse(response);

    return _extractObject(result);
  }

  // =========================
  // CREATE ASSET SUBMISSION
  // =========================

  @override
  Future<AssetSubmission> createAssetSubmission(
    Map<String, dynamic> assetData,
  ) async {
    final response = await _apiClient.post(
      '/api/assets/submit',
      body: assetData,
    );

    final result = _decodeResponse(response);

    return AssetSubmission.fromJson(
      _extractObject(result),
    );
  }

  // =========================
  // UPLOAD ASSET PHOTOS
  // =========================

  Future<Map<String, dynamic>> uploadAssetPhotos({
    required int assetId,
    required List<http.MultipartFile> photos,
  }) async {
    if (photos.isEmpty) {
      throw Exception('Please select at least one asset photo.');
    }

    if (photos.length > 5) {
      throw Exception('You can upload a maximum of 5 photos.');
    }

    final response = await _apiClient.uploadMultipart(
      path: '/api/assets/$assetId/photos',
      files: photos,
    );

    final result = _decodeResponse(response);

    return _extractObject(result);
  }

  // =========================
  // UPLOAD SUPPORTING DOCUMENTS
  // =========================

  Future<Map<String, dynamic>> uploadAssetDocuments({
    required int assetId,
    required List<http.MultipartFile> documents,
    required String documentType,
  }) async {
    const allowedDocumentTypes = {
      'ownership',
      'valuation',
      'registration',
      'identification',
      'legal',
      'inspection',
      'other',
    };

    if (documents.isEmpty) {
      throw Exception('Please select at least one PDF document.');
    }

    if (documents.length > 5) {
      throw Exception('You can upload a maximum of 5 documents.');
    }

    if (!allowedDocumentTypes.contains(documentType)) {
      throw Exception('Please select a valid document type.');
    }

    final response = await _apiClient.uploadMultipart(
      path: '/api/assets/$assetId/documents',
      files: documents,
      fields: {
        'documentType': documentType,
      },
    );

    final result = _decodeResponse(response);

    return _extractObject(result);
  }
}