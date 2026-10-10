class AdminStaffPermissionModel {
  const AdminStaffPermissionModel({
    required this.id,
    required this.code,
    required this.name,
    this.module,
    this.action,
    this.description,
    this.accessType,
    this.isGrantedByRole,
  });

  final int id;
  final String code;
  final String name;
  final String? module;
  final String? action;
  final String? description;

  /// Individual override, when one exists: grant or deny.
  final String? accessType;

  /// Whether the assigned role grants this permission.
  final bool? isGrantedByRole;

  bool get isDenied => accessType?.toLowerCase() == 'deny';

  bool get isExplicitlyGranted => accessType?.toLowerCase() == 'grant';

  factory AdminStaffPermissionModel.fromJson(Map<String, dynamic> json) {
    return AdminStaffPermissionModel(
      id: _toInt(json['id'] ?? json['permissionId']) ?? 0,
      code: _toString(json['code'] ?? json['permissionCode']),
      name: _toString(
        json['name'] ?? json['permissionName'],
        fallback: 'Unnamed permission',
      ),
      module: _toNullableString(json['module']),
      action: _toNullableString(json['action']),
      description: _toNullableString(json['description']),
      accessType: _toNullableString(json['accessType']),
      isGrantedByRole: _toBool(
        json['isGrantedByRole'] ?? json['grantedByRole'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'module': module,
      'action': action,
      'description': description,
      'accessType': accessType,
      'isGrantedByRole': isGrantedByRole,
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
        case 'yes':
          return true;
        case 'false':
        case '0':
        case 'no':
          return false;
      }
    }

    return null;
  }
}
