class KycRecordModel {
  const KycRecordModel({
    required this.id,
    required this.userId,
    required this.nationalId,
    required this.verificationMethod,
    required this.status,
    required this.submittedAt,
    required this.createdAt,
    required this.updatedAt,
    this.idDocumentUrl,
    this.selfieUrl,
    this.rejectionReason,
    this.verifiedBy,
    this.verifiedAt,
  });

  final int id;
  final int userId;
  final String nationalId;
  final String? idDocumentUrl;
  final String? selfieUrl;
  final String verificationMethod;
  final String status;
  final String? rejectionReason;
  final int? verifiedBy;
  final DateTime? verifiedAt;
  final DateTime submittedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory KycRecordModel.fromJson(Map<String, dynamic> json) {
    return KycRecordModel(
      id: _parseInt(json['id']),
      userId: _parseInt(json['userId']),
      nationalId: json['nationalId']?.toString() ?? '',
      idDocumentUrl: json['idDocumentUrl']?.toString(),
      selfieUrl: json['selfieUrl']?.toString(),
      verificationMethod: json['verificationMethod']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      rejectionReason: json['rejectionReason']?.toString(),
      verifiedBy: _parseNullableInt(json['verifiedBy']),
      verifiedAt: _parseNullableDateTime(json['verifiedAt']),
      submittedAt: _parseDateTime(json['submittedAt']),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'nationalId': nationalId,
      'idDocumentUrl': idDocumentUrl,
      'selfieUrl': selfieUrl,
      'verificationMethod': verificationMethod,
      'status': status,
      'rejectionReason': rejectionReason,
      'verifiedBy': verifiedBy,
      'verifiedAt': verifiedAt?.toIso8601String(),
      'submittedAt': submittedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value.toString());
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) {
      return value;
    }

    return DateTime.tryParse(value?.toString() ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  static DateTime? _parseNullableDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.tryParse(value.toString());
  }
}
