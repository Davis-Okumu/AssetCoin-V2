
class TradingOrder {
  final int id;
  final String orderReference;
  final int userId;
  final int tokenId;
  final int? listingId;

  final String orderType;

  /// DECIMAL(30,8)
  final String quantity;

  /// DECIMAL(30,8)
  final String filledQuantity;

  /// DECIMAL(20,8)
  final String pricePerToken;

  /// DECIMAL(20,2)
  final String totalAmount;

  final String currency;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TradingOrder({
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
  });

  factory TradingOrder.fromJson(Map<String, dynamic> json) {
    return TradingOrder(
      id: _parseInt(json['id']),
      orderReference: json['orderReference']?.toString() ?? '',
      userId: _parseInt(json['userId']),
      tokenId: _parseInt(json['tokenId']),
      listingId: _nullableInt(json['listingId']),
      orderType: json['orderType']?.toString() ?? '',
      quantity: _decimalString(json['quantity']),
      filledQuantity: _decimalString(json['filledQuantity']),
      pricePerToken: _decimalString(json['pricePerToken']),
      totalAmount: _decimalString(json['totalAmount']),
      currency: json['currency']?.toString() ?? 'KES',
      status: json['status']?.toString() ?? 'pending',
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
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
    };
  }

  TradingOrder copyWith({
    int? id,
    String? orderReference,
    int? userId,
    int? tokenId,
    int? listingId,
    String? orderType,
    String? quantity,
    String? filledQuantity,
    String? pricePerToken,
    String? totalAmount,
    String? currency,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TradingOrder(
      id: id ?? this.id,
      orderReference: orderReference ?? this.orderReference,
      userId: userId ?? this.userId,
      tokenId: tokenId ?? this.tokenId,
      listingId: listingId ?? this.listingId,
      orderType: orderType ?? this.orderType,
      quantity: quantity ?? this.quantity,
      filledQuantity: filledQuantity ?? this.filledQuantity,
      pricePerToken: pricePerToken ?? this.pricePerToken,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _nullableInt(dynamic value) {
    if (value == null) {
      return null;
    }

    return int.tryParse(value.toString());
  }

  static String _decimalString(dynamic value) {
    if (value == null) {
      return '0';
    }

    return value.toString();
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }
}
