import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aitradex/screens/account/setpin_screen.dart';
import 'package:aitradex/services/app_lock_service.dart';
import 'package:aitradex/services/biometric_auth_service.dart';

// ============================================================================
// SECURITY SCREEN
// ============================================================================
//
// Supports:
// - Light Mode
// - Dark Mode
// - Global App Theme color
// - Dynamic primary color from Theme.of(context).colorScheme.primary
// - Theme-aware cards, backgrounds, text, borders and bottom sheets
//
// ============================================================================
// THEME HELPERS
// ============================================================================

Color _primary({
  required BuildContext context,
}) {
  return Theme.of(context).colorScheme.primary;
}

Color _background({
  required BuildContext context,
}) {
  return Theme.of(context).scaffoldBackgroundColor;
}

Color _card({
  required BuildContext context,
}) {
  return Theme.of(context).cardColor;
}

Color _textPrimary({
  required BuildContext context,
}) {
  return Theme.of(context).colorScheme.onSurface;
}

Color _textSecondary({
  required BuildContext context,
}) {
  return _textPrimary(
    context: context,
  ).withValues(
    alpha: 0.62,
  );
}

Color _textMuted({
  required BuildContext context,
}) {
  return _textPrimary(
    context: context,
  ).withValues(
    alpha: 0.45,
  );
}

Color _border({
  required BuildContext context,
}) {
  return Theme.of(context).dividerColor.withValues(
    alpha: 0.55,
  );
}

Color _softPrimary({
  required BuildContext context,
  double alpha = 0.10,
}) {
  return _primary(
    context: context,
  ).withValues(
    alpha: alpha,
  );
}

Color _softSurface({
  required BuildContext context,
}) {
  return _textPrimary(
    context: context,
  ).withValues(
    alpha: 0.055,
  );
}

bool _isDark({
  required BuildContext context,
}) {
  return Theme.of(context).brightness == Brightness.dark;
}

// ============================================================================
// SECURITY SCREEN
// ============================================================================

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({
    super.key,
  });

  @override
  State<SecurityScreen> createState() =>
      _SecurityScreenState();
}

