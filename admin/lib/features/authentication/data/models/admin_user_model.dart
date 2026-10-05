import '../../domain/admin_user.dart';

class AdminUserModel extends AdminUser {
  const AdminUserModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.role,
    super.phone,
    super.profilePhotoUrl,
    super.isActive,
    super.permissions,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    final permissionsJson = json['permissions'];

    final permissions = permissionsJson is List
        ? permissionsJson
            .whereType<String>()
            .toList()
        : <String>[];

    return AdminUserModel(
      id: _parseInt(json['id']),
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      phone: json['phone']?.toString(),
      profilePhotoUrl: json['profilePhotoUrl']?.toString(),
      isActive: _parseBool(
        json['isActive'] ?? json['accountStatus'] == 'active',
      ),
      permissions: permissions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'role': role,
      'phone': phone,
      'profilePhotoUrl': profilePhotoUrl,
      'isActive': isActive,
      'permissions': permissions,
    };
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) {
      return value;
    }

    if (value is String) {
      return value.toLowerCase() == 'true';
    }

    if (value is num) {
      return value != 0;
    }

    return false;
  }
}