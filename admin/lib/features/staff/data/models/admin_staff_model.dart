class AdminStaffModel {
  const AdminStaffModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.profilePhotoUrl,
    this.roleId,
    this.roleCode,
    this.roleName,
    this.accountStatus = 'active',
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
    this.permissions = const [],
  });

  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? profilePhotoUrl;

  final int? roleId;
  final String? roleCode;
  final String? roleName;

  final String accountStatus;
  final bool? isActive;

  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLoginAt;

  final List<String> permissions;

  String get fullName => '$firstName $lastName'.trim();

  bool get isAccountActive =>
      isActive ?? accountStatus.toLowerCase() == 'active';

  factory AdminStaffModel.fromJson(Map<String, dynamic> json) {
    return AdminStaffModel(
      id: _toInt(json['id'] ?? json['staffId']) ?? 0,
      firstName: _toString(json['firstName']),
      lastName: _toString(json['lastName']),
      email: _toString(json['email']),
      phone: _toNullableString(json['phone']),
      profilePhotoUrl: _toNullableString(json['profilePhotoUrl']),
      roleId: _toInt(json['roleId']),
      roleCode: _toNullableString(json['roleCode'] ?? json['role']),
      roleName: _toNullableString(json['roleName']),
      accountStatus: _toString(
        json['accountStatus'] ?? json['status'],
        fallback: 'active',
      ),
      isActive: _toBool(json['isActive']),
      createdAt: _toDateTime(json['createdAt']),
      updatedAt: _toDateTime(json['updatedAt']),
      lastLoginAt: _toDateTime(json['lastLoginAt'] ?? json['lastLogin']),
      permissions: _toStringList(json['permissions']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'profilePhotoUrl': profilePhotoUrl,
      'roleId': roleId,
      'roleCode': roleCode,
      'roleName': roleName,
      'accountStatus': accountStatus,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'permissions': permissions,
    };
  }

  static String _toString(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    return value.toString();
  }

  static String? _toNullableString(dynamic value) {
    if (value == null) return null;

    final result = value.toString().trim();
    return result.isEmpty ? null : result;
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    if (value is String) {
      return int.tryParse(value);
    }

    return null;
  }

  static bool? _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;

    if (value is String) {
      switch (value.toLowerCase().trim()) {
        case 'true':
        case '1':
        case 'active':
          return true;
        case 'false':
        case '0':
        case 'inactive':
        case 'suspended':
        case 'deactivated':
        case 'locked':
          return false;
      }
    }

    return null;
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;

    return DateTime.tryParse(value.toString());
  }

  static List<String> _toStringList(dynamic value) {
    if (value is! List) return const [];

    return value
        .where((item) => item != null)
        .map((item) => item.toString())
        .toList(growable: false);
  }
}
