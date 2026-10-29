import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ============================================================
// HOME / DASHBOARD
// ============================================================

import 'dashboard_screen.dart';

// ============================================================
// OTHER MAIN SCREENS
// ============================================================

import '../portfolio/portfolio_screen.dart';
import '../discover/discover_screen.dart';
import '../more/more_screen.dart';
import '../account/account_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.initialIndex = 0,
  });

  /// Initial tab:
  ///
  /// 0 = Home
  /// 1 = Portfolio
  /// 2 = Discover
  /// 3 = More
  /// 4 = Account
  final int initialIndex;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryColor = Color(0xff18C48F);

  static const Color inactiveColor = Color(0xff8C8C8C);

  // ============================================================
  // CURRENT TAB
  // ============================================================

  late int _currentIndex;

  // ============================================================
  // APP SCREENS
  // ============================================================

  late final List<Widget> _screens;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _currentIndex =
        widget.initialIndex.clamp(0, 4).toInt();

    _screens = const [
      DashboardScreen(),
      PortfolioScreen(),
      DiscoverScreen(),
      MoreScreen(),
      AccountScreen(),
    ];
  }

  // ============================================================
  // TAB CHANGE
  // ============================================================

  void _changeTab(int index) {
    if (_currentIndex == index) {
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,

        statusBarIconBrightness: Brightness.dark,

        statusBarBrightness: Brightness.light,

        systemNavigationBarColor: Colors.white,

        systemNavigationBarIconBrightness:
        Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,

        // ======================================================
        // MAIN CONTENT
        // ======================================================

        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),

        // ======================================================
        // BOTTOM NAVIGATION
        // ======================================================

        bottomNavigationBar:
        _buildBottomNavigationBar(),
      ),
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION BAR
  // ============================================================

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,

        border: const Border(
          top: BorderSide(
            color: Color(0xffEEEEEE),
            width: 0.7,
          ),
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.035,
            ),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, -2),
          ),
        ],
      ),

      child: SafeArea(
        top: false,
        bottom: true,

        child: SizedBox(
          height: 68,

          child: Row(
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
              ),

              _buildNavItem(
                index: 1,
                icon: Icons.show_chart_outlined,
                activeIcon: Icons.show_chart_rounded,
                label: 'Portfolio',
              ),

              _buildNavItem(
                index: 2,
                icon: Icons.explore_outlined,
                activeIcon: Icons.explore_rounded,
                label: 'Discover',
              ),

              _buildNavItem(
                index: 3,
                icon: Icons.more_horiz_rounded,
                activeIcon: Icons.more_horiz_rounded,
                label: 'More',
              ),

              _buildNavItem(
                index: 4,
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Account',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // NAVIGATION ITEM
  // ============================================================

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final bool selected = _currentIndex == index;

    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,

        child: Material(
          color: Colors.transparent,

          child: InkWell(
            onTap: () => _changeTab(index),

            splashColor:
            primaryColor.withValues(
              alpha: 0.08,
            ),

            highlightColor:
            primaryColor.withValues(
              alpha: 0.04,
            ),

            child: SizedBox(
              height: 68,

              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,

                children: [
                  // ==================================================
                  // ICON
                  // ==================================================

                  AnimatedContainer(
                    duration:
                    const Duration(
                      milliseconds: 180,
                    ),

                    curve: Curves.easeOut,

                    width: selected ? 30 : 25,

                    height: selected ? 30 : 25,

                    decoration: selected
                        ? const BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    )
                        : null,

                    alignment: Alignment.center,

                    child: Icon(
                      selected
                          ? activeIcon
                          : icon,

                      size: selected ? 18 : 23,

                      color: selected
                          ? Colors.white
                          : inactiveColor,
                    ),
                  ),

                  const SizedBox(height: 3),

                  // ==================================================
                  // LABEL
                  // ==================================================

                  Text(
                    label,

                    maxLines: 1,

                    overflow:
                    TextOverflow.ellipsis,

                    style: TextStyle(
                      color: selected
                          ? primaryColor
                          : inactiveColor,

                      fontSize: 10,

                      height: 1.1,

                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.w400,
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