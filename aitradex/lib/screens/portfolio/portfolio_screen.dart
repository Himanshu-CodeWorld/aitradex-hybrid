import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:aitradex/screens/stockDetails/stock_details_screen.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  static const Color primaryColor = Color(0xff18C48F);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,

        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ============================================================
            // PORTFOLIO HEADER
            // ============================================================

            const SliverToBoxAdapter(
              child: _PortfolioHeader(),
            ),

            // ============================================================
            // PORTFOLIO VALUE CARD
            // ============================================================

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  24,
                  24,
                  24,
                  0,
                ),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xffEEEEEE),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "\$196,548.50",
                        style: GoogleFonts.poppins(
                          fontSize: 38,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                          letterSpacing: -1.2,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 17,
                            height: 17,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Icon(
                              Icons.arrow_upward_rounded,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),

                          const SizedBox(width: 8),

                          Text(
                            "\$66,378.49",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: primaryColor,
                            ),
                          ),

                          const SizedBox(width: 8),

                          Text(
                            "(24.65%)",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ============================================================
            // MY ACCOUNT TITLE
            // ============================================================

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  24,
                  28,
                  24,
                  18,
                ),
                child: Text(
                  "My Account",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            // ============================================================
            // MY ACCOUNT ITEMS
            // ============================================================

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                ),
                child: Column(
                  children: [
                    // ----------------------------------------------------------
                    // ROW 1
                    // ----------------------------------------------------------

                    Row(
                      children: [
                        Expanded(
                          child: _AccountItem(
                            icon: Icons.account_balance_wallet_outlined,
                            iconColor: const Color(0xff3978F6),
                            iconBackground: const Color(0xffEEF4FF),
                            title: "Cash Available",
                            value: "\$23,087.39",
                          ),
                        ),

                        const SizedBox(width: 20),

                        Expanded(
                          child: _AccountItem(
                            icon: Icons.access_time_rounded,
                            iconColor: const Color(0xffff9418),
                            iconBackground: const Color(0xfffff3e7),
                            title: "Pending Buys",
                            value: "\$9,739.36",
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ----------------------------------------------------------
                    // ROW 2
                    // ----------------------------------------------------------

                    Row(
                      children: [
                        Expanded(
                          child: _AccountItem(
                            icon: Icons.pie_chart_rounded,
                            iconColor: const Color(0xffff6f7c),
                            iconBackground: const Color(0xfffff1f1),
                            title: "Equity",
                            value: "\$186,473.68",
                          ),
                        ),

                        const SizedBox(width: 20),

                        Expanded(
                          child: _AccountItem(
                            icon: Icons.trending_up_rounded,
                            iconColor: const Color(0xff7357F6),
                            iconBackground: const Color(0xffF0EEFF),
                            title: "Total Returns",
                            value: "\$66,378.49",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ============================================================
            // MY POSITIONS
            // ============================================================

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  24,
                  22,
                  24,
                  8,
                ),
                child: Row(
                  children: [
                    Text(
                      "My Positions",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),

                    const Spacer(),

                    Text(
                      "Recently",
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff18C48F),
                      ),
                    ),

                    const SizedBox(width: 8),

                    const Icon(
                      Icons.swap_vert_rounded,
                      size: 21,
                      color: Color(0xff18C48F),
                    ),
                  ],
                ),
              ),
            ),

            // ============================================================
            // POSITIONS LIST
            // ============================================================

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                24,
                4,
                24,
                30,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  const [
                    PortfolioPositionTile(
                      company: "Spotify",
                      shares: "0.17469 shares",
                      value: "\$22,935.46",
                      percent: "+2.94%",
                      isPositive: true,
                      logo: "spotify",
                    ),

                    PortfolioPositionTile(
                      company: "Meta - Fac...",
                      shares: "0.09374 shares",
                      value: "\$13,286.82",
                      percent: "-2.16%",
                      isPositive: false,
                      logo: "meta",
                    ),

                    PortfolioPositionTile(
                      company: "Tesla",
                      shares: "0.09569 shares",
                      value: "\$20,564.78",
                      percent: "+2.37%",
                      isPositive: true,
                      logo: "tesla",
                    ),

                    PortfolioPositionTile(
                      company: "Google",
                      shares: "0.17384 shares",
                      value: "\$16,857.75",
                      percent: "+3.85%",
                      isPositive: true,
                      logo: "google",
                    ),

                    PortfolioPositionTile(
                      company: "Netflix",
                      shares: "0.19375 shares",
                      value: "\$9,284.59",
                      percent: "+1.94%",
                      isPositive: true,
                      logo: "netflix",
                    ),

                    PortfolioPositionTile(
                      company: "McDonald's",
                      shares: "0.08476 shares",
                      value: "\$10,038.25",
                      percent: "-0.86%",
                      isPositive: false,
                      logo: "mcdonalds",
                    ),

                    PortfolioPositionTile(
                      company: "Amazon",
                      shares: "0.19843 shares",
                      value: "\$17,653.69",
                      percent: "+1.89%",
                      isPositive: true,
                      logo: "amazon",
                    ),

                    PortfolioPositionTile(
                      company: "CocaCola",
                      shares: "0.18473 shares",
                      value: "\$8,272.38",
                      percent: "+1.64%",
                      isPositive: true,
                      logo: "cocacola",
                    ),

                    PortfolioPositionTile(
                      company: "Nike",
                      shares: "0.07486 shares",
                      value: "\$11,775.65",
                      percent: "-4.25%",
                      isPositive: false,
                      logo: "nike",
                    ),

                    PortfolioPositionTile(
                      company: "Starbucks",
                      shares: "0.28474 shares",
                      value: "\$14,489.47",
                      percent: "+8.29%",
                      isPositive: true,
                      logo: "starbucks",
                    ),

                    PortfolioPositionTile(
                      company: "Airbnb",
                      shares: "0.09343 shares",
                      value: "\$9,946.09",
                      percent: "-4.23%",
                      isPositive: false,
                      logo: "airbnb",
                    ),
                  ],
                ),
              ),
            ),

            // ============================================================
            // ACCOUNT GRID
            // ============================================================

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _AccountItem(
                            icon: Icons.account_balance_wallet_outlined,
                            iconColor: const Color(0xff3978F6),
                            iconBackground: const Color(0xffEEF4FF),
                            title: "Cash Available",
                            value: "\$23,087.39",
                          ),
                        ),

                        const SizedBox(width: 20),

                        Expanded(
                          child: _AccountItem(
                            icon: Icons.access_time_rounded,
                            iconColor: const Color(0xffff9418),
                            iconBackground: const Color(0xfffff3e7),
                            title: "Pending Buys",
                            value: "\$9,739.36",
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: _AccountItem(
                            icon: Icons.pie_chart_rounded,
                            iconColor: const Color(0xffff6f7c),
                            iconBackground: const Color(0xfffff1f1),
                            title: "Equity",
                            value: "\$186,473.68",
                          ),
                        ),

                        const SizedBox(width: 20),

                        Expanded(
                          child: _AccountItem(
                            icon: Icons.trending_up_rounded,
                            iconColor: const Color(0xff7357F6),
                            iconBackground: const Color(0xffF0EEFF),
                            title: "Total Returns",
                            value: "\$66,378.49",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Bottom spacing for existing BottomNav
            const SliverToBoxAdapter(
              child: SizedBox(height: 90),
            ),
          ],
        ),
      ),
    );
  }
}

