import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_client_provider.dart';
import '../models/admin_asset_details_model.dart';
import '../models/admin_asset_list_model.dart';

final assetsRepositoryProvider = Provider<AssetsRepository>((ref) {
  return AssetsRepository(ref.read(apiClientProvider));
});

class AssetsRepository {
  AssetsRepository(this._apiClient);

  final ApiClient _apiClient;

  // =========================================================
  // GET ASSETS
  // =========================================================

  Future<AdminAssetListModel> getAssets({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    String? assetType,
    int? ownerId,
    String sort = 'createdAt',
    String order = 'DESC',
  }) async {
    final query = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      'sort': sort,
      'order': order,
    };

    if (search != null && search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }

    if (status != null && status.trim().isNotEmpty) {
      query['status'] = status.trim();
    }

    if (assetType != null && assetType.trim().isNotEmpty) {
      query['assetType'] = assetType.trim();
    }

    if (ownerId != null) {
      query['ownerId'] = ownerId.toString();
    }

    final response = await _apiClient.get(
      '/api/admin/assets',
      queryParameters: query,
    );

    final data = response['data'] as Map<String, dynamic>? ?? const {};

    return AdminAssetListModel.fromJson(data);
  }

  // =========================================================
  // GET ASSET DETAILS
  // =========================================================

  Future<AdminAssetDetailsModel> getAsset(int assetId) async {
    final response = await _apiClient.get('/api/admin/assets/$assetId');

    final data = response['data'] as Map<String, dynamic>? ?? const {};

    return AdminAssetDetailsModel.fromJson(data);
  }

  // =========================================================
  // REVIEW ASSET
  // =========================================================

  Future<AdminAssetDetailsModel?> reviewAsset({
    required int assetId,
    required String decision,
    String? comments,
  }) async {
    final response = await _apiClient.patch(
      '/api/admin/assets/$assetId/review',
      body: {
        'decision': decision,
        if (comments != null && comments.trim().isNotEmpty)
          'comments': comments.trim(),
      },
    );

    final data = response['data'];

    if (data is! Map<String, dynamic>) {
      return null;
    }

    final asset = data['asset'];

    if (asset is! Map<String, dynamic>) {
      return null;
    }

    return AdminAssetDetailsModel.fromJson(asset);
  }

  // =========================================================
  // CHANGE STATUS
  // =========================================================

  Future<AdminAssetDetailsModel?> changeStatus({
    required int assetId,
    required String status,
    String? reason,
  }) async {
    final response = await _apiClient.patch(
      '/api/admin/assets/$assetId/status',
      body: {
        'status': status,
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      },
    );

    final data = response['data'];

    if (data is! Map<String, dynamic>) {
      return null;
    }

    final asset = data['asset'];

    if (asset is! Map<String, dynamic>) {
      return null;
    }

    return AdminAssetDetailsModel.fromJson(asset);
  }
}
