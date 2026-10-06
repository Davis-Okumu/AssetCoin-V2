/// Represents a KYC application as viewed by an administrator.
///
/// This model maps the application data returned by:
/// GET /api/admin/kyc
/// GET /api/admin/kyc/:id
///
/// The list endpoint additionally includes assignment information,
/// so those optional fields are included here as well.
class AdminKycApplication {
  const AdminKycApplication({
    required this.id,
    required this.userId,
    required this.nationalId,
    required this.verificationMethod,
    required this.status,
    required this.submittedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.idDocumentUrl,
    this.selfieUrl,
    this.profilePhotoUrl,
    this.rejectionReason,
    this.verifiedBy,
    this.verifiedAt,
    this.assignmentId,
    this.assignedTo,
    this.assignmentStatus,
    this.assignmentPriority,
    this.assignedAt,
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

  // ============================================================
  // APPLICANT INFORMATION
  // ============================================================

  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? profilePhotoUrl;

  // ============================================================
  // ASSIGNMENT INFORMATION
  // ============================================================

  final int? assignmentId;
  final int? assignedTo;
  final String? assignmentStatus;
  final String? assignmentPriority;
  final DateTime? assignedAt;

  // ============================================================
  // DISPLAY HELPERS
  // ============================================================

  String get applicantName {
    final name = '$firstName $lastName'.trim();

    if (name.isEmpty) {
      return 'Unknown Applicant';
    }

    return name;
  }

  bool get isPending => status == 'pending';

  bool get isUnderReview => status == 'under_review';

  bool get requiresChanges => status == 'changes_required';

  bool get isVerified => status == 'verified';

  bool get isRejected => status == 'rejected';

  bool get isAssigned => assignmentId != null;

  bool get hasIdDocument =>
      idDocumentUrl != null && idDocumentUrl!.trim().isNotEmpty;

  bool get hasSelfie => selfieUrl != null && selfieUrl!.trim().isNotEmpty;

  // ============================================================
  // JSON
  // ============================================================

  factory AdminKycApplication.fromJson(Map<String, dynamic> json) {
    return AdminKycApplication(
      id: _parseInt(json['id']),
      userId: _parseInt(json['userId']),
      nationalId: json['nationalId']?.toString() ?? '',
      idDocumentUrl: _parseNullableString(json['idDocumentUrl']),
      selfieUrl: _parseNullableString(json['selfieUrl']),
      verificationMethod: json['verificationMethod']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      rejectionReason: _parseNullableString(json['rejectionReason']),
      verifiedBy: _parseNullableInt(json['verifiedBy']),
      verifiedAt: _parseDateTime(json['verifiedAt']),
      submittedAt:
          _parseDateTime(json['submittedAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      createdAt:
          _parseDateTime(json['createdAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt:
          _parseDateTime(json['updatedAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      profilePhotoUrl: _parseNullableString(json['profilePhotoUrl']),
      assignmentId: _parseNullableInt(json['assignmentId']),
      assignedTo: _parseNullableInt(json['assignedTo']),
      assignmentStatus: _parseNullableString(json['assignmentStatus']),
      assignmentPriority: _parseNullableString(json['assignmentPriority']),
      assignedAt: _parseDateTime(json['assignedAt']),
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
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'profilePhotoUrl': profilePhotoUrl,
      'assignmentId': assignmentId,
      'assignedTo': assignedTo,
      'assignmentStatus': assignmentStatus,
      'assignmentPriority': assignmentPriority,
      'assignedAt': assignedAt?.toIso8601String(),
    };
  }

  // ============================================================
  // PARSING HELPERS
  // ============================================================

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

  static String? _parseNullableString(dynamic value) {
    if (value == null) {
      return null;
    }

    final valueString = value.toString().trim();

    if (valueString.isEmpty) {
      return null;
    }

    return valueString;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.tryParse(value.toString());
  }
}
