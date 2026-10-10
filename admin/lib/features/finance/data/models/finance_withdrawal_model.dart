import 'wallet_transaction_model.dart';

class FinanceWithdrawalModel {
  const FinanceWithdrawalModel({
    required this.transaction,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.paymentMethod,
    this.destinationReference,
  });

  final WalletTransactionModel transaction;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;

  /// Optional API enrichment; not a wallet_transactions column.
  final String? paymentMethod;

  /// Optional API enrichment; not a wallet_transactions column.
  final String? destinationReference;

  int get id => transaction.id;
  int get walletId => transaction.walletId;
  int get userId => transaction.userId;
  String get reference => transaction.reference;
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

  factory FinanceWithdrawalModel.fromJson(Map<String, dynamic> json) {
    final transactionJson = json['transaction'] is Map
        ? Map<String, dynamic>.from(json['transaction'] as Map)
        : json;

    return FinanceWithdrawalModel(
      transaction: WalletTransactionModel.fromJson(transactionJson),
      firstName: _stringOrNull(json['firstName'] ?? json['first_name']),
      lastName: _stringOrNull(json['lastName'] ?? json['last_name']),
      email: _stringOrNull(json['email']),
      phone: _stringOrNull(json['phone']),
      paymentMethod: _stringOrNull(
        json['paymentMethod'] ?? json['payment_method'],
      ),
      destinationReference: _stringOrNull(
        json['destinationReference'] ?? json['destination_reference'],
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
      'paymentMethod': paymentMethod,
      'destinationReference': destinationReference,
    };
  }
}

String? _stringOrNull(dynamic value) {
  if (value == null) return null;
  final result = value.toString().trim();
  return result.isEmpty ? null : result;
}
