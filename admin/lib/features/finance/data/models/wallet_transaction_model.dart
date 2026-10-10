class WalletTransactionModel {
  const WalletTransactionModel({
    required this.id,
    required this.walletId,
    required this.userId,
    required this.reference,
    required this.type,
    required this.amount,
    required this.currency,
    required this.status,
    this.balanceBefore,
    this.balanceAfter,
    this.description,
    this.transactionHash,
    this.previousHash,
    this.createdAt,
  });

  final int id;
  final int walletId;
  final int userId;
  final String reference;
  final String type;
  final double amount;
  final String currency;
  final String status;
  final double? balanceBefore;
  final double? balanceAfter;
  final String? description;
  final String? transactionHash;
  final String? previousHash;
  final DateTime? createdAt;

  bool get isDeposit => type == 'deposit';
  bool get isWithdrawal => type == 'withdrawal';
  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isReversed => status == 'reversed';

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      id: _toInt(json['id']),
      walletId: _toInt(json['walletId'] ?? json['wallet_id']),
      userId: _toInt(json['userId'] ?? json['user_id']),
      reference:
          (json['transactionReference'] ??
                  json['transaction_reference'] ??
                  json['reference'] ??
                  '')
              .toString(),
      type:
          (json['transactionType'] ??
                  json['transaction_type'] ??
                  json['type'] ??
                  '')
              .toString(),
      amount: _toDouble(json['amount']),
      currency: (json['currency'] ?? 'KES').toString(),
      status: (json['status'] ?? 'pending').toString(),
      balanceBefore: _nullableDouble(
        json['balanceBefore'] ?? json['balance_before'],
      ),
      balanceAfter: _nullableDouble(
        json['balanceAfter'] ?? json['balance_after'],
      ),
      description: _stringOrNull(json['description']),
      transactionHash: _stringOrNull(
        json['transactionHash'] ?? json['transaction_hash'],
      ),
      previousHash: _stringOrNull(
        json['previousHash'] ?? json['previous_hash'],
      ),
      createdAt: _toDate(json['createdAt'] ?? json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'walletId': walletId,
      'userId': userId,
      'transactionReference': reference,
      'transactionType': type,
      'amount': amount,
      'currency': currency,
      'status': status,
      'balanceBefore': balanceBefore,
      'balanceAfter': balanceAfter,
      'description': description,
      'transactionHash': transactionHash,
      'previousHash': previousHash,
      'createdAt': createdAt?.toIso8601String(),
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

double? _nullableDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

String? _stringOrNull(dynamic value) {
  if (value == null) return null;
  final result = value.toString().trim();
  return result.isEmpty ? null : result;
}

DateTime? _toDate(dynamic value) {
  if (value == null || value.toString().isEmpty) return null;
  return DateTime.tryParse(value.toString());
}
