import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color kAiTradeXDefaultGreen = Color(0xFF18C48F);

// ============================================================================
// THEME HELPERS
// ============================================================================

Color _primary(BuildContext context) {
  return Theme.of(context).colorScheme.primary;
}

Color _background(BuildContext context) {
  return Theme.of(context).scaffoldBackgroundColor;
}

Color _card(BuildContext context) {
  final ThemeData theme = Theme.of(context);

  return theme.cardColor;
}

Color _surface(BuildContext context) {
  final ThemeData theme = Theme.of(context);

  return theme.colorScheme.surface;
}

Color _textPrimary(BuildContext context) {
  return Theme.of(context).colorScheme.onSurface;
}

Color _textSecondary(BuildContext context) {
  final Color primaryText = _textPrimary(context);

  return primaryText.withValues(alpha: 0.62);
}

Color _textMuted(BuildContext context) {
  final Color primaryText = _textPrimary(context);

  return primaryText.withValues(alpha: 0.45);
}

Color _border(BuildContext context) {
  final ThemeData theme = Theme.of(context);

  return theme.dividerColor.withValues(alpha: 0.55);
}

Color _softPrimary(BuildContext context, {double alpha = 0.10}) {
  return _primary(context).withValues(alpha: alpha);
}

Color _softSurface(BuildContext context) {
  final Color text = _textPrimary(context);

  return text.withValues(alpha: 0.055);
}

bool _isDark(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark;
}

// ============================================================================
// TYPOGRAPHY
// ============================================================================

TextStyle _titleStyle(BuildContext context) {
  return GoogleFonts.poppins(
    fontSize: 23,
    fontWeight: FontWeight.w600,
    color: _textPrimary(context),
    letterSpacing: -0.5,
  );
}

TextStyle _bodyStyle(BuildContext context) {
  return GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: _textPrimary(context),
  );
}

TextStyle _descriptionStyle(BuildContext context) {
  return GoogleFonts.poppins(
    fontSize: 11.5,
    height: 1.45,
    color: _textSecondary(context),
  );
}

// ============================================================================
// SETTINGS HEADER
// ============================================================================

class SettingsHeader extends StatelessWidget {
  const SettingsHeader({
    super.key,
    required this.title,
    required this.onBack,
    this.trailing,
  });

  final String title;
  final VoidCallback onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final Color primary = _primary(context);

    return Row(
      children: [
        Material(
          color: _card(context),
          borderRadius: BorderRadius.circular(13),
          child: InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(13),
            splashColor: primary.withValues(alpha: 0.08),
            highlightColor: primary.withValues(alpha: 0.04),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: _border(context),
                ),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                size: 22,
                color: _textPrimary(context),
              ),
            ),
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Text(
            title,
            style: _titleStyle(context),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

// ============================================================================
// CUSTOM SWITCH
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
    final Color primary = _primary(context);

    return Semantics(
      button: true,
      toggled: value,
      label: 'Notification switch',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: 48,
          height: 28,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: value
                ? primary
                : Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.16)
                : const Color(0xFFD9DCDE),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: value
                  ? primary.withValues(alpha: 0.30)
                  : _border(context),
              width: 0.7,
            ),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            alignment:
            value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: _isDark(context) ? 0.28 : 0.10,
                    ),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SETTING ROW
// ============================================================================

