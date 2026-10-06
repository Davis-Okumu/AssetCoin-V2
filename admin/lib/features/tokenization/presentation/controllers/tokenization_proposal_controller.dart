import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tokenization_controller.dart';

final tokenizationProposalControllerProvider =
    AsyncNotifierProvider<TokenizationProposalController, void>(
      TokenizationProposalController.new,
    );

class TokenizationProposalController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> submit(int proposalId) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final api = ref.read(tokenizationApiProvider);

      await api.submitProposal(proposalId);
    });
  }

  Future<void> review(
    int proposalId, {
    required String decision,
    String? comments,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final api = ref.read(tokenizationApiProvider);

      await api.reviewProposal(proposalId, {
        'decision': decision,
        if (comments != null) 'comments': comments,
      });
    });
  }

  Future<void> approve(int proposalId, {String? comments}) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final api = ref.read(tokenizationApiProvider);

      await api.approveProposal(proposalId, comments: comments);
    });
  }

  Future<void> reject(int proposalId, {String? reason}) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final api = ref.read(tokenizationApiProvider);

      await api.rejectProposal(proposalId, reason: reason);
    });
  }

  Future<void> assign(
    int proposalId, {
    required int assignedTo,
    String priority = 'normal',
    String? notes,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final api = ref.read(tokenizationApiProvider);

      await api.assignProposal(
        proposalId,
        assignedTo: assignedTo,
        priority: priority,
        notes: notes,
      );
    });
  }
}
