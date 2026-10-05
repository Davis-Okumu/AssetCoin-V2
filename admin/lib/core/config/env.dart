class AppEnv {
  AppEnv._();

  /// Base URL for the AssetCoin backend.
  ///
  /// Flutter Web running in Chrome can access the backend
  /// through localhost because both applications are running
  /// on the same development machine.
  static const String apiBaseUrl = 'http://localhost:3000';

  /// Admin API prefix.
  static const String adminApiPrefix = '/api/admin';

  /// Complete admin authentication API URL.
  static String get adminAuthBaseUrl {
    return '$apiBaseUrl$adminApiPrefix/auth';
  }
}