// ========================================================================
// PORTFOLIO HEADER
// ========================================================================

class _PortfolioHeader extends StatelessWidget {
  const _PortfolioHeader();

  static const Color primaryColor = Color(0xff18C48F);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 480,
      width: double.infinity,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xff16D19A),
              Color(0xff14C991),
            ],
          ),
        ),
        child: Stack(
          children: [
            // ============================================================
            // BACKGROUND SHAPES
            // ============================================================

            Positioned(
              top: -75,
              left: 65,
              child: _PortfolioShape(
                width: 175,
                height: 230,
              ),
            ),

            Positioned(
              top: 70,
              right: -45,
              child: _PortfolioShape(
                width: 180,
                height: 220,
              ),
            ),

            Positioned(
              bottom: -70,
              right: -35,
              child: _PortfolioShape(
                width: 160,
                height: 180,
              ),
            ),

            // ============================================================
            // HEADER CONTENT
            // ============================================================

            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10,
                left: 24,
                right: 24,
              ),
              child: Column(
                children: [
                  // ========================================================
                  // TOP BAR
                  // ========================================================

                  Row(
                    children: [
                      // Logo
                      Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.auto_graph_rounded,
                          color: primaryColor,
                          size: 22,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Text(
                        "My Portfolio",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.4,
                        ),
                      ),

                      const Spacer(),

                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white,
                            width: 1.5,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.more_horiz_rounded,
                          color: Colors.white,
                          size: 23,
                        ),
                      ),
                    ],
                  ),

                  // ========================================================
                  // CHART AREA
                  // ========================================================

                  const SizedBox(height: 24),

                  SizedBox(
                    height: 300,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        // Top value
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Text(
                            "\$209,647.50",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        // Top chart point
                        Positioned(
                          top: 27,
                          right: 2,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                            ),
                          ),
                        ),

                        // Bottom value
                        Positioned(
                          left: 22,
                          bottom: 58,
                          child: Text(
                            "\$168,249.67",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        // Bottom chart point
                        Positioned(
                          left: 58,
                          bottom: 78,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                            ),
                          ),
                        ),

                        // Chart
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 28,
                              bottom: 50,
                            ),
                            child: CustomPaint(
                              painter: _PortfolioChartPainter(),
                            ),
                          ),
                        ),

                        // ==================================================
                        // PERIOD BUTTONS
                        // ==================================================

                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              _PeriodText(
                                text: "1D",
                              ),
                              _PeriodText(
                                text: "1M",
                              ),
                              _SelectedPeriod(
                                text: "1M",
                              ),
                              _PeriodText(
                                text: "3M",
                              ),
                              _PeriodText(
                                text: "1Y",
                              ),
                              _PeriodText(
                                text: "5Y",
                              ),
                            ],
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
      ),
    );
  }
}

