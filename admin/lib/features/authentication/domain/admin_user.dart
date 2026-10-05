class AdminUser {
  const AdminUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    this.phone,
    this.profilePhotoUrl,
    this.isActive = true,
    this.permissions = const [],
  });

  final int id;

  final String firstName;

  final String lastName;

  final String email;

  final String role;

  final String? phone;

  final String? profilePhotoUrl;

  final bool isActive;

  final List<String> permissions;

  String get fullName {
    final name = '$firstName $lastName'.trim();

    return name.isEmpty ? email : name;
  }

  String get initials {
    final first =
        firstName.trim().isNotEmpty ? firstName.trim()[0] : '';

    final last =
        lastName.trim().isNotEmpty ? lastName.trim()[0] : '';

    if (first.isEmpty && last.isEmpty) {
      return email.isNotEmpty
          ? email.substring(0, 1).toUpperCase()
          : 'A';
    }

    return '$first$last'.toUpperCase();
  }

  bool hasPermission(String permission) {
    return permissions.contains(permission);
  }

  bool get isSuperAdministrator {
    return role == 'super_admin';
  }

  bool get isAssetOfficer {
    return role == 'asset_officer';
  }

  bool get isKycOfficer {
    return role == 'kyc_officer';
  }

  bool get isTokenizationOfficer {
    return role == 'tokenization_officer';
  }

  bool get isFinanceOfficer {
    return role == 'finance_officer';
  }

  bool get isTradingOfficer {
    return role == 'trading_officer';
  }

  bool get isSupportOfficer {
    return role == 'support_officer';
  }

  bool get isAuditor {
    return role == 'auditor';
  }
}