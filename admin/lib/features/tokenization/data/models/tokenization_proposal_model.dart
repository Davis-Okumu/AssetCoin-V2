class TokenizationProposalModel {
  const TokenizationProposalModel({
    required this.id,
    required this.proposalReference,
    required this.assetId,
    required this.assetCode,
    required this.assetName,
    required this.assetType,
    required this.status,
    this.proposedTokenName,
    this.proposedTokenCode,
    this.totalSupply,
    this.offeringSupply,
    this.initialTokenPrice,
    this.currency,
    this.minimumPurchaseQuantity,
    this.maximumPurchaseQuantity,
    this.offeringStartAt,
    this.offeringEndAt,
    this.description,
    this.reviewNotes,
    this.rejectionReason,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String proposalReference;

  final int assetId;
  final String assetCode;
  final String assetName;
  final String assetType;

  final String status;

  final String? proposedTokenName;
  final String? proposedTokenCode;

  final double? totalSupply;
  final double? offeringSupply;
  final double? initialTokenPrice;

  final String? currency;

  final double? minimumPurchaseQuantity;
  final double? maximumPurchaseQuantity;

  final DateTime? offeringStartAt;
  final DateTime? offeringEndAt;

  final String? description;
  final String? reviewNotes;
  final String? rejectionReason;

  final int? createdBy;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory TokenizationProposalModel.fromJson(Map<String, dynamic> json) {
    return TokenizationProposalModel(
      id: _toInt(json['id']),
      proposalReference: json['proposalReference']?.toString() ?? '',
      assetId: _toInt(json['assetId']),
      assetCode: json['assetCode']?.toString() ?? '',
      assetName: json['assetName']?.toString() ?? '',
      assetType: json['assetType']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      proposedTokenName: json['proposedTokenName']?.toString(),
      proposedTokenCode: json['proposedTokenCode']?.toString(),
      totalSupply: _toDouble(json['totalSupply']),
      offeringSupply: _toDouble(json['offeringSupply']),
      initialTokenPrice: _toDouble(json['initialTokenPrice']),
      currency: json['currency']?.toString(),
      minimumPurchaseQuantity: _toDouble(json['minimumPurchaseQuantity']),
      maximumPurchaseQuantity: _toDouble(json['maximumPurchaseQuantity']),
      offeringStartAt: _toDate(json['offeringStartAt']),
      offeringEndAt: _toDate(json['offeringEndAt']),
      description: json['description']?.toString(),
      reviewNotes: json['reviewNotes']?.toString(),
      rejectionReason: json['rejectionReason']?.toString(),
      createdBy: json['createdBy'] == null ? null : _toInt(json['createdBy']),
      createdAt: _toDate(json['createdAt']),
      updatedAt: _toDate(json['updatedAt']),
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