// ========================================================================
// BACKGROUND SHAPE
// ========================================================================

class _PortfolioShape extends StatelessWidget {
  final double width;
  final double height;

  const _PortfolioShape({
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.06,
      child: Transform.rotate(
        angle: 0.55,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }
}

// ========================================================================
// CHART PAINTER
// ========================================================================

class _PortfolioChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) {
      return;
    }

    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    path.moveTo(
      0,
      size.height * 0.52,
    );

    path.lineTo(
      size.width * 0.025,
      size.height * 0.45,
    );

    path.lineTo(
      size.width * 0.05,
      size.height * 0.58,
    );

    path.lineTo(
      size.width * 0.075,
      size.height * 0.40,
    );

    path.lineTo(
      size.width * 0.10,
      size.height * 0.48,
    );

    path.lineTo(
      size.width * 0.125,
      size.height * 0.84,
    );

    path.lineTo(
      size.width * 0.15,
      size.height * 0.76,
    );

    path.lineTo(
      size.width * 0.18,
      size.height * 0.55,
    );

    path.lineTo(
      size.width * 0.20,
      size.height * 0.65,
    );

    path.lineTo(
      size.width * 0.225,
      size.height * 0.40,
    );

    path.lineTo(
      size.width * 0.25,
      size.height * 0.72,
    );

    path.lineTo(
      size.width * 0.275,
      size.height * 0.48,
    );

    path.lineTo(
      size.width * 0.30,
      size.height * 0.30,
    );

    path.lineTo(
      size.width * 0.325,
      size.height * 0.74,
    );

    path.lineTo(
      size.width * 0.35,
      size.height * 0.62,
    );

    path.lineTo(
      size.width * 0.375,
      size.height * 0.50,
    );

    path.lineTo(
      size.width * 0.40,
      size.height * 0.78,
    );

    path.lineTo(
      size.width * 0.425,
      size.height * 0.60,
    );

