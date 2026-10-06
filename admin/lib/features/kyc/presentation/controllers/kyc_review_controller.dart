import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/admin_kyc_repository.dart';

final kycReviewControllerProvider =
    AsyncNotifierProvider<KycReviewController, void>(KycReviewController.new);

class KycReviewController extends AsyncNotifier<void> {
  late AdminKycRepository _repository;

  @override
  Future<void> build() async {
    _repository = ref.watch(adminKycRepositoryProvider);
  }

  Future<AdminKycAssignmentResult> assignApplication({
    required int kycId,
    required int assignedTo,
    String? priority,
    String? notes,
  }) async {
    state = const AsyncLoading();

    final result = await AsyncValue.guard(
      () => _repository.assignApplication(
        kycId: kycId,
        assignedTo: assignedTo,
        priority: priority,
        notes: notes,
      ),
    );

    state = result.when(
      data: (_) => const AsyncData(null),
      loading: () => const AsyncLoading(),
      error: (error, stackTrace) => AsyncError(error, stackTrace),
    );

    return result.requireValue;
  }

  Future<AdminKycStatusChangeResult> startReview(int kycId) async {
    state = const AsyncLoading();

    final result = await AsyncValue.guard(() => _repository.startReview(kycId));

    state = result.when(
      data: (_) => const AsyncData(null),
      loading: () => const AsyncLoading(),
      error: (error, stackTrace) => AsyncError(error, stackTrace),
    );

    return result.requireValue;
  }

  Future<AdminKycInformationRequestResult> requestInformation({
    required int kycId,
    required String comments,
  }) async {
    state = const AsyncLoading();

    final result = await AsyncValue.guard(
      () => _repository.requestInformation(kycId: kycId, comments: comments),
    );

    state = result.when(
      data: (_) => const AsyncData(null),
      loading: () => const AsyncLoading(),
      error: (error, stackTrace) => AsyncError(error, stackTrace),
    );

    return result.requireValue;
  }

  Future<AdminKycStatusChangeResult> approveApplication(int kycId) async {
    state = const AsyncLoading();

    final result = await AsyncValue.guard(
      () => _repository.approveApplication(kycId),
    );

    state = result.when(
      data: (_) => const AsyncData(null),
      loading: () => const AsyncLoading(),
      error: (error, stackTrace) => AsyncError(error, stackTrace),
    );

    return result.requireValue;
  }

  Future<AdminKycRejectionResult> rejectApplication({
    required int kycId,
    required String rejectionReason,
  }) async {
    state = const AsyncLoading();

    final result = await AsyncValue.guard(
      () => _repository.rejectApplication(
        kycId: kycId,
        rejectionReason: rejectionReason,
      ),
    );

    state = result.when(
      data: (_) => const AsyncData(null),
      loading: () => const AsyncLoading(),
      error: (error, stackTrace) => AsyncError(error, stackTrace),
    );

    return result.requireValue;
  }

  void clearError() {
    state = const AsyncData(null);
  }
}
