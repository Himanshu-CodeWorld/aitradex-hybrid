import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  static const Color primaryColor = Color(0xff18C48F);

  static const List<WishlistStock> stocks = [
    WishlistStock(
      company: "Twitter",
      symbol: "TWTR",
      price: "\$124.68",
      percent: "-1.98%",
      isPositive: false,
      logoText: "♥",
      logoColor: Color(0xff2196F3),
    ),
    WishlistStock(
      company: "Apple",
      symbol: "AAPL",
      price: "\$138.73",
      percent: "+2.45%",
      isPositive: true,
      logoText: "●",
      logoColor: Colors.black,
    ),
    WishlistStock(
      company: "Tesla",
      symbol: "TSLA",
      price: "\$207.47",
      percent: "+2.37%",
      isPositive: true,
      logoText: "T",
      logoColor: Color(0xffD50000),
    ),
    WishlistStock(
      company: "Burger King",
      symbol: "QSR",
      price: "\$97.49",
      percent: "-2.04%",
      isPositive: false,
      logoText: "BK",
      logoColor: Color(0xffFF9800),
    ),
    WishlistStock(
      company: "Linkedin",
      symbol: "LNKD",
      price: "\$84.32",
      percent: "+6.43%",
      isPositive: true,
      logoText: "in",
      logoColor: Color(0xff1683B8),
    ),
    WishlistStock(
      company: "Mozilla",
      symbol: "MZLA",
      price: "\$87.63",
      percent: "-3.44%",
      isPositive: false,
      logoText: "M",
      logoColor: Color(0xffff7043),
    ),
    WishlistStock(
      company: "Pinterest",
      symbol: "PINS",
      price: "\$90.35",
      percent: "+1.77%",
      isPositive: true,
      logoText: "P",
      logoColor: Color(0xffE60023),
    ),
    WishlistStock(
      company: "Slack",
      symbol: "WORK",
      price: "\$86.46",
      percent: "+0.32%",
      isPositive: true,
      logoText: "#",
      logoColor: Color(0xff611F69),
    ),
    WishlistStock(
      company: "HP",
      symbol: "HPQ",
      price: "\$92.49",
      percent: "+2.65%",
      isPositive: true,
      logoText: "hp",
      logoColor: Color(0xff0096D6),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,

        body: SafeArea(
          child: Column(
            children: [
              // ==========================================================
              // HEADER
              // ==========================================================

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  10,
                  18,
                  0,
                ),
                child: Row(
                  children: [
                    // Back
                    IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 42,
                        minHeight: 42,
                      ),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 23,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Title
                    Text(
                      "My Wishlist",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        letterSpacing: -0.4,
                      ),
                    ),

                    const Spacer(),

                    // Search
                    IconButton(
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 42,
                        minHeight: 42,
                      ),
                      icon: const Icon(
                        Icons.search_rounded,
                        size: 30,
                        color: Colors.black,
                      ),
                    ),

                    // Add
                    IconButton(
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 42,
                        minHeight: 42,
                      ),
                      icon: const Icon(
                        Icons.add_rounded,
                        size: 32,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              // ==========================================================
              // COUNT + SORT
              // ==========================================================

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  24,
                  22,
                  24,
                  10,
                ),
                child: Row(
                  children: [
                    Text(
                      "24 Companies",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
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
                        color: primaryColor,
                      ),
                    ),

                    const SizedBox(width: 8),

                    const Icon(
                      Icons.swap_vert_rounded,
                      size: 21,
                      color: primaryColor,
                    ),
                  ],
                ),
              ),

              // ==========================================================
              // STOCK LIST
              // ==========================================================

              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    24,
                    4,
                    24,
                    30,
                  ),
                  itemCount: stocks.length,
                  itemBuilder: (context, index) {
                    return WishlistStockTile(
                      stock: stocks[index],
                    );
                  },
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
// MODEL
// ========================================================================

class WishlistStock {
  final String company;
  final String symbol;
  final String price;
  final String percent;
  final bool isPositive;
  final String logoText;
  final Color logoColor;

