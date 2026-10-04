import 'wallet_summary.dart';
import 'wallet_transaction.dart';

abstract class WalletRepository {
  /// Returns the current wallet summary for the authenticated user.
  Future<WalletSummary> getWalletSummary();

  /// Returns the user's wallet transaction history.
  Future<List<WalletTransaction>> getTransactions();

  /// Returns a single wallet transaction by its ID.
  Future<WalletTransaction> getTransaction(int transactionId);

  /// Creates a deposit request.
  Future<WalletTransaction> deposit({
    required double amount,
  });

  /// Creates a withdrawal request.
  Future<WalletTransaction> withdraw({
    required double amount,
  });

  /// Creates a currency/token conversion request.
  Future<WalletTransaction> convert({
    required String fromCurrency,
    required String toCurrency,
    required double amount,
  });
}