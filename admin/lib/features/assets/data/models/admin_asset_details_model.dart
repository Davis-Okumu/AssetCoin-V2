import '../../domain/admin_asset_record.dart';

class AdminAssetDetailsModel {
  const AdminAssetDetailsModel({
    required this.asset,
    this.photos = const [],
    this.documents = const [],
    this.valuations = const [],
    this.reviews = const [],
    this.statusHistory = const [],
    this.tokens = const [],
  });

  final AdminAssetRecord asset;

  final List<AdminAssetPhoto> photos;
  final List<AdminAssetDocument> documents;
  final List<AdminAssetValuation> valuations;
  final List<AdminAssetReview> reviews;
  final List<AdminAssetStatusHistory> statusHistory;
  final List<AdminAssetToken> tokens;

  factory AdminAssetDetailsModel.fromJson(Map<String, dynamic> json) {
    return AdminAssetDetailsModel(
      asset: AdminAssetRecord.fromJson(json),
      photos: _parseList(json['photos'], AdminAssetPhoto.fromJson),
      documents: _parseList(json['documents'], AdminAssetDocument.fromJson),
      valuations: _parseList(json['valuations'], AdminAssetValuation.fromJson),
      reviews: _parseList(json['reviews'], AdminAssetReview.fromJson),
      statusHistory: _parseList(
        json['statusHistory'],
        AdminAssetStatusHistory.fromJson,
      ),
      tokens: _parseList(json['tokens'], AdminAssetToken.fromJson),
    );
  }

  static List<T> _parseList<T>(
    dynamic value,
    T Function(Map<String, dynamic>) parser,
  ) {
    if (value is! List) {
      return [];
    }

    return value.whereType<Map<String, dynamic>>().map(parser).toList();
  }
}

class AdminAssetPhoto {
  const AdminAssetPhoto({
    required this.id,
    required this.assetId,
    required this.photoUrl,
    this.isPrimary = false,
    this.displayOrder = 0,
    this.createdAt,
  });

  final int id;
  final int assetId;
  final String photoUrl;
  final bool isPrimary;
  final int displayOrder;
  final String? createdAt;

  factory AdminAssetPhoto.fromJson(Map<String, dynamic> json) {
    return AdminAssetPhoto(
      id: _int(json['id']),
      assetId: _int(json['assetId']),
      photoUrl: json['photoUrl']?.toString() ?? '',
      isPrimary:
          json['isPrimary'] == true ||
          json['isPrimary'] == 1 ||
          json['isPrimary']?.toString() == '1',
      displayOrder: _int(json['displayOrder']),
      createdAt: json['createdAt']?.toString(),
    );
  }
}

class AdminAssetDocument {
  const AdminAssetDocument({
    required this.id,
    required this.assetId,
    required this.documentType,
    required this.documentName,
    required this.status,
    this.documentUrl,
    this.documentHash,
    this.verifiedBy,
    this.verifiedAt,
    this.createdAt,
  });

  final int id;
  final int assetId;

  final String documentType;
  final String documentName;
  final String status;

  final String? documentUrl;
  final String? documentHash;

  final int? verifiedBy;
  final String? verifiedAt;
  final String? createdAt;

  factory AdminAssetDocument.fromJson(Map<String, dynamic> json) {
    return AdminAssetDocument(
      id: _int(json['id']),
      assetId: _int(json['assetId']),
      documentType: json['documentType']?.toString() ?? '',
      documentName: json['documentName']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      documentUrl: json['documentUrl']?.toString(),
      documentHash: json['documentHash']?.toString(),
      verifiedBy: _nullableInt(json['verifiedBy']),
      verifiedAt: json['verifiedAt']?.toString(),
      createdAt: json['createdAt']?.toString(),
    );
  }
}

class AdminAssetValuation {
  const AdminAssetValuation({
    required this.id,
    required this.assetId,
    required this.valuationAmount,
    required this.currency,
    required this.valuationMethod,
    required this.status,
    this.valuerName,
    this.valuationDocumentId,
    this.notes,
    this.valuedAt,
    this.createdAt,
  });

  final int id;
  final int assetId;

  final double valuationAmount;
  final String currency;
  final String valuationMethod;
  final String status;

  final String? valuerName;
  final int? valuationDocumentId;
  final String? notes;

  final String? valuedAt;
  final String? createdAt;

