class AdminTradingOrderModel {
  const AdminTradingOrderModel({
    required this.id,
    required this.orderReference,
    required this.userId,
    required this.tokenId,
    this.listingId,
    required this.orderType,
    required this.quantity,
    required this.filledQuantity,
    required this.pricePerToken,
    required this.totalAmount,
    required this.currency,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.tokenName,
    this.tokenCode,
    this.assetName,
    this.assetCode,
    this.assetType,
    this.listingStatus,
  });

  final int id;
  final String orderReference;

  final int userId;
  final int tokenId;
  final int? listingId;

  final String orderType;

  final String quantity;
  final String filledQuantity;
  final String pricePerToken;
  final String totalAmount;

  final String currency;
  final String status;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;

  final String? tokenName;
  final String? tokenCode;

  final String? assetName;
  final String? assetCode;
  final String? assetType;

  final String? listingStatus;

  factory AdminTradingOrderModel.fromJson(Map<String, dynamic> json) {
    return AdminTradingOrderModel(
      id: _asInt(json['id']),
      orderReference: _asString(json['orderReference']),
      userId: _asInt(json['userId']),
      tokenId: _asInt(json['tokenId']),
      listingId: _asNullableInt(json['listingId']),
      orderType: _asString(json['orderType']),
      quantity: _asDecimalString(json['quantity']),
      filledQuantity: _asDecimalString(json['filledQuantity']),
      pricePerToken: _asDecimalString(json['pricePerToken']),
      totalAmount: _asDecimalString(json['totalAmount']),
      currency: _asString(json['currency'], fallback: 'KES'),
      status: _asString(json['status']),
      createdAt: _asDateTime(json['createdAt']),
      updatedAt: _asDateTime(json['updatedAt']),
      firstName: _asNullableString(json['firstName']),
      lastName: _asNullableString(json['lastName']),
      email: _asNullableString(json['email']),
      phone: _asNullableString(json['phone']),
      tokenName: _asNullableString(json['tokenName']),
      tokenCode: _asNullableString(json['tokenCode']),
      assetName: _asNullableString(json['assetName']),
      assetCode: _asNullableString(json['assetCode']),
      assetType: _asNullableString(json['assetType']),
      listingStatus: _asNullableString(json['listingStatus']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderReference': orderReference,
      'userId': userId,
      'tokenId': tokenId,
      'listingId': listingId,
      'orderType': orderType,
      'quantity': quantity,
      'filledQuantity': filledQuantity,
      'pricePerToken': pricePerToken,
      'totalAmount': totalAmount,
      'currency': currency,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'tokenName': tokenName,
      'tokenCode': tokenCode,
      'assetName': assetName,
      'assetCode': assetCode,
      'assetType': assetType,
      'listingStatus': listingStatus,
    };
  }

  String get customerName {
    final parts = <String>[
      if (firstName != null && firstName!.trim().isNotEmpty) firstName!.trim(),
      if (lastName != null && lastName!.trim().isNotEmpty) lastName!.trim(),
    ];

    if (parts.isEmpty) {
      return 'Unknown customer';
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

    return 'Unknown asset';
  }

  String get orderTypeLabel {
    switch (orderType.toLowerCase()) {
      case 'buy':
        return 'Buy';
      case 'sell':
        return 'Sell';
      default:
        return orderType;
    }
  }

  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'open':
        return 'Open';
      case 'partially_filled':
        return 'Partially Filled';
      case 'filled':
        return 'Filled';
      case 'cancelled':
        return 'Cancelled';
      case 'rejected':
        return 'Rejected';
      case 'expired':
        return 'Expired';
      default:
        return status;
    }
  }

  bool get isPending => status.toLowerCase() == 'pending';

  bool get isOpen => status.toLowerCase() == 'open';

  bool get isPartiallyFilled => status.toLowerCase() == 'partially_filled';

  bool get isFilled => status.toLowerCase() == 'filled';

  bool get isCancelled => status.toLowerCase() == 'cancelled';

  bool get isRejected => status.toLowerCase() == 'rejected';

  bool get isExpired => status.toLowerCase() == 'expired';

  bool get isBuyOrder => orderType.toLowerCase() == 'buy';

  bool get isSellOrder => orderType.toLowerCase() == 'sell';

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