  const WishlistStock({
    required this.company,
    required this.symbol,
    required this.price,
    required this.percent,
    required this.isPositive,
    required this.logoText,
    required this.logoColor,
  });
}

// ========================================================================
// STOCK TILE
// ========================================================================

class WishlistStockTile extends StatelessWidget {
  final WishlistStock stock;

  const WishlistStockTile({
    super.key,
    required this.stock,
  });

  @override
  Widget build(BuildContext context) {
    final Color chartColor = stock.isPositive
        ? const Color(0xff18C48F)
        : const Color(0xffF44336);

    return SizedBox(
      height: 84,
      child: Row(
        children: [
          // ==============================================================
          // LOGO
          // ==============================================================

          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: stock.logoColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              stock.logoText,
              style: TextStyle(
                color: Colors.white,
                fontSize: stock.logoText == "hp"
                    ? 20
                    : 25,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          const SizedBox(width: 18),

          // ==============================================================
          // COMPANY
          // ==============================================================

          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stock.company,
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
                  stock.symbol,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // ==============================================================
          // MINI CHART
          // ==============================================================

          SizedBox(
            width: 72,
            height: 38,
            child: CustomPaint(
              painter: _WishlistSparklinePainter(
                color: chartColor,
                positive: stock.isPositive,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // ==============================================================
          // PRICE + PERCENT
          // ==============================================================

          SizedBox(
            width: 72,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  stock.price,
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
                  stock.percent,
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
    );
  }
}

// ========================================================================
// SPARKLINE
// ========================================================================

class _WishlistSparklinePainter extends CustomPainter {
  final Color color;
  final bool positive;

  const _WishlistSparklinePainter({
    required this.color,
    required this.positive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) {
      return;
    }

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 1.35
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    if (positive) {
      path.moveTo(0, size.height * .52);
      path.lineTo(size.width * .06, size.height * .42);
      path.lineTo(size.width * .12, size.height * .58);
      path.lineTo(size.width * .18, size.height * .35);
      path.lineTo(size.width * .24, size.height * .50);
      path.lineTo(size.width * .30, size.height * .45);
      path.lineTo(size.width * .36, size.height * .64);
      path.lineTo(size.width * .42, size.height * .34);
      path.lineTo(size.width * .48, size.height * .55);
      path.lineTo(size.width * .54, size.height * .40);
      path.lineTo(size.width * .60, size.height * .68);
      path.lineTo(size.width * .66, size.height * .46);
      path.lineTo(size.width * .72, size.height * .55);
      path.lineTo(size.width * .78, size.height * .30);
      path.lineTo(size.width * .84, size.height * .48);
      path.lineTo(size.width * .90, size.height * .26);
      path.lineTo(size.width, size.height * .40);
    } else {
      path.moveTo(0, size.height * .30);
      path.lineTo(size.width * .06, size.height * .46);
      path.lineTo(size.width * .12, size.height * .36);
      path.lineTo(size.width * .18, size.height * .62);
      path.lineTo(size.width * .24, size.height * .44);
      path.lineTo(size.width * .30, size.height * .70);
      path.lineTo(size.width * .36, size.height * .38);
      path.lineTo(size.width * .42, size.height * .55);
      path.lineTo(size.width * .48, size.height * .42);
      path.lineTo(size.width * .54, size.height * .72);
      path.lineTo(size.width * .60, size.height * .48);
      path.lineTo(size.width * .66, size.height * .62);
      path.lineTo(size.width * .72, size.height * .40);
      path.lineTo(size.width * .78, size.height * .68);
      path.lineTo(size.width * .84, size.height * .50);
      path.lineTo(size.width * .90, size.height * .72);
      path.lineTo(size.width, size.height * .55);
    }

    canvas.drawPath(path, linePaint);

    // Chart fill
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(0.12),
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
      covariant _WishlistSparklinePainter oldDelegate,
      ) {
    return oldDelegate.color != color ||
        oldDelegate.positive != positive;
  }
}