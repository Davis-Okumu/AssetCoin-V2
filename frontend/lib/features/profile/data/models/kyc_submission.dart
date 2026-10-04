class KycSubmission {
  final int id;
  final String status;
  final String? rejectionReason;
  final String? verificationMethod;
  final DateTime? submittedAt;
  final DateTime? verifiedAt;

  const KycSubmission({
    required this.id,
    required this.status,
    this.rejectionReason,
    this.verificationMethod,
    this.submittedAt,
    this.verifiedAt,
  });

  factory KycSubmission.fromJson(
    Map<String, dynamic> json,
  ) {
    return KycSubmission(
      id: _parseInt(json['id']) ?? 0,
      status: json['status']?.toString() ?? 'pending',
      rejectionReason: _nullableString(
        json['rejectionReason'],
      ),
      verificationMethod: _nullableString(
        json['verificationMethod'],
      ),
      submittedAt: _parseDate(json['submittedAt']),
      verifiedAt: _parseDate(json['verifiedAt']),
    );
  }

  bool get isVerified =>
      status.toLowerCase() == 'verified';

  bool get isRejected =>
      status.toLowerCase() == 'rejected';

  bool get isPending =>
      status.toLowerCase() == 'pending';

  bool get isUnderReview =>
      status.toLowerCase() == 'under_review';

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