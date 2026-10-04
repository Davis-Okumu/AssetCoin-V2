
import 'token.dart';

class Listing {
  final int id;
  final int sellerId;
  final int tokenId;

  /// DECIMAL(30,8)
  final String quantity;

  /// DECIMAL(30,8)
  final String remainingQuantity;

  /// DECIMAL(20,8)
  final String pricePerToken;

  final String currency;
  final String listingType;
  final String status;
  final DateTime? expiresAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final Token? token;

  // Related asset information returned by marketplace queries.
  final int? assetId;
  final String? assetCode;
  final String? assetType;
  final String? assetName;
  final String? assetDescription;
  final String? assetLocation;
  final String? assetCurrency;

  /// DECIMAL(20,2)
  final String? assetEstimatedValue;

  final String? primaryImageUrl;

  const Listing({
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
    this.token,
    this.assetId,
    this.assetCode,
    this.assetType,
    this.assetName,
    this.assetDescription,
    this.assetLocation,
    this.assetCurrency,
    this.assetEstimatedValue,
    this.primaryImageUrl,
  });

  factory Listing.fromJson(Map<String, dynamic> json) {
    final tokenJson = json['token'];

    return Listing(
      id: _parseInt(json['id']),
      sellerId: _parseInt(json['sellerId']),
      tokenId: _parseInt(json['tokenId']),
      quantity: _decimalString(json['quantity']),
      remainingQuantity: _decimalString(json['remainingQuantity']),
      pricePerToken: _decimalString(json['pricePerToken']),
      currency: json['currency']?.toString() ?? 'KES',
      listingType: json['listingType']?.toString() ?? 'sell',
      status: json['status']?.toString() ?? 'active',
      expiresAt: _parseDateTime(json['expiresAt']),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      token: tokenJson is Map<String, dynamic>
          ? Token.fromJson(tokenJson)
          : null,
      assetId: _nullableInt(json['assetId']),
      assetCode: json['assetCode']?.toString(),
      assetType: json['assetType']?.toString(),
      assetName: json['assetName']?.toString(),
      assetDescription: json['assetDescription']?.toString(),
      assetLocation: json['assetLocation']?.toString(),
      assetCurrency: json['assetCurrency']?.toString(),
      assetEstimatedValue: json['assetEstimatedValue'] == null
          ? null
          : _decimalString(json['assetEstimatedValue']),
      primaryImageUrl: json['primaryImageUrl']?.toString(),
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
      'token': token?.toJson(),
      'assetId': assetId,
      'assetCode': assetCode,
      'assetType': assetType,
      'assetName': assetName,
      'assetDescription': assetDescription,
      'assetLocation': assetLocation,
      'assetCurrency': assetCurrency,
      'assetEstimatedValue': assetEstimatedValue,
      'primaryImageUrl': primaryImageUrl,
    };
  }

  Listing copyWith({
    int? id,
    int? sellerId,
    int? tokenId,
    String? quantity,
    String? remainingQuantity,
    String? pricePerToken,
    String? currency,
    String? listingType,
    String? status,
    DateTime? expiresAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    Token? token,
    int? assetId,
    String? assetCode,
    String? assetType,
    String? assetName,
    String? assetDescription,
    String? assetLocation,
    String? assetCurrency,
    String? assetEstimatedValue,
    String? primaryImageUrl,
  }) {
    return Listing(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      tokenId: tokenId ?? this.tokenId,
      quantity: quantity ?? this.quantity,
      remainingQuantity: remainingQuantity ?? this.remainingQuantity,
      pricePerToken: pricePerToken ?? this.pricePerToken,
      currency: currency ?? this.currency,
      listingType: listingType ?? this.listingType,
      status: status ?? this.status,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      token: token ?? this.token,
      assetId: assetId ?? this.assetId,
      assetCode: assetCode ?? this.assetCode,
      assetType: assetType ?? this.assetType,
      assetName: assetName ?? this.assetName,
      assetDescription: assetDescription ?? this.assetDescription,
      assetLocation: assetLocation ?? this.assetLocation,
      assetCurrency: assetCurrency ?? this.assetCurrency,
      assetEstimatedValue:
          assetEstimatedValue ?? this.assetEstimatedValue,
      primaryImageUrl: primaryImageUrl ?? this.primaryImageUrl,
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
