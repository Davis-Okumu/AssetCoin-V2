
class Token {
  final int id;
  final int assetId;
  final String tokenCode;
  final String tokenName;
  final String? description;

  /// DECIMAL(30,8)
  final String totalSupply;

  /// DECIMAL(30,8)
  final String availableSupply;

  /// DECIMAL(20,8)
  final String tokenPrice;

  final String currency;
  final int decimals;
  final String status;
  final DateTime? mintedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Token({
    required this.id,
    required this.assetId,
    required this.tokenCode,
    required this.tokenName,
    this.description,
    required this.totalSupply,
    required this.availableSupply,
    required this.tokenPrice,
    required this.currency,
    required this.decimals,
    required this.status,
    this.mintedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      id: _parseInt(json['id']),
      assetId: _parseInt(json['assetId']),
      tokenCode: json['tokenCode']?.toString() ?? '',
      tokenName: json['tokenName']?.toString() ?? '',
      description: json['description']?.toString(),
      totalSupply: _decimalString(json['totalSupply']),
      availableSupply: _decimalString(json['availableSupply']),
      tokenPrice: _decimalString(json['tokenPrice']),
      currency: json['currency']?.toString() ?? 'KES',
      decimals: _parseInt(json['decimals'], fallback: 8),
      status: json['status']?.toString() ?? 'pending',
      mintedAt: _parseDateTime(json['mintedAt']),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assetId': assetId,
      'tokenCode': tokenCode,
      'tokenName': tokenName,
      'description': description,
      'totalSupply': totalSupply,
      'availableSupply': availableSupply,
      'tokenPrice': tokenPrice,
      'currency': currency,
      'decimals': decimals,
      'status': status,
      'mintedAt': mintedAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Token copyWith({
    int? id,
    int? assetId,
    String? tokenCode,
    String? tokenName,
    String? description,
    String? totalSupply,
    String? availableSupply,
    String? tokenPrice,
    String? currency,
    int? decimals,
    String? status,
    DateTime? mintedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Token(
      id: id ?? this.id,
      assetId: assetId ?? this.assetId,
      tokenCode: tokenCode ?? this.tokenCode,
      tokenName: tokenName ?? this.tokenName,
      description: description ?? this.description,
      totalSupply: totalSupply ?? this.totalSupply,
      availableSupply: availableSupply ?? this.availableSupply,
      tokenPrice: tokenPrice ?? this.tokenPrice,
      currency: currency ?? this.currency,
      decimals: decimals ?? this.decimals,
      status: status ?? this.status,
      mintedAt: mintedAt ?? this.mintedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static int _parseInt(
    dynamic value, {
    int fallback = 0,
  }) {
    if (value == null) {
      return fallback;
    }

    if (value is int) {
      return value;
    }

    return int.tryParse(value.toString()) ?? fallback;
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

