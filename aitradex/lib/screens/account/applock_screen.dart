import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// AiTradeX 4-digit App Lock screen.
///
/// Use this screen when the user already has an MPIN and needs to unlock
/// the application.
///
/// The screen uses Theme.of(context), so your existing AiTradeX light theme,
/// dark theme, and dynamic App Theme primary color are applied automatically.
///
/// Example:
///
/// AppLockScreen(
///   onUnlock: (pin) async {
///     // Verify the PIN securely.
///     return pin == '1234';
///   },
///   onBiometric: () async {
///     // Connect local_auth here.
///     return true;
///   },
///   onForgotPin: () {},
/// );
class AppLockScreen extends StatefulWidget {
  final Future<bool> Function(String pin) onUnlock;
  final Future<bool> Function()? onBiometric;
  final VoidCallback? onForgotPin;
  final bool showBiometric;
  final bool showForgotPin;
  final bool allowBack;

  const AppLockScreen({
    super.key,
    required this.onUnlock,
    this.onBiometric,
    this.onForgotPin,
    this.showBiometric = true,
    this.showForgotPin = true,
    this.allowBack = false,
  });

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen>
    with SingleTickerProviderStateMixin {
  static const int _pinLength = 4;

  final List<String> _pin = <String>[];

  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  bool _isLoading = false;
  bool _isBiometricLoading = false;
  String? _errorMessage;
  int _failedAttempts = 0;
  DateTime? _lockedUntil;

  ThemeData get _theme => Theme.of(context);

  Color get _primary => _theme.colorScheme.primary;

  Color get _background => _theme.scaffoldBackgroundColor;

  Color get _surface => _theme.colorScheme.surface;

  Color get _textPrimary => _theme.colorScheme.onSurface;

  Color get _textSecondary =>
      _theme.textTheme.bodyMedium?.color ??
          _theme.colorScheme.onSurface.withValues(alpha: 0.65);

  Color get _border => _theme.dividerColor.withValues(alpha: 0.55);

  bool get _isDark => _theme.brightness == Brightness.dark;

  bool get _isLocked {
    final DateTime? until = _lockedUntil;

    if (until == null) return false;

    if (DateTime.now().isAfter(until)) {
      _lockedUntil = null;
      _failedAttempts = 0;
      return false;
    }

    return true;
  }

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    _shakeAnimation = CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _shake() {
    _shakeController
      ..reset()
      ..forward();
  }

  void _addDigit(String digit) {
    if (_isLoading || _isBiometricLoading || _isLocked) return;
    if (_pin.length >= _pinLength) return;

    HapticFeedback.selectionClick();

    setState(() {
      _errorMessage = null;
      _pin.add(digit);
    });

    if (_pin.length == _pinLength) {
      _verifyPin();
    }
  }

  void _deleteDigit() {
    if (_isLoading || _isBiometricLoading || _isLocked) return;
    if (_pin.isEmpty) return;

    HapticFeedback.selectionClick();

    setState(() {
      _errorMessage = null;
      _pin.removeLast();
    });
  }

  Future<void> _verifyPin() async {
    if (_pin.length != _pinLength || _isLoading || _isLocked) return;

    final String pin = _pin.join();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final bool unlocked = await widget.onUnlock(pin);

      if (!mounted) return;

      if (unlocked) {
        HapticFeedback.heavyImpact();
        return;
      }

      _failedAttempts++;

      if (_failedAttempts >= 5) {
        _lockedUntil = DateTime.now().add(const Duration(seconds: 30));
        _showError('Too many attempts. Try again in 30 seconds.');
      } else {
        final int remaining = 5 - _failedAttempts;
        _showError(
          'Incorrect MPIN. $remaining attempt'
              '${remaining == 1 ? '' : 's'} remaining.',
        );
      }
    } catch (_) {
      if (!mounted) return;
      _showError('Unable to verify MPIN. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    setState(() {
      _errorMessage = message;
      _pin.clear();
      _isLoading = false;
    });

    _shake();
    HapticFeedback.vibrate();
  }

  Future<void> _authenticateBiometric() async {
    if (_isLoading ||
        _isBiometricLoading ||
        _isLocked ||
        widget.onBiometric == null) {
      return;
    }

    setState(() {
      _isBiometricLoading = true;
      _errorMessage = null;
    });

    try {
      final bool authenticated = await widget.onBiometric!();

      if (!mounted) return;

      if (authenticated) {
        HapticFeedback.heavyImpact();
      } else {
        _showError('Biometric authentication was not successful.');
      }
    } catch (_) {
      if (!mounted) return;
      _showError('Biometric authentication is unavailable.');
    } finally {
      if (mounted) {
        setState(() {
          _isBiometricLoading = false;
        });
      }
    }
  }

