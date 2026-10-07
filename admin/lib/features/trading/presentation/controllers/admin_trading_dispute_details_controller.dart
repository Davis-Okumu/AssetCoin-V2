import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/admin_trading_dispute_model.dart';
import 'admin_trading_overview_controller.dart';

final adminTradingDisputeDetailsControllerProvider =
    AsyncNotifierProvider.family<
      AdminTradingDisputeDetailsController,
      AdminTradingDisputeModel,
      int
    >(AdminTradingDisputeDetailsController.new);

class AdminTradingDisputeDetailsController
    extends AsyncNotifier<AdminTradingDisputeModel> {
  AdminTradingDisputeDetailsController(this.disputeId);

  final int disputeId;

  @override
  Future<AdminTradingDisputeModel> build() async {
    final repository = ref.read(adminTradingRepositoryProvider);

    return repository.getDispute(disputeId);
  }

  Future<void> getDetails() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(adminTradingRepositoryProvider);

      return repository.getDispute(disputeId);
    });
  }

  Future<void> refresh() async {
    await getDetails();
  }

  Future<void> assign({required int assignedTo}) async {
    final repository = ref.read(adminTradingRepositoryProvider);

    state = await AsyncValue.guard(() async {
      return repository.assignDispute(disputeId, assignedTo: assignedTo);
    });
  }

  Future<void> updateDispute({
    String? status,
    String? priority,
    String? resolutionNotes,
  }) async {
    final repository = ref.read(adminTradingRepositoryProvider);

    state = await AsyncValue.guard(() async {
      return repository.updateDispute(
        disputeId,
        status: status,
        priority: priority,
        resolutionNotes: resolutionNotes,
      );
    });
  }
}
