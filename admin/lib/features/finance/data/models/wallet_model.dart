class WalletModel {
  const WalletModel({
    required this.id,
    required this.userId,
    required this.walletAddress,
    required this.availableBalance,
    required this.lockedBalance,
    required this.currency,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final int userId;
  final String walletAddress;

  /// Maps to wallets.fiatBalance in the database.
  final double availableBalance;

  /// Maps to wallets.lockedFiatBalance in the database.
  final double lockedBalance;

  final String currency;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  double get totalBalance => availableBalance + lockedBalance;

  bool get isActive => status == 'active';
  bool get isFrozen => status == 'frozen';
  bool get isClosed => status == 'closed';

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: _toInt(json['id']),
      userId: _toInt(json['userId'] ?? json['user_id']),
      walletAddress: (json['walletAddress'] ?? json['wallet_address'] ?? '')
          .toString(),
      availableBalance: _toDouble(
        json['fiatBalance'] ??
            json['fiat_balance'] ??
            json['availableBalance'] ??
            json['available_balance'],
      ),
      lockedBalance: _toDouble(
        json['lockedFiatBalance'] ??
            json['locked_fiat_balance'] ??
            json['lockedBalance'] ??
            json['locked_balance'],
      ),
      currency: (json['currency'] ?? 'KES').toString(),
      status: (json['status'] ?? 'active').toString(),
      createdAt: _toDate(json['createdAt'] ?? json['created_at']),
      updatedAt: _toDate(json['updatedAt'] ?? json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'walletAddress': walletAddress,
      'fiatBalance': availableBalance,
      'lockedFiatBalance': lockedBalance,
      'currency': currency,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
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

DateTime? _toDate(dynamic value) {
  if (value == null || value.toString().isEmpty) return null;
  return DateTime.tryParse(value.toString());
}