  factory AdminAssetValuation.fromJson(Map<String, dynamic> json) {
    return AdminAssetValuation(
      id: _int(json['id']),
      assetId: _int(json['assetId']),
      valuationAmount: _double(json['valuationAmount']),
      currency: json['currency']?.toString() ?? 'KES',
      valuationMethod: json['valuationMethod']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      valuerName: json['valuerName']?.toString(),
      valuationDocumentId: _nullableInt(json['valuationDocumentId']),
      notes: json['notes']?.toString(),
      valuedAt: json['valuedAt']?.toString(),
      createdAt: json['createdAt']?.toString(),
    );
  }
}

class AdminAssetReview {
  const AdminAssetReview({
    required this.id,
    required this.assetId,
    required this.adminId,
    required this.decision,
    this.comments,
    this.createdAt,
    this.admin,
  });

  final int id;
  final int assetId;
  final int adminId;

  final String decision;
  final String? comments;
  final String? createdAt;

  final AdminAssetReviewAdmin? admin;

  factory AdminAssetReview.fromJson(Map<String, dynamic> json) {
    final adminJson = json['admin'];

    return AdminAssetReview(
      id: _int(json['id']),
      assetId: _int(json['assetId']),
      adminId: _int(json['adminId']),
      decision: json['decision']?.toString() ?? '',
      comments: json['comments']?.toString(),
      createdAt: json['createdAt']?.toString(),
      admin: adminJson is Map<String, dynamic>
          ? AdminAssetReviewAdmin.fromJson(adminJson)
          : null,
    );
  }
}

class AdminAssetReviewAdmin {
  const AdminAssetReviewAdmin({
    required this.id,
    this.firstName,
    this.lastName,
    this.email,
  });

  final int id;
  final String? firstName;
  final String? lastName;
  final String? email;

  String get fullName {
    final parts = [firstName, lastName]
        .where((value) => value != null && value.trim().isNotEmpty)
        .map((value) => value!.trim())
        .toList();

    return parts.isEmpty ? 'Administrator' : parts.join(' ');
  }

  factory AdminAssetReviewAdmin.fromJson(Map<String, dynamic> json) {
    return AdminAssetReviewAdmin(
      id: _int(json['id']),
      firstName: json['firstName']?.toString(),
      lastName: json['lastName']?.toString(),
      email: json['email']?.toString(),
    );
  }
}

class AdminAssetStatusHistory {
  const AdminAssetStatusHistory({
    required this.id,
    required this.assetId,
    this.previousStatus,
    required this.newStatus,
    this.changedBy,
    this.changeReason,
    this.createdAt,
    this.administrator,
  });

  final int id;
  final int assetId;

  final String? previousStatus;
  final String newStatus;

  final int? changedBy;
  final String? changeReason;
  final String? createdAt;

  final AdminAssetReviewAdmin? administrator;

  factory AdminAssetStatusHistory.fromJson(Map<String, dynamic> json) {
    final adminJson = json['administrator'];

    return AdminAssetStatusHistory(
      id: _int(json['id']),
      assetId: _int(json['assetId']),
      previousStatus: json['previousStatus']?.toString(),
      newStatus: json['newStatus']?.toString() ?? '',
      changedBy: _nullableInt(json['changedBy']),
      changeReason: json['changeReason']?.toString(),
      createdAt: json['createdAt']?.toString(),
      administrator: adminJson is Map<String, dynamic>
          ? AdminAssetReviewAdmin.fromJson(adminJson)
          : null,
    );
  }
}

class AdminAssetToken {
  const AdminAssetToken({
    required this.id,
    required this.assetId,
    required this.tokenCode,
    required this.tokenName,
    this.description,
    this.totalSupply,
    this.availableSupply,
    this.tokenPrice,
    this.currency,
    this.decimals,
    this.status,
    this.mintedAt,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final int assetId;

  final String tokenCode;
  final String tokenName;

  final String? description;

  final double? totalSupply;
  final double? availableSupply;
  final double? tokenPrice;

  final String? currency;
  final int? decimals;

  final String? status;

  final String? mintedAt;
  final String? createdAt;
  final String? updatedAt;

  factory AdminAssetToken.fromJson(Map<String, dynamic> json) {
    return AdminAssetToken(
      id: _int(json['id']),
      assetId: _int(json['assetId']),
      tokenCode: json['tokenCode']?.toString() ?? '',
      tokenName: json['tokenName']?.toString() ?? '',
      description: json['description']?.toString(),
      totalSupply: _nullableDouble(json['totalSupply']),
      availableSupply: _nullableDouble(json['availableSupply']),
      tokenPrice: _nullableDouble(json['tokenPrice']),
      currency: json['currency']?.toString(),
      decimals: _nullableInt(json['decimals']),
      status: json['status']?.toString(),
      mintedAt: json['mintedAt']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }
}

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

double _double(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(value?.toString() ?? '') ?? 0;
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
