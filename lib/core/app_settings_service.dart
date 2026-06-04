import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppSettingsService {
  AppSettingsService({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
          );

  static const _notificationsEnabledKey = 'settings_notifications_enabled';

  final FlutterSecureStorage _storage;

  Future<bool> notificationsEnabled() async {
    final value = await _storage.read(key: _notificationsEnabledKey);
    return value == null ? true : value == 'true';
  }

  Future<void> setNotificationsEnabled(bool enabled) {
    return _storage.write(
      key: _notificationsEnabledKey,
      value: enabled.toString(),
    );
  }
}
