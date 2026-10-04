
import 'token.dart';

class TokenHolding {
  final int id;
  final int userId;
  final int tokenId;

  /// DECIMAL(30,8)
  final String quantity;

  /// DECIMAL(30,8)
  final String lockedQuantity;

  /// DECIMAL(20,8)
  final String? averageBuyPrice;

  /// DECIMAL(20,2)
  final String? totalInvested;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final Token? token;

  const TokenHolding({
    required this.id,
    required this.userId,
    required this.tokenId,
    required this.quantity,
    required this.lockedQuantity,
    this.averageBuyPrice,
    this.totalInvested,
    this.createdAt,
    this.updatedAt,
    this.token,
  });

  factory TokenHolding.fromJson(Map<String, dynamic> json) {
    final tokenJson = json['token'];

    return TokenHolding(
      id: _parseInt(json['id']),
      userId: _parseInt(json['userId']),
      tokenId: _parseInt(json['tokenId']),
      quantity: _decimalString(json['quantity']),
      lockedQuantity: _decimalString(json['lockedQuantity']),
      averageBuyPrice: json['averageBuyPrice'] == null
          ? null
          : _decimalString(json['averageBuyPrice']),
      totalInvested: json['totalInvested'] == null
          ? null
          : _decimalString(json['totalInvested']),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      token: tokenJson is Map<String, dynamic>
          ? Token.fromJson(tokenJson)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'tokenId': tokenId,
      'quantity': quantity,
      'lockedQuantity': lockedQuantity,
      'averageBuyPrice': averageBuyPrice,
      'totalInvested': totalInvested,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'token': token?.toJson(),
    };
  }

  TokenHolding copyWith({
    int? id,
    int? userId,
    int? tokenId,
    String? quantity,
    String? lockedQuantity,
    String? averageBuyPrice,
    String? totalInvested,
    DateTime? createdAt,
    DateTime? updatedAt,
    Token? token,
  }) {
    return TokenHolding(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tokenId: tokenId ?? this.tokenId,
      quantity: quantity ?? this.quantity,
      lockedQuantity: lockedQuantity ?? this.lockedQuantity,
      averageBuyPrice: averageBuyPrice ?? this.averageBuyPrice,
      totalInvested: totalInvested ?? this.totalInvested,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      token: token ?? this.token,
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
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
