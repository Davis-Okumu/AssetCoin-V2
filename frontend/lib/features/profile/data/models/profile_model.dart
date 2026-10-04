class ProfileModel {
  const ProfileModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.email,
    this.nationalId,
    this.idDocumentUrl,
    this.profilePhotoUrl,
    required this.kycStatus,
    required this.role,
    required this.accountStatus,
    this.lastLoginAt,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String firstName;
  final String lastName;
  final String phone;
  final String? email;
  final String? nationalId;
  final String? idDocumentUrl;
  final String? profilePhotoUrl;
  final String kycStatus;
  final String role;
  final String accountStatus;
  final DateTime? lastLoginAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get fullName {
    final name = '$firstName $lastName'.trim();
    return name.isEmpty ? 'AssetCoin User' : name;
  }

  bool get isKycVerified => kycStatus.toLowerCase() == 'verified';

  bool get isKycPending => kycStatus.toLowerCase() == 'pending';

  bool get isKycRejected => kycStatus.toLowerCase() == 'rejected';

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: _parseInt(json['id']),
      firstName: _parseString(json['firstName']),
      lastName: _parseString(json['lastName']),
      phone: _parseString(json['phone']),
      email: _parseNullableString(json['email']),
      nationalId: _parseNullableString(json['nationalId']),
      idDocumentUrl: _parseNullableString(json['idDocumentUrl']),
      profilePhotoUrl: _parseNullableString(json['profilePhotoUrl']),
      kycStatus: _parseString(
        json['kycStatus'],
        fallback: 'pending',
      ),
      role: _parseString(
        json['role'],
        fallback: 'user',
      ),
      accountStatus: _parseString(
        json['accountStatus'],
        fallback: 'active',
      ),
      lastLoginAt: _parseDateTime(json['lastLoginAt']),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'email': email,
      'nationalId': nationalId,
      'idDocumentUrl': idDocumentUrl,
      'profilePhotoUrl': profilePhotoUrl,
      'kycStatus': kycStatus,
      'role': role,
      'accountStatus': accountStatus,
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  ProfileModel copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? nationalId,
    String? idDocumentUrl,
    String? profilePhotoUrl,
    String? kycStatus,
    String? role,
    String? accountStatus,
    DateTime? lastLoginAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      nationalId: nationalId ?? this.nationalId,
      idDocumentUrl: idDocumentUrl ?? this.idDocumentUrl,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      kycStatus: kycStatus ?? this.kycStatus,
      role: role ?? this.role,
      accountStatus: accountStatus ?? this.accountStatus,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _parseString(
    dynamic value, {
    String fallback = '',
  }) {
    final parsed = value?.toString().trim();

    if (parsed == null || parsed.isEmpty) {
      return fallback;
    }

    return parsed;
  }

  static String? _parseNullableString(dynamic value) {
    final parsed = value?.toString().trim();

    if (parsed == null || parsed.isEmpty || parsed == 'null') {
      return null;
    }

    return parsed;
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