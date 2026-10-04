class NotificationPreference {
  final String notificationType;
  final bool inAppEnabled;
  final bool emailEnabled;
  final bool smsEnabled;

  const NotificationPreference({
    required this.notificationType,
    required this.inAppEnabled,
    required this.emailEnabled,
    required this.smsEnabled,
  });

  factory NotificationPreference.fromJson(
    Map<String, dynamic> json,
  ) {
    return NotificationPreference(
      notificationType: json['notificationType'].toString(),
      inAppEnabled: _parseBool(json['inAppEnabled']),
      emailEnabled: _parseBool(json['emailEnabled']),
      smsEnabled: _parseBool(json['smsEnabled']),
    );
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;

    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }

    return false;
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationType': notificationType,
      'inAppEnabled': inAppEnabled,
      'emailEnabled': emailEnabled,
      'smsEnabled': smsEnabled,
    };
  }

  NotificationPreference copyWith({
    String? notificationType,
    bool? inAppEnabled,
    bool? emailEnabled,
    bool? smsEnabled,
  }) {
    return NotificationPreference(
      notificationType:
          notificationType ?? this.notificationType,
      inAppEnabled: inAppEnabled ?? this.inAppEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      smsEnabled: smsEnabled ?? this.smsEnabled,
    );
  }
}