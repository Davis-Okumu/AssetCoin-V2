class SecuritySettings {
  const SecuritySettings({
    this.biometricEnabled = false,
    this.twoFactorEnabled = false,
    this.twoFactorMethod,
    this.twoFactorVerifiedAt,
    this.loginNotificationEnabled = true,
    this.passwordChangedAt,
    this.createdAt,
    this.updatedAt,
  });

  final bool biometricEnabled;
  final bool twoFactorEnabled;
  final String? twoFactorMethod;
  final DateTime? twoFactorVerifiedAt;
  final bool loginNotificationEnabled;
  final DateTime? passwordChangedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isTwoFactorVerified =>
      twoFactorVerifiedAt != null;

  String get twoFactorLabel {
    if (!twoFactorEnabled) {
      return 'Not enabled';
    }

    if (twoFactorMethod == null ||
        twoFactorMethod!.trim().isEmpty) {
      return 'Enabled';
    }

    switch (twoFactorMethod!.toLowerCase()) {
      case 'sms':
        return 'SMS';
      case 'email':
        return 'Email';
      case 'authenticator':
        return 'Authenticator app';
      default:
        return twoFactorMethod!;
    }
  }

  factory SecuritySettings.fromJson(
    Map<String, dynamic> json,
  ) {
    return SecuritySettings(
      biometricEnabled: _parseBool(
        json['biometricEnabled'],
      ),
      twoFactorEnabled: _parseBool(
        json['twoFactorEnabled'],
      ),
      twoFactorMethod: _nullableString(
        json['twoFactorMethod'],
      ),
      twoFactorVerifiedAt: _parseDateTime(
        json['twoFactorVerifiedAt'],
      ),
      loginNotificationEnabled:
          json['loginNotificationEnabled'] == null
              ? true
              : _parseBool(
                  json['loginNotificationEnabled'],
                ),
      passwordChangedAt: _parseDateTime(
        json['passwordChangedAt'],
      ),
      createdAt: _parseDateTime(
        json['createdAt'],
      ),
      updatedAt: _parseDateTime(
        json['updatedAt'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'biometricEnabled': biometricEnabled,
      'twoFactorEnabled': twoFactorEnabled,
      'twoFactorMethod': twoFactorMethod,
      'twoFactorVerifiedAt':
          twoFactorVerifiedAt?.toIso8601String(),
      'loginNotificationEnabled':
          loginNotificationEnabled,
      'passwordChangedAt':
          passwordChangedAt?.toIso8601String(),
      'createdAt':
          createdAt?.toIso8601String(),
      'updatedAt':
          updatedAt?.toIso8601String(),
    };
  }

  SecuritySettings copyWith({
    bool? biometricEnabled,
    bool? twoFactorEnabled,
    String? twoFactorMethod,
    DateTime? twoFactorVerifiedAt,
    bool? loginNotificationEnabled,
    DateTime? passwordChangedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SecuritySettings(
      biometricEnabled:
          biometricEnabled ?? this.biometricEnabled,
      twoFactorEnabled:
          twoFactorEnabled ?? this.twoFactorEnabled,
      twoFactorMethod:
          twoFactorMethod ?? this.twoFactorMethod,
      twoFactorVerifiedAt:
          twoFactorVerifiedAt ??
              this.twoFactorVerifiedAt,
      loginNotificationEnabled:
          loginNotificationEnabled ??
              this.loginNotificationEnabled,
      passwordChangedAt:
          passwordChangedAt ??
              this.passwordChangedAt,
      createdAt:
          createdAt ?? this.createdAt,
      updatedAt:
          updatedAt ?? this.updatedAt,
    );
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    final normalized =
        value?.toString().toLowerCase().trim();

    return normalized == 'true' ||
        normalized == '1' ||
        normalized == 'yes';
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

    return DateTime.tryParse(
      value.toString(),
    );
  }
}