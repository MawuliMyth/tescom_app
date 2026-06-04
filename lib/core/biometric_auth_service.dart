import 'package:local_auth/local_auth.dart';

import 'app_settings_service.dart';

class BiometricAuthService {
  BiometricAuthService({
    LocalAuthentication? localAuthentication,
    AppSettingsService? settingsService,
  }) : _localAuthentication = localAuthentication ?? LocalAuthentication(),
       _settingsService = settingsService ?? AppSettingsService();

  final LocalAuthentication _localAuthentication;
  final AppSettingsService _settingsService;

  Future<bool> isAvailable() async {
    try {
      final canCheck = await _localAuthentication.canCheckBiometrics;
      final supported = await _localAuthentication.isDeviceSupported();
      return canCheck && supported;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isEnabled() => _settingsService.biometricUnlockEnabled();

  Future<void> setEnabled(bool enabled) {
    return _settingsService.setBiometricUnlockEnabled(enabled);
  }

  Future<bool> authenticate({
    String reason = 'Use your biometrics to unlock TESCON',
  }) async {
    if (!await isAvailable()) return false;
    try {
      return _localAuthentication.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }
}
