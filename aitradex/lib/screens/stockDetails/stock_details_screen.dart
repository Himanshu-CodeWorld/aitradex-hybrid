import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

class StockDetailsScreen extends StatelessWidget {
  final String company;
  final String symbol;
  final String price;
  final String percent;
  final String shares;
  final String avgCost;
  final String equity;
  final String totalReturns;
  final bool isPositive;

  const StockDetailsScreen({
    super.key,
    required this.company,
    required this.symbol,
    required this.price,
    required this.percent,
    required this.shares,
    required this.avgCost,
    required this.equity,
    required this.totalReturns,
    required this.isPositive,
  });

  void _showShareSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (context) {
        return _ShareBottomSheet(
          company: company,
          symbol: symbol,
          price: price,
          percent: percent,
          equity: equity,
        );
      },
    );
  }

  static const Color primary = Color(0xff18C48F);

  @override
  Widget build(BuildContext context) {
    final Color changeColor =
    isPositive ? primary : const Color(0xffF44336);

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

        // ============================================================
        // BODY
        // ============================================================

        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ==========================================================
            // STOCK HEADER
            // ==========================================================

            SliverToBoxAdapter(
              child: _StockChartHeader(
                company: company,
                symbol: symbol,
                price: price,
                isPositive: isPositive,
                onShare: () => _showShareSheet(context),
              ),
            ),

            // ==========================================================
            // PRICE CARD
            // ==========================================================

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  24,
                  27,
                  24,
                  0,
                ),
                child: _PriceCard(
                  price: price,
                  percent: percent,
                  isPositive: isPositive,
                ),
              ),
            ),

            // ==========================================================
            // MY POSITION TITLE
            // ==========================================================

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  24,
                  30,
                  24,
                  18,
                ),
                child: Text(
                  "My $symbol Position",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            // ==========================================================
            // POSITION ROW 1
            // ==========================================================

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _PositionItem(
                        icon: Icons.grid_view_rounded,
                        iconColor: const Color(0xff3978F6),
                        iconBackground:
                        const Color(0xffEEF4FF),
                        title: "Shares",
                        value: shares,
                      ),
                    ),
                    Expanded(
                      child: _PositionItem(
                        icon:
                        Icons.account_balance_wallet_outlined,
                        iconColor: const Color(0xffff9d20),
                        iconBackground:
                        const Color(0xfffff3e4),
                        title: "Avg. Cost",
                        value: avgCost,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),

            // ==========================================================
            // POSITION ROW 2
            // ==========================================================

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _PositionItem(
                        icon: Icons.pie_chart_rounded,
                        iconColor: const Color(0xffff6878),
                        iconBackground:
                        const Color(0xfffff0f2),
                        title: "Equity",
                        value: equity,
                      ),
                    ),
                    Expanded(
                      child: _PositionItem(
                        icon: Icons.trending_up_rounded,
                        iconColor: const Color(0xff7357F6),
                        iconBackground:
                        const Color(0xfff0eeff),
                        title: "Total Returns",
                        value: totalReturns,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ==========================================================
            // MARKET STATS
            // ==========================================================

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  30,
                  42,
                  30,
                  18,
                ),
                child: Text(
                  "$symbol Market Stats",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: _MarketStatRow(
                icon: Icons.business_center_outlined,
                title: "Market Cap",
                value: "\$12.75B",
              ),
            ),

            const SliverToBoxAdapter(
              child: _MarketStatRow(
                icon: Icons.credit_card_outlined,
                title: "Price-Earning Ratio",
                value: "N/A",
              ),
            ),

            const SliverToBoxAdapter(
              child: _MarketStatRow(
                icon: Icons.percent_rounded,
                title: "Dividend Yield",
                value: "N/A",
              ),
            ),

            // ==========================================================
            // MORE CONTENT
            // ==========================================================

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  24,
                  32,
                  24,
                  125,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ============================================================
                    // WHAT THE EXPERTS SAY
                    // ============================================================

                    Text(
                      "What the Experts Say",
                      style: GoogleFonts.poppins(
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 30),

                    _ExpertBar(
                      title: "Buy",
                      value: "70%",
                      progress: 0.70,
                      color: const Color(0xff18C48F),
                    ),

                    const SizedBox(height: 20),

                    _ExpertBar(
                      title: "Hold",
                      value: "25%",
                      progress: 0.25,
                      color: const Color(0xffffa000),
                    ),

                    const SizedBox(height: 20),

                    _ExpertBar(
                      title: "Sell",
                      value: "5%",
                      progress: 0.05,
                      color: const Color(0xfff45b63),
                    ),

                    // ============================================================
                    // RISK
                    // ============================================================

                    const SizedBox(height: 60),

                    Text(
                      "Risk",
                      style: GoogleFonts.poppins(
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 25),

                    Text(
                      "$symbol has 27% more risk than the market as a whole.",
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        height: 1.55,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    // ============================================================
                    // NEWS
                    // ============================================================

                    const SizedBox(height: 60),

                    Text(
                      "News",
                      style: GoogleFonts.poppins(
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 35),

                    const _NewsItem(
                      source: "Forbes",
                      title:
                      "NASDAQ Roundup: Latest earnings and market updates.",
                      time: "1 day ago",
                    ),

                    const _NewsItem(
                      source: "Seeking Alpha",
                      title:
                      "Latest analysis and market outlook.",
                      time: "2 days ago",
                    ),

                    const _NewsItem(
                      source: "The Motley Fool",
                      title:
                      "What investors should know about this stock.",
                      time: "2 days ago",
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // ============================================================
        // FIXED BUY / SELL
        // ============================================================

        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            height: 117,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(
              24,
              24,
              24,
              20,
            ),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 58,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor:
                        const Color(0xffE4F8F3),
                        foregroundColor:
                        const Color(0xff18C48F),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(32),
                        ),
                      ),
                      child: Text(
                        "Sell",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: SizedBox(
                    height: 58,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        elevation: 5,
                        shadowColor:
                        const Color(0xff18C48F)
                            .withOpacity(.35),
                        backgroundColor:
                        const Color(0xff18C48F),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(32),
                        ),
                      ),
                      child: Text(
                        "Buy",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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

class _StockChartHeader extends StatelessWidget {
  final String company;
  final String symbol;
  final String price;
  final bool isPositive;
  final VoidCallback onShare;

  const _StockChartHeader({
    required this.company,
    required this.symbol,
    required this.price,
    required this.isPositive,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final Color chartColor = isPositive
        ? const Color(0xff18E98A)
        : const Color(0xffff4d5f);

    final double statusBarHeight =
        MediaQuery.of(context).padding.top;

    return Container(
      height: 550,
      width: double.infinity,
      color: Colors.black,
      child: Stack(
        children: [
          // ============================================================
          // BACKGROUND GEOMETRIC SHAPES
          // ============================================================

          Positioned(
            top: -20,
            left: 65,
            child: _CubeShape(
              size: 175,
            ),
          ),

          Positioned(
            top: 110,
            right: -40,
            child: _CubeShape(
              size: 160,
            ),
          ),

          Positioned(
            top: 165,
            left: -70,
            child: _CubeShape(
              size: 190,
            ),
          ),

          Positioned(
            bottom: -40,
            left: 185,
            child: _CubeShape(
              size: 150,
            ),
          ),

          // ============================================================
          // STOCK CHART
          // ============================================================

          Positioned(
            left: 0,
            right: 0,
            top: 210,
            bottom: 60,
            child: CustomPaint(
              painter: _StockChartPainter(
                color: chartColor,
              ),
            ),
          ),

          // ============================================================
          // BACK BUTTON
          // ============================================================

          Positioned(
            top: statusBarHeight + 24,
            left: 24,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 23,
              ),
            ),
          ),

          // ============================================================
          // SHARE
          // ============================================================

          Positioned(
            top: statusBarHeight + 24,
            right: 70,
            child: GestureDetector(
              onTap: () => onShare,
              child: const Icon(
                Icons.send_outlined,
                color: Colors.white,
                size: 25,
              ),
            ),
          ),

          // ============================================================
          // FAVORITE
          // ============================================================

          Positioned(
            top: statusBarHeight + 24,
            right: 25,
            child: const Icon(
              Icons.favorite_border_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),

          // ============================================================
          // COMPANY LOGO
          // ============================================================

          Positioned(
            top: statusBarHeight + 100,
            left: 24,
            child: Container(
              width: 62,
              height: 62,
              decoration: const BoxDecoration(
                color: Color(0xff1ED760),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.music_note_rounded,
                color: Colors.black,
                size: 43,
              ),
            ),
          ),

          // ============================================================
          // COMPANY NAME
          // ============================================================

          Positioned(
            top: statusBarHeight + 115,
            left: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  company,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  symbol,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // ============================================================
          // LAST CLOSE
          // ============================================================

          Positioned(
            top: statusBarHeight + 110,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "Last close",
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  price,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // ============================================================
          // HIGH PRICE
          // ============================================================

          Positioned(
            top: 190,
            right: 30,
            child: Text(
              "\$76.46",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // ============================================================
          // LOW PRICE
          // ============================================================

          Positioned(
            left: 40,
            bottom: 83,
            child: Text(
              "\$62.94",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // ============================================================
          // TIME PERIODS
          // ============================================================

          Positioned(
            left: 24,
            right: 24,
            bottom: 18,
            child: Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                const _PeriodButton(
                  text: "1D",
                  selected: true,
                ),
                const _PeriodButton(
                  text: "1W",
                ),
                const _PeriodButton(
                  text: "1M",
                ),
                const _PeriodButton(
                  text: "3M",
                ),
                const _PeriodButton(
                  text: "1Y",
                ),
                const _PeriodButton(
                  text: "5Y",
                ),
                const Icon(
                  Icons.tune_rounded,
                  color: Color(0xff18E98A),
                  size: 21,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CubeShape extends StatelessWidget {
  final double size;

  const _CubeShape({
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.16,
      child: Transform.rotate(
        angle: 0.0,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: const Color(0xff18201f),
            borderRadius: BorderRadius.circular(2),
            border: Border.all(
              color: const Color(0xff242b2a),
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _StockChartPainter extends CustomPainter {
  final Color color;

  const _StockChartPainter({
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Path path = Path();

    final List<Offset> points = [
      Offset(0, size.height * .62),
      Offset(size.width * .04, size.height * .74),
      Offset(size.width * .08, size.height * .53),
      Offset(size.width * .12, size.height * .69),
      Offset(size.width * .16, size.height * .43),
      Offset(size.width * .20, size.height * .61),
      Offset(size.width * .24, size.height * .47),
      Offset(size.width * .28, size.height * .67),
      Offset(size.width * .32, size.height * .42),
      Offset(size.width * .36, size.height * .55),
      Offset(size.width * .40, size.height * .37),
      Offset(size.width * .44, size.height * .61),
      Offset(size.width * .48, size.height * .30),
      Offset(size.width * .52, size.height * .48),
      Offset(size.width * .56, size.height * .35),
      Offset(size.width * .60, size.height * .54),
      Offset(size.width * .64, size.height * .29),
      Offset(size.width * .68, size.height * .46),
      Offset(size.width * .72, size.height * .25),
      Offset(size.width * .76, size.height * .42),
      Offset(size.width * .80, size.height * .22),
      Offset(size.width * .84, size.height * .39),
      Offset(size.width * .88, size.height * .20),
      Offset(size.width * .92, size.height * .35),
      Offset(size.width * .96, size.height * .24),
      Offset(size.width, size.height * .30),
    ];

    path.moveTo(
      points.first.dx,
      points.first.dy,
    );

    for (int i = 1; i < points.length; i++) {
      path.lineTo(
        points[i].dx,
        points[i].dy,
      );
    }

    canvas.drawPath(path, paint);

    // ================================================================
    // LOW POINT
    // ================================================================

    final Offset lowPoint = Offset(
      size.width * .15,
      size.height * .69,
    );

    final Paint pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      lowPoint,
      5,
      pointPaint,
    );

    final Paint pointBorder = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(
      lowPoint,
      5,
      pointBorder,
    );

    // ================================================================
    // HIGH POINT
    // ================================================================

    final Offset highPoint = Offset(
      size.width * .88,
      size.height * .20,
    );

    canvas.drawCircle(
      highPoint,
      5,
      pointPaint,
    );

    canvas.drawCircle(
      highPoint,
      5,
      pointBorder,
    );
  }

  @override
  bool shouldRepaint(
      covariant _StockChartPainter oldDelegate,
      ) {
    return oldDelegate.color != color;
  }
}

class _PriceCard extends StatelessWidget {
  final String price;
  final String percent;
  final bool isPositive;

  const _PriceCard({
    required this.price,
    required this.percent,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = isPositive
        ? const Color(0xff18C48F)
        : const Color(0xffF44336);

    return Container(
      height: 116,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xffeeeeee),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            price,
            style: GoogleFonts.poppins(
              fontSize: 36,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 2),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius:
                  BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.arrow_upward,
                  color: Colors.white,
                  size: 10,
                ),
              ),

              const SizedBox(width: 5),

              Text(
                "\$2.17",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: color,
                ),
              ),

              const SizedBox(width: 7),

              Text(
                percent,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: color,
                ),
              ),

              const SizedBox(width: 7),

              Text(
                "Last close",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PositionItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String value;

  const _PositionItem({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            color: iconBackground,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 29,
          ),
        ),

        const SizedBox(width: 15),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MarketStatRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _MarketStatRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 30,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 18,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xffeeeeee),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              color: Color(0xffEAFBF5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Color(0xff18C48F),
              size: 26,
            ),
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodButton extends StatelessWidget {
  final String text;
  final bool selected;

  const _PeriodButton({
    required this.text,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 32,
      alignment: Alignment.center,
      decoration: selected
          ? BoxDecoration(
        color: const Color(0xff18E98A),
        borderRadius: BorderRadius.circular(7),
      )
          : null,
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: selected
              ? Colors.black
              : const Color(0xff18E98A),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ExpertBar extends StatelessWidget {
  final String title;
  final String value;
  final double progress;
  final Color color;

  const _ExpertBar({
    required this.title,
    required this.value,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 14,
                decoration: BoxDecoration(
                  color: const Color(0xffeeeeee),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 14,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 18),

        SizedBox(
          width: 45,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),

        const SizedBox(width: 10),

        SizedBox(
          width: 40,
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _NewsItem extends StatelessWidget {
  final String source;
  final String title;
  final String time;

  const _NewsItem({
    required this.source,
    required this.title,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 0,
        bottom: 24,
      ),
      margin: const EdgeInsets.only(
        bottom: 24,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xffeeeeee),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  source,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Text(
                time,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 17,
              height: 1.45,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareBottomSheet extends StatelessWidget {
  final String company;
  final String symbol;
  final String price;
  final String percent;
  final String equity;

  const _ShareBottomSheet({
    required this.company,
    required this.symbol,
    required this.price,
    required this.percent,
    required this.equity,
  });

  Future<void> _share(BuildContext context) async {
    Navigator.pop(context);

    await SharePlus.instance.share(
      ShareParams(
        title: '$company ($symbol)',
        subject: '$company Stock',
        text:
        '$company ($symbol)\n'
            'Price: $price\n'
            'Change: $percent\n'
            'Equity: $equity\n\n'
            'Powered by AiTradeX',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 380,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            24,
            8,
            24,
            20,
          ),
          child: Column(
            children: [
              // ========================================================
              // HANDLE
              // ========================================================

              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(
                  bottom: 25,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // ========================================================
              // TITLE
              // ========================================================

              Text(
                "Share",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 25),

              Divider(
                color: Colors.grey.shade200,
                height: 1,
              ),

              const SizedBox(height: 24),

              // ========================================================
              // SHARE APPS ROW 1
              // ========================================================

              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceAround,
                children: [
                  _ShareApp(
                    icon: Icons.phone,
                    color: const Color(0xff25D366),
                    label: "WhatsApp",
                    onTap: () => _share(context),
                  ),

                  _ShareApp(
                    icon: Icons.flutter_dash,
                    color: const Color(0xff1DA1F2),
                    label: "Twitter",
                    onTap: () => _share(context),
                  ),

                  _ShareApp(
                    icon: Icons.facebook,
                    color: const Color(0xff1877F2),
                    label: "Facebook",
                    onTap: () => _share(context),
                  ),

                  _ShareApp(
                    icon: Icons.camera_alt_rounded,
                    color: const Color(0xffE4405F),
                    label: "Instagram",
                    onTap: () => _share(context),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // ========================================================
              // SHARE APPS ROW 2
              // ========================================================

              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceAround,
                children: [
                  _ShareApp(
                    icon: Icons.email_rounded,
                    color: const Color(0xff673DE6),
                    label: "Yahoo",
                    onTap: () => _share(context),
                  ),

                  _ShareApp(
                    icon: Icons.music_note_rounded,
                    color: Colors.black,
                    label: "Tiktok",
                    onTap: () => _share(context),
                  ),

                  _ShareApp(
                    icon: Icons.message_rounded,
                    color: const Color(0xff1677FF),
                    label: "Chat",
                    onTap: () => _share(context),
                  ),

                  _ShareApp(
                    icon: Icons.chat_rounded,
                    color: const Color(0xff07C160),
                    label: "WeChat",
                    onTap: () => _share(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShareApp extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _ShareApp({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: color,
                borderRadius:
                BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 34,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}