class WalletSummary {
  final double fiatBalance;
  final double lockedFiatBalance;
  final String currency;
  final double tokenValue;
  final double totalAssetValue;
  final List<TokenHoldingSummary> tokenHoldings;

  const WalletSummary({
    required this.fiatBalance,
    required this.lockedFiatBalance,
    required this.currency,
    required this.tokenValue,
    required this.totalAssetValue,
    required this.tokenHoldings,
  });

  factory WalletSummary.fromJson(Map<String, dynamic> json) {
    return WalletSummary(
      fiatBalance: (json['fiatBalance'] as num?)?.toDouble() ?? 0.0,
      lockedFiatBalance:
          (json['lockedFiatBalance'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'KES',
      tokenValue: (json['tokenValue'] as num?)?.toDouble() ?? 0.0,
      totalAssetValue:
          (json['totalAssetValue'] as num?)?.toDouble() ?? 0.0,
      tokenHoldings: (json['tokenHoldings'] as List<dynamic>? ?? [])
          .map(
            (item) => TokenHoldingSummary.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fiatBalance': fiatBalance,
      'lockedFiatBalance': lockedFiatBalance,
      'currency': currency,
      'tokenValue': tokenValue,
      'totalAssetValue': totalAssetValue,
      'tokenHoldings': tokenHoldings
          .map((holding) => holding.toJson())
          .toList(),
    };
  }
}

class TokenHoldingSummary {
  final int tokenId;
  final String tokenCode;
  final String tokenName;
  final double quantity;
  final double lockedQuantity;
  final double tokenPrice;
  final double currentValue;
  final String currency;

  const TokenHoldingSummary({
    required this.tokenId,
    required this.tokenCode,
    required this.tokenName,
    required this.quantity,
    required this.lockedQuantity,
    required this.tokenPrice,
    required this.currentValue,
    required this.currency,
  });

  factory TokenHoldingSummary.fromJson(Map<String, dynamic> json) {
    return TokenHoldingSummary(
      tokenId: (json['tokenId'] as num?)?.toInt() ?? 0,
      tokenCode: json['tokenCode'] as String? ?? '',
      tokenName: json['tokenName'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      lockedQuantity:
          (json['lockedQuantity'] as num?)?.toDouble() ?? 0.0,
      tokenPrice: (json['tokenPrice'] as num?)?.toDouble() ?? 0.0,
      currentValue:
          (json['currentValue'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'KES',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tokenId': tokenId,
      'tokenCode': tokenCode,
      'tokenName': tokenName,
      'quantity': quantity,
      'lockedQuantity': lockedQuantity,
      'tokenPrice': tokenPrice,
      'currentValue': currentValue,
      'currency': currency,
    };
  }
}