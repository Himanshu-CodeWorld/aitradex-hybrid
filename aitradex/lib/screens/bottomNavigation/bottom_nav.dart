import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../home/dashboard_screen.dart';
import '../invest/invest_screen.dart';
import '../wishlist/wishlist_screen.dart';
import '../markets/markets_screen.dart';
import '../portfolio/portfolio_screen.dart';

/// AiTradeX bottom navigation.
///
/// Tabs:
/// 0 → Home
/// 1 → Invest
/// 2 → Watchlist
/// 3 → Markets
/// 4 → Portfolio
///
/// TradeX AI is intentionally opened from the Dashboard, not from the
/// bottom navigation.
class BottomNav extends StatefulWidget {
  const BottomNav({
    super.key,
    this.initialIndex = 0,
  });

  final int initialIndex;

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  late int _currentIndex;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    _currentIndex = _normalizeIndex(widget.initialIndex);

    _screens = const <Widget>[
      DashboardScreen(),
      InvestScreen(),
      WishlistScreen(),
      MarketsScreen(),
      PortfolioScreen(),
    ];
  }

  int _normalizeIndex(int index) {
    if (index < 0 || index >= 5) {
      return 0;
    }
    return index;
  }

  void _selectTab(int index) {
    if (index < 0 || index >= 5) {
      return;
    }

    if (_currentIndex == index) {
      HapticFeedback.selectionClick();
      return;
    }

    HapticFeedback.lightImpact();

    setState(() {
      _currentIndex = index;
    });
  }

  ColorScheme _scheme(BuildContext context) {
    return Theme.of(context).colorScheme;
  }

  bool _isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  Color _background(BuildContext context) {
    return Theme.of(context).scaffoldBackgroundColor;
  }

  Color _barColor(BuildContext context) {
    final scheme = _scheme(context);
    return scheme.surface.withValues(
      alpha: _isDark(context) ? 0.97 : 0.95,
    );
  }

  Color _inactiveColor(BuildContext context) {
    return _scheme(context).onSurface.withValues(
      alpha: _isDark(context) ? 0.54 : 0.48,
    );
  }

  Color _borderColor(BuildContext context) {
    return _scheme(context).outline.withValues(
      alpha: _isDark(context) ? 0.20 : 0.09,
    );
  }

  Color _activeBackground(BuildContext context) {
    return _scheme(context).primary.withValues(
      alpha: _isDark(context) ? 0.15 : 0.09,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: _background(context),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 24,
          sigmaY: 24,
        ),
        child: Container(
          height: 84 + bottomInset,
          decoration: BoxDecoration(
            color: _barColor(context),
            border: Border(
              top: BorderSide(
                color: _borderColor(context),
                width: 0.8,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: _isDark(context) ? 0.28 : 0.075,
                ),
                blurRadius: 28,
                spreadRadius: -6,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: 6,
              right: 6,
              bottom: bottomInset,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildNavItem(
                    context: context,
                    index: 0,
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    label: 'Home',
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    context: context,
                    index: 1,
                    icon: Icons.account_balance_wallet_outlined,
                    activeIcon: Icons.account_balance_wallet_rounded,
                    label: 'Invest',
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    context: context,
                    index: 2,
                    icon: Icons.star_border_rounded,
                    activeIcon: Icons.star_rounded,
                    label: 'Watchlist',
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    context: context,
                    index: 3,
                    icon: Icons.candlestick_chart_outlined,
                    activeIcon: Icons.candlestick_chart_rounded,
                    label: 'Markets',
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    context: context,
                    index: 4,
                    icon: Icons.pie_chart_outline_rounded,
                    activeIcon: Icons.pie_chart_rounded,
                    label: 'Portfolio',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final selected = _currentIndex == index;
    final primary = _scheme(context).primary;
    final inactive = _inactiveColor(context);

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: () => _selectTab(index),
        splashColor: primary.withValues(alpha: 0.08),
        highlightColor: primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          height: 74,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              width: 68,
              height: 62,
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? _activeBackground(context)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
                border: selected
                    ? Border.all(
                  color: primary.withValues(alpha: 0.09),
                  width: 0.8,
                )
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    switchInCurve: Curves.easeOutBack,
                    switchOutCurve: Curves.easeIn,
                    child: Icon(
                      selected ? activeIcon : icon,
                      key: ValueKey<String>('$index-$selected'),
                      size: selected ? 23 : 22,
                      color: selected ? primary : inactive,
                    ),
                  ),
                  const SizedBox(height: 5),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 180),
                    style: TextStyle(
                      color: selected ? primary : inactive,
                      fontSize: 9.5,
                      fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w600,
                      height: 1,
                      fontFamily: GoogleFonts.poppins().fontFamily,
                    ),
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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
