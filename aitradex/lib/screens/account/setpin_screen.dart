import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// AiTradeX 4-digit MPIN setup screen.
///
/// Flow:
/// 1. Create a 4-digit MPIN.
/// 2. Confirm the same 4-digit MPIN.
/// 3. [onPinCreated] receives the final MPIN.
///
/// The screen automatically uses the current ThemeData, therefore your
/// AiTradeX Light Mode, Dark Mode, and dynamic App Theme primary color
/// are applied without hardcoded theme colors.
///
/// IMPORTANT:
/// Persist the final MPIN using secure storage. Do not save a plaintext
/// MPIN in SharedPreferences.
class SetPinScreen extends StatefulWidget {
  final Future<bool> Function(String pin)? onPinCreated;
  final VoidCallback? onCancel;
  final bool allowCancel;

  const SetPinScreen({
    super.key,
    this.onPinCreated,
    this.onCancel,
    this.allowCancel = true,
  });

  @override
  State<SetPinScreen> createState() => _SetPinScreenState();
}

enum _SetPinStep {
  create,
  confirm,
}

class _SetPinScreenState extends State<SetPinScreen>
    with SingleTickerProviderStateMixin {
  static const int _pinLength = 4;

  final List<String> _pin = <String>[];

  _SetPinStep _step = _SetPinStep.create;

  String? _firstPin;
  String? _errorMessage;
  bool _isSaving = false;

  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

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

  bool get _isConfirming => _step == _SetPinStep.confirm;

  String get _title =>
      _isConfirming ? 'Confirm your MPIN' : 'Create your MPIN';

  String get _subtitle => _isConfirming
      ? 'Enter the same 4-digit MPIN again'
      : 'Set a 4-digit MPIN to protect your AiTradeX account';

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
    if (_isSaving || _pin.length >= _pinLength) return;

    HapticFeedback.selectionClick();

    setState(() {
      _errorMessage = null;
      _pin.add(digit);
    });

    if (_pin.length == _pinLength) {
      _finishCurrentStep();
    }
  }

  void _deleteDigit() {
    if (_isSaving || _pin.isEmpty) return;

    HapticFeedback.selectionClick();

    setState(() {
      _errorMessage = null;
      _pin.removeLast();
    });
  }

  Future<void> _finishCurrentStep() async {
    final String currentPin = _pin.join();

    if (!_isConfirming) {
      setState(() {
        _firstPin = currentPin;
        _pin.clear();
        _errorMessage = null;
        _step = _SetPinStep.confirm;
      });

      HapticFeedback.mediumImpact();
      return;
    }

    if (_firstPin == null || currentPin != _firstPin) {
      _showError('MPINs do not match. Please try again.');
      return;
    }

    if (widget.onPinCreated == null) {
      _showError('MPIN save handler is not configured.');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final bool saved = await widget.onPinCreated!(currentPin);

      if (!mounted) return;

      if (!saved) {
        _showError('Unable to save your MPIN. Please try again.');
        return;
      }

      HapticFeedback.heavyImpact();

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (_) {
      if (!mounted) return;
      _showError('Unable to save your MPIN. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    setState(() {
      _errorMessage = message;
      _pin.clear();
      _isSaving = false;
    });

    _shake();
    HapticFeedback.vibrate();
  }

  void _goBackToCreate() {
    if (_isSaving) return;

    setState(() {
      _step = _SetPinStep.create;
      _firstPin = null;
      _pin.clear();
      _errorMessage = null;
    });
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
            child: Icon(
              _isConfirming
                  ? Icons.verified_user_rounded
                  : Icons.lock_open_rounded,
              color: Colors.white,
              size: 30,
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
          _title,
          style: GoogleFonts.poppins(
            color: _textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          _subtitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: _textSecondary,
            fontSize: 12.5,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildProgress() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 6,
              decoration: BoxDecoration(
                color: _primary,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 6,
              decoration: BoxDecoration(
                color: _isConfirming
                    ? _primary
                    : _theme.dividerColor.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinIndicator() {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (BuildContext context, Widget? child) {
        final double shake =
        _errorMessage == null ? 0 : _shakeAnimation.value * 7;

        return Transform.translate(
          offset: Offset(shake, 0),
          child: child,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(top: 15),
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
    return SizedBox(
      width: 74,
      height: 62,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isSaving ? null : onTap,
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
                color: highlighted ? _primary : _textPrimary,
              )
                  : Text(
                label,
                style: GoogleFonts.poppins(
                  color: _textPrimary,
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

  Widget _buildBottom() {
    return Column(
      children: <Widget>[
        if (_isConfirming)
          TextButton(
            onPressed: _isSaving ? null : _goBackToCreate,
            child: Text(
              'Change MPIN',
              style: GoogleFonts.poppins(
                color: _primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        if (widget.allowCancel && widget.onCancel != null)
          TextButton(
            onPressed: _isSaving ? null : widget.onCancel,
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: _textSecondary,
                fontSize: 12,
              ),
            ),
          ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.shield_outlined,
              size: 14,
              color: _textSecondary,
            ),
            const SizedBox(width: 5),
            Text(
              'Secure MPIN protection',
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
      canPop: widget.allowCancel,
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
                  compact ? 14 : 25,
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
                        _buildProgress(),
                        _buildPinIndicator(),
                        _buildKeypad(),
                        if (_isSaving)
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
                        SizedBox(height: compact ? 8 : 16),
                        _buildBottom(),
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
