class AdminLedgerEntryModel {
  const AdminLedgerEntryModel({
    required this.id,
    required this.entryReference,
    required this.entryType,
    required this.assetType,
    required this.amount,
    required this.currency,
    this.userId,
    this.walletId,
    this.tokenId,
    this.transactionId,
    this.balanceBefore,
    this.balanceAfter,
    this.description,
    this.previousHash,
    this.entryHash,
    this.createdAt,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.walletAddress,
    this.marketplaceTransactionReference,
    this.marketplaceTransactionStatus,
    this.marketplaceTransactionQuantity,
    this.marketplacePricePerToken,
    this.marketplaceTotalAmount,
    this.marketplaceFeeAmount,
  });

  final int id;
  final String entryReference;
  final String entryType;
  final String assetType;
  final String amount;
  final String currency;

  final int? userId;
  final int? walletId;
  final int? tokenId;
  final int? transactionId;

  final String? balanceBefore;
  final String? balanceAfter;
  final String? description;
  final String? previousHash;
  final String? entryHash;
  final DateTime? createdAt;

  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? walletAddress;

  final String? marketplaceTransactionReference;
  final String? marketplaceTransactionStatus;
  final String? marketplaceTransactionQuantity;
  final String? marketplacePricePerToken;
  final String? marketplaceTotalAmount;
  final String? marketplaceFeeAmount;

  factory AdminLedgerEntryModel.fromJson(Map<String, dynamic> json) {
    return AdminLedgerEntryModel(
      id: _int(json['id']),
      entryReference: _string(json['entryReference']),
      entryType: _string(json['entryType']),
      assetType: _string(json['assetType']),
      amount: _decimal(json['amount']),
      currency: _string(json['currency'], fallback: 'KES'),
      userId: _nullableInt(json['userId']),
      walletId: _nullableInt(json['walletId']),
      tokenId: _nullableInt(json['tokenId']),
      transactionId: _nullableInt(json['transactionId']),
      balanceBefore: _nullableDecimal(json['balanceBefore']),
      balanceAfter: _nullableDecimal(json['balanceAfter']),
      description: _nullableString(json['description']),
      previousHash: _nullableString(json['previousHash']),
      entryHash: _nullableString(json['entryHash']),
      createdAt: _date(json['createdAt']),
      firstName: _nullableString(json['firstName']),
      lastName: _nullableString(json['lastName']),
      email: _nullableString(json['email']),
      phone: _nullableString(json['phone']),
      walletAddress: _nullableString(json['walletAddress']),
      marketplaceTransactionReference: _nullableString(
        json['marketplaceTransactionReference'],
      ),
      marketplaceTransactionStatus: _nullableString(
        json['marketplaceTransactionStatus'],
      ),
      marketplaceTransactionQuantity: _nullableDecimal(
        json['marketplaceTransactionQuantity'],
      ),
      marketplacePricePerToken: _nullableDecimal(
        json['marketplacePricePerToken'],
      ),
      marketplaceTotalAmount: _nullableDecimal(json['marketplaceTotalAmount']),
      marketplaceFeeAmount: _nullableDecimal(json['marketplaceFeeAmount']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'entryReference': entryReference,
    'entryType': entryType,
    'assetType': assetType,
    'amount': amount,
    'currency': currency,
    'userId': userId,
    'walletId': walletId,
    'tokenId': tokenId,
    'transactionId': transactionId,
    'balanceBefore': balanceBefore,
    'balanceAfter': balanceAfter,
    'description': description,
    'previousHash': previousHash,
    'entryHash': entryHash,
    'createdAt': createdAt?.toIso8601String(),
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'phone': phone,
    'walletAddress': walletAddress,
    'marketplaceTransactionReference': marketplaceTransactionReference,
    'marketplaceTransactionStatus': marketplaceTransactionStatus,
    'marketplaceTransactionQuantity': marketplaceTransactionQuantity,
    'marketplacePricePerToken': marketplacePricePerToken,
    'marketplaceTotalAmount': marketplaceTotalAmount,
    'marketplaceFeeAmount': marketplaceFeeAmount,
  };

  String get customerName {
    final parts = [
      if (_hasText(firstName)) firstName!.trim(),
      if (_hasText(lastName)) lastName!.trim(),
    ];

    return parts.isEmpty ? 'Unknown customer' : parts.join(' ');
  }

  String get entryTypeLabel => _titleCase(entryType);

  String get assetTypeLabel => _titleCase(assetType);

  bool get isCredit => entryType.toLowerCase() == 'credit';

  bool get isDebit => entryType.toLowerCase() == 'debit';

  bool get isFiat => assetType.toLowerCase() == 'fiat';

  bool get isToken => assetType.toLowerCase() == 'token';

  bool get hasPreviousHash => _hasText(previousHash);

  bool get hasEntryHash => _hasText(entryHash);

  static bool _hasText(String? value) =>
      value != null && value.trim().isNotEmpty;

  static int _int(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _nullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static String _string(dynamic value, {String fallback = ''}) {
    final result = value?.toString().trim() ?? '';
    return result.isEmpty ? fallback : result;
  }

  static String? _nullableString(dynamic value) {
    final result = value?.toString().trim();
    return result == null || result.isEmpty ? null : result;
  }

  static String _decimal(dynamic value) => value?.toString() ?? '0';

  static String? _nullableDecimal(dynamic value) =>
      value == null ? null : value.toString();

  static DateTime? _date(dynamic value) {
    if (value is DateTime) return value;
    return value == null ? null : DateTime.tryParse(value.toString());
  }

  static String _titleCase(String value) {
    final normalized = value.replaceAll('_', ' ').trim();
    if (normalized.isEmpty) return value;

    return normalized
        .split(RegExp(r'\s+'))
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}
