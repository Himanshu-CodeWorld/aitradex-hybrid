import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage service for AiTradeX App Lock.
///
/// The current 4-digit MPIN is replaced whenever [enable] is called.
/// Therefore, changing the MPIN immediately invalidates the previous MPIN.
class AppLockService {
  AppLockService._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _enabledKey = 'aitradex_app_lock_enabled';
  static const String _pinKey = 'aitradex_app_lock_pin';

  static final RegExp _pinRegex = RegExp(r'^\d{4}$');

  static Future<bool> isEnabled() async {
    final String? value = await _storage.read(key: _enabledKey);
    return value == 'true';
  }

  static Future<String?> getPin() async {
    return _storage.read(key: _pinKey);
  }

  static Future<bool> hasPin() async {
    final String? pin = await getPin();
    return pin != null && _pinRegex.hasMatch(pin);
  }

  /// Creates a PIN or replaces the existing PIN.
  ///
  /// This is intentionally the single write path for the PIN so a changed
  /// PIN becomes active immediately.
  static Future<void> enable(String pin) async {
    if (!_pinRegex.hasMatch(pin)) {
      throw ArgumentError('MPIN must contain exactly 4 digits.');
    }

    await _storage.write(key: _pinKey, value: pin);
    await _storage.write(key: _enabledKey, value: 'true');
  }

  static Future<void> disable() async {
    await _storage.write(key: _enabledKey, value: 'false');
  }

  static Future<bool> verify(String pin) async {
    if (!_pinRegex.hasMatch(pin)) {
      return false;
    }

    final String? savedPin = await getPin();

    return savedPin != null && savedPin == pin;
  }

  static Future<void> removePin() async {
    await _storage.delete(key: _pinKey);
    await _storage.write(key: _enabledKey, value: 'false');
  }
}
