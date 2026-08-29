import 'package:flutter/material.dart';

import '../account/account_screen.dart';
import '../discover/discover_screen.dart';
import '../home/dashboard_screen.dart';
import '../more/more_screen.dart';
import '../portfolio/portfolio_screen.dart';

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
  static const Color primaryColor = Color(0xff18C48F);
  static const Color inactiveColor = Color(0xff8C8C8C);

  late int _currentIndex;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    _currentIndex = widget.initialIndex.clamp(0, 4);

    _screens = const [
      DashboardScreen(),
      PortfolioScreen(),
      DiscoverScreen(),
      MoreScreen(),
      AccountScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ============================================================
      // MAIN CONTENT
      // ============================================================
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      // ============================================================
      // CUSTOM BOTTOM NAVIGATION
      // ============================================================
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
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
            color: Colors.black.withValues(alpha: 0.035),
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
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (_currentIndex == index) {
              return;
            }

            setState(() {
              _currentIndex = index;
            });
          },
          child: SizedBox(
            height: 68,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ======================================================
                // ICON
                // ======================================================
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  width: selected ? 28 : 25,
                  height: selected ? 28 : 25,
                  decoration: selected
                      ? const BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  )
                      : null,
                  child: Icon(
                    selected ? activeIcon : icon,
                    size: selected ? 18 : 23,
                    color: selected ? Colors.white : inactiveColor,
                  ),
                ),

                const SizedBox(height: 4),

                // ======================================================
                // LABEL
                // ======================================================
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? primaryColor : inactiveColor,
                    fontSize: 10,
                    height: 1.1,
                    fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}