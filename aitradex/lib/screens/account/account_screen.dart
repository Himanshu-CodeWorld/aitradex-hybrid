
import 'package:aitradex/screens/rewards/invite_friends_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:aitradex/screens/rewards/invite_friends_screen.dart';
import 'personal_info_screen.dart';
import 'notification_screen.dart';
import 'security_screen.dart';
import 'language_screen.dart';
import 'help_center_screen.dart';
import 'about_aitradex_screen.dart';
import 'logout_bottom_sheet.dart';

const Color _accountPrimary = Color(0xff18C48F);

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 110),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    _buildProfile(),
                    const SizedBox(height: 24),
                    _ReferralCard(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const InviteFriendsScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 23),
                    const Divider(
                      height: 1,
                      thickness: 0.8,
                      color: Color(0xffE8E8E8),
                    ),
                    const SizedBox(height: 22),

                    _AccountOption(
                      title: 'Personal Info',
                      icon: Icons.person_rounded,
                      iconColor: const Color(0xffff9818),
                      backgroundColor: const Color(0xfffff6e8),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const PersonalInfoScreen(),
                          ),
                        );
                      },
                    ),
                    _AccountOption(
                      title: 'Notification',
                      icon: Icons.notifications_rounded,
                      iconColor: const Color(0xffff6979),
                      backgroundColor: const Color(0xffffeff1),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const NotificationScreen(),
                          ),
                        );
                      },
                    ),
                    _AccountOption(
                      title: 'Security',
                      icon: Icons.verified_user_rounded,
                      iconColor: const Color(0xff35D09F),
                      backgroundColor: const Color(0xffeaf9f3),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SecurityScreen(),
                          ),
                        );
                      },
                    ),
                    _AccountOption(
                      title: 'Language',
                      icon: Icons.grid_view_rounded,
                      iconColor: const Color(0xff785BFF),
                      backgroundColor: const Color(0xfff1efff),
                      trailing: Text(
                        'English (US)',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xff222222),
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const LanguageScreen(),
                          ),
                        );
                      },
                    ),
                    _AccountOption(
                      title: 'Dark Mode',
                      icon: Icons.visibility_rounded,
                      iconColor: const Color(0xff397AF5),
                      backgroundColor: const Color(0xffedf3ff),
                      showChevron: false,
                      trailing: Switch(
                        value: _darkMode,
                        onChanged: (value) {
                          setState(() => _darkMode = value);
                        },
                        activeThumbColor: _accountPrimary,
                        activeTrackColor: const Color(0xffbcefe0),
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: const Color(0xffe9e9e9),
                        materialTapTargetSize:
                        MaterialTapTargetSize.shrinkWrap,
                      ),
                      onTap: () {
                        setState(() => _darkMode = !_darkMode);
                      },
                    ),

                    const SizedBox(height: 8),
                    const Divider(
                      height: 1,
                      thickness: 0.8,
                      color: Color(0xffE8E8E8),
                    ),
                    const SizedBox(height: 12),

                    _AccountOption(
                      title: 'Help Center',
                      icon: Icons.description_rounded,
                      iconColor: const Color(0xff42D1AE),
                      backgroundColor: const Color(0xffeaf9f3),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const HelpCenterScreen(),
                          ),
                        );
                      },
                    ),
                    _AccountOption(
                      title: 'Legal Agreements',
                      icon: Icons.check_rounded,
                      iconColor: const Color(0xffff9e19),
                      backgroundColor: const Color(0xfffff5e6),
                      onTap: () => _showMessage('Legal Agreements'),
                    ),
                    _AccountOption(
                      title: 'About AiTradeX',
                      icon: Icons.info_rounded,
                      iconColor: const Color(0xff4d7ff3),
                      backgroundColor: const Color(0xffedf3ff),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AboutAiTradeXScreen(),
                          ),
                        );
                      },
                    ),
                    _AccountOption(
                      title: 'Close Your Account',
                      icon: Icons.close_rounded,
                      iconColor: const Color(0xffff5961),
                      backgroundColor: const Color(0xffffeef0),
                      titleColor: const Color(0xffff4f58),
                      onTap: () => _confirmCloseAccount(),
                    ),
                    _AccountOption(
                      title: 'Logout',
                      icon: Icons.logout_rounded,
                      iconColor: const Color(0xffff6d7b),
                      backgroundColor: const Color(0xffffeef0),
                      titleColor: const Color(0xffff4f58),
                      onTap: () {
                        showLogoutDialog(context);
                      },
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 26, 24, 0),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xffe6faf4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.bubble_chart_rounded,
              color: _accountPrimary,
              size: 23,
            ),
          ),
          const SizedBox(width: 11),
          Text(
            'Account',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfile() {
    return Row(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xffd8d8d8),
          ),
          clipBehavior: Clip.antiAlias,
          child: const Icon(
            Icons.person_rounded,
            color: Color(0xff7b7b7b),
            size: 42,
          ),
        ),
        const SizedBox(width: 17),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Andrew Ainsley',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'andrew_ainsley@yourdomain.com',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xff3f3f3f),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => _showMessage('Edit Profile'),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(
            minWidth: 28,
            minHeight: 28,
          ),
          icon: const Icon(
            Icons.edit_outlined,
            color: _accountPrimary,
            size: 22,
          ),
        ),
      ],
    );
  }

  void _showMessage(String title) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '$title is ready to configure.',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1000),
        ),
      );
  }

  void _showLanguageSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(
                    'English (US)',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.check_circle_rounded,
                    color: _accountPrimary,
                  ),
                  onTap: () => Navigator.of(sheetContext).pop(),
                ),
                ListTile(
                  title: Text(
                    'English (UK)',
                    style: GoogleFonts.poppins(),
                  ),
                  onTap: () => Navigator.of(sheetContext).pop(),
                ),
                ListTile(
                  title: Text(
                    'Hindi',
                    style: GoogleFonts.poppins(),
                  ),
                  onTap: () => Navigator.of(sheetContext).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmLogout() {
    _confirmAction(
      title: 'Logout',
      message: 'Are you sure you want to logout?',
      confirmText: 'Logout',
    );
  }

  void _confirmCloseAccount() {
    _confirmAction(
      title: 'Close Your Account',
      message:
      'Closing your account is permanent. Are you sure you want to continue?',
      confirmText: 'Close Account',
    );
  }

  void _confirmAction({
    required String title,
    required String message,
    required String confirmText,
  }) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xff666666),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: const Color(0xff666666),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                confirmText,
                style: GoogleFonts.poppins(
                  color: const Color(0xffff4f58),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AccountOption extends StatelessWidget {
  const _AccountOption({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.onTap,
    this.trailing,
    this.showChevron = true,
    this.titleColor,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool showChevron;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: 80,
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 23,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: titleColor ?? const Color(0xff171717),
                ),
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
            if (showChevron)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 25,
                  color: Color(0xff202020),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ReferralCard extends StatelessWidget {
  const _ReferralCard({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(23),
      child: Container(
        height: 116,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: const Color(0xfffcfcfc),
          borderRadius: BorderRadius.circular(23),
          border: Border.all(
            color: const Color(0xffeeeeee),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 100,
              height: 88,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Positioned(
                    bottom: 7,
                    left: 5,
                    right: 5,
                    child: Container(
                      height: 2,
                      color: const Color(0xffd6d6d6),
                    ),
                  ),
                  const Positioned(
                    left: 12,
                    bottom: 9,
                    child: _ReferralPerson(
                      color: Color(0xff18C48F),
                      height: 46,
                    ),
                  ),
                  const Positioned(
                    left: 40,
                    bottom: 8,
                    child: _ReferralPerson(
                      color: Color(0xfff25b83),
                      height: 54,
                    ),
                  ),
                  const Positioned(
                    right: 8,
                    bottom: 8,
                    child: _ReferralPerson(
                      color: Color(0xff18C48F),
                      height: 48,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Get free stock 💰',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Refer your friends & unlock up to\n\$100 of free stock per friend',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      height: 1.45,
                      color: const Color(0xff3d3d3d),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReferralPerson extends StatelessWidget {
  const _ReferralPerson({
    required this.color,
    required this.height,
  });

  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final double scale = (height / 50.0).clamp(0.70, 1.0);

    return SizedBox(
      width: 24,
      height: height,
      child: Center(
        child: SizedBox(
          width: 24 * scale,
          height: 50 * scale,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                top: 0,
                left: 7.5 * scale,
                child: Container(
                  width: 9 * scale,
                  height: 9 * scale,
                  decoration: const BoxDecoration(
                    color: Color(0xff202020),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                top: 11 * scale,
                left: 4.5 * scale,
                child: Container(
                  width: 15 * scale,
                  height: 25 * scale,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8 * scale),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 4 * scale,
                child: Container(
                  width: 5 * scale,
                  height: 13 * scale,
                  decoration: BoxDecoration(
                    color: const Color(0xff222222),
                    borderRadius: BorderRadius.circular(5 * scale),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 4 * scale,
                child: Container(
                  width: 5 * scale,
                  height: 13 * scale,
                  decoration: BoxDecoration(
                    color: const Color(0xff222222),
                    borderRadius: BorderRadius.circular(5 * scale),
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
