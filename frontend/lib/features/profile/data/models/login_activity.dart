class LoginActivity {
  const LoginActivity({
    required this.id,
    required this.eventType,
    this.deviceName,
    this.deviceType,
    this.ipAddress,
    this.userAgent,
    this.description,
    this.createdAt,
  });

  final int id;
  final String eventType;
  final String? deviceName;
  final String? deviceType;
  final String? ipAddress;
  final String? userAgent;
  final String? description;
  final DateTime? createdAt;

  String get readableEventType {
    switch (eventType) {
      case 'login_success':
        return 'Login successful';

      case 'login_failed':
        return 'Login failed';

      case 'logout':
        return 'Logged out';

      case 'password_changed':
        return 'Password changed';

      case 'password_reset':
        return 'Password reset';

      case 'two_factor_enabled':
        return 'Two-factor authentication enabled';

      case 'two_factor_disabled':
        return 'Two-factor authentication disabled';

      case 'session_revoked':
        return 'Session revoked';

      default:
        return eventType
            .replaceAll('_', ' ')
            .split(' ')
            .map(
              (word) => word.isEmpty
                  ? word
                  : '${word[0].toUpperCase()}${word.substring(1)}',
            )
            .join(' ');
    }
  }

  factory LoginActivity.fromJson(Map<String, dynamic> json) {
    return LoginActivity(
      id: _parseInt(json['id']),
      eventType: _string(
        json['eventType'],
        fallback: 'unknown',
      ),
      deviceName: _nullableString(json['deviceName']),
      deviceType: _nullableString(json['deviceType']),
      ipAddress: _nullableString(
        json['ipAddress'] ?? json['IP'],
      ),
      userAgent: _nullableString(json['userAgent']),
      description: _nullableString(json['description']),
      createdAt: _parseDateTime(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventType': eventType,
      'deviceName': deviceName,
      'deviceType': deviceType,
      'ipAddress': ipAddress,
      'userAgent': userAgent,
      'description': description,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _string(
    dynamic value, {
    required String fallback,
  }) {
    final result = value?.toString().trim();

    if (result == null || result.isEmpty) {
      return fallback;
    }

    return result;
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
}