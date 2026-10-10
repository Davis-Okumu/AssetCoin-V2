class AdminStaffRoleModel {
  const AdminStaffRoleModel({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    this.isActive = true,
    this.staffCount = 0,
    this.permissions = const [],
  });

  final int id;
  final String code;
  final String name;
  final String? description;
  final bool isActive;
  final int staffCount;
  final List<String> permissions;

  factory AdminStaffRoleModel.fromJson(Map<String, dynamic> json) {
    return AdminStaffRoleModel(
      id: _toInt(json['id'] ?? json['roleId']) ?? 0,
      code: _toString(json['code'] ?? json['roleCode']),
      name: _toString(
        json['name'] ?? json['roleName'],
        fallback: 'Unnamed role',
      ),
      description: _toNullableString(json['description']),
      isActive: _toBool(json['isActive'] ?? json['active']) ?? true,
      staffCount: _toInt(json['staffCount']) ?? 0,
      permissions: _toStringList(json['permissions']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'isActive': isActive,
      'staffCount': staffCount,
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
    if (value is String) return int.tryParse(value);

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
        case 'disabled':
          return false;
      }
    }

    return null;
  }

  static List<String> _toStringList(dynamic value) {
    if (value is! List) return const [];

    return value
        .where((item) => item != null)
        .map((item) => item.toString())
        .toList(growable: false);
  }
}
