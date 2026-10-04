/*
Important Physical Android and iOS devices cannot be reliably distinguished from emulators using Flutter's platform information alone. For those devices, we'll override the URL at launch.

For example:

flutter run --dart-define=API_BASE_URL=http://192.168.1.10:3000

Replace 192.168.1.10 with your computer's actual LAN IP address.
*/


import 'package:flutter/foundation.dart';

abstract final class AppEnv {
  static const _apiBaseUrlOverride = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static const environment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  static String get apiBaseUrl {
    // Explicit URL always takes priority.
    if (_apiBaseUrlOverride.isNotEmpty) {
      return _apiBaseUrlOverride;
    }

    // Chrome / other web browsers.
    if (kIsWeb) {
      return 'http://localhost:3000';
    }

    // Native platforms.
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:3000';

      case TargetPlatform.iOS:
      case TargetPlatform.windows:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
        return 'http://localhost:3000';

      default:
        return 'http://localhost:3000';
    }
  }
}

