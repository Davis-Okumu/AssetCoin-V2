
class MarketplaceTransaction {
  final int id;
  final String transactionReference;
  final int buyerId;
  final int sellerId;
  final int tokenId;
  final int? listingId;
  final int? buyOrderId;
  final int? sellOrderId;

  /// DECIMAL(30,8)
  final String quantity;

  /// DECIMAL(20,8)
  final String pricePerToken;

  /// DECIMAL(20,2)
  final String totalAmount;

  /// DECIMAL(20,2)
  final String feeAmount;

  final String currency;
  final String status;
  final DateTime? createdAt;

  const MarketplaceTransaction({
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
    this.createdAt,
  });

  factory MarketplaceTransaction.fromJson(
    Map<String, dynamic> json,
  ) {
    return MarketplaceTransaction(
      id: _parseInt(json['id']),
      transactionReference:
          json['transactionReference']?.toString() ?? '',
      buyerId: _parseInt(json['buyerId']),
      sellerId: _parseInt(json['sellerId']),
      tokenId: _parseInt(json['tokenId']),
      listingId: _nullableInt(json['listingId']),
      buyOrderId: _nullableInt(json['buyOrderId']),
      sellOrderId: _nullableInt(json['sellOrderId']),
      quantity: _decimalString(json['quantity']),
      pricePerToken: _decimalString(json['pricePerToken']),
      totalAmount: _decimalString(json['totalAmount']),
      feeAmount: _decimalString(json['feeAmount']),
      currency: json['currency']?.toString() ?? 'KES',
      status: json['status']?.toString() ?? 'pending',
      createdAt: _parseDateTime(json['createdAt']),
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
      'createdAt': createdAt?.toIso8601String(),
    };
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