    path.lineTo(
      size.width * 0.45,
      size.height * 0.32,
    );

    path.lineTo(
      size.width * 0.475,
      size.height * 0.70,
    );

    path.lineTo(
      size.width * 0.50,
      size.height * 0.50,
    );

    path.lineTo(
      size.width * 0.525,
      size.height * 0.40,
    );

    path.lineTo(
      size.width * 0.55,
      size.height * 0.68,
    );

    path.lineTo(
      size.width * 0.575,
      size.height * 0.32,
    );

    path.lineTo(
      size.width * 0.60,
      size.height * 0.60,
    );

    path.lineTo(
      size.width * 0.625,
      size.height * 0.80,
    );

    path.lineTo(
      size.width * 0.65,
      size.height * 0.70,
    );

    path.lineTo(
      size.width * 0.675,
      size.height * 0.35,
    );

    path.lineTo(
      size.width * 0.70,
      size.height * 0.64,
    );

    path.lineTo(
      size.width * 0.725,
      size.height * 0.52,
    );

    path.lineTo(
      size.width * 0.75,
      size.height * 0.30,
    );

    path.lineTo(
      size.width * 0.775,
      size.height * 0.48,
    );

    path.lineTo(
      size.width * 0.80,
      size.height * 0.42,
    );

    path.lineTo(
      size.width * 0.825,
      size.height * 0.22,
    );

    path.lineTo(
      size.width * 0.85,
      size.height * 0.68,
    );

    path.lineTo(
      size.width * 0.875,
      size.height * 0.48,
    );

    path.lineTo(
      size.width * 0.90,
      size.height * 0.56,
    );

    path.lineTo(
      size.width * 0.925,
      size.height * 0.18,
    );

    path.lineTo(
      size.width * 0.95,
      size.height * 0.05,
    );

    path.lineTo(
      size.width * 0.975,
      size.height * 0.38,
    );

    path.lineTo(
      size.width,
      size.height * 0.22,
    );

    canvas.drawPath(
      path,
      linePaint,
    );
  }

  @override
  bool shouldRepaint(
      covariant CustomPainter oldDelegate,
      ) {
    return false;
  }
}

// ========================================================================
// PERIOD TEXT
// ========================================================================

class _PeriodText extends StatelessWidget {
  final String text;

