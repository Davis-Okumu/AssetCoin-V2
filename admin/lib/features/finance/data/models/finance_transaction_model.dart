import 'wallet_transaction_model.dart';

class FinanceTransactionModel {
  const FinanceTransactionModel({
    required this.transaction,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.walletAddress,
  });

  final WalletTransactionModel transaction;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? walletAddress;

  int get id => transaction.id;
  int get walletId => transaction.walletId;
  int get userId => transaction.userId;
  String get reference => transaction.reference;
  String get type => transaction.type;
  double get amount => transaction.amount;
  String get currency => transaction.currency;
  String get status => transaction.status;
  String? get description => transaction.description;
  DateTime? get createdAt => transaction.createdAt;

  String get customerName {
    final name = [
      firstName?.trim() ?? '',
      lastName?.trim() ?? '',
    ].where((part) => part.isNotEmpty).join(' ');

    return name.isEmpty ? 'Customer #$userId' : name;
  }

  factory FinanceTransactionModel.fromJson(Map<String, dynamic> json) {
    final transactionJson = json['transaction'] is Map
        ? Map<String, dynamic>.from(json['transaction'] as Map)
        : json;

    return FinanceTransactionModel(
      transaction: WalletTransactionModel.fromJson(transactionJson),
      firstName: _stringOrNull(json['firstName'] ?? json['first_name']),
      lastName: _stringOrNull(json['lastName'] ?? json['last_name']),
      email: _stringOrNull(json['email']),
      phone: _stringOrNull(json['phone']),
      walletAddress: _stringOrNull(
        json['walletAddress'] ?? json['wallet_address'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction': transaction.toJson(),
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'walletAddress': walletAddress,
    };
  }
}

String? _stringOrNull(dynamic value) {
  if (value == null) return null;
  final result = value.toString().trim();
  return result.isEmpty ? null : result;
}
