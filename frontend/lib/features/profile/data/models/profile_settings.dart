class ProfileSettings {
  const ProfileSettings({
    this.theme = 'light',
    this.language = 'en',
    this.displayCurrency = 'KES',
    this.profileVisibility = 'private',
    this.showEmail = false,
    this.showPhone = false,
    this.marketingNotificationsEnabled = false,
    this.emailUpdatesEnabled = true,
  });

  final String theme;
  final String language;
  final String displayCurrency;
  final String profileVisibility;
  final bool showEmail;
  final bool showPhone;
  final bool marketingNotificationsEnabled;
  final bool emailUpdatesEnabled;

  bool get isLightTheme => theme == 'light';

  bool get isDarkTheme => theme == 'dark';

  bool get followsSystemTheme => theme == 'system';

  factory ProfileSettings.fromJson(Map<String, dynamic> json) {
    return ProfileSettings(
      theme: _string(
        json['theme'],
        fallback: 'light',
      ),
      language: _string(
        json['language'],
        fallback: 'en',
      ),
      displayCurrency: _string(
        json['displayCurrency'],
        fallback: 'KES',
      ),
      profileVisibility: _string(
        json['profileVisibility'],
        fallback: 'private',
      ),
      showEmail: _bool(json['showEmail']),
      showPhone: _bool(json['showPhone']),
      marketingNotificationsEnabled:
          _bool(json['marketingNotificationsEnabled']),
      emailUpdatesEnabled: json.containsKey('emailUpdatesEnabled')
          ? _bool(json['emailUpdatesEnabled'])
          : true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'theme': theme,
      'language': language,
      'displayCurrency': displayCurrency,
      'profileVisibility': profileVisibility,
      'showEmail': showEmail,
      'showPhone': showPhone,
      'marketingNotificationsEnabled': marketingNotificationsEnabled,
      'emailUpdatesEnabled': emailUpdatesEnabled,
    };
  }

  ProfileSettings copyWith({
    String? theme,
    String? language,
    String? displayCurrency,
    String? profileVisibility,
    bool? showEmail,
    bool? showPhone,
    bool? marketingNotificationsEnabled,
    bool? emailUpdatesEnabled,
  }) {
    return ProfileSettings(
      theme: theme ?? this.theme,
      language: language ?? this.language,
      displayCurrency: displayCurrency ?? this.displayCurrency,
      profileVisibility:
          profileVisibility ?? this.profileVisibility,
      showEmail: showEmail ?? this.showEmail,
      showPhone: showPhone ?? this.showPhone,
      marketingNotificationsEnabled:
          marketingNotificationsEnabled ??
              this.marketingNotificationsEnabled,
      emailUpdatesEnabled:
          emailUpdatesEnabled ?? this.emailUpdatesEnabled,
    );
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

  static bool _bool(dynamic value) {
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