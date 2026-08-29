import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _rewardsGreen = Color(0xff18C48F);

/// Opens when the user taps "Get free stock" from Account.
class InviteFriendsScreen extends StatelessWidget {
  const InviteFriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 22, 24, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TopBar(
                      title: '',
                      onBack: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(height: 28),
                    const _InviteIllustration(),
                    const SizedBox(height: 18),
                    Center(
                      child: Text(
                        'Invite Friends.',
                        style: GoogleFonts.poppins(
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Get Free Stock!',
                        style: GoogleFonts.poppins(
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Divider(
                      height: 1,
                      color: Color(0xffE8E8E8),
                    ),
                    const SizedBox(height: 8),
                    const _InviteStep(
                      icon: Icons.star_rounded,
                      title: 'Invite your friends',
                      description:
                      'Send your friends your personal invite link.',
                    ),
                    const _InviteStep(
                      icon: Icons.star_rounded,
                      title: 'They get free stock',
                      description:
                      'Your friends get \$5 of free stock when they\njoin. ',
                      linkText: 'Terms apply.',
                    ),
                    const _InviteStep(
                      icon: Icons.star_rounded,
                      title: 'You get free stock',
                      description:
                      'Get rewarded when your friends join AiTradeX.',
                    ),
                  ],
                ),
              ),
            ),
            _BottomActions(
              primaryText: 'Share My Invite Link',
              primaryIcon: Icons.send_rounded,
              onPrimary: () => _shareInvite(context),
              secondaryText: 'My Rewards',
              secondaryIcon: Icons.card_giftcard_rounded,
              onSecondary: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const MyRewardsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _shareInvite(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Invite link ready to share.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

class MyRewardsScreen extends StatelessWidget {
  const MyRewardsScreen({super.key});

  static const List<_RewardPerson> _people = [
    _RewardPerson('Augustina Midgett', '\$5', 'AM'),
    _RewardPerson('Chieko Chute', '\$10', 'CC'),
    _RewardPerson('Thad Eddings', '\$10', 'TE'),
    _RewardPerson('Maryland Winkles', '\$5', 'MW'),
    _RewardPerson('Merrill Kervin', '\$5', 'MK'),
    _RewardPerson('Florencio Dorrance', '\$10', 'FD'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 22, 24, 110),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _TopBar(
                          title: 'My Rewards',
                          showSearch: true,
                          onBack: () => Navigator.of(context).pop(),
                          onSearch: () => _showSearch(context),
                        ),
                        const SizedBox(height: 36),
                        Text(
                          'You’ve invited 25 friends\n& unlocked \$250 of free\nstock! 🎁',
                          style: GoogleFonts.poppins(
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                            height: 1.68,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Keep inviting friends to unlock more!',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: const Color(0xff333333),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ..._people.map(
                              (person) => _RewardRow(person: person),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
            _BottomActions(
              primaryText: 'Share My Invite Link',
              primaryIcon: Icons.send_rounded,
              onPrimary: () => _share(context),
            ),
          ],
        ),
      ),
    );
  }

  void _share(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invite link ready to share.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSearch(BuildContext context) {
    showSearch(
      context: context,
      delegate: _RewardsSearchDelegate(),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.onBack,
    this.showSearch = false,
    this.onSearch,
  });

  final String title;
  final VoidCallback onBack;
  final bool showSearch;
  final VoidCallback? onSearch;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: onBack,
          borderRadius: BorderRadius.circular(24),
          child: const SizedBox(
            width: 34,
            height: 34,
            child: Icon(
              Icons.arrow_back_rounded,
              size: 27,
            ),
          ),
        ),
        if (title.isNotEmpty) ...[
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ] else
          const Spacer(),
        if (showSearch)
          InkWell(
            onTap: onSearch,
            borderRadius: BorderRadius.circular(30),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.search_rounded,
                size: 31,
                color: Colors.black,
              ),
            ),
          ),
      ],
    );
  }
}

