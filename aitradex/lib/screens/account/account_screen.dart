
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:aitradex/core/theme/theme_controller.dart';
import 'package:aitradex/services/api_service.dart';
import 'package:aitradex/services/shared_preferences_service.dart';
import 'package:aitradex/screens/onboarding/onboarding_screen.dart';

import 'package:aitradex/screens/rewards/invite_friends_screen.dart';

import 'about_aitradex_screen.dart';
import 'add_broker.dart';
import 'AiTradeX_coins.dart';
import 'mypurchase_screen.dart';
import 'app_theme_screen.dart';
import 'help_center_screen.dart';
import 'notification_screen.dart';
import 'personal_info_screen.dart';
import 'security_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({
    super.key,
  });

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  // ===========================================================================
  // PROFILE
  // ===========================================================================

  String _userName = '';
  String _userEmail = '';
  String _profileImageUrl = '';

  bool _isLoadingProfile = true;
  bool _isDeletingAccount = false;

  // ===========================================================================
  // THEME CONTROLLER
  // ===========================================================================

  ThemeController get _themeController => Get.find<ThemeController>();

  // ===========================================================================
  // THEME HELPERS
  // ===========================================================================

  Color _primary(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  Color _background(BuildContext context) {
    return Theme.of(context).scaffoldBackgroundColor;
  }

  Color _surface(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  Color _surfaceVariant(BuildContext context) {
    return Theme.of(context).colorScheme.surfaceContainerHighest;
  }

  Color _textPrimary(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  Color _textSecondary(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;

    return color.withValues(
      alpha: 0.65,
    );
  }

  Color _textMuted(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;

    return color.withValues(
      alpha: 0.45,
    );
  }

  Color _border(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;

    return color.withValues(
      alpha: 0.10,
    );
  }

  Color _danger(BuildContext context) {
    return Theme.of(context).colorScheme.error;
  }

  bool _isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  // ===========================================================================
  // INIT
  // ===========================================================================

  @override
  void initState() {
    super.initState();

    _loadUserProfile();
  }

  // ===========================================================================
  // LOAD PROFILE
  // ===========================================================================

  Future<void> _loadUserProfile() async {
    if (mounted) {
      setState(() {
        _isLoadingProfile = true;
      });
    }

    try {
      // Always use the Firebase-authenticated account as the identity source.
      // This supports both Google and email/password users.
      final User? firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser == null) {
        throw Exception('No Firebase user is currently signed in.');
      }

      // Refresh Firebase user data first so Google photo/name and email
      // verification state are current.
      try {
        await firebaseUser.reload();
      } catch (error) {
        debugPrint('FIREBASE USER RELOAD WARNING: $error');
      }

      final User? refreshedUser = FirebaseAuth.instance.currentUser;
      final User user = refreshedUser ?? firebaseUser;

      // SharedPreferencesService first tries MongoDB with the Firebase ID
      // token, then falls back to the local cache/Firebase data.
      final Map<String, dynamic> profile =
      await SharedPreferencesService.getCurrentUserProfile();

      String name = _readString(
        profile,
        'fullName',
        fallbackKeys: const ['name', 'displayName'],
      );

      String email = _readString(profile, 'email');

      String image = _readString(
        profile,
        'profileImage',
        fallbackKeys: const ['profileImageUrl', 'photoURL'],
      );

      // Firebase is the final fallback. This is important for a brand-new
      // Google account before the MongoDB document/cache has been created.
      if (name.isEmpty) {
        name = user.displayName?.trim() ?? '';
      }

      if (email.isEmpty) {
        email = user.email?.trim() ?? '';
      }

      if (image.isEmpty) {
        image = user.photoURL?.trim() ?? '';
      }

      final String provider = _readString(
        profile,
        'authProvider',
      ).isNotEmpty
          ? _readString(profile, 'authProvider')
          : _getFirebaseProvider(user);

      // Keep the local cache synchronized with the actual Firebase account.
      await SharedPreferencesService.saveUserProfile(
        name: name,
        username: _readString(
          profile,
          'username',
          fallbackKeys: const ['userName'],
        ),
        email: email,
        phone: _readString(
          profile,
          'phoneNumber',
          fallbackKeys: const ['phone'],
        ),
        emailVerified:
        _readBool(profile, 'emailVerified') || user.emailVerified,
        phoneVerified: _readBool(profile, 'phoneVerified'),
        profileImageUrl: image,
        firebaseUid: user.uid,
        authProvider: provider,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _userName = name;
        _userEmail = email;
        _profileImageUrl = image;
        _isLoadingProfile = false;
      });

      debugPrint('========================================');
      debugPrint('AITRADEX ACCOUNT PROFILE LOADED');
      debugPrint('Provider: $provider');
      debugPrint('UID: ${user.uid}');
      debugPrint('Name: $name');
      debugPrint('Email: $email');
      debugPrint('========================================');
    } catch (error, stackTrace) {
      debugPrint('ACCOUNT PROFILE ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      // Never leave the Account screen stuck on a loading spinner.
      try {
        final Map<String, dynamic> localProfile =
        await SharedPreferencesService.getUserProfile();

        final User? firebaseUser = FirebaseAuth.instance.currentUser;

        String name = _readString(
          localProfile,
          'fullName',
          fallbackKeys: const ['name', 'displayName'],
        );
        String email = _readString(localProfile, 'email');
        String image = _readString(
          localProfile,
          'profileImageUrl',
          fallbackKeys: const ['profileImage', 'photoURL'],
        );

        if (firebaseUser != null) {
          name = name.isNotEmpty
              ? name
              : (firebaseUser.displayName?.trim() ?? '');
          email = email.isNotEmpty
              ? email
              : (firebaseUser.email?.trim() ?? '');
          image = image.isNotEmpty
              ? image
              : (firebaseUser.photoURL?.trim() ?? '');
        }

        if (!mounted) {
          return;
        }

        setState(() {
          _userName = name;
          _userEmail = email;
          _profileImageUrl = image;
          _isLoadingProfile = false;
        });
      } catch (fallbackError, fallbackStackTrace) {
        debugPrint('ACCOUNT PROFILE FALLBACK ERROR: $fallbackError');
        debugPrintStack(stackTrace: fallbackStackTrace);

        if (!mounted) {
          return;
        }

        setState(() {
          _userName = '';
          _userEmail = '';
          _profileImageUrl = '';
          _isLoadingProfile = false;
        });
      }
    }
  }

  String _getFirebaseProvider(User user) {
    for (final UserInfo provider in user.providerData) {
      final String providerId = provider.providerId.trim().toLowerCase();

      if (providerId == 'google.com') {
        return 'google';
      }

      if (providerId == 'password') {
        return 'password';
      }
    }

    return 'firebase';
  }

  String _readString(
      Map<String, dynamic> data,
      String key, {
        List<String> fallbackKeys = const <String>[],
      }) {
    final dynamic value = data[key];

    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString().trim();
    }

    for (final String fallbackKey in fallbackKeys) {
      final dynamic fallbackValue = data[fallbackKey];

      if (fallbackValue != null &&
          fallbackValue.toString().trim().isNotEmpty) {
        return fallbackValue.toString().trim();
      }
    }

    return '';
  }

  bool _readBool(
      Map<String, dynamic> data,
      String key, {
        bool fallback = false,
      }) {
    final dynamic value = data[key];

    if (value is bool) {
      return value;
    }

    if (value is String) {
      final String normalized = value.trim().toLowerCase();

      if (normalized == 'true' || normalized == '1') {
        return true;
      }

      if (normalized == 'false' || normalized == '0') {
        return false;
      }
    }

    if (value is num) {
      return value != 0;
    }

    return fallback;
  }

  // ===========================================================================
  // REFRESH
  // ===========================================================================

  Future<void> _refreshProfile() async {
    await _loadUserProfile();
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
        _isDark(context) ? Brightness.light : Brightness.dark,
        statusBarBrightness:
        _isDark(context) ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: _background(context),
        systemNavigationBarIconBrightness:
        _isDark(context) ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _background(context),
        body: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            color: _primary(context),
            backgroundColor: _surface(context),
            onRefresh: _refreshProfile,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: _buildHeader(context),
                ),

                SliverToBoxAdapter(
                  child: _buildProfileHero(context),
                ),

                SliverToBoxAdapter(
                  child: _buildAccountStats(context),
                ),

                SliverToBoxAdapter(
                  child: _buildSectionTitle(
                    context,
                    'Stock',
                  ),
                ),

                SliverToBoxAdapter(
                  child: _buildStockSection(context),
                ),

                SliverToBoxAdapter(
                  child: _buildSectionTitle(
                    context,
                    'Account',
                  ),
                ),

                SliverToBoxAdapter(
                  child: _buildAccountSection(context),
                ),

                SliverToBoxAdapter(
                  child: _buildSectionTitle(
                    context,
                    'Preferences',
                  ),
                ),

                SliverToBoxAdapter(
                  child: _buildPreferencesSection(context),
                ),

                SliverToBoxAdapter(
                  child: _buildSectionTitle(
                    context,
                    'Support & Information',
                  ),
                ),

                SliverToBoxAdapter(
                  child: _buildSupportSection(context),
                ),

                SliverToBoxAdapter(
                  child: _buildInviteCard(context),
                ),

                SliverToBoxAdapter(
                  child: _buildDangerSection(context),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 125,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // HEADER
  // ===========================================================================

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        12,
        20,
        12,
      ),
      child: Row(
        children: [
          _buildCircleButton(
            context: context,
            icon: Icons.arrow_back_rounded,
            onTap: () {
              HapticFeedback.lightImpact();

              Navigator.of(context).pop();
            },
          ),
          const SizedBox(
            width: 14,
          ),
          Expanded(
            child: Text(
              'Account',
              style: GoogleFonts.poppins(
                color: _textPrimary(context),
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
          ),
          _buildCircleButton(
            context: context,
            icon: Icons.settings_outlined,
            onTap: () {
              _showComingSoon(
                context,
                'Account settings',
              );
            },
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // CIRCLE BUTTON
  // ===========================================================================

  Widget _buildCircleButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _surface(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _border(context),
            ),
          ),
          child: Icon(
            icon,
            color: _textPrimary(context),
            size: 21,
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // PROFILE HERO
  // ===========================================================================

  Widget _buildProfileHero(BuildContext context) {
    final primary = _primary(context);

    final hasImage = _profileImageUrl.trim().isNotEmpty;

    final String displayName = _userName.trim().isNotEmpty
        ? _userName.trim()
        : 'AiTradeX User';

    final String displayEmail = _userEmail.trim().isNotEmpty
        ? _userEmail.trim()
        : 'No email available';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        8,
        20,
        14,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primary.withValues(
                alpha: _isDark(context) ? 0.16 : 0.10,
              ),
              _surface(context),
            ],
          ),
          border: Border.all(
            color: primary.withValues(
              alpha: 0.20,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: primary.withValues(
                alpha: _isDark(context) ? 0.10 : 0.05,
              ),
              blurRadius: 25,
              offset: const Offset(
                0,
                12,
              ),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // PROFILE IMAGE
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primary,
                        primary.withValues(
                          alpha: 0.55,
                        ),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withValues(
                          alpha: 0.22,
                        ),
                        blurRadius: 18,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(2),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _surfaceVariant(context),
                      shape: BoxShape.circle,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _isLoadingProfile
                        ? Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: primary,
                        ),
                      ),
                    )
                        : hasImage
                        ? Image.network(
                      _profileImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (
                          context,
                          error,
                          stackTrace,
                          ) {
                        return Icon(
                          Icons.person_rounded,
                          color: _textSecondary(context),
                          size: 40,
                        );
                      },
                    )
                        : Icon(
                      Icons.person_rounded,
                      color: _textSecondary(context),
                      size: 40,
                    ),
                  ),
                ),

                const SizedBox(
                  width: 16,
                ),

                // USER INFORMATION
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
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        displayEmail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: _textSecondary(context),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(
                        height: 9,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: primary.withValues(
                            alpha: 0.10,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              'Active account',
                              style: GoogleFonts.poppins(
                                color: primary,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  width: 8,
                ),

                // EDIT
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _showComingSoon(
                        context,
                        'Edit profile',
                      );
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _textPrimary(context).withValues(
                          alpha: 0.06,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _border(context),
                        ),
                      ),
                      child: Icon(
                        Icons.edit_outlined,
                        color: _textSecondary(context),
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),

            // VIEW PROFILE
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: _openPersonalInfo,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: primary,
                  foregroundColor:
                  _isDark(context) ? Colors.black : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'View Profile',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // ACCOUNT STATS
  // ===========================================================================

  Widget _buildAccountStats(BuildContext context) {
    final primary = _primary(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        0,
        20,
        18,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildMiniStat(
              context: context,
              icon: Icons.notifications_active_outlined,
              title: 'Stock Alerts',
              value: '0',
              color: primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildMiniStat(
              context: context,
              icon: Icons.monetization_on_outlined,
              title: 'Coins',
              value: '0',
              color: Colors.amber,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildMiniStat(
              context: context,
              icon: Icons.card_membership_outlined,
              title: 'Subscriptions',
              value: '0',
              color: Colors.deepPurple,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // MINI STAT
  // ===========================================================================

  Widget _buildMiniStat({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: _surface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _border(context),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withValues(
                alpha: 0.10,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 16,
            ),
          ),
          const SizedBox(
            height: 9,
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: _textSecondary(context),
              fontSize: 8.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(
            height: 3,
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: _textPrimary(context),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // STOCK SECTION
  // ===========================================================================

  Widget _buildStockSection(BuildContext context) {
    final primary = _primary(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        0,
        20,
        8,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: _surface(context),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: _border(context),
          ),
          boxShadow: [
            if (!_isDark(context))
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
          ],
        ),
        child: Column(
          children: [
            _buildOption(
              context: context,
              title: 'Add Broker',
              subtitle: 'Connect your stock broker account',
              icon: Icons.account_balance_outlined,
              iconColor: primary,
              onTap: _openAddBroker,
            ),
            _buildDivider(context),
            _buildOption(
              context: context,
              title: 'AiTradeX Coins',
              subtitle: 'Manage your AiTradeX coin balance',
              icon: Icons.monetization_on_outlined,
              iconColor: Colors.amber,
              onTap: _openAiTradeXCoins,
            ),
            _buildDivider(context),
            _buildOption(
              context: context,
              title: 'My Purchases',
              subtitle: 'View your purchased stocks and products',
              icon: Icons.shopping_bag_outlined,
              iconColor: Colors.blue,
              onTap: _openMyPurchases,
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // SECTION TITLE
  // ===========================================================================

  Widget _buildSectionTitle(
      BuildContext context,
      String title,
      ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        10,
        20,
        9,
      ),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          color: _textPrimary(context),
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ===========================================================================
  // ACCOUNT SECTION
  // ===========================================================================

  Widget _buildAccountSection(BuildContext context) {
    return _buildOptionsCard(
      context,
      children: [
        _buildOption(
          context: context,
          title: 'Personal Info',
          subtitle: 'Manage your personal details',
          icon: Icons.person_outline_rounded,
          iconColor: Colors.orange,
          onTap: _openPersonalInfo,
        ),
        _buildDivider(context),
        _buildOption(
          context: context,
          title: 'Notifications',
          subtitle: 'Manage alerts and updates',
          icon: Icons.notifications_none_rounded,
          iconColor: Colors.pink,
          onTap: () {
            _openPage(
              const NotificationScreen(),
            );
          },
        ),
        _buildDivider(context),
        _buildOption(
          context: context,
          title: 'Security',
          subtitle: 'Password, verification & security',
          icon: Icons.shield_outlined,
          iconColor: _primary(context),
          onTap: () {
            _openPage(
              const SecurityScreen(),
            );
          },
        ),
      ],
    );
  }

  // ===========================================================================
  // PREFERENCES
  // ===========================================================================

  Widget _buildPreferencesSection(BuildContext context) {
    return Obx(
          () {
        final controller = _themeController;

        final bool isDark = controller.isDarkMode.value;
        final Color selectedColor = controller.primaryColor.value;

        final String colorName = _getThemeColorName(
          selectedColor,
        );

        return _buildOptionsCard(
          context,
          children: [
            // -----------------------------------------------------------------
            // LANGUAGE
            // -----------------------------------------------------------------

            _buildOption(
              context: context,
              title: 'Language',
              subtitle: 'English (US)',
              icon: Icons.language_rounded,
              iconColor: Colors.deepPurple,
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: _textMuted(context),
                size: 22,
              ),
              onTap: _showLanguageSheet,
            ),

            _buildDivider(context),

            // -----------------------------------------------------------------
            // APP THEME
            // -----------------------------------------------------------------

            _buildOption(
              context: context,
              title: 'App Theme',
              subtitle: 'Customize your app color',
              icon: Icons.palette_outlined,
              iconColor: selectedColor,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: selectedColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: selectedColor.withValues(
                            alpha: 0.30,
                          ),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 7,
                  ),
                  Text(
                    colorName,
                    style: GoogleFonts.poppins(
                      color: _textSecondary(context),
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    width: 3,
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: _textMuted(context),
                    size: 22,
                  ),
                ],
              ),
              onTap: _openAppTheme,
            ),

            _buildDivider(context),

            // -----------------------------------------------------------------
            // DARK MODE
            // -----------------------------------------------------------------

            _buildOption(
              context: context,
              title: 'Dark Mode',
              subtitle: isDark
                  ? 'Dark mode is currently active'
                  : 'Light mode is currently active',
              icon: isDark
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined,
              iconColor: selectedColor,
              showChevron: false,
              trailing: _buildThemeSwitch(
                context: context,
                value: isDark,
                activeColor: selectedColor,
                onChanged: (value) {
                  HapticFeedback.lightImpact();

                  controller.setDarkMode(
                    value,
                  );
                },
              ),
              onTap: () {
                HapticFeedback.lightImpact();

                controller.setDarkMode(
                  !isDark,
                );
              },
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // THEME SWITCH
  // ===========================================================================

  Widget _buildThemeSwitch({
    required BuildContext context,
    required bool value,
    required Color activeColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Switch.adaptive(
      value: value,
      onChanged: onChanged,
      activeColor: activeColor,
      activeTrackColor: activeColor.withValues(
        alpha: 0.35,
      ),
      inactiveThumbColor: _isDark(context)
          ? Colors.white70
          : Colors.white,
      inactiveTrackColor: _isDark(context)
          ? Colors.white.withValues(
        alpha: 0.12,
      )
          : Colors.black.withValues(
        alpha: 0.10,
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  // ===========================================================================
  // GET THEME COLOR NAME
  // ===========================================================================

  String _getThemeColorName(Color color) {
    final int value = color.toARGB32();

    switch (value) {
      case 0xFF18C48F:
        return 'Emerald';

      case 0xFF2196F3:
        return 'Blue';

      case 0xFF7C4DFF:
        return 'Purple';

      case 0xFFE91E63:
        return 'Pink';

      case 0xFFFF9800:
        return 'Orange';

      case 0xFFF44336:
        return 'Red';

      case 0xFF00BCD4:
        return 'Cyan';

      case 0xFF3F51B5:
        return 'Indigo';

      default:
        return 'Custom';
    }
  }

  // ===========================================================================
  // OPEN APP THEME
  // ===========================================================================

  void _openAppTheme() {
    HapticFeedback.lightImpact();

    _openPage(
      const AppThemeScreen(),
    );
  }

  // ===========================================================================
  // SUPPORT
  // ===========================================================================

  Widget _buildSupportSection(BuildContext context) {
    return _buildOptionsCard(
      context,
      children: [
        _buildOption(
          context: context,
          title: 'Help Center',
          subtitle: 'Find answers and get support',
          icon: Icons.help_outline_rounded,
          iconColor: _primary(context),
          onTap: () {
            _openPage(
              const HelpCenterScreen(),
            );
          },
        ),
        _buildDivider(context),
        _buildOption(
          context: context,
          title: 'Legal Agreements',
          subtitle: 'Terms, privacy & agreements',
          icon: Icons.description_outlined,
          iconColor: Colors.orange,
          onTap: () {
            _showComingSoon(
              context,
              'Legal Agreements',
            );
          },
        ),
        _buildDivider(context),
        _buildOption(
          context: context,
          title: 'About AiTradeX',
          subtitle: 'App information & version',
          icon: Icons.info_outline_rounded,
          iconColor: Colors.blue,
          onTap: () {
            _openPage(
              const AboutAiTradeXScreen(),
            );
          },
        ),
      ],
    );
  }

  // ===========================================================================
  // OPTIONS CARD
  // ===========================================================================

  Widget _buildOptionsCard(
      BuildContext context, {
        required List<Widget> children,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: _surface(context),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: _border(context),
          ),
          boxShadow: [
            if (!_isDark(context))
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.035,
                ),
                blurRadius: 18,
                offset: const Offset(
                  0,
                  7,
                ),
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Column(
            children: children,
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // OPTION
  // ===========================================================================

  Widget _buildOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
    Widget? trailing,
    bool showChevron = true,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 21,
                ),
              ),
              const SizedBox(
                width: 13,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: _textPrimary(context),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: _textSecondary(context),
                        fontSize: 8.5,
                        fontWeight: FontWeight.w500,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              if (trailing != null)
                trailing
              else if (showChevron)
                Icon(
                  Icons.chevron_right_rounded,
                  color: _textMuted(context),
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // DIVIDER
  // ===========================================================================

  Widget _buildDivider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 71,
      ),
      child: Divider(
        height: 1,
        thickness: 0.6,
        color: _border(context),
      ),
    );
  }

  // ===========================================================================
  // INVITE FRIENDS
  // ===========================================================================

  Widget _buildInviteCard(BuildContext context) {
    final primary = _primary(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        4,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            _openPage(
              const InviteFriendsScreen(),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primary.withValues(
                    alpha: _isDark(context) ? 0.18 : 0.10,
                  ),
                  _surface(context),
                ],
              ),
              border: Border.all(
                color: primary.withValues(
                  alpha: 0.20,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primary,
                        primary.withValues(
                          alpha: 0.60,
                        ),
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.card_giftcard_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(
                  width: 14,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Invite friends',
                        style: GoogleFonts.poppins(
                          color: _textPrimary(context),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        'Share AiTradeX and unlock rewards',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: _textSecondary(context),
                          fontSize: 9,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: _textMuted(context),
                  size: 15,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // DANGER SECTION
  // ===========================================================================

  Widget _buildDangerSection(BuildContext context) {
    final danger = _danger(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        0,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: danger.withValues(
            alpha: _isDark(context) ? 0.07 : 0.04,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: danger.withValues(
              alpha: 0.15,
            ),
          ),
        ),
        child: Column(
          children: [
            _buildOption(
              context: context,
              title: 'Close Your Account',
              subtitle: _isDeletingAccount
                  ? 'Deleting account...'
                  : 'Permanently delete your account',
              icon: Icons.delete_outline_rounded,
              iconColor: danger,
              onTap: _isDeletingAccount
                  ? () {}
                  : _confirmCloseAccount,
            ),
            _buildDivider(context),
            _buildOption(
              context: context,
              title: 'Logout',
              subtitle: 'Sign out from this device',
              icon: Icons.logout_rounded,
              iconColor: danger,
              onTap: _confirmLogout,
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // STOCK / REWARDS NAVIGATION
  // ===========================================================================

  void _openAddBroker() {
    HapticFeedback.lightImpact();

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const AddBrokerScreen(),
      ),
    );
  }

  void _openAiTradeXCoins() {
    HapticFeedback.lightImpact();

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const AiTradeXCoinsScreen(),
      ),
    );
  }

  void _openMyPurchases() {
    HapticFeedback.lightImpact();

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const MyPurchaseScreen(),
      ),
    );
  }

  // ===========================================================================
  // OPEN PERSONAL INFO
  // ===========================================================================

  void _openPersonalInfo() {
    _openPage(
      const PersonalInfoScreen(),
    );
  }

  // ===========================================================================
  // OPEN PAGE
  // ===========================================================================

  void _openPage(
      Widget page,
      ) {
    HapticFeedback.lightImpact();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => page,
      ),
    );
  }

  // ===========================================================================
  // LANGUAGE SHEET
  // ===========================================================================

  void _showLanguageSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _surface(context),
      barrierColor: Colors.black.withValues(
        alpha: 0.60,
      ),
      showDragHandle: true,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              8,
              20,
              25,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Language',
                  style: GoogleFonts.poppins(
                    color: _textPrimary(sheetContext),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(
                  height: 6,
                ),
                Text(
                  'Choose your preferred language',
                  style: GoogleFonts.poppins(
                    color: _textSecondary(sheetContext),
                    fontSize: 10,
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                _buildLanguageItem(
                  context: sheetContext,
                  title: 'English (US)',
                  selected: true,
                ),
                _buildLanguageItem(
                  context: sheetContext,
                  title: 'English (UK)',
                  selected: false,
                ),
                _buildLanguageItem(
                  context: sheetContext,
                  title: 'Hindi',
                  selected: false,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // LANGUAGE ITEM
  // ===========================================================================

  Widget _buildLanguageItem({
    required BuildContext context,
    required String title,
    required bool selected,
  }) {
    final primary = _primary(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Container(
          margin: const EdgeInsets.only(
            bottom: 7,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
          decoration: BoxDecoration(
            color: selected
                ? primary.withValues(
              alpha: 0.08,
            )
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? primary.withValues(
                alpha: 0.22,
              )
                  : _border(context),
            ),
          ),
          child: Row(
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: _textPrimary(context),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (selected)
                Icon(
                  Icons.check_circle_rounded,
                  color: primary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // CONFIRM DELETE
  // ===========================================================================

  void _confirmCloseAccount() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final danger = _danger(dialogContext);

        return AlertDialog(
          backgroundColor: _surface(dialogContext),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Delete Account?',
            style: GoogleFonts.poppins(
              color: _textPrimary(dialogContext),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Your account and associated data will be permanently deleted. This action cannot be undone.',
            style: GoogleFonts.poppins(
              color: _textSecondary(dialogContext),
              fontSize: 11,
              height: 1.5,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(
            18,
            0,
            18,
            18,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: _textSecondary(dialogContext),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();

                _deleteAccount();
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: danger,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Delete',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // DELETE ACCOUNT
  // ===========================================================================


  Future<void> _deleteAccount() async {
    if (_isDeletingAccount) return;

    FocusScope.of(context).unfocus();

    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showDeleteError('No signed-in account was found.');
      return;
    }

    setState(() => _isDeletingAccount = true);

    try {
      // Refresh the Firebase user before calling the backend.
      await user.reload();

      if (FirebaseAuth.instance.currentUser == null) {
        throw Exception(
          'Your session has expired. Please sign in again.',
        );
      }

      // IMPORTANT: This API must exist in your backend and must
      // delete the Firebase account and associated MongoDB data.
      final bool deleted = await ApiService.deleteAccount();

      if (!deleted) {
        throw Exception(
          'The server did not confirm account deletion. Please try again.',
        );
      }

      // Sign out of Google if this account used Google sign-in.
      try {
        final googleSignIn = GoogleSignIn.instance;
        await googleSignIn.initialize();
        await googleSignIn.signOut();
      } catch (error) {
        debugPrint('Google sign-out warning: $error');
      }

      // Clear Firebase session and locally cached account data.
      await FirebaseAuth.instance.signOut();
      await SharedPreferencesService.clearAll();

      if (!mounted) return;

      setState(() => _isDeletingAccount = false);

      // Show success before navigating away.
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            icon: const Icon(
              Icons.check_circle_rounded,
              color: Colors.green,
              size: 56,
            ),
            title: const Text('Account Closed Successfully'),
            content: const Text(
              'Your account has been deleted successfully. '
                  'You can start again whenever you are ready.',
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Continue'),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      // Use the widget directly instead of a named route. This avoids
      // GetX PageRedirect's null-check error when '/onboarding' is not
      // registered in GetMaterialApp.getPages.
      Get.offAll(
            () => const OnboardingScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 250),
      );
    } on FirebaseAuthException catch (error) {
      debugPrint(
        'Account deletion Firebase error: '
            '${error.code} ${error.message}',
      );

      if (!mounted) return;

      setState(() => _isDeletingAccount = false);

      _showDeleteError(
        error.code == 'requires-recent-login'
            ? 'Please sign in again before closing your account.'
            : error.message ?? 'Unable to close your account.',
      );
    } catch (error, stackTrace) {
      debugPrint('Account deletion error: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() => _isDeletingAccount = false);

      _showDeleteError(
        error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }


  Future<void> _confirmLogout() async {
    if (!mounted) {
      return;
    }

    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _surface(dialogContext),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Logout?',
            style: GoogleFonts.poppins(
              color: _textPrimary(dialogContext),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Are you sure you want to logout from your AiTradeX account?',
            style: GoogleFonts.poppins(
              color: _textSecondary(dialogContext),
              fontSize: 11,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: _textSecondary(dialogContext),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: _danger(dialogContext),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Logout',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) {
      return;
    }

    await _logout();
  }

  Future<void> _logout() async {
    try {
      FocusScope.of(context).unfocus();

      // Clear the Google session too. Firebase sign-out alone can leave the
      // Google account available for the next Google authentication attempt.
      try {
        final GoogleSignIn googleSignIn = GoogleSignIn.instance;
        await googleSignIn.initialize();
        await googleSignIn.signOut();
      } catch (googleError) {
        debugPrint('GOOGLE SIGN OUT WARNING: $googleError');
      }

      await FirebaseAuth.instance.signOut();

      // Remove authenticated/session data but preserve non-auth preferences.
      await SharedPreferencesService.logout();

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
            (route) => false,
      );
    } catch (e, stackTrace) {
      debugPrint('ACCOUNT LOGOUT ERROR: $e');
      debugPrint('$stackTrace');

      if (!mounted) {
        return;
      }

      _showDeleteError(
        'Unable to logout completely. Please try again.',
      );
    }
  }

  // ===========================================================================
  // DELETE ERROR
  // ===========================================================================

  void _showDeleteError(
      String message,
      ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 10.5,
            ),
          ),
          backgroundColor: _danger(context),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  // ===========================================================================
  // COMING SOON
  // ===========================================================================

  void _showComingSoon(
      BuildContext context,
      String title,
      ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '$title is coming soon.',
            style: GoogleFonts.poppins(
              fontSize: 10.5,
            ),
          ),
          backgroundColor: _surface(context),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }
}
