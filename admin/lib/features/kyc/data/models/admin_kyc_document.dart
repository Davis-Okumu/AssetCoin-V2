class AdminKycDocument {
  const AdminKycDocument({required this.type, required this.url, this.label});

  final String type;
  final String url;
  final String? label;

  String get displayName {
    if (label != null && label!.trim().isNotEmpty) {
      return label!;
    }

    switch (type) {
      case 'id':
        return 'National ID';
      case 'selfie':
        return 'Selfie';
      default:
        return 'KYC Document';
    }
  }

  factory AdminKycDocument.fromJson(Map<String, dynamic> json) {
    return AdminKycDocument(
      type: json['type']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      label: json['label']?.toString(),
    );
  }
}
