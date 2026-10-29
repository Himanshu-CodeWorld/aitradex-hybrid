import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color kAiTradeXGreen = Color(0xFF18C48F);
const Color kAiTradeXDanger = Color(0xFFFF4D55);

TextStyle _titleStyle(BuildContext context) {
  final ColorScheme scheme = Theme.of(context).colorScheme;

  return GoogleFonts.poppins(
    fontSize: 23,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    color: scheme.onSurface,
  );
}

TextStyle _bodyStyle(BuildContext context) {
  final ColorScheme scheme = Theme.of(context).colorScheme;

  return GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: scheme.onSurface,
  );
}

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
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Material(
          color: scheme.surfaceContainerHighest.withValues(
            alpha: Theme.of(context).brightness == Brightness.dark
                ? 0.55
                : 0.65,
          ),
          borderRadius: BorderRadius.circular(15),
          child: InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(15),
            child: SizedBox(
              width: 42,
              height: 42,
              child: Icon(
                Icons.arrow_back_rounded,
                size: 22,
                color: scheme.onSurface,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
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

class SettingSwitchRow extends StatelessWidget {
  const SettingSwitchRow({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 61,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: _bodyStyle(context),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: scheme.onPrimary,
            activeTrackColor: scheme.primary,
            inactiveThumbColor: scheme.onSurfaceVariant,
            inactiveTrackColor: scheme.surfaceContainerHighest,
            materialTapTargetSize:
            MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}

class AboutAiTradeXScreen extends StatelessWidget {
  const AboutAiTradeXScreen({super.key});

  static const List<_AboutItem> _items = [
    _AboutItem(
      title: 'Job Vacancy',
      subtitle: 'Explore career opportunities',
      icon: Icons.work_outline_rounded,
    ),
    _AboutItem(
      title: 'Fees',
      subtitle: 'View applicable charges',
      icon: Icons.receipt_long_outlined,
    ),
    _AboutItem(
      title: 'Developer',
      subtitle: 'Meet the team behind AiTradeX',
      icon: Icons.code_rounded,
    ),
    _AboutItem(
      title: 'Partner',
      subtitle: 'Discover partnership opportunities',
      icon: Icons.handshake_outlined,
    ),
    _AboutItem(
      title: 'Privacy Policy',
      subtitle: 'Learn how your data is handled',
      icon: Icons.privacy_tip_outlined,
    ),
    _AboutItem(
      title: 'Accessibility',
      subtitle: 'Accessibility and inclusive design',
      icon: Icons.accessibility_new_rounded,
    ),
    _AboutItem(
      title: 'Feedback',
      subtitle: 'Share your thoughts with us',
      icon: Icons.chat_bubble_outline_rounded,
    ),
    _AboutItem(
      title: 'Rate us',
      subtitle: 'Tell us about your AiTradeX experience',
      icon: Icons.star_border_rounded,
    ),
    _AboutItem(
      title: 'Visit Our Website',
      subtitle: 'Open the official AiTradeX website',
      icon: Icons.language_rounded,
    ),
    _AboutItem(
      title: 'Follow us on Social Media',
      subtitle: 'Stay connected with AiTradeX',
      icon: Icons.share_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    final Color background = theme.scaffoldBackgroundColor;
    final Color surface = scheme.surface;
    final Color textPrimary = scheme.onSurface;
    final Color textSecondary = scheme.onSurfaceVariant;
    final Color border = scheme.outline.withValues(
      alpha: isDark ? 0.30 : 0.14,
    );

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                20,
                18,
                20,
                28,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    SettingsHeader(
                      title: 'About AiTradeX',
                      onBack: () => Navigator.of(context).pop(),
                    ),

                    const SizedBox(height: 28),

                    _BrandHero(
                      primary: scheme.primary,
                      surface: surface,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),

                    const SizedBox(height: 24),

                    _SectionLabel(
                      label: 'AiTradeX',
                      color: textSecondary,
                    ),

                    const SizedBox(height: 10),

                    _OptionsCard(
                      items: _items,
                      primary: scheme.primary,
                      surface: surface,
                      border: border,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),

                    const SizedBox(height: 20),

                    Center(
                      child: Text(
                        'AiTradeX v5.6.9',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: textSecondary.withValues(
                            alpha: 0.78,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Center(
                      child: Text(
                        'Invest smarter. Trade with confidence.',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: textSecondary.withValues(
                            alpha: 0.62,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandHero extends StatelessWidget {
  const _BrandHero({
    required this.primary,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
  });

  final Color primary;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        20,
        22,
        20,
        22,
      ),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: primary.withValues(
            alpha: isDark ? 0.20 : 0.10,
          ),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(
              alpha: isDark ? 0.08 : 0.07,
            ),
            blurRadius: 28,
            spreadRadius: -4,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          const _AiTradeXLogo(),

          const SizedBox(height: 16),

          Text(
            'AiTradeX',
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.7,
              color: textPrimary,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'AI-powered investing & market intelligence',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: textSecondary,
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: primary.withValues(
                alpha: isDark ? 0.13 : 0.08,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.40),
                        blurRadius: 7,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Smart investing, simplified',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
          color: color,
        ),
      ),
    );
  }
}

class _OptionsCard extends StatelessWidget {
  const _OptionsCard({
    required this.items,
    required this.primary,
    required this.surface,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
  });

  final List<_AboutItem> items;
  final Color primary;
  final Color surface;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: border,
          width: 0.8,
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          vertical: 5,
        ),
        itemCount: items.length,
        separatorBuilder: (_, __) {
          return Divider(
            height: 1,
            thickness: 0.7,
            indent: 72,
            endIndent: 18,
            color: border,
          );
        },
        itemBuilder: (context, index) {
          final _AboutItem item = items[index];

          return _AboutOptionTile(
            item: item,
            primary: primary,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          );
        },
      ),
    );
  }
}

class _AboutOptionTile extends StatelessWidget {
  const _AboutOptionTile({
    required this.item,
    required this.primary,
    required this.textPrimary,
    required this.textSecondary,
  });

  final _AboutItem item;
  final Color primary;
  final Color textPrimary;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark =
        theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.fromLTRB(
                  18,
                  0,
                  18,
                  18,
                ),
                backgroundColor:
                theme.colorScheme.inverseSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                content: Text(
                  '${item.title} selected.',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color:
                    theme.colorScheme.onInverseSurface,
                  ),
                ),
              ),
            );
        },
        borderRadius: BorderRadius.circular(20),
        splashColor: primary.withValues(
          alpha: isDark ? 0.10 : 0.06,
        ),
        highlightColor: primary.withValues(
          alpha: isDark ? 0.06 : 0.03,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: primary.withValues(
                    alpha: isDark ? 0.12 : 0.07,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  item.icon,
                  size: 20,
                  color: primary,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              Icon(
                Icons.chevron_right_rounded,
                size: 23,
                color: textSecondary.withValues(
                  alpha: 0.72,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AboutItem {
  const _AboutItem({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

class _AiTradeXLogo extends StatelessWidget {
  const _AiTradeXLogo();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final bool isDark =
        theme.brightness == Brightness.dark;

    final Color primary = scheme.primary;
    final Color logoCenter = isDark
        ? scheme.surface
        : Colors.white;

    return SizedBox(
      width: 116,
      height: 116,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primary,
                  Color.lerp(
                    primary,
                    Colors.black,
                    isDark ? 0.16 : 0.08,
                  ) ??
                      primary,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(
                    alpha: isDark ? 0.25 : 0.20,
                  ),
                  blurRadius: 24,
                  spreadRadius: 1,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
          ),

          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: logoCenter,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: isDark ? 0.22 : 0.06,
                  ),
                  blurRadius: 10,
                ),
              ],
            ),
          ),

          Positioned(
            top: 8,
            right: 25,
            child: _Dot(
              size: 18,
              color: primary,
            ),
          ),

          Positioned(
            top: 25,
            right: 8,
            child: _Dot(
              size: 12,
              color: primary,
            ),
          ),

          Positioned(
            top: 5,
            left: 40,
            child: _Dot(
              size: 9,
              color: primary,
            ),
          ),

          Positioned(
            top: 39,
            right: 0,
            child: _Dot(
              size: 8,
              color: primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
