
class AssetSubmission {
  const AssetSubmission({
    required this.id,
    required this.assetCode,
    required this.assetType,
    required this.name,
    required this.status,
    required this.estimatedValue,
    required this.currency,
    this.location,
    this.rejectionReason,
    this.primaryPhoto,
    this.createdAt,
  });

  final int id;
  final String assetCode;
  final String assetType;
  final String name;
  final String status;
  final double estimatedValue;
  final String currency;
  final String? location;
  final String? rejectionReason;
  final String? primaryPhoto;
  final DateTime? createdAt;

  String get displayStatus {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';

      case 'under_review':
        return 'Under Review';

      case 'changes_required':
        return 'Changes Required';

      case 'approved':
        return 'Approved';

      case 'rejected':
        return 'Rejected';

      case 'tokenized':
        return 'Tokenized';

      case 'suspended':
        return 'Suspended';

      default:
        return status;
    }
  }

  factory AssetSubmission.fromJson(Map<String, dynamic> json) {
    return AssetSubmission(
      id: _toInt(json['id']),
      assetCode: json['assetCode']?.toString() ?? '',
      assetType: json['assetType']?.toString() ?? 'other',
      name: json['name']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      estimatedValue: _toDouble(json['estimatedValue']),
      currency: json['currency']?.toString() ?? 'KES',
      location: json['location']?.toString(),
      rejectionReason: json['rejectionReason']?.toString(),
      primaryPhoto: json['primaryPhoto']?.toString(),
      createdAt: _toDateTime(json['createdAt']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;

    if (value is num) return value.toInt();

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;

    return DateTime.tryParse(value.toString());
  }
}