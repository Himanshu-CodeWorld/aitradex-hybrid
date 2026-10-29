import 'package:flutter/material.dart';

import 'applock_screen.dart';
import '../../services/app_lock_service.dart';
import '../../services/biometric_auth_service.dart';

/// Locks the authenticated app when App Lock / Two-Factor Authentication
/// is enabled.
///
/// App Lock supports:
/// - 4-digit MPIN
/// - Fingerprint/Biometric ID
/// - Face ID
class AppLockGate extends StatefulWidget {
  final Widget child;

  const AppLockGate({
    super.key,
    required this.child,
  });

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate>
    with WidgetsBindingObserver {
  bool _checking = true;
  bool _locked = false;
  bool _unlocked = false;
  bool _showBiometric = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadLockState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadLockState() async {
    final bool enabled = await AppLockService.isEnabled();
    final bool hasPin = await AppLockService.hasPin();
    final bool biometricEnabled =
    await BiometricAuthService.anyBiometricEnabled();

    if (!mounted) return;

    setState(() {
      _locked = enabled && hasPin;
      _showBiometric = enabled && hasPin && biometricEnabled;
      _checking = false;
      _unlocked = !(enabled && hasPin);
    });
  }

  void _lockApp() {
    if (!_locked || !mounted) return;

    setState(() {
      _unlocked = false;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadLockState();
    }

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _lockApp();
    }
  }

  Future<bool> _unlockWithPin(String pin) async {
    final bool valid = await AppLockService.verify(pin);

    if (valid && mounted) {
      setState(() {
        _unlocked = true;
      });
    }

    return valid;
  }

  Future<bool> _unlockWithBiometric() async {
    if (!_showBiometric) return false;

    final bool authenticated =
    await BiometricAuthService.authenticate(
      reason: 'Verify your identity to unlock AiTradeX.',
    );

    if (authenticated && mounted) {
      setState(() {
        _unlocked = true;
      });
    }

    return authenticated;
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const SizedBox.shrink();
    }

    if (!_locked || _unlocked) {
      return widget.child;
    }

    return AppLockScreen(
      onUnlock: _unlockWithPin,
      onBiometric: _unlockWithBiometric,
      showBiometric: _showBiometric,
      showForgotPin: false,
      allowBack: false,
    );
  }
}