class _InviteIllustration extends StatelessWidget {
  const _InviteIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 235,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            left: 28,
            top: 55,
            child: _Firework(
              color: const Color(0xffFF9F21),
              size: 54,
            ),
          ),
          Positioned(
            left: 70,
            top: 10,
            child: _Firework(
              color: const Color(0xff7B68FF),
              size: 42,
            ),
          ),
          Positioned(
            right: 72,
            top: 5,
            child: _Firework(
              color: const Color(0xff48D6AE),
              size: 58,
            ),
          ),
          Positioned(
            right: 22,
            top: 60,
            child: _Firework(
              color: const Color(0xffff7f86),
              size: 42,
            ),
          ),
          Positioned(
            right: 50,
            top: 45,
            child: _Firework(
              color: const Color(0xffffb84a),
              size: 25,
            ),
          ),
          Positioned(
            left: 74,
            bottom: 2,
            child: _PersonIllustration(
              shirtColor: const Color(0xff19CF94),
              skirt: true,
              scale: 1.0,
            ),
          ),
          Positioned(
            left: 143,
            bottom: 1,
            child: _PersonIllustration(
              shirtColor: const Color(0xff20CF98),
              scale: 1.08,
            ),
          ),
          Positioned(
            right: 63,
            bottom: 1,
            child: _PersonIllustration(
              shirtColor: const Color(0xff1DCE96),
              scale: 1.0,
            ),
          ),
          Positioned(
            left: 60,
            right: 60,
            bottom: 0,
            child: Container(
              height: 1,
              color: const Color(0xff555555),
            ),
          ),
        ],
      ),
    );
  }
}

class _Firework extends StatelessWidget {
  const _Firework({
    required this.color,
    required this.size,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _FireworkPainter(color),
      ),
    );
  }
}

class _FireworkPainter extends CustomPainter {
  _FireworkPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * .43;

    for (int i = 0; i < 16; i++) {
      final angle = i * 3.14159265359 / 8;
      final start = Offset(
        center.dx + radius * .18 * _cos(angle),
        center.dy + radius * .18 * _sin(angle),
      );
      final end = Offset(
        center.dx + radius * _cos(angle),
        center.dy + radius * _sin(angle),
      );
      canvas.drawLine(start, end, paint);
    }
  }

  double _cos(double v) => _Trig.cos(v);
  double _sin(double v) => _Trig.sin(v);

  @override
  bool shouldRepaint(covariant _FireworkPainter oldDelegate) =>
      oldDelegate.color != color;
}

// Small trigonometric helpers avoid adding another dependency.
class _Trig {
  static double sin(double x) {
    // Taylor approximation is more than sufficient for this tiny decoration.
    double term = x;
    double sum = x;
    for (int n = 1; n <= 6; n++) {
      term *= -x * x / ((2 * n) * (2 * n + 1));
      sum += term;
    }
    return sum;
  }

  static double cos(double x) {
    return sin(x + 1.57079632679);
  }
}

class _PersonIllustration extends StatelessWidget {
  const _PersonIllustration({
    required this.shirtColor,
    this.skirt = false,
    this.scale = 1,
  });

