import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  TokenStorage._();

  static const String _adminTokenKey = 'assetcoin_admin_token';

  static Future<void> saveToken(String token) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(
      _adminTokenKey,
      token,
    );
  }

  static Future<String?> getToken() async {
    final preferences = await SharedPreferences.getInstance();

    return preferences.getString(
      _adminTokenKey,
    );
  }

  static Future<void> clearToken() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(
      _adminTokenKey,
    );
  }

  static Future<bool> hasToken() async {
    final token = await getToken();

    return token != null && token.isNotEmpty;
  }
}