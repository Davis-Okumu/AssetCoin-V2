import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/asset_submission.dart';
import '../providers/asset_providers.dart';

class AssetSubmissionController extends AsyncNotifier<void> {
  AssetSubmission? lastCreatedSubmission;

  @override
  Future<void> build() async {}

  Future<void> submitAsset(
    Map<String, dynamic> assetData,
  ) async {
    state = const AsyncLoading();

    try {
      final repository = ref.read(assetRepositoryProvider);

      // Create the submission and retain its returned details.
      final submission = await repository.createAssetSubmission(
        assetData,
      );

      lastCreatedSubmission = submission;

      // Refresh the user's submissions after successful creation.
      ref.invalidate(myAssetSubmissionsProvider);

      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}

final assetSubmissionControllerProvider =
    AsyncNotifierProvider<AssetSubmissionController, void>(
  AssetSubmissionController.new,
);