  const _PeriodText({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      height: 34,
      child: Center(
        child: Text(
          text,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ========================================================================
// SELECTED PERIOD
// ========================================================================

class _SelectedPeriod extends StatelessWidget {
  final String text;

  const _SelectedPeriod({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 39,
      height: 34,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: const Color(0xff18C48F),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ========================================================================
// ACCOUNT ITEM
// ========================================================================

class _AccountItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String value;

  const _AccountItem({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: iconBackground,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 25,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade700,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ========================================================================
// PORTFOLIO POSITION TILE
// ========================================================================

class PortfolioPositionTile extends StatelessWidget {
  final String company;
  final String shares;
  final String value;
  final String percent;
  final bool isPositive;
  final String logo;

  const PortfolioPositionTile({
    super.key,
    required this.company,
    required this.shares,
    required this.value,
    required this.percent,
    required this.isPositive,
    required this.logo,
  });

  // ============================================================
  // GET STOCK SYMBOL
  // ============================================================

  String _getSymbol() {
    switch (logo.toLowerCase()) {
      case "spotify":
        return "SPOT";

      case "meta":
        return "META";

      case "tesla":
        return "TSLA";

      case "google":
        return "GOOG";

      case "netflix":
        return "NFLX";

      case "mcdonalds":
        return "MCD";

      case "amazon":
        return "AMZN";

      case "cocacola":
        return "KO";

      case "nike":
        return "NKE";

      case "starbucks":
        return "SBUX";

      case "airbnb":
        return "ABNB";

      default:
        return "SPOT";
    }
  }

  // ============================================================
  // GET MARKET PRICE
  // ============================================================

  String _getMarketPrice(String symbol) {
    switch (symbol) {
      case "SPOT":
        return "\$71.05";

      case "META":
        return "\$90.79";

      case "TSLA":
        return "\$207.47";

      case "GOOG":
        return "\$86.70";

      case "NFLX":
        return "\$260.45";

      case "MCD":
        return "\$285.12";

      case "AMZN":
        return "\$178.35";

      case "KO":
        return "\$62.48";

      case "NKE":
        return "\$72.36";

      case "SBUX":
        return "\$95.42";

      case "ABNB":
        return "\$132.64";

      default:
        return "\$71.05";
    }
  }

  // ============================================================
  // GET AVERAGE COST
  // ============================================================

  String _getAverageCost(String symbol) {
    switch (symbol) {
      case "SPOT":
        return "\$73.86";

      case "META":
        return "\$86.42";

      case "TSLA":
        return "\$201.15";

      case "GOOG":
        return "\$82.45";

      case "NFLX":
        return "\$255.72";

      case "MCD":
        return "\$287.35";

      case "AMZN":
        return "\$174.82";

      case "KO":
        return "\$60.92";

      case "NKE":
        return "\$75.18";

      case "SBUX":
        return "\$88.42";

      case "ABNB":
        return "\$138.25";

      default:
        return "\$73.86";
    }
  }

  // ============================================================
  // GET TOTAL RETURNS
  // ============================================================

  String _getTotalReturns(String symbol) {
    switch (symbol) {
      case "SPOT":
        return "\$1,946.75";

      case "META":
        return "\$1,428.32";

      case "TSLA":
        return "\$1,285.64";

      case "GOOG":
        return "\$1,735.42";

      case "NFLX":
        return "\$985.30";

      case "MCD":
        return "\$428.75";

      case "AMZN":
        return "\$1,125.42";

      case "KO":
        return "\$382.64";

      case "NKE":
        return "-\$528.35";

      case "SBUX":
        return "\$1,248.76";

      case "ABNB":
        return "-\$428.42";

      default:
        return "\$1,946.75";
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final Color chartColor = isPositive
        ? const Color(0xff18C48F)
        : const Color(0xffF44336);

    // Get symbol from logo
    final String symbol = _getSymbol();

    // Get actual stock market price
    final String marketPrice = _getMarketPrice(symbol);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),

        // ==========================================================
        // TAP STOCK
        // ==========================================================

        onTap: () {
          Get.to(
                () => StockDetailsScreen(
              company: company,
              symbol: symbol,
              price: marketPrice,
              percent: percent,
              shares: shares,
              avgCost: _getAverageCost(symbol),
              equity: value,
              totalReturns: _getTotalReturns(symbol),
              isPositive: isPositive,
            ),
          );
        },

        // ==========================================================
        // POSITION CONTENT
        // ==========================================================

        child: SizedBox(
          height: 84,
          child: Row(
            children: [
              // ======================================================
              // COMPANY LOGO
              // ======================================================

              _CompanyLogo(
                type: logo,
              ),

              const SizedBox(width: 18),

              // ======================================================
              // COMPANY + SHARES
              // ======================================================

              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      company,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      shares,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // ======================================================
              // MINI CHART
              // ======================================================

              SizedBox(
                width: 72,
                height: 38,
                child: CustomPaint(
                  painter: _PositionSparklinePainter(
                    color: chartColor,
                    positive: isPositive,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // ======================================================
              // VALUE + PERCENT
              // ======================================================

              SizedBox(
                width: 100,
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  crossAxisAlignment:
                  CrossAxisAlignment.end,
                  children: [
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      percent,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: chartColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ========================================================================
// COMPANY LOGO
// ========================================================================

class _CompanyLogo extends StatelessWidget {
  final String type;

  const _CompanyLogo({
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case "spotify":
        return Container(
          width: 58,
          height: 58,
          decoration: const BoxDecoration(
            color: Color(0xff1ED760),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.music_note_rounded,
            color: Colors.white,
            size: 32,
          ),
        );

      case "meta":
        return Container(
          width: 58,
          height: 58,
          decoration: const BoxDecoration(
            color: Color(0xff087FF5),
            shape: BoxShape.circle,
          ),
          child: const Text(
            "∞",
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w600,
            ),
          ),
        );

      case "tesla":
        return Container(
          width: 58,
          height: 58,
          decoration: const BoxDecoration(
            color: Color(0xffD90000),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              "T",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );

      case "google":
        return Container(
          width: 58,
          height: 58,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              "G",
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w600,
                color: Color(0xff4285F4),
              ),
            ),
          ),
        );

      case "netflix":
        return Container(
          width: 58,
          height: 58,
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              "N",
              style: TextStyle(
                color: Color(0xffE50914),
                fontSize: 35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );

      case "mcdonalds":
        return Container(
          width: 58,
          height: 58,
          decoration: const BoxDecoration(
            color: Color(0xffff0000),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              "M",
              style: TextStyle(
                color: Color(0xffffcc00),
                fontSize: 32,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        );

      case "amazon":
        return Container(
          width: 58,
          height: 58,
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              "a",
              style: TextStyle(
                color: Colors.white,
                fontSize: 38,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );

      case "cocacola":
        return Container(
          width: 58,
          height: 58,
          decoration: const BoxDecoration(
            color: Color(0xffE31B23),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              "Coca-Cola",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        );

      case "nike":
        return Container(
          width: 58,
          height: 58,
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
        );

      case "starbucks":
        return Container(
          width: 58,
          height: 58,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.coffee_rounded,
              color: Color(0xff08783E),
              size: 35,
            ),
          ),
        );

      case "airbnb":
        return Container(
          width: 58,
          height: 58,
          decoration: const BoxDecoration(
            color: Color(0xffff5a5f),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              "A",
              style: TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );

      default:
        return Container(
          width: 58,
          height: 58,
          decoration: const BoxDecoration(
            color: Color(0xff18C48F),
            shape: BoxShape.circle,
          ),
        );
    }
  }
}

// ========================================================================
// POSITION SPARKLINE
// ========================================================================

class _PositionSparklinePainter extends CustomPainter {
  final Color color;
  final bool positive;

  const _PositionSparklinePainter({
    required this.color,
    required this.positive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) {
      return;
    }

    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.35
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    if (positive) {
      path.moveTo(0, size.height * .55);
      path.lineTo(size.width * .08, size.height * .43);
      path.lineTo(size.width * .15, size.height * .60);
      path.lineTo(size.width * .22, size.height * .38);
      path.lineTo(size.width * .30, size.height * .52);
      path.lineTo(size.width * .38, size.height * .45);
      path.lineTo(size.width * .46, size.height * .65);
      path.lineTo(size.width * .54, size.height * .35);
      path.lineTo(size.width * .62, size.height * .55);
      path.lineTo(size.width * .70, size.height * .42);
      path.lineTo(size.width * .78, size.height * .62);
      path.lineTo(size.width * .86, size.height * .30);
      path.lineTo(size.width, size.height * .42);
    } else {
      path.moveTo(0, size.height * .30);
      path.lineTo(size.width * .08, size.height * .48);
      path.lineTo(size.width * .16, size.height * .38);
      path.lineTo(size.width * .24, size.height * .62);
      path.lineTo(size.width * .32, size.height * .45);
      path.lineTo(size.width * .40, size.height * .68);
      path.lineTo(size.width * .48, size.height * .40);
      path.lineTo(size.width * .56, size.height * .55);
      path.lineTo(size.width * .64, size.height * .43);
      path.lineTo(size.width * .72, size.height * .70);
      path.lineTo(size.width * .80, size.height * .48);
      path.lineTo(size.width * .90, size.height * .65);
      path.lineTo(size.width, size.height * .52);
    }

    canvas.drawPath(
      path,
      paint,
    );

    // ================================================================
    // CHART GRADIENT
    // ================================================================

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(0.13),
          color.withOpacity(0.0),
        ],
      ).createShader(
        Rect.fromLTWH(
          0,
          0,
          size.width,
          size.height,
        ),
      );

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      fillPath,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(
      covariant _PositionSparklinePainter oldDelegate,
      ) {
    return oldDelegate.color != color ||
        oldDelegate.positive != positive;
  }
}