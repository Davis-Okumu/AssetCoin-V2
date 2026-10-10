class AdminStaffOverviewModel {
  const AdminStaffOverviewModel({
    this.totalStaff = 0,
    this.activeStaff = 0,
    this.suspendedStaff = 0,
    this.inactiveStaff = 0,
    this.lockedStaff = 0,
    this.roleDistribution = const [],
  });

  final int totalStaff;
  final int activeStaff;
  final int suspendedStaff;
  final int inactiveStaff;
  final int lockedStaff;

  /// Number of staff members assigned to each role.
  final List<AdminStaffRoleDistribution> roleDistribution;

  factory AdminStaffOverviewModel.fromJson(Map<String, dynamic> json) {
    final distribution = json['roleDistribution'] ?? json['staffByRole'];

    return AdminStaffOverviewModel(
      totalStaff: _toInt(json['totalStaff'] ?? json['total']),
      activeStaff: _toInt(json['activeStaff'] ?? json['active']),
      suspendedStaff: _toInt(json['suspendedStaff'] ?? json['suspended']),
      inactiveStaff: _toInt(json['inactiveStaff'] ?? json['inactive']),
      lockedStaff: _toInt(json['lockedStaff'] ?? json['locked']),
      roleDistribution: distribution is List
          ? distribution
                .whereType<Map>()
                .map(
                  (item) => AdminStaffRoleDistribution.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList(growable: false)
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalStaff': totalStaff,
      'activeStaff': activeStaff,
      'suspendedStaff': suspendedStaff,
      'inactiveStaff': inactiveStaff,
      'lockedStaff': lockedStaff,
      'roleDistribution': roleDistribution
          .map((item) => item.toJson())
          .toList(),
    };
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;

    return 0;
  }
}

class AdminStaffRoleDistribution {
  const AdminStaffRoleDistribution({
    required this.roleCode,
    required this.roleName,
    required this.staffCount,
  });

  final String roleCode;
  final String roleName;
  final int staffCount;

  factory AdminStaffRoleDistribution.fromJson(Map<String, dynamic> json) {
    return AdminStaffRoleDistribution(
      roleCode: _toString(json['roleCode'] ?? json['code']),
      roleName: _toString(json['roleName'] ?? json['name'], fallback: 'Other'),
      staffCount: _toInt(json['staffCount'] ?? json['count']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roleCode': roleCode,
      'roleName': roleName,
      'staffCount': staffCount,
    };
  }

  static String _toString(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    return value.toString();
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;

    return 0;
  }
}
