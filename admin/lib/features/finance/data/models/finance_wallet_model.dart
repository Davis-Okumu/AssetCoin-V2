import 'wallet_model.dart';

class FinanceWalletModel {
  const FinanceWalletModel({
    required this.wallet,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
  });

  final WalletModel wallet;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;

  int get id => wallet.id;
  int get userId => wallet.userId;
  String get walletAddress => wallet.walletAddress;
  double get availableBalance => wallet.availableBalance;
  double get lockedBalance => wallet.lockedBalance;
  double get totalBalance => wallet.totalBalance;
  String get currency => wallet.currency;
  String get status => wallet.status;
  DateTime? get createdAt => wallet.createdAt;
  DateTime? get updatedAt => wallet.updatedAt;

  String get customerName {
    final name = [
      firstName?.trim() ?? '',
      lastName?.trim() ?? '',
    ].where((part) => part.isNotEmpty).join(' ');

    return name.isEmpty ? 'Customer #$userId' : name;
  }

  factory FinanceWalletModel.fromJson(Map<String, dynamic> json) {
    final walletJson = json['wallet'] is Map
        ? Map<String, dynamic>.from(json['wallet'] as Map)
        : json;

    return FinanceWalletModel(
      wallet: WalletModel.fromJson(walletJson),
      firstName: _stringOrNull(json['firstName'] ?? json['first_name']),
      lastName: _stringOrNull(json['lastName'] ?? json['last_name']),
      email: _stringOrNull(json['email']),
      phone: _stringOrNull(json['phone']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wallet': wallet.toJson(),
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
    };
  }
}

String? _stringOrNull(dynamic value) {
  if (value == null) return null;
  final result = value.toString().trim();
  return result.isEmpty ? null : result;
}
