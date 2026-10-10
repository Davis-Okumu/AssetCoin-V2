import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/wallet_model.dart';
import '../../data/models/wallet_transaction_model.dart';
import '../../data/repositories/finance_repository.dart';
import 'finance_overview_controller.dart';

final financeRepositoryProvider = Provider<FinanceRepository>((ref) {
  return FinanceRepository(ref.read(adminFinanceApiProvider));
});

final walletDetailsControllerProvider =
    AsyncNotifierProvider.family<WalletDetailsController, WalletModel, int>(
      WalletDetailsController.new,
    );

class WalletDetailsController extends AsyncNotifier<WalletModel> {
  WalletDetailsController(this.walletId);

  final int walletId;

  @override
  Future<WalletModel> build() async {
    final repository = ref.read(financeRepositoryProvider);
    return repository.getWalletDetails(walletId);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => ref.read(financeRepositoryProvider).getWalletDetails(walletId),
    );
  }
}

final walletTransactionsControllerProvider =
    AsyncNotifierProvider.family<
      WalletTransactionsController,
      List<WalletTransactionModel>,
      int
    >(WalletTransactionsController.new);

class WalletTransactionsController
    extends AsyncNotifier<List<WalletTransactionModel>> {
  WalletTransactionsController(this.walletId);

  final int walletId;

  @override
  Future<List<WalletTransactionModel>> build() async {
    final repository = ref.read(financeRepositoryProvider);
    return repository.getWalletTransactions(walletId);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => ref.read(financeRepositoryProvider).getWalletTransactions(walletId),
    );
  }
}