class _SecurityScreenState
    extends State<SecurityScreen> {
  // ==========================================================================
  // SETTINGS
  // ==========================================================================

  bool rememberMe = true;
  bool biometricId = false;
  bool faceId = false;
  bool twoFactorEnabled = false;

  bool _busy = false;

  static const String _rememberMeKey = 'aitradex_remember_me';

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  void initState() {
    super.initState();
    _loadSecuritySettings();
  }

  Future<void> _loadSecuritySettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final bool appLockEnabled = await AppLockService.isEnabled();
      final bool remember = prefs.getBool(_rememberMeKey) ?? true;
      final bool fingerprintEnabled =
      await BiometricAuthService.isFingerprintEnabled();
      final bool faceEnabled =
      await BiometricAuthService.isFaceEnabled();

      if (!mounted) return;

      setState(() {
        rememberMe = remember;
        twoFactorEnabled = appLockEnabled;
        biometricId = fingerprintEnabled;
        faceId = faceEnabled;
      });
    } catch (error, stackTrace) {
      debugPrint('SECURITY SETTINGS LOAD ERROR: $error');
      debugPrint(stackTrace.toString());
      if (!mounted) return;
      setState(() {
      });
    }
  }

  Future<void> _setRememberMe(bool value) async {
    if (_busy) return;
    setState(() => rememberMe = value);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_rememberMeKey, value);
      _showSnackBar(
        value
            ? 'Remember me enabled.'
            : 'Remember me disabled. You will sign in again after the next app restart.',
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => rememberMe = !value);
      _showSnackBar('Unable to save Remember me setting.');
      debugPrint('REMEMBER ME ERROR: $error');
    }
  }

  Future<void> _setBiometricId(bool value) async {
    await _setBiometric(
      value: value,
      type: BiometricType.fingerprint,
      title: 'Biometric ID',
    );
  }

  Future<void> _setFaceId(bool value) async {
    await _setBiometric(
      value: value,
      type: BiometricType.face,
      title: 'Face ID',
    );
  }

  Future<void> _setBiometric({
    required bool value,
    required BiometricType type,
    required String title,
  }) async {
    if (_busy) return;

    if (!value) {
      try {
        if (type == BiometricType.fingerprint) {
          await BiometricAuthService.setFingerprintEnabled(false);
          if (mounted) setState(() => biometricId = false);
        } else {
          await BiometricAuthService.setFaceEnabled(false);
          if (mounted) setState(() => faceId = false);
        }
        _showSnackBar('$title disabled.');
      } catch (error) {
        debugPrint('$title disable error: $error');
        _showSnackBar('Unable to disable $title.');
      }
      return;
    }

    if (!twoFactorEnabled) {
      _showSnackBar(
        'Turn on Two-Factor Authentication first to use $title for App Lock.',
      );
      return;
    }

    setState(() => _busy = true);
    try {
      final bool supported =
      await BiometricAuthService.isTypeAvailable(type);

      if (!supported) {
        _showSnackBar(
          type == BiometricType.face
              ? 'Face ID is not available on this device.'
              : 'Fingerprint/Biometric ID is not available on this device.',
        );
        return;
      }

      final bool authenticated =
      await BiometricAuthService.authenticate(
        reason: 'Verify your identity to enable $title for AiTradeX App Lock.',
      );

      if (!authenticated) {
        _showSnackBar('$title verification was cancelled or failed.');
        return;
      }

      if (type == BiometricType.fingerprint) {
        await BiometricAuthService.setFingerprintEnabled(true);
        if (mounted) setState(() => biometricId = true);
      } else {
        await BiometricAuthService.setFaceEnabled(true);
        if (mounted) setState(() => faceId = true);
      }

      _showSnackBar('$title enabled.');
    } catch (error, stackTrace) {
      debugPrint('$title enable error: $error');
      debugPrint(stackTrace.toString());
      _showSnackBar('Unable to enable $title.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = _primary(
      context: context,
    );

    return Scaffold(
      backgroundColor: _background(
        context: context,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),

            Expanded(
              child: RefreshIndicator(
                color: primary,
                backgroundColor: _card(
                  context: context,
                ),
                onRefresh: _refreshSecurity,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    8,
                    20,
                    32,
                  ),
                  children: [
                    _buildSecurityStatusCard(context),

                    const SizedBox(height: 24),

                    _buildSectionTitle(
                      context,
                      'Login Security',
                    ),

                    const SizedBox(height: 10),

                    _buildSecurityCard(
                      context,
                      children: [
                        _buildSwitchRow(
                          context: context,
                          icon: Icons.login_rounded,
                          iconBackground: const Color(
                            0xFFEEF4FF,
                          ),
                          iconColor: const Color(
                            0xFF4776E6,
                          ),
                          title: 'Remember me',
                          description:
                          'Keep your account signed in on this device.',
                          value: rememberMe,
                          onChanged: _setRememberMe,
                        ),

                        _buildDivider(context),

                        _buildSwitchRow(
                          context: context,
                          icon: Icons.fingerprint_rounded,
                          iconBackground: _softPrimary(
                            context: context,
                            alpha: 0.10,
                          ),
                          iconColor: primary,
                          title: 'Biometric ID',
                          description:
                          'Use your fingerprint for faster login.',
                          value: biometricId,
                          onChanged: _setBiometricId,
                        ),

                        _buildDivider(context),

                        _buildSwitchRow(
                          context: context,
                          icon: Icons.face_rounded,
                          iconBackground: _softOrange(
                            context: context,
                          ),
                          iconColor: const Color(
                            0xFFF28B45,
                          ),
                          title: 'Face ID',
                          description:
                          'Use face recognition for secure access.',
                          value: faceId,
                          onChanged: _setFaceId,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    _buildSectionTitle(
                      context,
                      'Account Protection',
                    ),

                    const SizedBox(height: 10),

                    _buildSecurityCard(
                      context,
                      children: [
                        _buildActionRow(
                          context: context,
                          icon: Icons.verified_user_rounded,
                          iconBackground: _softPrimary(
                            context: context,
                            alpha: 0.10,
                          ),
                          iconColor: primary,
                          title: 'Two-Factor Authentication',
                          description:
                          'Add an extra layer of protection to your account.',
                          trailing: _buildStatusBadge(
                            context: context,
                            enabled: twoFactorEnabled,
                          ),
                          onTap:
                          _openTwoFactorAuthentication,
                        ),

                        _buildDivider(context),

                        _buildActionRow(
                          context: context,
                          icon: Icons.lock_reset_rounded,
                          iconBackground:
                          _softOrange(
                            context: context,
                          ),
                          iconColor: const Color(
                            0xFFF28B45,
                          ),
                          title: 'Change PIN',
                          description:
                          'Update your security PIN regularly.',
                          onTap: _openChangePin,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    _buildSecurityInfoCard(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // HEADER
  // ==========================================================================

  Widget _buildHeader(BuildContext context) {
    final Color primary = _primary(
      context: context,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        14,
        20,
        14,
      ),
      child: Row(
        children: [
          _buildBackButton(context),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Security',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary(
                      context: context,
                    ),
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  'Protect your AiTradeX account',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: _textSecondary(
                      context: context,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _softPrimary(
                context: context,
                alpha: 0.10,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: primary.withValues(
                  alpha: 0.08,
                ),
              ),
            ),
            child: Icon(
              Icons.shield_rounded,
              color: primary,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // BACK BUTTON
  // ==========================================================================

  Widget _buildBackButton(
      BuildContext context,
      ) {
    final Color primary = _primary(
      context: context,
    );

    return Material(
      color: _card(
        context: context,
      ),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop();
        },
        borderRadius: BorderRadius.circular(14),
        splashColor: primary.withValues(
          alpha: 0.08,
        ),
        highlightColor: primary.withValues(
          alpha: 0.04,
        ),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _border(
                context: context,
              ),
            ),
          ),
          child: Icon(
            Icons.arrow_back_rounded,
            size: 21,
            color: _textPrimary(
              context: context,
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // SECURITY STATUS
  // ==========================================================================

  Widget _buildSecurityStatusCard(
      BuildContext context,
      ) {
    final Color primary = _primary(
      context: context,
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card(
          context: context,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _border(
            context: context,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: _isDark(
                context: context,
              )
                  ? 0.12
                  : 0.035,
            ),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _softPrimary(
                context: context,
                alpha: 0.10,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: primary.withValues(
                  alpha: 0.16,
                ),
              ),
            ),
            child: Icon(
              Icons.shield_outlined,
              color: primary,
              size: 29,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Your account is protected',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary(
                      context: context,
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Manage your login and authentication settings.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    height: 1.45,
                    color: _textSecondary(
                      context: context,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: _softPrimary(
                context: context,
                alpha: 0.09,
              ),
              borderRadius:
              BorderRadius.circular(20),
            ),
            child: Text(
              'Secure',
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // SECTION TITLE
  // ==========================================================================

  Widget _buildSectionTitle(
      BuildContext context,
      String title,
      ) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 3,
      ),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: _textPrimary(
            context: context,
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // SECURITY CARD
  // ==========================================================================

  Widget _buildSecurityCard(
      BuildContext context, {
        required List<Widget> children,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: _card(
          context: context,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _border(
            context: context,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: _isDark(
                context: context,
              )
                  ? 0.10
                  : 0.025,
            ),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  // ==========================================================================
  // SWITCH ROW
  // ==========================================================================

  Widget _buildSwitchRow({
    required BuildContext context,
    required IconData icon,
    required Color iconBackground,
    required Color iconColor,
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        15,
        12,
        15,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.center,
        children: [
          _buildIconContainer(
            context: context,
            icon: icon,
            backgroundColor: iconBackground,
            iconColor: iconColor,
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary(
                      context: context,
                    ),
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    height: 1.35,
                    color: _textSecondary(
                      context: context,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          _AiTradeXSwitch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // ACTION ROW
  // ==========================================================================

  Widget _buildActionRow({
    required BuildContext context,
    required IconData icon,
    required Color iconBackground,
    required Color iconColor,
    required String title,
    required String description,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    final Color primary = _primary(
      context: context,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: primary.withValues(
          alpha: 0.05,
        ),
        highlightColor: primary.withValues(
          alpha: 0.025,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            15,
            14,
            15,
          ),
          child: Row(
            children: [
              _buildIconContainer(
                context: context,
                icon: icon,
                backgroundColor: iconBackground,
                iconColor: iconColor,
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary(
                          context: context,
                        ),
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      description,
                      maxLines: 2,
                      overflow:
                      TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        height: 1.35,
                        color: _textSecondary(
                          context: context,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              if (trailing != null)
                trailing
              else
                Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: _textMuted(
                    context: context,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // ICON CONTAINER
  // ==========================================================================

  Widget _buildIconContainer({
    required BuildContext context,
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: iconColor.withValues(
            alpha: 0.08,
          ),
        ),
      ),
      child: Icon(
        icon,
        size: 20,
        color: iconColor,
      ),
    );
  }

  // ==========================================================================
  // DIVIDER
  // ==========================================================================

  Widget _buildDivider(
      BuildContext context,
      ) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 71,
      ),
      child: Divider(
        height: 1,
        thickness: 1,
        color: _border(
          context: context,
        ),
      ),
    );
  }

  // ==========================================================================
  // STATUS BADGE
  // ==========================================================================

  Widget _buildStatusBadge({
    required BuildContext context,
    required bool enabled,
  }) {
    final Color primary = _primary(
      context: context,
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: enabled
            ? _softPrimary(
          context: context,
          alpha: 0.10,
        )
            : _softSurface(
          context: context,
        ),
        borderRadius:
        BorderRadius.circular(20),
        border: Border.all(
          color: enabled
              ? primary.withValues(
            alpha: 0.08,
          )
              : _border(
            context: context,
          ),
          width: 0.7,
        ),
      ),
      child: Text(
        enabled ? 'On' : 'Off',
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: enabled
              ? primary
              : _textSecondary(
            context: context,
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // SECURITY INFO
  // ==========================================================================

  Widget _buildSecurityInfoCard(
      BuildContext context,
      ) {
    final Color primary = _primary(
      context: context,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _softPrimary(
          context: context,
          alpha: _isDark(
            context: context,
          )
              ? 0.08
              : 0.055,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: primary.withValues(
            alpha: 0.12,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _card(
                context: context,
              ),
              borderRadius:
              BorderRadius.circular(11),
              border: Border.all(
                color: primary.withValues(
                  alpha: 0.08,
                ),
              ),
            ),
            child: Icon(
              Icons.info_outline_rounded,
              color: primary,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Keep your account secure',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary(
                      context: context,
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Never share your password, PIN, OTP, or '
                      'verification codes with anyone.',
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    height: 1.45,
                    color: _textSecondary(
                      context: context,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // TWO-FACTOR AUTHENTICATION
  // ==========================================================================

  Future<void> _openTwoFactorAuthentication() async {
    if (_busy) return;

    if (twoFactorEnabled) {
      await _disableAppLock();
      return;
    }

    setState(() => _busy = true);
    try {
      final bool hasPin = await AppLockService.hasPin();

      if (!hasPin) {
        final bool? created = await Navigator.of(context).push<bool>(
          MaterialPageRoute<bool>(
            builder: (_) => SetPinScreen(
              onPinCreated: (pin) async {
                await AppLockService.enable(pin);
                return true;
              },
            ),
          ),
        );

        if (created != true) return;
      } else {
        final String? existingPin = await AppLockService.getPin();
        if (existingPin == null) {
          _showSnackBar('Please create your App Lock PIN again.');
          return;
        }
        await AppLockService.enable(existingPin);
      }

      if (!mounted) return;
      setState(() => twoFactorEnabled = true);
      _showSnackBar('Two-Factor Authentication and App Lock enabled.');
    } catch (error, stackTrace) {
      debugPrint('ENABLE APP LOCK ERROR: $error');
      debugPrint(stackTrace.toString());
      _showSnackBar('Unable to enable App Lock.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _disableAppLock() async {
    try {
      await AppLockService.disable();
      await BiometricAuthService.setFingerprintEnabled(false);
      await BiometricAuthService.setFaceEnabled(false);

      if (!mounted) return;
      setState(() {
        twoFactorEnabled = false;
        biometricId = false;
        faceId = false;
      });
      _showSnackBar('Two-Factor Authentication and App Lock disabled.');
    } catch (error, stackTrace) {
      debugPrint('DISABLE APP LOCK ERROR: $error');
      debugPrint(stackTrace.toString());
      _showSnackBar('Unable to disable App Lock.');
    }
  }

  void _openChangePin() {
    if (!twoFactorEnabled) {
      _showSnackBar(
        'Turn on Two-Factor Authentication first to change the App Lock PIN.',
      );
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return _ChangePinSheet(
          onSubmit: (
              String currentPin,
              String newPin,
              String confirmPin,
              ) {
            _validatePinChange(
              sheetContext,
              currentPin,
              newPin,
              confirmPin,
            );
          },
        );
      },
    );
  }

  // ==========================================================================
  // PIN VALIDATION
  // ==========================================================================

  Future<void> _validatePinChange(
      BuildContext sheetContext,
      String currentPin,
      String newPin,
      String confirmPin,
      ) async {
    if (currentPin.isEmpty || newPin.isEmpty || confirmPin.isEmpty) {
      _showSnackBar('Please fill in all PIN fields.');
      return;
    }

    if (!RegExp(r'^\d{4}$').hasMatch(currentPin) ||
        !RegExp(r'^\d{4}$').hasMatch(newPin) ||
        !RegExp(r'^\d{4}$').hasMatch(confirmPin)) {
      _showSnackBar('PIN must contain exactly 4 digits.');
      return;
    }

    if (newPin != confirmPin) {
      _showSnackBar('New PIN and confirmation PIN do not match.');
      return;
    }

    if (currentPin == newPin) {
      _showSnackBar('New PIN must be different from your current PIN.');
      return;
    }

    try {
      final bool currentPinValid =
      await AppLockService.verify(currentPin);

      if (!currentPinValid) {
        _showSnackBar('Current PIN is incorrect.');
        return;
      }

      await AppLockService.enable(newPin);

      if (!mounted) return;
      Navigator.of(sheetContext).pop();
      _showSnackBar('App Lock PIN changed successfully.');
    } catch (error, stackTrace) {
      debugPrint('CHANGE PIN ERROR: $error');
      debugPrint(stackTrace.toString());
      _showSnackBar('Unable to change PIN. Please try again.');
    }
  }

  Future<void> _refreshSecurity() async {
    await _loadSecuritySettings();
  }

  // ==========================================================================
  // MESSAGE
  // ==========================================================================

  void _showSnackBar(
      String message,
      ) {
    if (!mounted) {
      return;
    }

    final Color primary = _primary(
      context: context,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          behavior:
          SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            16,
          ),
          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(14),
          ),
          backgroundColor: primary,
        ),
      );
  }

  // ==========================================================================
  // ORANGE SOFT COLOR
  // ==========================================================================

  Color _softOrange({
    required BuildContext context,
  }) {
    if (_isDark(context: context)) {
      return const Color(0xFFF28B45).withValues(
        alpha: 0.12,
      );
    }

    return const Color(0xFFFFF1E8);
  }
}

// ============================================================================
// CUSTOM APP SWITCH
// ============================================================================

class _AiTradeXSwitch extends StatelessWidget {
  const _AiTradeXSwitch({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final Color primary = _primary(
      context: context,
    );

    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 220,
        ),
        curve: Curves.easeOut,
        width: 50,
        height: 29,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value
              ? primary
              : _isDark(
            context: context,
          )
              ? Colors.white.withValues(
            alpha: 0.16,
          )
              : const Color(0xFFDCDDE0),
          borderRadius:
          BorderRadius.circular(20),
          border: Border.all(
            color: value
                ? primary.withValues(
              alpha: 0.30,
            )
                : _border(
              context: context,
            ),
            width: 0.7,
          ),
        ),
        child: AnimatedAlign(
          duration: const Duration(
            milliseconds: 220,
          ),
          curve: Curves.easeOut,
          alignment: value
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            width: 23,
            height: 23,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: _isDark(
                      context: context,
                    )
                        ? 0.28
                        : 0.10,
                  ),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// TWO FACTOR SHEET
// ============================================================================

// ============================================================================
// CHANGE PIN SHEET
// ============================================================================
//
// Controllers belong to this StatefulWidget instead of the parent
// showModalBottomSheet closure. They are therefore disposed only when the
// sheet widget itself is removed from the tree, preventing:
//
// TextEditingController was used after being disposed.
//
// ============================================================================
class _ChangePinSheet extends StatefulWidget {
  final void Function(
      String currentPin,
      String newPin,
      String confirmPin,
      ) onSubmit;

  const _ChangePinSheet({
    required this.onSubmit,
  });

  @override
  State<_ChangePinSheet> createState() => _ChangePinSheetState();
}

class _ChangePinSheetState extends State<_ChangePinSheet> {
  late final TextEditingController _currentPinController;
  late final TextEditingController _newPinController;
  late final TextEditingController _confirmPinController;

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();

    _currentPinController = TextEditingController();
    _newPinController = TextEditingController();
    _confirmPinController = TextEditingController();
  }

  @override
  void dispose() {
    _currentPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Color _primary(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  Color _card(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.cardColor;
  }

  Color _border(BuildContext context) {
    final Color primary = _primary(context);
    return primary.withValues(
      alpha: Theme.of(context).brightness == Brightness.dark
          ? 0.18
          : 0.12,
    );
  }

  Color _textPrimary(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  Color _textSecondary(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface.withValues(
      alpha: 0.62,
    );
  }

  Color _softSurface(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color primary = theme.colorScheme.primary;

    return theme.brightness == Brightness.dark
        ? primary.withValues(alpha: 0.07)
        : theme.colorScheme.surfaceContainerHighest.withValues(
      alpha: 0.48,
    );
  }

  Widget _buildPinField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    final Color primary = _primary(context);

    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: TextInputType.number,
      maxLength: 4,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
      ],
      textInputAction: TextInputAction.next,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: _textPrimary(context),
      ),
      cursorColor: primary,
      decoration: InputDecoration(
        counterText: '',
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          fontSize: 12,
          color: _textSecondary(context),
        ),
        floatingLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
          color: primary,
          fontWeight: FontWeight.w600,
        ),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            obscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: _textSecondary(context),
            size: 20,
          ),
        ),
        filled: true,
        fillColor: _softSurface(context),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: _border(context),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: _border(context),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          20,
          10,
          20,
          24,
        ),
        decoration: BoxDecoration(
          color: _card(context),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(28),
          ),
          border: Border.all(
            color: _border(context),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _border(context),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Change PIN',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary(context),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Create a new PIN for your AiTradeX account.',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: _textSecondary(context),
                ),
              ),
              const SizedBox(height: 22),
              _buildPinField(
                context: context,
                controller: _currentPinController,
                label: 'Current PIN',
                obscureText: _obscureCurrent,
                onToggle: () {
                  setState(() {
                    _obscureCurrent = !_obscureCurrent;
                  });
                },
              ),
              const SizedBox(height: 13),
              _buildPinField(
                context: context,
                controller: _newPinController,
                label: 'New PIN',
                obscureText: _obscureNew,
                onToggle: () {
                  setState(() {
                    _obscureNew = !_obscureNew;
                  });
                },
              ),
              const SizedBox(height: 13),
              _buildPinField(
                context: context,
                controller: _confirmPinController,
                label: 'Confirm New PIN',
                obscureText: _obscureConfirm,
                onToggle: () {
                  setState(() {
                    _obscureConfirm = !_obscureConfirm;
                  });
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onSubmit(
                      _currentPinController.text.trim(),
                      _newPinController.text.trim(),
                      _confirmPinController.text.trim(),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary(context),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Update PIN',
                    style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

