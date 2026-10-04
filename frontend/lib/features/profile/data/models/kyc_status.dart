class KycStatus {
  final String status;
  final String? rejectionReason;
  final String? verificationMethod;
  final DateTime? submittedAt;
  final DateTime? verifiedAt;
  final int? submissionId;

  const KycStatus({
    required this.status,
    this.rejectionReason,
    this.verificationMethod,
    this.submittedAt,
    this.verifiedAt,
    this.submissionId,
  });

  factory KycStatus.fromJson(Map<String, dynamic> json) {
    return KycStatus(
      status: json['status']?.toString() ?? 'pending',
      rejectionReason: _nullableString(
        json['rejectionReason'],
      ),
      verificationMethod: _nullableString(
        json['verificationMethod'],
      ),
      submittedAt: _parseDate(json['submittedAt']),
      verifiedAt: _parseDate(json['verifiedAt']),
      submissionId: _parseInt(json['submissionId']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'rejectionReason': rejectionReason,
      'verificationMethod': verificationMethod,
      'submittedAt': submittedAt?.toIso8601String(),
      'verifiedAt': verifiedAt?.toIso8601String(),
      'submissionId': submissionId,
    };
  }

  bool get isPending =>
      status.toLowerCase() == 'pending';

  bool get isUnderReview =>
      status.toLowerCase() == 'under_review';

  bool get isVerified =>
      status.toLowerCase() == 'verified';

  bool get isRejected =>
      status.toLowerCase() == 'rejected';

  bool get isProcessing =>
      isPending || isUnderReview;

  String get readableStatus {
    switch (status.toLowerCase()) {
      case 'verified':
        return 'Verified';
      case 'rejected':
        return 'Rejected';
      case 'under_review':
        return 'Under Review';
      case 'pending':
        return 'Pending';
      default:
        return status
            .replaceAll('_', ' ')
            .split(' ')
            .map(
              (word) => word.isEmpty
                  ? word
                  : '${word[0].toUpperCase()}${word.substring(1)}',
            )
            .join(' ');
    }
  }

  KycStatus copyWith({
    String? status,
    String? rejectionReason,
    String? verificationMethod,
    DateTime? submittedAt,
    DateTime? verifiedAt,
    int? submissionId,
  }) {
    return KycStatus(
      status: status ?? this.status,
      rejectionReason:
          rejectionReason ?? this.rejectionReason,
      verificationMethod:
          verificationMethod ?? this.verificationMethod,
      submittedAt: submittedAt ?? this.submittedAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      submissionId:
          submissionId ?? this.submissionId,
    );
  }

  static String? _nullableString(dynamic value) {
    if (value == null) return null;

    final string = value.toString().trim();

    return string.isEmpty ? null : string;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;

    return DateTime.tryParse(value.toString());
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;

    return int.tryParse(value.toString());
  }
}