class SettingSwitchRow extends StatelessWidget {
  const SettingSwitchRow({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.description,
    this.icon,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? description;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final Color primary = _primary(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: _card(context),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: _border(context),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: _isDark(context) ? 0.10 : 0.025,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: value
                    ? primary.withValues(alpha: 0.10)
                    : _softSurface(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: value
                      ? primary.withValues(alpha: 0.08)
                      : _border(context),
                  width: 0.6,
                ),
              ),
              child: Icon(
                icon,
                size: 19,
                color: value
                    ? primary
                    : _textMuted(context),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _bodyStyle(context),
                ),
                if (description != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: _descriptionStyle(context),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          _AiTradeXSwitch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// NOTIFICATION SCREEN
// ============================================================================

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({
    super.key,
  });

  @override
  State<NotificationScreen> createState() =>
      _NotificationScreenState();
}

class _NotificationScreenState
    extends State<NotificationScreen> {
  // ==========================================================================
  // NOTIFICATION SETTINGS
  // ==========================================================================

  final Map<String, bool> _settings = {
    'My Stock Goes up': true,
    'My Stock is Down': false,
    'Top Movers Updates': true,
    'I Bought Stock': true,
    'I Exchange Stock': true,
    'I Make Funding': false,
    'AiTradeX Announcements': true,
    'App Updates': false,
    'New Services Available': true,
    'New Tips Available': false,
  };

  // ==========================================================================
  // NOTIFICATION ICONS
  // ==========================================================================

  final Map<String, IconData> _icons = {
    'My Stock Goes up': Icons.trending_up_rounded,
    'My Stock is Down': Icons.trending_down_rounded,
    'Top Movers Updates': Icons.speed_rounded,
    'I Bought Stock': Icons.shopping_bag_outlined,
    'I Exchange Stock': Icons.swap_horiz_rounded,
    'I Make Funding':
    Icons.account_balance_wallet_outlined,
    'AiTradeX Announcements':
    Icons.campaign_outlined,
    'App Updates':
    Icons.system_update_alt_rounded,
    'New Services Available':
    Icons.auto_awesome_outlined,
    'New Tips Available':
    Icons.lightbulb_outline_rounded,
  };

  // ==========================================================================
  // DESCRIPTIONS
  // ==========================================================================

  final Map<String, String> _descriptions = {
    'My Stock Goes up':
    'Get notified when your tracked stock increases.',
    'My Stock is Down':
    'Receive alerts when your tracked stock falls.',
    'Top Movers Updates':
    'Stay updated with the biggest market movements.',
    'I Bought Stock':
    'Receive a notification after a stock purchase.',
    'I Exchange Stock':
    'Get updates when your stock exchange order changes.',
    'I Make Funding':
    'Receive updates about account funding activity.',
    'AiTradeX Announcements':
    'Important news and announcements from AiTradeX.',
    'App Updates':
    'Know when a new version of the app is available.',
    'New Services Available':
    'Discover newly launched AiTradeX services.',
    'New Tips Available':
    'Receive useful investing and market tips.',
  };

  // ==========================================================================
  // ENABLED COUNT
  // ==========================================================================

  int get _enabledCount {
    return _settings.values
        .where((enabled) => enabled)
        .length;
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    final Color primary = _primary(context);

    return Scaffold(
      backgroundColor: _background(context),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                14,
                20,
                0,
              ),
              child: SettingsHeader(
                title: 'Notifications',
                onBack: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            const SizedBox(height: 22),
            Expanded(
              child: RefreshIndicator(
                color: primary,
                backgroundColor: _card(context),
                onRefresh: _refreshSettings,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    0,
                    20,
                    32,
                  ),
                  children: [
                    _buildOverviewCard(context),
                    const SizedBox(height: 25),

                    _buildSectionHeader(
                      context,
                      'Market Activity',
                      'Stay informed about your investments.',
                    ),
                    const SizedBox(height: 12),

                    _buildSetting(
                      context,
                      'My Stock Goes up',
                    ),
                    _buildSetting(
                      context,
                      'My Stock is Down',
                    ),
                    _buildSetting(
                      context,
                      'Top Movers Updates',
                    ),

                    const SizedBox(height: 20),

                    _buildSectionHeader(
                      context,
                      'Account Activity',
                      'Receive updates about your account actions.',
                    ),
                    const SizedBox(height: 12),

                    _buildSetting(
                      context,
                      'I Bought Stock',
                    ),
                    _buildSetting(
                      context,
                      'I Exchange Stock',
                    ),
                    _buildSetting(
                      context,
                      'I Make Funding',
                    ),

                    const SizedBox(height: 20),

                    _buildSectionHeader(
                      context,
                      'AiTradeX Updates',
                      'Important news, features and helpful content.',
                    ),
                    const SizedBox(height: 12),

                    _buildSetting(
                      context,
                      'AiTradeX Announcements',
                    ),
                    _buildSetting(
                      context,
                      'App Updates',
                    ),
                    _buildSetting(
                      context,
                      'New Services Available',
                    ),
                    _buildSetting(
                      context,
                      'New Tips Available',
                    ),

                    const SizedBox(height: 10),

                    _buildFooterInfo(context),
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
  // OVERVIEW CARD
  // ==========================================================================

  Widget _buildOverviewCard(BuildContext context) {
    final Color primary = _primary(context);
    final int total = _settings.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _border(context),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: _isDark(context) ? 0.12 : 0.035,
            ),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: primary.withValues(alpha: 0.08),
              ),
            ),
            child: Icon(
              Icons.notifications_active_outlined,
              color: primary,
              size: 24,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notification Preferences',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary(context),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$_enabledCount of $total notifications enabled',
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    color: _textSecondary(context),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: primary.withValues(alpha: 0.08),
              ),
            ),
            child: Text(
              '$_enabledCount ON',
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
  // SECTION HEADER
  // ==========================================================================

  Widget _buildSectionHeader(
      BuildContext context,
      String title,
      String subtitle,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _textPrimary(context),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 11.5,
            color: _textSecondary(context),
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // SETTING
  // ==========================================================================

  Widget _buildSetting(
      BuildContext context,
      String title,
      ) {
    return SettingSwitchRow(
      title: title,
      description: _descriptions[title],
      icon: _icons[title],
      value: _settings[title] ?? false,
      onChanged: (value) {
        setState(() {
          _settings[title] = value;
        });
      },
    );
  }

  // ==========================================================================
  // FOOTER
  // ==========================================================================

  Widget _buildFooterInfo(BuildContext context) {
    final Color primary = _primary(context);

    return Container(
      margin: const EdgeInsets.only(
        top: 12,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _softPrimary(
          context,
          alpha: _isDark(context) ? 0.07 : 0.055,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primary.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: primary,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              'You can change these notification preferences '
                  'at any time.',
              style: GoogleFonts.poppins(
                fontSize: 11,
                height: 1.45,
                color: _textSecondary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // REFRESH
  // ==========================================================================

  Future<void> _refreshSettings() async {
    await Future<void>.delayed(
      const Duration(
        milliseconds: 300,
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {});
  }
}