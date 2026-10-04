
class WalletSummary {
  final double fiatBalance;
  final double tokenBalance;
  final double tokenValue;
  final double totalAssetValue;
  final String currency;

  const WalletSummary({
    required this.fiatBalance,
    required this.tokenBalance,
    required this.tokenValue,
    required this.totalAssetValue,
    required this.currency,
  });

  factory WalletSummary.fromJson(Map<String, dynamic> json) {
    return WalletSummary(
      fiatBalance: (json['fiatBalance'] as num?)?.toDouble() ?? 0.0,
      tokenBalance: (json['tokenBalance'] as num?)?.toDouble() ?? 0.0,
      tokenValue: (json['tokenValue'] as num?)?.toDouble() ?? 0.0,
      totalAssetValue:
          (json['totalAssetValue'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'KES',
    );
  }
}