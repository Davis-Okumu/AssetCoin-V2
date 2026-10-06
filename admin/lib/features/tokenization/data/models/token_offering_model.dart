class TokenOfferingModel {
  const TokenOfferingModel({
    required this.id,
    required this.offeringReference,
    required this.proposalId,
    required this.tokenId,
    required this.status,
    required this.offeringSupply,
    required this.pricePerToken,
    required this.currency,
    required this.tokensSold,
    required this.totalRaised,
    this.tokenCode,
    this.proposalReference,
    this.tokenName,
    this.offeringStartAt,
    this.offeringEndAt,
    this.minimumPurchaseQuantity,
    this.maximumPurchaseQuantity,
    this.activatedAt,
    this.completedAt,
  });

  final int id;
  final String offeringReference;

  final int proposalId;
  final int tokenId;

  final String status;

  final double offeringSupply;
  final double pricePerToken;

  final String currency;

  final double tokensSold;
  final double totalRaised;

  final String? tokenCode;
  final String? proposalReference;
  final String? tokenName;

  final DateTime? offeringStartAt;
  final DateTime? offeringEndAt;

  final double? minimumPurchaseQuantity;
  final double? maximumPurchaseQuantity;

  final DateTime? activatedAt;
  final DateTime? completedAt;

  bool get canResume => status == 'paused' || status == 'suspended';

  factory TokenOfferingModel.fromJson(Map<String, dynamic> json) {
    return TokenOfferingModel(
      id: _toInt(json['id']),
      offeringReference: json['offeringReference']?.toString() ?? '',
      proposalId: _toInt(json['proposalId']),
      tokenId: _toInt(json['tokenId']),
      status: json['status']?.toString() ?? '',
      offeringSupply: _toDouble(json['offeringSupply']) ?? 0,
      pricePerToken: _toDouble(json['pricePerToken']) ?? 0,
      currency: json['currency']?.toString() ?? 'KES',
      tokensSold: _toDouble(json['tokensSold']) ?? 0,
      totalRaised: _toDouble(json['totalRaised']) ?? 0,
      tokenCode: json['tokenCode']?.toString(),
      proposalReference: json['proposalReference']?.toString(),
      tokenName: json['tokenName']?.toString(),
      offeringStartAt: _toDate(json['offeringStartAt']),
      offeringEndAt: _toDate(json['offeringEndAt']),
      minimumPurchaseQuantity: _toDouble(json['minimumPurchaseQuantity']),
      maximumPurchaseQuantity: _toDouble(json['maximumPurchaseQuantity']),
      activatedAt: _toDate(json['activatedAt']),
      completedAt: _toDate(json['completedAt']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();

    return double.tryParse(value.toString());
  }

  static DateTime? _toDate(dynamic value) {
    if (value == null) return null;

    return DateTime.tryParse(value.toString());
  }
}
