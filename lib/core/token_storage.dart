import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'auth_tokens.dart';

class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _accessTokenExpiresAtKey = 'access_token_expires_at';
  static const _refreshTokenExpiresAtKey = 'refresh_token_expires_at';

  final FlutterSecureStorage _storage;

  Future<void> save(AuthTokens tokens) async {
    final now = DateTime.now();
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: tokens.accessToken),
      _storage.write(key: _refreshTokenKey, value: tokens.refreshToken),
      _storage.write(
        key: _accessTokenExpiresAtKey,
        value: now
            .add(Duration(seconds: tokens.accessTokenExpiresIn))
            .toIso8601String(),
      ),
      _storage.write(
        key: _refreshTokenExpiresAtKey,
        value: now
            .add(Duration(seconds: tokens.refreshTokenExpiresIn))
            .toIso8601String(),
      ),
    ]);
  }

  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);

  Future<String?> readRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<bool> hasRefreshSession() async {
    final refreshToken = await readRefreshToken();
    final expiresAt = await _readDate(_refreshTokenExpiresAtKey);
    return refreshToken != null &&
        expiresAt != null &&
        expiresAt.isAfter(DateTime.now());
  }

  Future<bool> shouldRefreshAccessToken() async {
    final accessToken = await readAccessToken();
    final expiresAt = await _readDate(_accessTokenExpiresAtKey);
    if (accessToken == null || expiresAt == null) return true;

    return expiresAt.isBefore(DateTime.now().add(const Duration(minutes: 1)));
  }

  Future<void> clear() => _storage.deleteAll();

  Future<DateTime?> _readDate(String key) async {
    final value = await _storage.read(key: key);
    return value == null ? null : DateTime.tryParse(value);
  }
}
