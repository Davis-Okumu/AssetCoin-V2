class AdminAssetRecord {
  const AdminAssetRecord({
    required this.id,
    required this.ownerId,
    required this.assetCode,
    required this.assetType,
    required this.name,
    required this.status,
    required this.currency,
    required this.createdAt,
    this.description,
    this.location,
    this.latitude,
    this.longitude,
    this.registrationNumber,
    this.estimatedValue,
    this.rejectionReason,
    this.approvedBy,
    this.approvedAt,
    this.reviewedBy,
    this.reviewedAt,
    this.reviewNotes,
    this.updatedAt,
    this.owner,
    this.reviewSummary,
    this.tokenSummary,
  });

  final int id;
  final int ownerId;

  final String assetCode;
  final String assetType;
  final String name;

  final String status;
  final String currency;

  final String? description;
  final String? location;

  final double? latitude;
  final double? longitude;

  final String? registrationNumber;

  final double? estimatedValue;

  final String? rejectionReason;

  final int? approvedBy;
  final String? approvedAt;

  final int? reviewedBy;
  final String? reviewedAt;

  final String? reviewNotes;

  final String createdAt;
  final String? updatedAt;

  final AdminAssetOwner? owner;

  final AdminAssetReviewSummary? reviewSummary;

  final AdminAssetTokenSummary? tokenSummary;

  // =========================================================
  // JSON
  // =========================================================

  factory AdminAssetRecord.fromJson(Map<String, dynamic> json) {
    final ownerJson = json['owner'];
    final reviewSummaryJson = json['reviewSummary'];
    final tokenSummaryJson = json['tokenSummary'];

    return AdminAssetRecord(
      id: _int(json['id']),
      ownerId: _int(json['ownerId']),
      assetCode: json['assetCode']?.toString() ?? '',
      assetType: json['assetType']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      currency: json['currency']?.toString() ?? 'KES',
      description: json['description']?.toString(),
      location: json['location']?.toString(),
      latitude: _nullableDouble(json['latitude']),
      longitude: _nullableDouble(json['longitude']),
      registrationNumber: json['registrationNumber']?.toString(),
      estimatedValue: _nullableDouble(json['estimatedValue']),
      rejectionReason: json['rejectionReason']?.toString(),
      approvedBy: _nullableInt(json['approvedBy']),
      approvedAt: json['approvedAt']?.toString(),
      reviewedBy: _nullableInt(json['reviewedBy']),
      reviewedAt: json['reviewedAt']?.toString(),
      reviewNotes: json['reviewNotes']?.toString(),
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString(),
      owner: ownerJson is Map<String, dynamic>
          ? AdminAssetOwner.fromJson(ownerJson)
          : null,
      reviewSummary: reviewSummaryJson is Map<String, dynamic>
          ? AdminAssetReviewSummary.fromJson(reviewSummaryJson)
          : null,
      tokenSummary: tokenSummaryJson is Map<String, dynamic>
          ? AdminAssetTokenSummary.fromJson(tokenSummaryJson)
          : null,
    );
  }

  String get ownerName {
    if (owner == null) {
      return 'Unknown owner';
    }

    final name = [
      owner!.firstName ?? '',
      owner!.lastName ?? '',
    ].where((value) => value.isNotEmpty).join(' ');

    return name.isEmpty ? 'Unknown owner' : name;
  }

  bool get isPending =>
      status == 'pending' ||
      status == 'under_review' ||
      status == 'changes_required';

  bool get isApproved => status == 'approved';

  bool get isRejected => status == 'rejected';

  bool get isTokenized => status == 'tokenized';

  bool get isSuspended => status == 'suspended';
}

// =========================================================
// OWNER
// =========================================================

class AdminAssetOwner {
  const AdminAssetOwner({
    required this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.kycStatus,
  });

  final int id;

  final String? firstName;
  final String? lastName;

  final String? email;
  final String? phone;

  final String? kycStatus;

  factory AdminAssetOwner.fromJson(Map<String, dynamic> json) {
    return AdminAssetOwner(
      id: _int(json['id']),
      firstName: json['firstName']?.toString(),
      lastName: json['lastName']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      kycStatus: json['kycStatus']?.toString(),
    );
  }
}

// =========================================================
// REVIEW SUMMARY
// =========================================================

class AdminAssetReviewSummary {
  const AdminAssetReviewSummary({
    this.reviewCount = 0,
    this.latestDecision,
    this.latestReviewAt,
  });

  final int reviewCount;

  final String? latestDecision;
  final String? latestReviewAt;

  factory AdminAssetReviewSummary.fromJson(Map<String, dynamic> json) {
    return AdminAssetReviewSummary(
      reviewCount: _int(json['reviewCount']),
      latestDecision: json['latestDecision']?.toString(),
      latestReviewAt: json['latestReviewAt']?.toString(),
    );
  }
}

// =========================================================
// TOKEN SUMMARY
// =========================================================

class AdminAssetTokenSummary {
  const AdminAssetTokenSummary({
    this.tokenCount = 0,
    this.tokenCode,
    this.tokenName,
    this.totalSupply,
    this.availableSupply,
    this.tokenPrice,
    this.tokenCurrency,
    this.tokenStatus,
  });

  final int tokenCount;

  final String? tokenCode;
  final String? tokenName;

  final double? totalSupply;
  final double? availableSupply;

  final double? tokenPrice;
  final String? tokenCurrency;

  final String? tokenStatus;

  factory AdminAssetTokenSummary.fromJson(Map<String, dynamic> json) {
    return AdminAssetTokenSummary(
      tokenCount: _int(json['tokenCount']),
      tokenCode: json['tokenCode']?.toString(),
      tokenName: json['tokenName']?.toString(),
      totalSupply: _nullableDouble(json['totalSupply']),
      availableSupply: _nullableDouble(json['availableSupply']),
      tokenPrice: _nullableDouble(json['tokenPrice']),
      tokenCurrency: json['tokenCurrency']?.toString(),
      tokenStatus: json['tokenStatus']?.toString(),
    );
  }
}

// =========================================================
// HELPERS
// =========================================================

int _int(dynamic value) {
  if (value is int) {
    return value;
  }

  return int.tryParse(value?.toString() ?? '') ?? 0;
}

int? _nullableInt(dynamic value) {
  if (value == null) {
    return null;
  }

  return int.tryParse(value.toString());
}

double? _nullableDouble(dynamic value) {
  if (value == null) {
    return null;
  }

  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(value.toString());
}
