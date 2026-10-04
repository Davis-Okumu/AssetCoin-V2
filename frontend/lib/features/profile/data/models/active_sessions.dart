class ActiveSession {
  const ActiveSession({
    required this.id,
    this.deviceName,
    this.deviceType,
    this.ipAddress,
    this.userAgent,
    this.lastActiveAt,
    this.expiresAt,
    this.revokedAt,
    this.createdAt,
    this.isCurrent = false,
  });

  final int id;
  final String? deviceName;
  final String? deviceType;
  final String? ipAddress;
  final String? userAgent;
  final DateTime? lastActiveAt;
  final DateTime? expiresAt;
  final DateTime? revokedAt;
  final DateTime? createdAt;
  final bool isCurrent;

  bool get isRevoked => revokedAt != null;

  bool get isExpired {
    if (expiresAt == null) {
      return false;
    }

    return expiresAt!.isBefore(DateTime.now());
  }

  factory ActiveSession.fromJson(Map<String, dynamic> json) {
    return ActiveSession(
      id: _parseInt(json['id']),
      deviceName: _nullableString(json['deviceName']),
      deviceType: _nullableString(json['deviceType']),
      ipAddress: _nullableString(
        json['ipAddress'] ?? json['IP'],
      ),
      userAgent: _nullableString(json['userAgent']),
      lastActiveAt: _parseDateTime(json['lastActiveAt']),
      expiresAt: _parseDateTime(json['expiresAt']),
      revokedAt: _parseDateTime(json['revokedAt']),
      createdAt: _parseDateTime(json['createdAt']),
      isCurrent: _parseBool(
        json['isCurrent'] ?? json['current'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deviceName': deviceName,
      'deviceType': deviceType,
      'ipAddress': ipAddress,
      'userAgent': userAgent,
      'lastActiveAt': lastActiveAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'revokedAt': revokedAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'isCurrent': isCurrent,
    };
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String? _nullableString(dynamic value) {
    final result = value?.toString().trim();

    if (result == null ||
        result.isEmpty ||
        result == 'null') {
      return null;
    }

    return result;
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

  static bool _parseBool(dynamic value) {
    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    final normalized = value?.toString().toLowerCase().trim();

    return normalized == 'true' ||
        normalized == '1' ||
        normalized == 'yes';
  }
}