  final Color shirtColor;
  final bool skirt;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 65 * scale,
      height: 160 * scale,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 0,
            child: Container(
              width: 18 * scale,
              height: 18 * scale,
              decoration: const BoxDecoration(
                color: Color(0xff252532),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 20 * scale,
            child: Container(
              width: 40 * scale,
              height: 55 * scale,
              decoration: BoxDecoration(
                color: shirtColor,
                borderRadius: BorderRadius.circular(18 * scale),
              ),
            ),
          ),
          Positioned(
            top: 70 * scale,
            left: 18 * scale,
            child: Container(
              width: 11 * scale,
              height: 68 * scale,
              decoration: BoxDecoration(
                color: const Color(0xff242434),
                borderRadius: BorderRadius.circular(7 * scale),
              ),
            ),
          ),
          Positioned(
            top: 70 * scale,
            right: 18 * scale,
            child: Container(
              width: 11 * scale,
              height: 68 * scale,
              decoration: BoxDecoration(
                color: const Color(0xff242434),
                borderRadius: BorderRadius.circular(7 * scale),
              ),
            ),
          ),
          Positioned(
            top: 35 * scale,
            left: 0,
            child: Transform.rotate(
              angle: -.45,
              child: Container(
                width: 11 * scale,
                height: 58 * scale,
                decoration: BoxDecoration(
                  color: shirtColor,
                  borderRadius: BorderRadius.circular(7 * scale),
                ),
              ),
            ),
          ),
          Positioned(
            top: 35 * scale,
            right: 0,
            child: Transform.rotate(
              angle: .45,
              child: Container(
                width: 11 * scale,
                height: 58 * scale,
                decoration: BoxDecoration(
                  color: shirtColor,
                  borderRadius: BorderRadius.circular(7 * scale),
                ),
              ),
            ),
          ),
          if (skirt)
            Positioned(
              top: 67 * scale,
              child: Transform.rotate(
                angle: -.08,
                child: Container(
                  width: 47 * scale,
                  height: 18 * scale,
                  decoration: BoxDecoration(
                    color: const Color(0xff242434),
                    borderRadius: BorderRadius.circular(7 * scale),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InviteStep extends StatelessWidget {
  const _InviteStep({
    required this.icon,
    required this.title,
    required this.description,
    this.linkText,
  });

  final IconData icon;
  final String title;
  final String description;
  final String? linkText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: 42,
            child: Icon(
              Icons.star_rounded,
              color: Color(0xffffa000),
              size: 34,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 7),
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xff555555),
                      height: 1.5,
                    ),
                    children: [
                      TextSpan(text: description),
                      if (linkText != null)
                        TextSpan(
                          text: linkText,
                          style: const TextStyle(
                            color: _rewardsGreen,
                          ),
                        ),
                    ],
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

class _RewardPerson {
  const _RewardPerson(this.name, this.amount, this.initials);

  final String name;
  final String amount;
  final String initials;
}

class _RewardRow extends StatelessWidget {
  const _RewardRow({required this.person});

  final _RewardPerson person;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xffE7E7E7),
            width: .8,
          ),
        ),
      ),
      child: Row(
        children: [
          _Avatar(initials: person.initials),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              person.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            person.amount,
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 17),
          const Icon(
            Icons.chevron_right_rounded,
            color: _rewardsGreen,
            size: 25,
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xffdcecff),
            Color((initials.hashCode & 0x00FFFFFF) | 0xFF000000),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.primaryText,
    required this.primaryIcon,
    required this.onPrimary,
    this.secondaryText,
    this.secondaryIcon,
    this.onSecondary,
  });

  final String primaryText;
  final IconData primaryIcon;
  final VoidCallback onPrimary;
  final String? secondaryText;
  final IconData? secondaryIcon;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        20 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xffeeeeee),
            width: .8,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton.icon(
              onPressed: onPrimary,
              icon: Icon(primaryIcon, size: 20),
              label: Text(
                primaryText,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _rewardsGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          if (secondaryText != null) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 57,
              child: TextButton.icon(
                onPressed: onSecondary,
                icon: Icon(
                  secondaryIcon,
                  size: 20,
                  color: _rewardsGreen,
                ),
                label: Text(
                  secondaryText!,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _rewardsGreen,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xffe8faf5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RewardsSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget>? buildActions(BuildContext context) => [
    if (query.isNotEmpty)
      IconButton(
        onPressed: () => query = '',
        icon: const Icon(Icons.clear),
      ),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    onPressed: () => close(context, ''),
    icon: const Icon(Icons.arrow_back_rounded),
  );

  @override
  Widget buildResults(BuildContext context) {
    return Center(
      child: Text(
        query.isEmpty ? 'Search rewards' : 'No matching rewards',
        style: GoogleFonts.poppins(),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}
