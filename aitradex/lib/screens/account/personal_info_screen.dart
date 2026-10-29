import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/shared_preferences_service.dart';

/// AiTradeX Personal Information
///
/// Read-only account screen.
///
/// The screen is aligned with the current AiTradeX MongoDB user document:
/// - firebaseUid
/// - fullName
/// - username
/// - email
/// - phoneNumber
/// - profileImage
/// - emailVerified
/// - phoneVerified
/// - isActive
/// - isBlocked
/// - firebaseCreatedAt
/// - firebaseLastSignInAt
/// - createdAt
/// - updatedAt
class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  bool _isLoading = true;
  bool _hasProfile = false;

  String _firebaseUid = '';
  String _fullName = '';
  String _username = '';
  String _email = '';
  String _phoneNumber = '';
  String _profileImage = '';

  bool _emailVerified = false;
  bool _phoneVerified = false;
  bool _isActive = true;
  bool _isBlocked = false;

  String _firebaseCreatedAt = '';
  String _firebaseLastSignInAt = '';
  String _createdAt = '';
  String _updatedAt = '';

  ThemeData _theme(BuildContext context) => Theme.of(context);

  Color _primary(BuildContext context) {
    return _theme(context).colorScheme.primary;
  }

  Color _background(BuildContext context) {
    return _theme(context).scaffoldBackgroundColor;
  }

  Color _surface(BuildContext context) {
    return _theme(context).colorScheme.surface;
  }

  Color _surfaceVariant(BuildContext context) {
    return _theme(context).colorScheme.surfaceContainerHighest;
  }

  Color _textPrimary(BuildContext context) {
    return _theme(context).colorScheme.onSurface;
  }

  Color _textSecondary(BuildContext context) {
    return _textPrimary(context).withValues(alpha: 0.64);
  }

  Color _textMuted(BuildContext context) {
    return _textPrimary(context).withValues(alpha: 0.42);
  }

  Color _border(BuildContext context) {
    return _textPrimary(context).withValues(alpha: 0.10);
  }

  Color _softPrimary(BuildContext context) {
    final bool dark = _theme(context).brightness == Brightness.dark;
    return _primary(context).withValues(alpha: dark ? 0.15 : 0.08);
  }

  bool _isDark(BuildContext context) {
    return _theme(context).brightness == Brightness.dark;
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final Map<String, dynamic> profile =
      await SharedPreferencesService.getUserProfile();

      String value(String key, [String fallback = '']) {
        final dynamic raw = profile[key];
        if (raw == null) {
          return fallback;
        }

        final String text = raw.toString().trim();
        return text.isEmpty ? fallback : text;
      }

      bool booleanValue(String key, {bool fallback = false}) {
        final dynamic raw = profile[key];

        if (raw is bool) {
          return raw;
        }

        if (raw is num) {
          return raw != 0;
        }

        if (raw is String) {
          final String text = raw.trim().toLowerCase();

          if (text == 'true' || text == '1') {
            return true;
          }

          if (text == 'false' || text == '0') {
            return false;
          }
        }

        return fallback;
      }

      String firstNonEmpty(List<String> values) {
        for (final String item in values) {
          final String text = item.trim();
          if (text.isNotEmpty) {
            return text;
          }
        }
        return '';
      }

      // ----------------------------------------------------------------------
      // MongoDB field names are the PRIMARY keys.
      // Old local profile keys are supported only as compatibility fallbacks.
      // ----------------------------------------------------------------------

      final String fullName = firstNonEmpty(<String>[
        value('fullName'),
        value('name'),
      ]);

      final String username = firstNonEmpty(<String>[
        value('username'),
        value('userName'),
      ]);

      final String email = value('email');

      final String phoneNumber = firstNonEmpty(<String>[
        value('phoneNumber'),
        value('phone'),
      ]);

      final String profileImage = firstNonEmpty(<String>[
        value('profileImage'),
        value('profileImageUrl'),
      ]);

      final String firebaseUid = value('firebaseUid');

      final bool emailVerified = booleanValue(
        'emailVerified',
        fallback: false,
      );

      final bool phoneVerified = booleanValue(
        'phoneVerified',
        fallback: false,
      );

      final bool isActive = booleanValue(
        'isActive',
        fallback: true,
      );

      final bool isBlocked = booleanValue(
        'isBlocked',
        fallback: false,
      );

      final String firebaseCreatedAt = value('firebaseCreatedAt');
      final String firebaseLastSignInAt = value('firebaseLastSignInAt');
      final String createdAt = value('createdAt');
      final String updatedAt = value('updatedAt');

      if (!mounted) {
        return;
      }

      setState(() {
        _firebaseUid = firebaseUid;
        _fullName = fullName;
        _username = username;
        _email = email;
        _phoneNumber = phoneNumber;
        _profileImage = profileImage;

        _emailVerified = emailVerified;
        _phoneVerified = phoneVerified;
        _isActive = isActive;
        _isBlocked = isBlocked;

        _firebaseCreatedAt = firebaseCreatedAt;
        _firebaseLastSignInAt = firebaseLastSignInAt;
        _createdAt = createdAt;
        _updatedAt = updatedAt;

        _hasProfile =
            fullName.isNotEmpty ||
                username.isNotEmpty ||
                email.isNotEmpty ||
                phoneNumber.isNotEmpty ||
                firebaseUid.isNotEmpty;
      });
    } catch (error, stackTrace) {
      debugPrint('PERSONAL INFO LOAD ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) {
        return;
      }

      setState(() {
        _hasProfile = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatDate(String value) {
    final String input = value.trim();

    if (input.isEmpty) {
      return '';
    }

    DateTime? date = DateTime.tryParse(input);

    if (date == null) {
      final String normalized =
      input.replaceFirst(RegExp(r'\s+UTC$'), 'Z');
      date = DateTime.tryParse(normalized);
    }

    if (date == null) {
      return input;
    }

    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  String _formatDateTime(String value) {
    final String input = value.trim();

    if (input.isEmpty) {
      return '';
    }

    final DateTime? date = DateTime.tryParse(input);

    if (date == null) {
      return input;
    }

    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String hour = date.hour.toString().padLeft(2, '0');
    final String minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/${date.year}  $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background(context),
      body: SafeArea(
        child: _isLoading
            ? _buildLoading(context)
            : !_hasProfile
            ? _buildEmpty(context)
            : _buildContent(context),
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: _softPrimary(context),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CircularProgressIndicator(
                color: _primary(context),
                strokeWidth: 2.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading profile...',
            style: GoogleFonts.poppins(
              color: _textSecondary(context),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: _softPrimary(context),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_outline_rounded,
                      size: 48,
                      color: _primary(context),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Profile information unavailable',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: _textPrimary(context),
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No saved AiTradeX account information was found.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: _textSecondary(context),
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 22),
                  ElevatedButton(
                    onPressed: _loadProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary(context),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Reload',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return RefreshIndicator(
      color: _primary(context),
      backgroundColor: _surface(context),
      onRefresh: _loadProfile,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 22),
            _buildProfileHero(context),
            const SizedBox(height: 24),
            _buildSectionTitle(
              context,
              'Account Information',
              Icons.person_outline_rounded,
            ),
            const SizedBox(height: 12),
            _buildAccountCard(context),
            const SizedBox(height: 24),
            _buildSectionTitle(
              context,
              'Verification',
              Icons.verified_user_outlined,
            ),
            const SizedBox(height: 12),
            _buildVerificationCard(context),
            const SizedBox(height: 24),
            _buildSectionTitle(
              context,
              'Account Status',
              Icons.shield_outlined,
            ),
            const SizedBox(height: 12),
            _buildStatusCard(context),
            if (_hasAccountDates()) ...[
              const SizedBox(height: 24),
              _buildSectionTitle(
                context,
                'Account Dates',
                Icons.schedule_outlined,
              ),
              const SizedBox(height: 12),
              _buildDatesCard(context),
            ],
            if (_firebaseUid.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildSectionTitle(
                context,
                'Firebase',
                Icons.local_fire_department_outlined,
              ),
              const SizedBox(height: 12),
              _buildFirebaseCard(context),
            ],
            const SizedBox(height: 20),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  bool _hasAccountDates() {
    return _firebaseCreatedAt.isNotEmpty ||
        _firebaseLastSignInAt.isNotEmpty ||
        _createdAt.isNotEmpty ||
        _updatedAt.isNotEmpty;
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Material(
          color: _surfaceVariant(context),
          shape: const CircleBorder(),
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () => Navigator.of(context).maybePop(),
            child: SizedBox(
              width: 42,
              height: 42,
              child: Icon(
                Icons.arrow_back_rounded,
                size: 21,
                color: _textPrimary(context),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Personal Info',
                style: GoogleFonts.poppins(
                  color: _textPrimary(context),
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Your AiTradeX account information',
                style: GoogleFonts.poppins(
                  color: _textSecondary(context),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: _softPrimary(context),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.verified_rounded,
                size: 14,
                color: _primary(context),
              ),
              const SizedBox(width: 5),
              Text(
                'Account',
                style: GoogleFonts.poppins(
                  color: _primary(context),
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHero(BuildContext context) {
    final String displayName =
    _fullName.isNotEmpty ? _fullName : 'AiTradeX User';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _border(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: _isDark(context) ? 0.16 : 0.04,
            ),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildAvatar(context, 82),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: _textPrimary(context),
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (_username.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    '@$_username',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: _primary(context),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                if (_email.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    _email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: _textSecondary(context),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const SizedBox(height: 9),
                _buildAccountBadge(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, double size) {
    final String image = _profileImage.trim();

    final bool hasImage =
        image.startsWith('http://') || image.startsWith('https://');

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _softPrimary(context),
        shape: BoxShape.circle,
        border: Border.all(
          color: _primary(context).withValues(alpha: 0.22),
          width: 2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.network(
        image,
        fit: BoxFit.cover,
        errorBuilder: (
            BuildContext context,
            Object error,
            StackTrace? stackTrace,
            ) {
          return _defaultAvatar(context, size);
        },
        loadingBuilder: (
            BuildContext context,
            Widget child,
            ImageChunkEvent? progress,
            ) {
          if (progress == null) {
            return child;
          }

          return Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                color: _primary(context),
                strokeWidth: 2,
              ),
            ),
          );
        },
      )
          : _defaultAvatar(context, size),
    );
  }

  Widget _defaultAvatar(BuildContext context, double size) {
    return Center(
      child: Icon(
        Icons.person_rounded,
        size: size * 0.55,
        color: _primary(context).withValues(alpha: 0.70),
      ),
    );
  }

  Widget _buildAccountBadge(BuildContext context) {
    final bool blocked = _isBlocked;
    final bool active = _isActive && !blocked;

    final Color color = blocked
        ? _theme(context).colorScheme.error
        : active
        ? _primary(context)
        : Colors.orange;

    final String text = blocked
        ? 'Account blocked'
        : active
        ? 'Active account'
        : 'Inactive account';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
      BuildContext context,
      String title,
      IconData icon,
      ) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: _softPrimary(context),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: _primary(context),
            size: 16,
          ),
        ),
        const SizedBox(width: 9),
        Text(
          title,
          style: GoogleFonts.poppins(
            color: _textPrimary(context),
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountCard(BuildContext context) {
    return _card(
      context,
      children: [
        _detail(
          context,
          icon: Icons.person_outline_rounded,
          label: 'Full Name',
          value: _fullName,
        ),
        _divider(context),
        _detail(
          context,
          icon: Icons.alternate_email_rounded,
          label: 'Username',
          value: _username,
        ),
        _divider(context),
        _detail(
          context,
          icon: Icons.email_outlined,
          label: 'Email',
          value: _email,
        ),
        _divider(context),
        _detail(
          context,
          icon: Icons.phone_outlined,
          label: 'Phone Number',
          value: _phoneNumber,
        ),
      ],
    );
  }

  Widget _buildVerificationCard(BuildContext context) {
    return _card(
      context,
      children: [
        _verificationRow(
          context,
          icon: Icons.email_outlined,
          title: 'Email Verification',
          verified: _emailVerified,
        ),
        _divider(context),
        _verificationRow(
          context,
          icon: Icons.phone_outlined,
          title: 'Phone Verification',
          verified: _phoneVerified,
        ),
      ],
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    return _card(
      context,
      children: [
        _statusRow(
          context,
          icon: Icons.toggle_on_outlined,
          title: 'Account Status',
          value: _isActive ? 'Active' : 'Inactive',
          positive: _isActive,
        ),
        _divider(context),
        _statusRow(
          context,
          icon: Icons.block_outlined,
          title: 'Blocked',
          value: _isBlocked ? 'Yes' : 'No',
          positive: !_isBlocked,
        ),
      ],
    );
  }

  Widget _buildDatesCard(BuildContext context) {
    final List<Widget> children = [];

    void addDate({
      required IconData icon,
      required String label,
      required String value,
    }) {
      if (value.isEmpty) {
        return;
      }

      if (children.isNotEmpty) {
        children.add(_divider(context));
      }

      children.add(
        _detail(
          context,
          icon: icon,
          label: label,
          value: _formatDateTime(value),
        ),
      );
    }

    addDate(
      icon: Icons.person_add_alt_1_outlined,
      label: 'Firebase Created',
      value: _firebaseCreatedAt,
    );

    addDate(
      icon: Icons.login_rounded,
      label: 'Last Sign In',
      value: _firebaseLastSignInAt,
    );

    addDate(
      icon: Icons.calendar_today_outlined,
      label: 'Account Created',
      value: _createdAt,
    );

    addDate(
      icon: Icons.update_rounded,
      label: 'Last Updated',
      value: _updatedAt,
    );

    return _card(
      context,
      children: children,
    );
  }

  Widget _buildFirebaseCard(BuildContext context) {
    return _card(
      context,
      children: [
        _detail(
          context,
          icon: Icons.fingerprint_rounded,
          label: 'Firebase UID',
          value: _firebaseUid,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _card(
      BuildContext context, {
        required List<Widget> children,
      }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: _surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border(context)),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _detail(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String value,
        int maxLines = 2,
      }) {
    final bool hasValue = value.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _softPrimary(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: _primary(context),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: _textMuted(context),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasValue ? value : 'Not provided',
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: hasValue
                        ? _textPrimary(context)
                        : _textMuted(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _verificationRow(
      BuildContext context, {
        required IconData icon,
        required String title,
        required bool verified,
      }) {
    final Color color = verified
        ? _primary(context)
        : _theme(context).colorScheme.error;

    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              color: _textPrimary(context),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 9,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                verified
                    ? Icons.check_circle_rounded
                    : Icons.cancel_rounded,
                size: 13,
                color: color,
              ),
              const SizedBox(width: 5),
              Text(
                verified ? 'Verified' : 'Not verified',
                style: GoogleFonts.poppins(
                  color: color,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statusRow(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String value,
        required bool positive,
      }) {
    final Color color = positive
        ? _primary(context)
        : _theme(context).colorScheme.error;

    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              color: _textPrimary(context),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _divider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Divider(
        height: 1,
        thickness: 0.7,
        color: _border(context),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _softPrimary(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _primary(context).withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: _primary(context),
            size: 19,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'This page is read-only. Your information is displayed '
                  'from the saved AiTradeX account profile.',
              style: GoogleFonts.poppins(
                color: _textSecondary(context),
                fontSize: 9,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
