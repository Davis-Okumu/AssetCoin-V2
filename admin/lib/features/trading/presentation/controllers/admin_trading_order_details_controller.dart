import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/admin_trading_order_model.dart';
import 'admin_trading_overview_controller.dart';

final adminTradingOrderDetailsControllerProvider =
    AsyncNotifierProvider.family<
      AdminTradingOrderDetailsController,
      AdminTradingOrderModel,
      int
    >(AdminTradingOrderDetailsController.new);

class AdminTradingOrderDetailsController
    extends AsyncNotifier<AdminTradingOrderModel> {
  AdminTradingOrderDetailsController(this.orderId);

  final int orderId;

  @override
  Future<AdminTradingOrderModel> build() async {
    final repository = ref.read(adminTradingRepositoryProvider);

    return repository.getOrder(orderId);
  }

  Future<void> getDetails() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(adminTradingRepositoryProvider);

      return repository.getOrder(orderId);
    });
  }

  Future<void> refresh() async {
    await getDetails();
  }
}
