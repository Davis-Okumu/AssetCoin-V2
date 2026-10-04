import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/wallet_repository_impl.dart';
import '../../domain/wallet_repository.dart';
import '../../domain/wallet_summary.dart';
import '../../domain/wallet_transaction.dart';

// ============================================================
// REPOSITORY PROVIDER
// ============================================================

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepositoryImpl();
});

// ============================================================
// WALLET SUMMARY PROVIDER
// ============================================================

final walletSummaryProvider =
    FutureProvider<WalletSummary>((ref) async {
  final repository = ref.read(walletRepositoryProvider);

  return repository.getWalletSummary();
});

// ============================================================
// WALLET TRANSACTIONS PROVIDER
// ============================================================

final walletTransactionsProvider =
    FutureProvider<List<WalletTransaction>>((ref) async {
  final repository = ref.read(walletRepositoryProvider);

  return repository.getTransactions();
});

// ============================================================
// WALLET CONTROLLER
// ============================================================

final walletControllerProvider =
    AsyncNotifierProvider<WalletController, WalletState>(
  WalletController.new,
);

class WalletController extends AsyncNotifier<WalletState> {
  late final WalletRepository _repository;

  @override
  Future<WalletState> build() async {
    _repository = ref.read(walletRepositoryProvider);

    final results = await Future.wait([
      _repository.getWalletSummary(),
      _repository.getTransactions(),
    ]);

    return WalletState(
      summary: results[0] as WalletSummary,
      transactions: results[1] as List<WalletTransaction>,
    );
  }

  // ==========================================================
  // REFRESH
  // ==========================================================

  Future<void> refresh() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final results = await Future.wait([
        _repository.getWalletSummary(),
        _repository.getTransactions(),
      ]);

      return WalletState(
        summary: results[0] as WalletSummary,
        transactions: results[1] as List<WalletTransaction>,
      );
    });
  }

  // ==========================================================
  // DEPOSIT
  // ==========================================================

  Future<WalletTransaction?> deposit({
    required double amount,
  }) async {
    try {
      final transaction = await _repository.deposit(
        amount: amount,
      );

      await refresh();

      return transaction;
    } catch (error) {
      return Future.error(error);
    }
  }

  // ==========================================================
  // WITHDRAW
  // ==========================================================

  Future<WalletTransaction?> withdraw({
    required double amount,
  }) async {
    try {
      final transaction = await _repository.withdraw(
        amount: amount,
      );

      await refresh();

      return transaction;
    } catch (error) {
      return Future.error(error);
    }
  }

  // ==========================================================
  // CONVERSION
  // ==========================================================

  Future<WalletTransaction?> convert({
    required String fromCurrency,
    required String toCurrency,
    required double amount,
  }) async {
    try {
      final transaction = await _repository.convert(
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
        amount: amount,
      );

      await refresh();

      return transaction;
    } catch (error) {
      return Future.error(error);
    }
  }
}

// ============================================================
// WALLET STATE
// ============================================================

class WalletState {
  final WalletSummary summary;
  final List<WalletTransaction> transactions;

  const WalletState({
    required this.summary,
    required this.transactions,
  });
}