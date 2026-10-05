class AdminUserRecord {
  const AdminUserRecord({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.kycStatus,
    required this.role,
    required this.accountStatus,
    this.profilePhotoUrl,
    this.lastLoginAt,
    this.createdAt,
    this.updatedAt,
  });

  final int id;

  final String firstName;

  final String lastName;

  final String fullName;

  final String? email;

  final String? phone;

  final String? profilePhotoUrl;

  final String kycStatus;

  final String role;

  final String accountStatus;

  final DateTime? lastLoginAt;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  bool get isActive => accountStatus == 'active';

  bool get isSuspended => accountStatus == 'suspended';

  bool get isDeactivated => accountStatus == 'deactivated';

  bool get isDeleted => accountStatus == 'deleted';

  bool get isKycPending => kycStatus == 'pending';

  bool get isKycVerified => kycStatus == 'verified';

  bool get isKycRejected => kycStatus == 'rejected';

  String get displayName {
    if (fullName.trim().isNotEmpty) {
      return fullName.trim();
    }

    final name = '$firstName $lastName'.trim();

    if (name.isNotEmpty) {
      return name;
    }

    return email ?? 'User #$id';
  }

  String get initials {
    final first = firstName.trim();
    final last = lastName.trim();

    if (first.isNotEmpty && last.isNotEmpty) {
      return '${first[0]}${last[0]}'.toUpperCase();
    }

    if (first.isNotEmpty) {
      return first[0].toUpperCase();
    }

    if (last.isNotEmpty) {
      return last[0].toUpperCase();
    }

    if (email != null && email!.trim().isNotEmpty) {
      return email!.trim()[0].toUpperCase();
    }

    return 'U';
  }
}
