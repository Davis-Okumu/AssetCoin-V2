import 'package:http/http.dart' as http;

import 'asset.dart';
import 'asset_category.dart';
import 'asset_submission.dart';

abstract class AssetRepository {
  Future<List<Asset>> getPublishedAssets({
    String? search,
    String? category,
    int page = 1,
    int limit = 20,
  });

  Future<Asset> getAssetDetails(int assetId);

  Future<List<AssetCategory>> getAssetCategories();

  Future<Map<String, dynamic>> getMarketStats();

  Future<List<AssetSubmission>> getMySubmissions();

  Future<Map<String, dynamic>> getMySubmissionDetails(int assetId);

  Future<AssetSubmission> createAssetSubmission(
    Map<String, dynamic> assetData,
  );

  Future<Map<String, dynamic>> uploadAssetPhotos({
    required int assetId,
    required List<http.MultipartFile> photos,
  });

  Future<Map<String, dynamic>> uploadAssetDocuments({
    required int assetId,
    required List<http.MultipartFile> documents,
    required String documentType,
  });
}