  Widget _buildHeader() {
    return Column(
      children: <Widget>[
        Container(
          width: 78,
          height: 78,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _primary.withValues(alpha: 0.10),
            border: Border.all(
              color: _primary.withValues(alpha: 0.18),
            ),
          ),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  _primary,
                  _primary.withValues(alpha: 0.72),
                ],
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: _primary.withValues(alpha: 0.22),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.lock_rounded,
              color: Colors.white,
              size: 31,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'AiTradeX',
          style: GoogleFonts.poppins(
            color: _textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'App Locked',
          style: GoogleFonts.poppins(
            color: _textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Enter your 4-digit MPIN to continue',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: _textSecondary,
            fontSize: 12.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPinIndicator() {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (BuildContext context, Widget? child) {
        final double shake = _errorMessage == null
            ? 0
            : _shakeAnimation.value * 7;

        return Transform.translate(
          offset: Offset(shake, 0),
          child: child,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(top: 24),
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _border),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(
                alpha: _isDark ? 0.12 : 0.04,
              ),
              blurRadius: 20,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(
                _pinLength,
                    (int index) {
                  final bool filled = index < _pin.length;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: filled ? 14 : 12,
                    height: filled ? 14 : 12,
                    margin: const EdgeInsets.symmetric(horizontal: 7),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled ? _primary : Colors.transparent,
                      border: Border.all(
                        color: filled ? _primary : _border,
                        width: filled ? 0 : 1.5,
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_errorMessage != null) ...<Widget>[
              const SizedBox(height: 11),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: _theme.colorScheme.error,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _key({
    required String label,
    required VoidCallback onTap,
    IconData? icon,
    bool highlighted = false,
  }) {
    final bool disabled =
        _isLoading || _isBiometricLoading || _isLocked;

    return SizedBox(
      width: 74,
      height: 62,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: disabled ? null : onTap,
          borderRadius: BorderRadius.circular(21),
          child: Ink(
            decoration: BoxDecoration(
              color: highlighted
                  ? _primary.withValues(alpha: 0.10)
                  : _surface,
              borderRadius: BorderRadius.circular(21),
              border: Border.all(
                color: highlighted
                    ? _primary.withValues(alpha: 0.22)
                    : _border,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: _isDark ? 0.08 : 0.03,
                  ),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: icon != null
                  ? Icon(
                icon,
                size: 22,
                color: disabled
                    ? _textSecondary
                    : highlighted
                    ? _primary
                    : _textPrimary,
              )
                  : Text(
                label,
                style: GoogleFonts.poppins(
                  color: disabled
                      ? _textSecondary
                      : _textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _key(label: '1', onTap: () => _addDigit('1')),
              _key(label: '2', onTap: () => _addDigit('2')),
              _key(label: '3', onTap: () => _addDigit('3')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _key(label: '4', onTap: () => _addDigit('4')),
              _key(label: '5', onTap: () => _addDigit('5')),
              _key(label: '6', onTap: () => _addDigit('6')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _key(label: '7', onTap: () => _addDigit('7')),
              _key(label: '8', onTap: () => _addDigit('8')),
              _key(label: '9', onTap: () => _addDigit('9')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              if (widget.showBiometric && widget.onBiometric != null)
                _key(
                  label: '',
                  icon: Icons.fingerprint_rounded,
                  highlighted: true,
                  onTap: _authenticateBiometric,
                )
              else
                const SizedBox(width: 74, height: 62),
              _key(label: '0', onTap: () => _addDigit('0')),
              _key(
                label: '',
                icon: Icons.backspace_outlined,
                onTap: _deleteDigit,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: <Widget>[
        if (widget.showBiometric && widget.onBiometric != null)
          TextButton.icon(
            onPressed: _isBiometricLoading
                ? null
                : _authenticateBiometric,
            icon: _isBiometricLoading
                ? SizedBox(
              width: 15,
              height: 15,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: _primary,
              ),
            )
                : Icon(
              Icons.fingerprint_rounded,
              color: _primary,
              size: 18,
            ),
            label: Text(
              _isBiometricLoading
                  ? 'Authenticating...'
                  : 'Use biometric',
              style: GoogleFonts.poppins(
                color: _primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        if (widget.showForgotPin && widget.onForgotPin != null)
          TextButton(
            onPressed: _isLoading ? null : widget.onForgotPin,
            child: Text(
              'Forgot MPIN?',
              style: GoogleFonts.poppins(
                color: _primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        const SizedBox(height: 3),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.shield_outlined,
              color: _textSecondary,
              size: 14,
            ),
            const SizedBox(width: 5),
            Text(
              'Protected by AiTradeX security',
              style: GoogleFonts.poppins(
                color: _textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsets safe = MediaQuery.of(context).padding;

    return PopScope(
      canPop: widget.allowBack,
      child: Scaffold(
        backgroundColor: _background,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (
                BuildContext context,
                BoxConstraints constraints,
                ) {
              final bool compact = constraints.maxHeight < 720;

              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  20,
                  compact ? 14 : 26,
                  20,
                  safe.bottom + 18,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 430,
                    ),
                    child: Column(
                      children: <Widget>[
                        _buildHeader(),
                        _buildPinIndicator(),
                        _buildKeypad(),
                        if (_isLoading)
                          Padding(
                            padding: const EdgeInsets.only(top: 14),
                            child: SizedBox(
                              width: 19,
                              height: 19,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: _primary,
                              ),
                            ),
                          ),
                        SizedBox(height: compact ? 9 : 17),
                        _buildFooter(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
