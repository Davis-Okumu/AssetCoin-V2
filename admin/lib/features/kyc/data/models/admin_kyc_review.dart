/// Represents one entry in the KYC review history.
///
/// Maps to the `reviewHistory` array returned by:
/// GET /api/admin/kyc/:id
class AdminKycReview {
  const AdminKycReview({
    required this.id,
    required this.adminId,
    required this.newStatus,
    required this.createdAt,
    this.previousStatus,
    this.comments,
    this.rejectionReason,
    this.adminName,
    this.adminEmail,
  });

  final int id;
  final int adminId;

  final String? previousStatus;
  final String newStatus;

  final String? comments;
  final String? rejectionReason;

  final String? adminName;
  final String? adminEmail;

  final DateTime createdAt;

  // ============================================================
  // DISPLAY HELPERS
  // ============================================================

  String get reviewerName {
    if (adminName != null && adminName!.trim().isNotEmpty) {
      return adminName!.trim();
    }

    if (adminEmail != null && adminEmail!.trim().isNotEmpty) {
      return adminEmail!.trim();
    }

    return 'Admin';
  }

  bool get wasApproved => newStatus == 'verified';

  bool get wasRejected => newStatus == 'rejected';

  bool get requestedChanges => newStatus == 'changes_required';

  bool get startedReview => newStatus == 'under_review';

  // ============================================================
  // JSON
  // ============================================================

  factory AdminKycReview.fromJson(Map<String, dynamic> json) {
    return AdminKycReview(
      id: _parseInt(json['id']),
      adminId: _parseInt(json['adminId']),
      previousStatus: _parseNullableString(json['previousStatus']),
      newStatus: json['newStatus']?.toString() ?? '',
      comments: _parseNullableString(json['comments']),
      rejectionReason: _parseNullableString(json['rejectionReason']),
      adminName: _parseNullableString(json['adminName']),
      adminEmail: _parseNullableString(json['adminEmail']),
      createdAt:
          _parseDateTime(json['createdAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'adminId': adminId,
      'previousStatus': previousStatus,
      'newStatus': newStatus,
      'comments': comments,
      'rejectionReason': rejectionReason,
      'adminName': adminName,
      'adminEmail': adminEmail,
      'createdAt': createdAt.toIso8601String(),
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
