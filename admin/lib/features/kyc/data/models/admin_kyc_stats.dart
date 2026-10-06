/// Statistics displayed on the Admin KYC dashboard.
///
/// Maps to:
/// GET /api/admin/kyc/stats
class AdminKycStats {
  const AdminKycStats({
    required this.total,
    required this.pending,
    required this.underReview,
    required this.changesRequired,
    required this.verified,
    required this.rejected,
  });

  final int total;
  final int pending;
  final int underReview;
  final int changesRequired;
  final int verified;
  final int rejected;

  // ============================================================
  // JSON
  // ============================================================

  factory AdminKycStats.fromJson(Map<String, dynamic> json) {
    return AdminKycStats(
      total: _parseInt(json['total']),
      pending: _parseInt(json['pending']),
      underReview: _parseInt(json['underReview']),
      changesRequired: _parseInt(json['changesRequired']),
      verified: _parseInt(json['verified']),
      rejected: _parseInt(json['rejected']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'pending': pending,
      'underReview': underReview,
      'changesRequired': changesRequired,
      'verified': verified,
      'rejected': rejected,
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
}
