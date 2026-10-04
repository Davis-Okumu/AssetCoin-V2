import 'wallet_transaction_type.dart';

class WalletTransaction {
  final int id;
  final int walletId;
  final int userId;
  final String transactionReference;
  final WalletTransactionType transactionType;
  final double amount;
  final String currency;
  final double balanceBefore;
  final double balanceAfter;
  final String status;
  final String? description;
  final DateTime createdAt;

  const WalletTransaction({
    required this.id,
    required this.walletId,
    required this.userId,
    required this.transactionReference,
    required this.transactionType,
    required this.amount,
    required this.currency,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.status,
    this.description,
    required this.createdAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: (json['id'] as num?)?.toInt() ?? 0,
      walletId: (json['walletId'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      transactionReference:
          json['transactionReference'] as String? ?? '',
      transactionType: WalletTransactionTypeExtension.fromValue(
        json['transactionType'] as String? ?? '',
      ),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'KES',
      balanceBefore:
          (json['balanceBefore'] as num?)?.toDouble() ?? 0.0,
      balanceAfter:
          (json['balanceAfter'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'pending',
      description: json['description'] as String?,
      createdAt: DateTime.tryParse(
            json['createdAt'] as String? ?? '',
          ) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'walletId': walletId,
      'userId': userId,
      'transactionReference': transactionReference,
      'transactionType': transactionType.value,
      'amount': amount,
      'currency': currency,
      'balanceBefore': balanceBefore,
      'balanceAfter': balanceAfter,
      'status': status,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool get isCredit {
    return transactionType == WalletTransactionType.deposit ||
        transactionType == WalletTransactionType.tokenSale ||
        transactionType == WalletTransactionType.refund ||
        transactionType == WalletTransactionType.adjustment;
  }

  bool get isDebit {
    return transactionType == WalletTransactionType.withdrawal ||
        transactionType == WalletTransactionType.tokenPurchase ||
        transactionType == WalletTransactionType.fee;
  }
}