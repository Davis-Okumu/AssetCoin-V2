import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/admin_asset_details_model.dart';
import '../../data/repositories/assets_repository.dart';

final assetDetailsControllerProvider =
    AsyncNotifierProvider.family<
      AssetDetailsController,
      AdminAssetDetailsModel,
      int
    >(AssetDetailsController.new);

class AssetDetailsController extends AsyncNotifier<AdminAssetDetailsModel> {
  AssetDetailsController(this.assetId);

  final int assetId;

  AssetsRepository get _repository => ref.read(assetsRepositoryProvider);

  @override
  Future<AdminAssetDetailsModel> build() {
    return _repository.getAsset(assetId);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.getAsset(assetId));
  }

  Future<void> review({required String decision, String? comments}) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final result = await _repository.reviewAsset(
        assetId: assetId,
        decision: decision,
        comments: comments,
      );

      return result ?? await _repository.getAsset(assetId);
    });
  }

  Future<void> changeStatus({required String status, String? reason}) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final result = await _repository.changeStatus(
        assetId: assetId,
        status: status,
        reason: reason,
      );

      return result ?? await _repository.getAsset(assetId);
    });
  }
}
