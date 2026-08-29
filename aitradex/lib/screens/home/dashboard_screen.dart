import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'widgets/balance_header.dart';
import 'widgets/market_card.dart';
import 'widgets/stock_title.dart';
import 'widgets/wishlist_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
        extendBodyBehindAppBar: true,

        body: Column(
          children: [
            // ============================================================
            // FIXED HEADER
            // ============================================================

            const BalanceHeader(),

            // ============================================================
            // SCROLLABLE CONTENT
            // ============================================================

            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ========================================================
                  // MARKET CARDS
                  // ========================================================

                  SliverToBoxAdapter(
                    child: Transform.translate(
                      offset: const Offset(0, -18),
                      child: SizedBox(
                        height: 140,
                        child: ListView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                          ),
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          children: const [
                            MarketCard(
                              title: "DOW",
                              percentage: "+3.57%",
                              isPositive: true,
                            ),

                            SizedBox(width: 12),

                            MarketCard(
                              title: "S&P 500",
                              percentage: "-1.96%",
                              isPositive: false,
                            ),

                            SizedBox(width: 12),

                            MarketCard(
                              title: "NASDAQ",
                              percentage: "+2.85%",
                              isPositive: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ========================================================
                  // MY WISHLIST TITLE
                  // ========================================================

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        24,
                        0,
                        20,
                        12,
                      ),
                      child: Row(
                        children: [
                          const Text(
                            "My Wishlist",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),

                          const Spacer(),

                          const Icon(
                            Icons.arrow_forward,
                            size: 22,
                            color: Color(0xff18C48F),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ========================================================
                  // WISHLIST
                  // ========================================================

                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 145,
                      child: ListView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                        ),
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        children: const [
                          WishlistCard(
                            symbol: "TWTR",
                            percent: "-1.98%",
                            isPositive: false,
                            icon: Icons.flutter_dash,
                          ),

                          SizedBox(width: 14),

                          WishlistCard(
                            symbol: "AAPL",
                            percent: "+2.45%",
                            isPositive: true,
                            icon: Icons.apple,
                          ),

                          SizedBox(width: 14),

                          WishlistCard(
                            symbol: "TSLA",
                            percent: "+3.14%",
                            isPositive: true,
                            icon: Icons.electric_car,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ========================================================
                  // MY STOCKS TITLE
                  // ========================================================

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        24,
                        18,
                        20,
                        8,
                      ),
                      child: Row(
                        children: [
                          const Text(
                            "My Stocks",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),

                          const Spacer(),

                          const Icon(
                            Icons.arrow_forward,
                            size: 22,
                            color: Color(0xff18C48F),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ========================================================
                  // STOCK LIST
                  // ========================================================

                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          const StockTile(
                            company: "Spotify",
                            symbol: "SPOT",
                            price: "\$71.05",
                            percent: "+2.94%",
                            isPositive: true,
                            icon: Icons.music_note,
                          ),

                          const StockTile(
                            company: "Meta - Fac...",
                            symbol: "META",
                            price: "\$90.79",
                            percent: "-2.16%",
                            isPositive: false,
                            icon: Icons.facebook,
                          ),

                          const StockTile(
                            company: "Tesla",
                            symbol: "TSLA",
                            price: "\$207.47",
                            percent: "+2.37%",
                            isPositive: true,
                            icon: Icons.electric_car,
                          ),

                          const StockTile(
                            company: "Google",
                            symbol: "GOOG",
                            price: "\$186.70",
                            percent: "+3.85%",
                            isPositive: true,
                            icon: Icons.g_mobiledata,
                          ),

                          const StockTile(
                            company: "Netflix",
                            symbol: "NFLX",
                            price: "\$260.45",
                            percent: "+1.94%",
                            isPositive: true,
                            icon: Icons.movie,
                          ),

                          const SizedBox(height: 90),
                        ],
                      ),
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