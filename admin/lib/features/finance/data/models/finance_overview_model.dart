import 'finance_transaction_model.dart';

class FinanceOverviewModel {
  const FinanceOverviewModel({
    this.totalWallets = 0,
    this.totalWalletBalance = 0,
    this.totalLockedBalance = 0,
    this.totalDeposits = 0,
    this.totalWithdrawals = 0,
    this.pendingDeposits = 0,
    this.pendingWithdrawals = 0,
    this.totalTransactions = 0,
    this.pendingTransactions = 0,
    this.failedTransactions = 0,
    this.recentTransactions = const [],
  });

  final int totalWallets;
  final double totalWalletBalance;
  final double totalLockedBalance;
  final double totalDeposits;
  final double totalWithdrawals;
  final int pendingDeposits;
  final int pendingWithdrawals;
  final int totalTransactions;
  final int pendingTransactions;
  final int failedTransactions;
  final List<FinanceTransactionModel> recentTransactions;

  double get totalWalletValue => totalWalletBalance + totalLockedBalance;

  factory FinanceOverviewModel.fromJson(Map<String, dynamic> json) {
    final rawSummary = json['summary'] ?? json['overview'];
    final summary = rawSummary is Map
        ? Map<String, dynamic>.from(rawSummary)
        : json;

    final rawTransactions =
        json['recentTransactions'] ??
        json['recent_transactions'] ??
        summary['recentTransactions'] ??
        summary['recent_transactions'];

    final transactions = <FinanceTransactionModel>[];

    if (rawTransactions is List) {
      for (final item in rawTransactions) {
        if (item is Map) {
          transactions.add(
            FinanceTransactionModel.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    return FinanceOverviewModel(
      totalWallets: _toInt(
        summary['totalWallets'] ??
            summary['totalWalletsCount'] ??
            summary['total_wallets'],
      ),
      totalWalletBalance: _toDouble(
        summary['totalWalletBalance'] ??
            summary['totalAvailableBalance'] ??
            summary['total_wallet_balance'] ??
            summary['total_available_balance'],
      ),
      totalLockedBalance: _toDouble(
        summary['totalLockedBalance'] ?? summary['total_locked_balance'],
      ),
      totalDeposits: _toDouble(
        summary['totalDeposits'] ??
            summary['totalDepositAmount'] ??
            summary['total_deposits'] ??
            summary['total_deposit_amount'],
      ),
      totalWithdrawals: _toDouble(
        summary['totalWithdrawals'] ??
            summary['totalWithdrawalAmount'] ??
            summary['total_withdrawals'] ??
            summary['total_withdrawal_amount'],
      ),
      pendingDeposits: _toInt(
        summary['pendingDeposits'] ?? summary['pending_deposits'],
      ),
      pendingWithdrawals: _toInt(
        summary['pendingWithdrawals'] ?? summary['pending_withdrawals'],
      ),
      totalTransactions: _toInt(
        summary['totalTransactions'] ?? summary['total_transactions'],
      ),
      pendingTransactions: _toInt(
        summary['pendingTransactions'] ?? summary['pending_transactions'],
      ),
      failedTransactions: _toInt(
        summary['failedTransactions'] ?? summary['failed_transactions'],
      ),
      recentTransactions: transactions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': {
        'totalWallets': totalWallets,
        'totalWalletBalance': totalWalletBalance,
        'totalLockedBalance': totalLockedBalance,
        'totalDeposits': totalDeposits,
        'totalWithdrawals': totalWithdrawals,
        'pendingDeposits': pendingDeposits,
        'pendingWithdrawals': pendingWithdrawals,
        'totalTransactions': totalTransactions,
        'pendingTransactions': pendingTransactions,
        'failedTransactions': failedTransactions,
      },
      'recentTransactions': recentTransactions
          .map((item) => item.toJson())
          .toList(),
    };
  }
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
