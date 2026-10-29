import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

/// Handles device biometric authentication and the user's biometric
/// App Lock preferences.
///
/// The preference flags are stored in secure storage. The actual biometric
/// secret is managed by the operating system; this service never stores a
/// fingerprint or face image.
class BiometricAuthService {
  BiometricAuthService._();

  static final LocalAuthentication _auth = LocalAuthentication();
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _fingerprintEnabledKey =
      'aitradex_biometric_fingerprint_enabled';
  static const String _faceEnabledKey =
      'aitradex_biometric_face_enabled';

  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return <BiometricType>[];
    }
  }

  static Future<bool> isDeviceSupported() async {
    try {
      final bool supported = await _auth.isDeviceSupported();
      return supported;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> isTypeAvailable(BiometricType type) async {
    try {
      final bool supported = await isDeviceSupported();
      if (!supported) return false;

      final List<BiometricType> available =
      await getAvailableBiometrics();

      if (type == BiometricType.fingerprint) {
        return available.contains(BiometricType.fingerprint) ||
            available.contains(BiometricType.strong) ||
            available.contains(BiometricType.weak);
      }

      if (type == BiometricType.face) {
        return available.contains(BiometricType.face);
      }

      return available.contains(type);
    } catch (_) {
      return false;
    }
  }

  static Future<bool> authenticate({
    required String reason,
  }) async {
    try {
      final bool supported = await isDeviceSupported();
      if (!supported) return false;

      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }

  static Future<bool> isFingerprintEnabled() async {
    final String? value =
    await _storage.read(key: _fingerprintEnabledKey);
    return value == 'true';
  }

  static Future<bool> isFaceEnabled() async {
    final String? value =
    await _storage.read(key: _faceEnabledKey);
    return value == 'true';
  }

  static Future<void> setFingerprintEnabled(bool enabled) async {
    await _storage.write(
      key: _fingerprintEnabledKey,
      value: enabled.toString(),
    );
  }

  static Future<void> setFaceEnabled(bool enabled) async {
    await _storage.write(
      key: _faceEnabledKey,
      value: enabled.toString(),
    );
  }

  static Future<bool> anyBiometricEnabled() async {
    return await isFingerprintEnabled() || await isFaceEnabled();
  }

  static Future<void> disableAll() async {
    await setFingerprintEnabled(false);
    await setFaceEnabled(false);
  }
}
