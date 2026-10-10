class AdminAuditLogModel {
  const AdminAuditLogModel({
    required this.id,
    required this.action,
    required this.entityType,
    this.userId,
    this.entityId,
    this.oldValues,
    this.newValues,
    this.ipAddress,
    this.userAgent,
    this.previousHash,
    this.logHash,
    this.createdAt,
    this.firstName,
    this.lastName,
    this.email,
  });

  final int id;
  final String action;
  final String entityType;
  final int? userId;
  final String? entityId;

  final dynamic oldValues;
  final dynamic newValues;

  final String? ipAddress;
  final String? userAgent;
  final String? previousHash;
  final String? logHash;
  final DateTime? createdAt;

  final String? firstName;
  final String? lastName;
  final String? email;

  factory AdminAuditLogModel.fromJson(Map<String, dynamic> json) {
    return AdminAuditLogModel(
      id: _int(json['id']),
      action: _string(json['action']),
      entityType: _string(json['entityType']),
      userId: _nullableInt(json['userId']),
      entityId: json['entityId']?.toString(),
      oldValues: _decodeJsonValue(json['oldValues']),
      newValues: _decodeJsonValue(json['newValues']),
      ipAddress: _nullableString(json['ipAddress']),
      userAgent: _nullableString(json['userAgent']),
      previousHash: _nullableString(json['previousHash']),
      logHash: _nullableString(json['logHash']),
      createdAt: _date(json['createdAt']),
      firstName: _nullableString(json['firstName']),
      lastName: _nullableString(json['lastName']),
      email: _nullableString(json['email']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'action': action,
    'entityType': entityType,
    'userId': userId,
    'entityId': entityId,
    'oldValues': oldValues,
    'newValues': newValues,
    'ipAddress': ipAddress,
    'userAgent': userAgent,
    'previousHash': previousHash,
    'logHash': logHash,
    'createdAt': createdAt?.toIso8601String(),
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
  };

  String get userName {
    final parts = [
      if (_hasText(firstName)) firstName!.trim(),
      if (_hasText(lastName)) lastName!.trim(),
    ];

    return parts.isEmpty ? 'Unknown user' : parts.join(' ');
  }

  String get actionLabel => _titleCase(action);
  String get entityTypeLabel => _titleCase(entityType);

  bool get hasPreviousHash => _hasText(previousHash);
  bool get hasLogHash => _hasText(logHash);

  static dynamic _decodeJsonValue(dynamic value) {
    if (value is Map || value is List || value == null) return value;

    // Preserve the value if the API supplies JSON as a string.
    // The UI can display it without risking a parsing exception.
    return value;
  }

  static bool _hasText(String? value) =>
      value != null && value.trim().isNotEmpty;

  static int _int(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _nullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static String _string(dynamic value) => value?.toString().trim() ?? '';

  static String? _nullableString(dynamic value) {
    final result = value?.toString().trim();
    return result == null || result.isEmpty ? null : result;
  }

  static DateTime? _date(dynamic value) {
    if (value is DateTime) return value;
    return value == null ? null : DateTime.tryParse(value.toString());
  }

  static String _titleCase(String value) {
    final normalized = value.replaceAll('_', ' ').trim();
    if (normalized.isEmpty) return value;

    return normalized
        .split(RegExp(r'\s+'))
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}
