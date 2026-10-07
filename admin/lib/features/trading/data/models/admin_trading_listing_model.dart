class AdminTradingListingModel {
  const AdminTradingListingModel({
    required this.id,
    required this.sellerId,
    required this.tokenId,
    required this.quantity,
    required this.remainingQuantity,
    required this.pricePerToken,
    required this.currency,
    required this.listingType,
    required this.status,
    this.expiresAt,
    this.createdAt,
    this.updatedAt,
    this.tokenName,
    this.tokenCode,
    this.tokenStatus,
    this.totalSupply,
    this.availableSupply,
    this.assetId,
    this.assetName,
    this.assetCode,
    this.assetType,
    this.assetStatus,
    this.sellerFirstName,
    this.sellerLastName,
    this.sellerEmail,
    this.sellerPhone,
  });

  final int id;
  final int sellerId;
  final int tokenId;

  final String quantity;
  final String remainingQuantity;
  final String pricePerToken;

  final String currency;
  final String listingType;
  final String status;

  final DateTime? expiresAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final String? tokenName;
  final String? tokenCode;
  final String? tokenStatus;

  final String? totalSupply;
  final String? availableSupply;

  final int? assetId;
  final String? assetName;
  final String? assetCode;
  final String? assetType;
  final String? assetStatus;

  final String? sellerFirstName;
  final String? sellerLastName;
  final String? sellerEmail;
  final String? sellerPhone;

  factory AdminTradingListingModel.fromJson(Map<String, dynamic> json) {
    return AdminTradingListingModel(
      id: _asInt(json['id']),
      sellerId: _asInt(json['sellerId']),
      tokenId: _asInt(json['tokenId']),
      quantity: _asDecimalString(json['quantity']),
      remainingQuantity: _asDecimalString(json['remainingQuantity']),
      pricePerToken: _asDecimalString(json['pricePerToken']),
      currency: _asString(json['currency'], fallback: 'KES'),
      listingType: _asString(json['listingType']),
      status: _asString(json['status']),
      expiresAt: _asDateTime(json['expiresAt']),
      createdAt: _asDateTime(json['createdAt']),
      updatedAt: _asDateTime(json['updatedAt']),
      tokenName: _asNullableString(json['tokenName']),
      tokenCode: _asNullableString(json['tokenCode']),
      tokenStatus: _asNullableString(json['tokenStatus']),
      totalSupply: _asNullableDecimalString(json['totalSupply']),
      availableSupply: _asNullableDecimalString(json['availableSupply']),
      assetId: _asNullableInt(json['assetId']),
      assetName: _asNullableString(json['assetName']),
      assetCode: _asNullableString(json['assetCode']),
      assetType: _asNullableString(json['assetType']),
      assetStatus: _asNullableString(json['assetStatus']),
      sellerFirstName: _asNullableString(json['sellerFirstName']),
      sellerLastName: _asNullableString(json['sellerLastName']),
      sellerEmail: _asNullableString(json['sellerEmail']),
      sellerPhone: _asNullableString(json['sellerPhone']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sellerId': sellerId,
      'tokenId': tokenId,
      'quantity': quantity,
      'remainingQuantity': remainingQuantity,
      'pricePerToken': pricePerToken,
      'currency': currency,
      'listingType': listingType,
      'status': status,
      'expiresAt': expiresAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'tokenName': tokenName,
      'tokenCode': tokenCode,
      'tokenStatus': tokenStatus,
      'totalSupply': totalSupply,
      'availableSupply': availableSupply,
      'assetId': assetId,
      'assetName': assetName,
      'assetCode': assetCode,
      'assetType': assetType,
      'assetStatus': assetStatus,
      'sellerFirstName': sellerFirstName,
      'sellerLastName': sellerLastName,
      'sellerEmail': sellerEmail,
      'sellerPhone': sellerPhone,
    };
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

  String get listingTypeLabel {
    switch (listingType.toLowerCase()) {
      case 'sell':
        return 'Sell';
      case 'buy':
        return 'Buy';
      default:
        return listingType;
    }
  }

  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Active';
      case 'partially_filled':
        return 'Partially Filled';
      case 'filled':
        return 'Filled';
      case 'cancelled':
        return 'Cancelled';
      case 'expired':
        return 'Expired';
      case 'suspended':
        return 'Suspended';
      default:
        return status;
    }
  }

  bool get isActive => status.toLowerCase() == 'active';

  bool get isSuspended => status.toLowerCase() == 'suspended';

  bool get isFilled => status.toLowerCase() == 'filled';

  bool get isPartiallyFilled => status.toLowerCase() == 'partially_filled';

  bool get isExpired => status.toLowerCase() == 'expired';

  bool get canSuspend =>
      status.toLowerCase() == 'active' ||
      status.toLowerCase() == 'partially_filled';

  bool get canReactivate => status.toLowerCase() == 'suspended';

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

  static String? _asNullableDecimalString(dynamic value) {
    if (value == null) {
      return null;
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
