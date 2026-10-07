import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/admin_trading_trade_model.dart';
import 'admin_trading_overview_controller.dart';

final adminTradingTradeDetailsControllerProvider =
    AsyncNotifierProvider.family<
      AdminTradingTradeDetailsController,
      AdminTradingTradeModel,
      int
    >(AdminTradingTradeDetailsController.new);

class AdminTradingTradeDetailsController
    extends AsyncNotifier<AdminTradingTradeModel> {
  AdminTradingTradeDetailsController(this.transactionId);

  final int transactionId;

  @override
  Future<AdminTradingTradeModel> build() async {
    final repository = ref.read(adminTradingRepositoryProvider);

    return repository.getTrade(transactionId);
  }

  Future<void> getDetails() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(adminTradingRepositoryProvider);

      return repository.getTrade(transactionId);
    });
  }

  Future<void> refresh() async {
    await getDetails();
  }
}
