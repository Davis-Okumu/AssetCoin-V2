class AdminTradingTradeModel {
  const AdminTradingTradeModel({
    required this.id,
    required this.transactionReference,
    required this.buyerId,
    required this.sellerId,
    required this.tokenId,
    this.listingId,
    this.buyOrderId,
    this.sellOrderId,
    required this.quantity,
    required this.pricePerToken,
    required this.totalAmount,
    required this.feeAmount,
    required this.currency,
    required this.status,
    this.previousHash,
    this.transactionHash,
    this.createdAt,
    this.buyerFirstName,
    this.buyerLastName,
    this.buyerEmail,
    this.buyerPhone,
    this.sellerFirstName,
    this.sellerLastName,
    this.sellerEmail,
    this.sellerPhone,
    this.tokenName,
    this.tokenCode,
    this.assetId,
    this.assetName,
    this.assetCode,
    this.assetType,
  });

  final int id;
  final String transactionReference;

  final int buyerId;
  final int sellerId;
  final int tokenId;

  final int? listingId;
  final int? buyOrderId;
  final int? sellOrderId;

  final String quantity;
  final String pricePerToken;
  final String totalAmount;
  final String feeAmount;

  final String currency;
  final String status;

  final String? previousHash;
  final String? transactionHash;

  final DateTime? createdAt;

  final String? buyerFirstName;
  final String? buyerLastName;
  final String? buyerEmail;
  final String? buyerPhone;

  final String? sellerFirstName;
  final String? sellerLastName;
  final String? sellerEmail;
  final String? sellerPhone;

  final String? tokenName;
  final String? tokenCode;

  final int? assetId;
  final String? assetName;
  final String? assetCode;
  final String? assetType;

  factory AdminTradingTradeModel.fromJson(Map<String, dynamic> json) {
    return AdminTradingTradeModel(
      id: _asInt(json['id']),
      transactionReference: _asString(json['transactionReference']),
      buyerId: _asInt(json['buyerId']),
      sellerId: _asInt(json['sellerId']),
      tokenId: _asInt(json['tokenId']),
      listingId: _asNullableInt(json['listingId']),
      buyOrderId: _asNullableInt(json['buyOrderId']),
      sellOrderId: _asNullableInt(json['sellOrderId']),
      quantity: _asDecimalString(json['quantity']),
      pricePerToken: _asDecimalString(json['pricePerToken']),
      totalAmount: _asDecimalString(json['totalAmount']),
      feeAmount: _asDecimalString(json['feeAmount']),
      currency: _asString(json['currency'], fallback: 'KES'),
      status: _asString(json['status']),
      previousHash: _asNullableString(json['previousHash']),
      transactionHash: _asNullableString(json['transactionHash']),
      createdAt: _asDateTime(json['createdAt']),
      buyerFirstName: _asNullableString(json['buyerFirstName']),
      buyerLastName: _asNullableString(json['buyerLastName']),
      buyerEmail: _asNullableString(json['buyerEmail']),
      buyerPhone: _asNullableString(json['buyerPhone']),
      sellerFirstName: _asNullableString(json['sellerFirstName']),
      sellerLastName: _asNullableString(json['sellerLastName']),
      sellerEmail: _asNullableString(json['sellerEmail']),
      sellerPhone: _asNullableString(json['sellerPhone']),
      tokenName: _asNullableString(json['tokenName']),
      tokenCode: _asNullableString(json['tokenCode']),
      assetId: _asNullableInt(json['assetId']),
      assetName: _asNullableString(json['assetName']),
      assetCode: _asNullableString(json['assetCode']),
      assetType: _asNullableString(json['assetType']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transactionReference': transactionReference,
      'buyerId': buyerId,
      'sellerId': sellerId,
      'tokenId': tokenId,
      'listingId': listingId,
      'buyOrderId': buyOrderId,
      'sellOrderId': sellOrderId,
      'quantity': quantity,
      'pricePerToken': pricePerToken,
      'totalAmount': totalAmount,
      'feeAmount': feeAmount,
      'currency': currency,
      'status': status,
      'previousHash': previousHash,
      'transactionHash': transactionHash,
      'createdAt': createdAt?.toIso8601String(),
      'buyerFirstName': buyerFirstName,
      'buyerLastName': buyerLastName,
      'buyerEmail': buyerEmail,
      'buyerPhone': buyerPhone,
      'sellerFirstName': sellerFirstName,
      'sellerLastName': sellerLastName,
      'sellerEmail': sellerEmail,
      'sellerPhone': sellerPhone,
      'tokenName': tokenName,
      'tokenCode': tokenCode,
      'assetId': assetId,
      'assetName': assetName,
      'assetCode': assetCode,
      'assetType': assetType,
    };
  }

  String get buyerName {
    final parts = <String>[
      if (buyerFirstName != null && buyerFirstName!.trim().isNotEmpty)
        buyerFirstName!.trim(),
      if (buyerLastName != null && buyerLastName!.trim().isNotEmpty)
        buyerLastName!.trim(),
    ];

    if (parts.isEmpty) {
      return 'Unknown buyer';
    }

    return parts.join(' ');
  }

  String get sellerName {
    final parts = <String>[
      if (sellerFirstName != null && sellerFirstName!.trim().isNotEmpty)
        sellerFirstName!.trim(),
      if (sellerLastName != null && sellerLastName!.trim().isNotEmpty)
        sellerLastName!.trim(),
    ];

    if (parts.isEmpty) {
      return 'Unknown seller';
    }

    return parts.join(' ');
  }

  String get tokenDisplayName {
    if (tokenName != null && tokenName!.trim().isNotEmpty) {
      return tokenName!.trim();
    }

    if (tokenCode != null && tokenCode!.trim().isNotEmpty) {
      return tokenCode!.trim();
    }

    return 'Token #$tokenId';
  }

  String get assetDisplayName {
    if (assetName != null && assetName!.trim().isNotEmpty) {
      return assetName!.trim();
    }

    if (assetCode != null && assetCode!.trim().isNotEmpty) {
      return assetCode!.trim();
    }

    if (assetId != null) {
      return 'Asset #$assetId';
    }

    return 'Unknown asset';
  }

  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'completed':
        return 'Completed';
      case 'failed':
        return 'Failed';
      case 'reversed':
        return 'Reversed';
      default:
        return status;
    }
  }

  bool get isPending => status.toLowerCase() == 'pending';

  bool get isCompleted => status.toLowerCase() == 'completed';

  bool get isFailed => status.toLowerCase() == 'failed';

  bool get isReversed => status.toLowerCase() == 'reversed';

  bool get hasTransactionHash =>
      transactionHash != null && transactionHash!.trim().isNotEmpty;

  bool get hasPreviousHash =>
      previousHash != null && previousHash!.trim().isNotEmpty;

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _asNullableInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value.toString());
  }

  static String _asString(dynamic value, {String fallback = ''}) {
    if (value == null) {
      return fallback;
    }

    final result = value.toString().trim();

    return result.isEmpty ? fallback : result;
  }

  static String? _asNullableString(dynamic value) {
    if (value == null) {
      return null;
    }

    final result = value.toString().trim();

    return result.isEmpty ? null : result;
  }

  static String _asDecimalString(dynamic value) {
    if (value == null) {
      return '0';
    }

    return value.toString();
  }

  static DateTime? _asDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.tryParse(value.toString());
  }
}
