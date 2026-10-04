import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const String _tokenKey = 'assetcoin_auth_token';

  static const FlutterSecureStorage _storage =
      FlutterSecureStorage();

  // SAVE TOKEN
  Future<void> saveToken(String token) async {
    final trimmedToken = token.trim();

    if (trimmedToken.isEmpty) {
      throw ArgumentError('Authentication token cannot be empty.');
    }

    await _storage.write(
      key: _tokenKey,
      value: trimmedToken,
    );
  }

  // READ TOKEN
  Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  // DELETE TOKEN
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // CHECK WHETHER A TOKEN EXISTS
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.trim().isNotEmpty;
  }
}
