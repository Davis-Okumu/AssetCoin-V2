
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client_provider.dart';
import '../../data/repositories/asset_repository_impl.dart';
import '../../domain/asset.dart';
import '../../domain/asset_category.dart';
import '../../domain/asset_repository.dart';
import '../../domain/asset_submission.dart';

// =========================
// ASSET REPOSITORY
// =========================

final assetRepositoryProvider = Provider<AssetRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);

  return AssetRepositoryImpl(apiClient);
});

// =========================
// PUBLISHED ASSETS
// =========================

final publishedAssetsProvider = FutureProvider<List<Asset>>((ref) async {
  final repository = ref.watch(assetRepositoryProvider);

  return repository.getPublishedAssets();
});

// =========================
// ASSET CATEGORIES
// =========================

final assetCategoriesProvider =
    FutureProvider<List<AssetCategory>>((ref) async {
  final repository = ref.watch(assetRepositoryProvider);

  return repository.getAssetCategories();
});

// =========================
// MARKET STATISTICS
// =========================

final assetMarketStatsProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(assetRepositoryProvider);

  return repository.getMarketStats();
});

// =========================
// MY ASSET SUBMISSIONS
// =========================

final myAssetSubmissionsProvider =
    FutureProvider<List<AssetSubmission>>((ref) async {
  final repository = ref.watch(assetRepositoryProvider);

  return repository.getMySubmissions();
});

// =========================
// SINGLE ASSET DETAILS
// =========================

final assetDetailsProvider =
    FutureProvider.family<Asset, int>((ref, assetId) async {
  final repository = ref.watch(assetRepositoryProvider);

  return repository.getAssetDetails(assetId);
});

// =========================
// SINGLE SUBMISSION DETAILS
// =========================

final myAssetSubmissionDetailsProvider =
    FutureProvider.family<Map<String, dynamic>, int>(
  (ref, assetId) async {
    final repository = ref.watch(assetRepositoryProvider);

    return repository.getMySubmissionDetails(assetId);
  },
);