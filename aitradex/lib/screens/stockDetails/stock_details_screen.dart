// cspell:ignore BANKNIFTY NIFTYIT HDFCBANK ICICIBANK BHARTIARTL NIFTYBEES

import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:aitradex/services/market_data_service.dart';
import '../wishlist/wishlist_store.dart';
import 'stock_ai_report_question.dart';

/// AiTradeX premium stock / asset details screen.
///
/// This screen intentionally keeps the same constructor used by the
/// Invest / Markets / Portfolio screens, so it can be dropped in directly:
///
/// StockDetailsScreen(
///   company: asset.name,
///   symbol: asset.symbol,
///   price: asset.price,
///   percent: asset.change,
///   shares: '0 shares',
///   avgCost: '₹0.00',
///   equity: '₹0.00',
///   totalReturns: '₹0.00',
///   isPositive: asset.positive,
/// )
///
/// The values supplied to this screen are presentation data. Connect the
/// chart, market statistics, news and order sheet to your live broker/API
/// layer when that backend is ready.
class StockDetailsScreen extends StatefulWidget {
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

  @override
  State<StockDetailsScreen> createState() => _StockDetailsScreenState();
}

class _StockDetailsScreenState extends State<StockDetailsScreen> {
  int _selectedPeriod = 0;
  bool _isFavorite = false;
  bool _isRefreshing = false;
  late String _livePrice;
  late String _livePercent;
  late bool _livePositive;

  static const List<String> _periods = <String>[
    '1D',
    '1W',
    '1M',
    '3M',
    '1Y',
    '5Y',
  ];

  String _instrumentKeyForSymbol(String symbol) {
    const Map<String, String> keys = <String, String>{
      'NIFTY': 'NSE_INDEX|Nifty 50',
      'SENSEX': 'BSE_INDEX|SENSEX',
      'BANKNIFTY': 'NSE_INDEX|Nifty Bank',
      'NIFTYIT': 'NSE_INDEX|Nifty IT',
      'RELIANCE': 'NSE_EQ|INE002A01018',
      'HDFCBANK': 'NSE_EQ|INE040A01034',
      'TCS': 'NSE_EQ|INE467B01029',
      'INFY': 'NSE_EQ|INE009A01021',
      'ICICIBANK': 'NSE_EQ|INE090A01021',
      'BHARTIARTL': 'NSE_EQ|INE397D01024',
      'ITC': 'NSE_EQ|INE154A01025',
      'LT': 'NSE_EQ|INE018A01030',
      'NIFTYBEES': 'NSE_EQ|INF204KB14I2',
    };
    return keys[symbol.trim().toUpperCase()] ?? '';
  }

  @override
  void initState() {
    super.initState();
    _livePrice = widget.price;
    _livePercent = widget.percent;
    _livePositive = widget.isPositive;
    _loadFavorite();
  }

  Future<void> _loadFavorite() async {
    final bool value = await WishlistStore.contains(widget.symbol);
    if (mounted) {
      setState(() => _isFavorite = value);
    }
  }

  Color get _positiveColor => const Color(0xFF18C48F);
  Color get _negativeColor => const Color(0xFFF0445A);

  Future<void> _refreshStock() async {
    if (_isRefreshing) {
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isRefreshing = true);

    try {
      bool updated = false;
      final String instrumentKey = _instrumentKeyForSymbol(widget.symbol);
      if (instrumentKey.isNotEmpty) {
        final Map<String, MarketQuote> quotes =
        await MarketDataService.fetchMarketData(<String>[instrumentKey])
            .timeout(const Duration(seconds: 20));
        final MarketQuote? quote = quotes[instrumentKey];

        if (quote != null && mounted) {
          final double livePrice = quote.lastPrice.toDouble();
          final double liveChange = quote.changePercent.toDouble();
          if (livePrice > 0) {
            updated = true;
          }
          setState(() {
            _livePrice = livePrice > 0
                ? MarketDataService.formatPrice(livePrice)
                : widget.price;
            _livePercent =
                MarketDataService.formatPercent(liveChange);
            _livePositive = liveChange >= 0;
          });
        }
      }
      if (!mounted) {
        return;
      }
      if (updated) {
        Get.snackbar(
          'Market data refreshed',
          '${widget.symbol} price was updated from the market service.',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 92),
          borderRadius: 16,
          duration: const Duration(seconds: 2),
          backgroundColor: Theme.of(context).colorScheme.inverseSurface,
          colorText: Theme.of(context).colorScheme.onInverseSurface,
          icon: Icon(
            Icons.check_circle_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
        );
      } else {
        Get.snackbar(
          'Market data unavailable',
          'No live quote was returned for ${widget.symbol}. Showing the last supplied price.',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 92),
          borderRadius: 16,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      Get.snackbar(
        'Refresh failed',
        error.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 92),
        borderRadius: 16,
        duration: const Duration(seconds: 2),
      );
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    final Color background = theme.scaffoldBackgroundColor;
    final Color card = isDark
        ? Color.alphaBlend(
      colors.primary.withValues(alpha: 0.025),
      colors.surfaceContainerHighest,
    )
        : colors.surface;
    final Color text = colors.onSurface;
    final Color secondary = colors.onSurfaceVariant;
    final Color border = colors.outlineVariant.withValues(
      alpha: isDark ? 0.45 : 0.60,
    );

    final Color movementColor =
    _livePositive ? _positiveColor : _negativeColor;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
        isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: background,
        systemNavigationBarIconBrightness:
        isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: background,
        body: RefreshIndicator(
          onRefresh: _refreshStock,
          color: colors.primary,
          backgroundColor: colors.surface,
          displacement: 34,
          strokeWidth: 2.5,
          notificationPredicate: (ScrollNotification notification) {
            return notification.depth == 0;
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: _StockHero(
                  company: widget.company,
                  symbol: widget.symbol,
                  price: _livePrice,
                  percent: _livePercent,
                  isPositive: _livePositive,
                  periods: _periods,
                  selectedPeriod: _selectedPeriod,
                  isFavorite: _isFavorite,
                  onBack: () => Get.back(),
                  onFavorite: () async {
                    HapticFeedback.selectionClick();
                    final bool next = !_isFavorite;
                    setState(() => _isFavorite = next);
                    await WishlistStore.set(widget.symbol, next);
                    if (!mounted) {
                      return;
                    }
                    Get.snackbar(
                      next ? 'Added to Watchlist' : 'Removed from Watchlist',
                      next
                          ? '${widget.symbol} is now in your watchlist.'
                          : '${widget.symbol} was removed from your watchlist.',
                      snackPosition: SnackPosition.BOTTOM,
                      margin: const EdgeInsets.fromLTRB(14, 0, 14, 92),
                      borderRadius: 16,
                      duration: const Duration(seconds: 2),
                    );
                  },
                  onShare: () => _showShareSheet(context),
                  onPeriodChanged: (int index) {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedPeriod = index);
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, 10),
                  child: Column(
                    children: <Widget>[
                      _PriceSummaryCard(
                        price: _livePrice,
                        percent: _livePercent,
                        isPositive: _livePositive,
                        background: card,
                        textColor: text,
                        secondaryColor: secondary,
                        borderColor: border,
                      ),
                      const SizedBox(height: 20),
                      _AskAiTradeXCard(
                        company: widget.company,
                        symbol: widget.symbol,
                        price: _livePrice,
                        onTap: _openAiTradeXBot,
                      ),
                      const SizedBox(height: 20),
                      _SectionHeader(
                        title: 'My position',
                        subtitle: 'Your current holding',
                        textColor: text,
                        secondaryColor: secondary,
                      ),
                      const SizedBox(height: 10),
                      _PositionGrid(
                        shares: widget.shares,
                        avgCost: widget.avgCost,
                        equity: widget.equity,
                        totalReturns: widget.totalReturns,
                        background: card,
                        textColor: text,
                        secondaryColor: secondary,
                        borderColor: border,
                      ),
                      const SizedBox(height: 30),
                      _SectionHeader(
                        title: 'Market overview',
                        subtitle: 'Key metrics',
                        textColor: text,
                        secondaryColor: secondary,
                      ),
                      const SizedBox(height: 14),
                      _MarketOverviewCard(
                        background: card,
                        textColor: text,
                        secondaryColor: secondary,
                        borderColor: border,
                      ),
                      const SizedBox(height: 30),
                      _SectionHeader(
                        title: 'Analyst snapshot',
                        subtitle: 'Illustrative sentiment data',
                        textColor: text,
                        secondaryColor: secondary,
                      ),
                      const SizedBox(height: 14),
                      _AnalystSnapshotCard(
                        background: card,
                        textColor: text,
                        secondaryColor: secondary,
                        borderColor: border,
                      ),
                      const SizedBox(height: 30),
                      _SectionHeader(
                        title: 'Risk',
                        subtitle: 'Risk indicator',
                        textColor: text,
                        secondaryColor: secondary,
                      ),
                      const SizedBox(height: 14),
                      _RiskCard(
                        symbol: widget.symbol,
                        background: card,
                        textColor: text,
                        secondaryColor: secondary,
                        borderColor: border,
                        movementColor: movementColor,
                      ),
                      const SizedBox(height: 30),
                      _SectionHeader(
                        title: 'Latest news',
                        subtitle: 'Market headlines',
                        textColor: text,
                        secondaryColor: secondary,
                      ),
                      const SizedBox(height: 14),
                      _NewsCard(
                        background: card,
                        textColor: text,
                        secondaryColor: secondary,
                        borderColor: border,
                      ),
                      const SizedBox(height: 150),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: _TradeBar(
            background: background,
            borderColor: border,
            onBuy: () => _showOrderSheet(context, isBuy: true),
            onSell: () => _showOrderSheet(context, isBuy: false),
          ),
        ),
      ),
    );
  }

  void _openAiTradeXBot() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AiTradeXBotSheet(
        company: widget.company,
        symbol: widget.symbol,
        currentPrice: _livePrice,
      ),
    );
  }

  void _showShareSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      builder: (_) => _ShareBottomSheet(
        company: widget.company,
        symbol: widget.symbol,
        price: widget.price,
        percent: widget.percent,
        equity: widget.equity,
      ),
    );
  }

  void _showOrderSheet(BuildContext context, {required bool isBuy}) {
    HapticFeedback.mediumImpact();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _OrderBottomSheet(
        company: widget.company,
        symbol: widget.symbol,
        price: widget.price,
        isBuy: isBuy,
      ),
    );
  }
}

class _StockHero extends StatelessWidget {
  final String company;
  final String symbol;
  final String price;
  final String percent;
  final bool isPositive;
  final List<String> periods;
  final int selectedPeriod;
  final bool isFavorite;
  final VoidCallback onBack;
  final VoidCallback onFavorite;
  final VoidCallback onShare;
  final ValueChanged<int> onPeriodChanged;

  const _StockHero({
    required this.company,
    required this.symbol,
    required this.price,
    required this.percent,
    required this.isPositive,
    required this.periods,
    required this.selectedPeriod,
    required this.isFavorite,
    required this.onBack,
    required this.onFavorite,
    required this.onShare,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final Color primary = colors.primary;
    final bool isDark = theme.brightness == Brightness.dark;
    final Color chartColor =
    isPositive ? const Color(0xFF35E6A8) : const Color(0xFFFF6073);
    final double top = MediaQuery.of(context).padding.top;

    return SizedBox(
      height: 488,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? <Color>[
                const Color(0xFF06110E),
                const Color(0xFF0A1D17),
                Color.alphaBlend(
                  primary.withValues(alpha: 0.14),
                  const Color(0xFF06110E),
                ),
              ]
                  : <Color>[
                const Color(0xFF07130F),
                const Color(0xFF102A21),
                Color.alphaBlend(
                  primary.withValues(alpha: 0.20),
                  const Color(0xFF07130F),
                ),
              ],
            ),
          ),
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: CustomPaint(
                  painter: _HeroGridPainter(
                    lineColor: Colors.white.withValues(alpha: 0.045),
                  ),
                ),
              ),
              Positioned(
                top: 55,
                right: -70,
                child: _GlowOrb(
                  size: 220,
                  color: primary.withValues(alpha: 0.11),
                ),
              ),
              Positioned(
                top: 235,
                left: -100,
                child: _GlowOrb(
                  size: 185,
                  color: chartColor.withValues(alpha: 0.055),
                ),
              ),

              // Clean top app-bar area. Keeping all controls inside the safe
              // area prevents the header from colliding with the status bar.
              Positioned(
                top: top + 8,
                left: 16,
                right: 16,
                child: Row(
                  children: <Widget>[
                    _HeroIconButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: onBack,
                    ),
                    const Spacer(),
                    Container(
                      height: 34,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.075),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: chartColor,
                              shape: BoxShape.circle,
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: chartColor.withValues(alpha: 0.7),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 7),
                          Text(
                            'Market',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withValues(alpha: 0.86),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    _HeroIconButton(
                      icon: Icons.ios_share_rounded,
                      onTap: onShare,
                    ),
                    const SizedBox(width: 8),
                    _HeroIconButton(
                      icon: isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: isFavorite ? const Color(0xFFFF5570) : null,
                      onTap: onFavorite,
                    ),
                  ],
                ),
              ),

              // Asset identity.
              Positioned(
                top: top + 72,
                left: 22,
                right: 22,
                child: Row(
                  children: <Widget>[
                    _AssetLogo(
                      company: company,
                      primary: primary,
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            company,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            symbol,
                            style: GoogleFonts.poppins(
                              color: Colors.white.withValues(alpha: 0.58),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Large, uncluttered price.
              Positioned(
                top: top + 145,
                left: 22,
                right: 22,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        price,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Container(
                      margin: const EdgeInsets.only(bottom: 2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: chartColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: chartColor.withValues(alpha: 0.20),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            isPositive
                                ? Icons.trending_up_rounded
                                : Icons.trending_down_rounded,
                            size: 16,
                            color: chartColor,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            percent,
                            style: GoogleFonts.poppins(
                              color: chartColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Chart is deliberately below the price, leaving the header
              // controls visually separated from the graph.
              Positioned(
                left: 0,
                right: 0,
                top: 218,
                bottom: 82,
                child: CustomPaint(
                  painter: _StockChartPainter(color: chartColor),
                ),
              ),

              Positioned(
                left: 22,
                right: 22,
                bottom: 66,
                child: Row(
                  children: <Widget>[
                    _HeroMetric(
                      label: 'Session',
                      value: isPositive ? 'Positive' : 'Negative',
                      alignEnd: false,
                      valueColor: chartColor,
                    ),
                    const Spacer(),
                    _HeroMetric(
                      label: 'Change',
                      value: percent,
                      alignEnd: true,
                      valueColor: chartColor,
                    ),
                  ],
                ),
              ),

              // Time range selector.
              Positioned(
                left: 14,
                right: 14,
                bottom: 10,
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.07),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      for (int i = 0; i < periods.length; i++)
                        Expanded(
                          child: _PeriodChip(
                            label: periods[i],
                            selected: i == selectedPeriod,
                            primary: primary,
                            onTap: () => onPeriodChanged(i),
                          ),
                        ),
                    ],
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

class _PriceSummaryCard extends StatelessWidget {
  final String price;
  final String percent;
  final bool isPositive;
  final Color background;
  final Color textColor;
  final Color secondaryColor;
  final Color borderColor;

  const _PriceSummaryCard({
    required this.price,
    required this.percent,
    required this.isPositive,
    required this.background,
    required this.textColor,
    required this.secondaryColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color movement =
    isPositive ? const Color(0xFF18C48F) : const Color(0xFFF0445A);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Current price',
                  style: GoogleFonts.poppins(
                    color: secondaryColor,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  price,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: textColor,
                    fontSize: 26,
                    height: 1.05,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
            decoration: BoxDecoration(
              color: movement.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  isPositive
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  size: 17,
                  color: movement,
                ),
                const SizedBox(width: 5),
                Text(
                  percent,
                  style: GoogleFonts.poppins(
                    color: movement,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
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

class _AskAiTradeXCard extends StatelessWidget {
  final String company;
  final String symbol;
  final String price;
  final VoidCallback onTap;

  const _AskAiTradeXCard({
    required this.company,
    required this.symbol,
    required this.price,
    required this.onTap,
  });

  static const Color green = Color(0xff18C48F);

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[
            green.withValues(alpha: 0.20),
            green.withValues(alpha: 0.08),
            colors.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: green.withValues(alpha: 0.34), width: 1.2),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: green.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
            child: Row(
              children: <Widget>[
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: green,
                    shape: BoxShape.circle,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: green.withValues(alpha: 0.24),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 23,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Ask AiTradeX Bot',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: colors.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Want buy/sell advice on $symbol?',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: colors.onSurfaceVariant,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$company • $price • Report 100 Coins',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: green,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 19,
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

class _AiTradeXBotSheet extends StatefulWidget {
  final String company;
  final String symbol;
  final String currentPrice;

  const _AiTradeXBotSheet({required this.company, required this.symbol, required this.currentPrice});

  @override
  State<_AiTradeXBotSheet> createState() => _AiTradeXBotSheetState();
}

class _AiTradeXBotSheetState extends State<_AiTradeXBotSheet> {
  static const green = Color(0xff18C48F);
  static const api = 'https://aitradex-api.onrender.com/api';
  final avg = TextEditingController();
  final qty = TextEditingController();
  bool owns = false;
  String? horizon;
  int step = 0;
  bool loading = false;

  @override
  void dispose() { avg.dispose(); qty.dispose(); super.dispose(); }

  Future<String> _token() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Please sign in again.');
    }
    final token = await user.getIdToken(true);
    if (token == null || token.isEmpty) {
      throw Exception('Authentication expired.');
    }
    return token;
  }

  Future<int> _balance() async {
    final r = await http.get(
      Uri.parse('$api/coins/balance'),
      headers: {
        'Authorization': 'Bearer ${await _token()}',
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 15));
    dynamic b;
    try { b = jsonDecode(r.body); } catch (_) {}
    if (r.statusCode != 200) {
      throw Exception(
        b is Map
            ? (b['message'] ?? 'Unable to load Coins.').toString()
            : 'Unable to load Coins.',
      );
    }
    if (b is Map && b['balance'] is num) {
      return (b['balance'] as num).toInt();
    }
    if (b is Map && b['data'] is Map && b['data']['balance'] is num) {
      return (b['data']['balance'] as num).toInt();
    }
    return 0;
  }

  Future<void> _submit() async {
    if (loading) {
      return;
    }

    final double? averagePrice = double.tryParse(avg.text.trim());
    final double? quantity = double.tryParse(qty.text.trim());

    if (owns) {
      if (averagePrice == null || averagePrice <= 0 ||
          quantity == null || quantity <= 0) {
        _error('Enter a valid average price and quantity greater than zero.');
        return;
      }
    } else if (horizon == null) {
      _error('Select an investment horizon.');
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Please sign in again.');
      }
      final token = await _token();
      final int startingBalance = await _balance();
      if (startingBalance < 100) {
        throw Exception(
          'Not enough AiTradeX Coins. You have $startingBalance; this report requires 100.',
        );
      }

      // Generate the report before charging. If AI fails, no coins are spent.
      final String ownershipContext = owns
          ? 'The user owns this stock. Average buying price: ₹${averagePrice!.toStringAsFixed(2)}. Quantity: ${quantity!.toStringAsFixed(0)}.'
          : 'The user does not currently own this stock. Investment horizon: $horizon.';

      final String prompt = '''
Create an AiTradeX stock intelligence report for ${widget.company} (${widget.symbol}).
Current displayed price: ${widget.currentPrice}.
$ownershipContext

Include:
1. AI prediction: Buy, Wait, or Avoid (not a guarantee).
2. Reasons and available evidence; do not invent current market facts.
3. Position or entry considerations.
4. Key risks and what to monitor.
5. Short summary for the stated investment horizon.

Clearly state that this is AI-generated educational research and not guaranteed financial advice.
''';

      final http.Response aiResponse = await http.post(
        Uri.parse('$api/ai/chat'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'message': prompt,
          'userId': user.uid,
          'history': <dynamic>[],
          'expenses': <dynamic>[],
          'income': 0,
        }),
      ).timeout(
        const Duration(seconds: 45),
        onTimeout: () => throw Exception(
          'Report generation timed out. No coins have been charged. Please retry.',
        ),
      );

      dynamic aiData;
      try {
        aiData = jsonDecode(aiResponse.body);
      } catch (_) {
        aiData = null;
      }

      if (aiResponse.statusCode < 200 ||
          aiResponse.statusCode >= 300 ||
          aiData is! Map ||
          aiData['success'] != true) {
        throw Exception(
          aiData is Map
              ? (aiData['message'] ?? aiData['error'] ??
              'Unable to generate the AI report.')
              .toString()
              : 'Unable to generate the AI report.',
        );
      }

      final dynamic nested = aiData['data'];
      final String report = <dynamic>[
        aiData['reply'],
        aiData['response'],
        aiData['message'],
        aiData['content'],
        aiData['text'],
        if (nested is Map) nested['reply'],
        if (nested is Map) nested['response'],
        if (nested is Map) nested['content'],
        if (nested is Map) nested['text'],
      ].whereType<String>()
          .map((value) => value.trim())
          .firstWhere((value) => value.isNotEmpty, orElse: () => '');

      if (report.isEmpty) {
        throw Exception(
          'The AI service returned an empty report. No coins have been charged.',
        );
      }

      // Charge/unlock only after a complete report is available.
      final http.Response unlockResponse = await http.post(
        Uri.parse('$api/coins/unlock-stock'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{'symbol': widget.symbol}),
      ).timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw Exception(
          'The unlock request timed out. Check your coin balance before retrying.',
        ),
      );

      dynamic unlockData;
      try {
        unlockData = jsonDecode(unlockResponse.body);
      } catch (_) {
        unlockData = null;
      }

      if (unlockResponse.statusCode == 402) {
        final dynamic balance = unlockData is Map
            ? (unlockData['balance'] ??
            (unlockData['data'] is Map
                ? unlockData['data']['balance']
                : null))
            : null;
        throw Exception(
          'Not enough AiTradeX Coins. Current balance: ${balance ?? 'unavailable'}.',
        );
      }

      if (unlockResponse.statusCode < 200 ||
          unlockResponse.statusCode >= 300 ||
          unlockData is! Map ||
          unlockData['success'] == false) {
        throw Exception(
          unlockData is Map
              ? (unlockData['message'] ?? 'Unable to unlock this report.')
              .toString()
              : 'Unable to unlock this report.',
        );
      }

      int remainingCoins = 0;
      final bool alreadyUnlocked = unlockData['alreadyUnlocked'] == true ||
          (unlockData['data'] is Map &&
              unlockData['data']['alreadyUnlocked'] == true);
      final dynamic rawBalance = unlockData['balance'] ??
          unlockData['remainingCoins'] ??
          unlockData['coins'] ??
          (unlockData['data'] is Map
              ? (unlockData['data']['balance'] ??
              unlockData['data']['remainingCoins'] ??
              unlockData['data']['coins'])
              : null);
      if (rawBalance is num) {
        remainingCoins = rawBalance.toInt();
      } else {
        remainingCoins = int.tryParse(rawBalance?.toString() ?? '') ??
            (alreadyUnlocked ? startingBalance : startingBalance - 100);
      }

      // Keep My Reports in sync with the chatbot screen's saved-report store.
      final String key = 'aitradex_my_reports_${user.uid}';
      final prefs = await SharedPreferences.getInstance();
      final List<String> stored = prefs.getStringList(key) ?? <String>[];
      final List<Map<String, dynamic>> reports = <Map<String, dynamic>>[];
      for (final String item in stored) {
        try {
          final dynamic decoded = jsonDecode(item);
          if (decoded is Map) {
            reports.add(Map<String, dynamic>.from(decoded));
          }
        } catch (_) {
          // Skip malformed saved entries.
        }
      }
      reports.removeWhere(
            (item) => item['symbol']?.toString().toUpperCase() ==
            widget.symbol.toUpperCase(),
      );
      final now = DateTime.now();
      final String date =
          '${now.day.toString().padLeft(2, '0')} '
          '${<String>['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][now.month - 1]} '
          '${now.year}, ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      reports.insert(0, <String, dynamic>{
        'symbol': widget.symbol,
        'company': widget.company,
        'logo': widget.symbol.length >= 3
            ? widget.symbol.substring(0, 3)
            : widget.symbol,
        'date': date,
        'report': report,
        'remainingCoins': remainingCoins,
      });
      if (reports.length > 30) {
        reports.removeRange(30, reports.length);
      }
      await prefs.setStringList(
        key,
        reports.map((item) => jsonEncode(item)).toList(),
      );

      if (!mounted) {
        return;
      }
      final navigator = Navigator.of(context, rootNavigator: true);
      Navigator.of(context).pop();
      await navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => StockAiReportScreen(
            company: widget.company,
            symbol: widget.symbol,
            report: report,
            remainingCoins: remainingCoins,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      _error(error.toString().replaceFirst('Exception: ', '').trim());
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  void _error(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _choice(String title, bool selected, VoidCallback tap) => InkWell(
    onTap: tap,
    borderRadius: BorderRadius.circular(17),
    child: Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: selected ? green.withValues(alpha: .08) : Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(17), border: Border.all(color: selected ? green : Theme.of(context).colorScheme.outlineVariant, width: selected ? 1.5 : 1)),
      child: Row(children: [Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: selected ? green : null), const SizedBox(width: 12), Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w700))]),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return FractionallySizedBox(
      heightFactor: 0.82,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: <Widget>[
              Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: colors.onSurface.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Ask AiTradeX Bot',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    '${step + 1}/3',
                    style: GoogleFonts.poppins(
                      color: green,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              Row(
                children: List<Widget>.generate(
                  3,
                      (int index) => Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(
                        right: index == 2 ? 0 : 5,
                      ),
                      decoration: BoxDecoration(
                        color: index <= step
                            ? green
                            : green.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: _body(colors),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(ColorScheme colors) {
    if (step == 0) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Which stock should AiTradeX Bot help you with?', style: GoogleFonts.poppins(fontSize: 19, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8), Text('The stock currently open is automatically selected.', style: GoogleFonts.poppins(fontSize: 10, color: colors.onSurfaceVariant)),
        const SizedBox(height: 20),
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: green.withValues(alpha: .07), borderRadius: BorderRadius.circular(18), border: Border.all(color: green.withValues(alpha: .2))), child: Row(children: [const CircleAvatar(backgroundColor: green, child: Icon(Icons.show_chart, color: Colors.white)), const SizedBox(width: 12), Expanded(child: Text('${widget.company}\n${widget.symbol} • ${widget.currentPrice}', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700))), const Icon(Icons.check_circle, color: green)])),
        const SizedBox(height: 25), _button('Continue', () => setState(() => step = 1)),
      ]);
    }
    if (step == 1) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Do you own this stock already?', style: GoogleFonts.poppins(fontSize: 19, fontWeight: FontWeight.w800)), const SizedBox(height: 20),
        _choice('Yes, I already own it', owns, () => setState(() => owns = true)), const SizedBox(height: 10), _choice('No, I do not own it', !owns, () => setState(() => owns = false)),
        const SizedBox(height: 25), _button('Continue', () => setState(() => step = 2)),
      ]);
    }
    if (owns) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Please enter your average buying price & quantity of stock', style: GoogleFonts.poppins(fontSize: 19, fontWeight: FontWeight.w800)), const SizedBox(height: 20),
        TextField(controller: avg, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Average buying price', prefixText: '₹ ', border: OutlineInputBorder())), const SizedBox(height: 12),
        TextField(controller: qty, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Quantity', border: OutlineInputBorder())), const SizedBox(height: 25), _button('Submit • 100 Coins', _submit, loading: loading),
      ]);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Okay, for how long do you want to invest in this stock?', style: GoogleFonts.poppins(fontSize: 19, fontWeight: FontWeight.w800)), const SizedBox(height: 20),
      _choice('0–3 months', horizon == '0–3 months', () => setState(() => horizon = '0–3 months')), const SizedBox(height: 10), _choice('3–12 months', horizon == '3–12 months', () => setState(() => horizon = '3–12 months')), const SizedBox(height: 10), _choice('12+ months', horizon == '12+ months', () => setState(() => horizon = '12+ months')), const SizedBox(height: 25), _button('Submit • 100 Coins', _submit, loading: loading),
    ]);
  }

  Widget _button(String title, VoidCallback onTap, {bool loading = false}) => SizedBox(width: double.infinity, height: 52, child: FilledButton(onPressed: loading ? null : onTap, child: loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w800))));
}

class _PositionGrid extends StatelessWidget {
  final String shares;
  final String avgCost;
  final String equity;
  final String totalReturns;
  final Color background;
  final Color textColor;
  final Color secondaryColor;
  final Color borderColor;

  const _PositionGrid({
    required this.shares,
    required this.avgCost,
    required this.equity,
    required this.totalReturns,
    required this.background,
    required this.textColor,
    required this.secondaryColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final List<_PositionData> items = <_PositionData>[
      _PositionData(
        icon: Icons.grid_view_rounded,
        label: 'Shares',
        value: shares,
        color: const Color(0xFF4C82F7),
      ),
      _PositionData(
        icon: Icons.account_balance_wallet_outlined,
        label: 'Avg. cost',
        value: avgCost,
        color: const Color(0xFFFFA52F),
      ),
      _PositionData(
        icon: Icons.pie_chart_rounded,
        label: 'Equity',
        value: equity,
        color: const Color(0xFFFF6376),
      ),
      _PositionData(
        icon: Icons.auto_graph_rounded,
        label: 'Total returns',
        value: totalReturns,
        color: const Color(0xFF8A68F6),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: GridView.builder(
        itemCount: items.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.65,
        ),
        itemBuilder: (BuildContext context, int index) {
          final _PositionData item = items[index];
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.11),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.icon, color: item.color, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: secondaryColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MarketOverviewCard extends StatelessWidget {
  final Color background;
  final Color textColor;
  final Color secondaryColor;
  final Color borderColor;

  const _MarketOverviewCard({
    required this.background,
    required this.textColor,
    required this.secondaryColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    const List<_StatData> stats = <_StatData>[
      _StatData('Market cap', '₹12.75B', Icons.business_center_outlined),
      _StatData('P/E ratio', 'N/A', Icons.speed_rounded),
      _StatData('Dividend yield', 'N/A', Icons.percent_rounded),
      _StatData('52W range', '₹62.94–₹76.46', Icons.swap_vert_rounded),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: <Widget>[
          for (int i = 0; i < stats.length; i++) ...<Widget>[
            _StatRow(
              stat: stats[i],
              textColor: textColor,
              secondaryColor: secondaryColor,
            ),
            if (i != stats.length - 1)
              Divider(
                height: 1,
                color: borderColor,
              ),
          ],
        ],
      ),
    );
  }
}

class _AnalystSnapshotCard extends StatelessWidget {
  final Color background;
  final Color textColor;
  final Color secondaryColor;
  final Color borderColor;

  const _AnalystSnapshotCard({
    required this.background,
    required this.textColor,
    required this.secondaryColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: <Widget>[
          _SentimentBar(
            label: 'Buy',
            percentage: 0.70,
            value: '70%',
            color: const Color(0xFF18C48F),
            textColor: textColor,
            secondaryColor: secondaryColor,
          ),
          const SizedBox(height: 18),
          _SentimentBar(
            label: 'Hold',
            percentage: 0.25,
            value: '25%',
            color: const Color(0xFFFFA000),
            textColor: textColor,
            secondaryColor: secondaryColor,
          ),
          const SizedBox(height: 18),
          _SentimentBar(
            label: 'Sell',
            percentage: 0.05,
            value: '5%',
            color: const Color(0xFFF05A68),
            textColor: textColor,
            secondaryColor: secondaryColor,
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Illustrative data only — not investment advice.',
              style: GoogleFonts.poppins(
                color: secondaryColor,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RiskCard extends StatelessWidget {
  final String symbol;
  final Color background;
  final Color textColor;
  final Color secondaryColor;
  final Color borderColor;
  final Color movementColor;

  const _RiskCard({
    required this.symbol,
    required this.background,
    required this.textColor,
    required this.secondaryColor,
    required this.borderColor,
    required this.movementColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: movementColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  Icons.shield_outlined,
                  color: movementColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Relative risk',
                      style: GoogleFonts.poppins(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$symbol compared with the broader market',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: secondaryColor,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Moderate',
                style: GoogleFonts.poppins(
                  color: movementColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: 0.57,
              minHeight: 9,
              backgroundColor: movementColor.withValues(alpha: 0.10),
              valueColor: AlwaysStoppedAnimation<Color>(movementColor),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Lower', style: _smallStyle(secondaryColor)),
              Text('Higher', style: _smallStyle(secondaryColor)),
            ],
          ),
        ],
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final Color background;
  final Color textColor;
  final Color secondaryColor;
  final Color borderColor;

  const _NewsCard({
    required this.background,
    required this.textColor,
    required this.secondaryColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    const List<_NewsData> news = <_NewsData>[
      _NewsData(
        source: 'Market Desk',
        title: 'Latest earnings and market updates.',
        time: '1d',
      ),
      _NewsData(
        source: 'Research',
        title: 'Latest analysis and market outlook.',
        time: '2d',
      ),
      _NewsData(
        source: 'Investor Brief',
        title: 'What investors should know about this asset.',
        time: '2d',
      ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: <Widget>[
          for (int i = 0; i < news.length; i++)
            _NewsTile(
              item: news[i],
              textColor: textColor,
              secondaryColor: secondaryColor,
              borderColor: borderColor,
              showDivider: i != news.length - 1,
            ),
        ],
      ),
    );
  }
}

class _TradeBar extends StatelessWidget {
  final Color background;
  final Color borderColor;
  final VoidCallback onBuy;
  final VoidCallback onSell;

  const _TradeBar({
    required this.background,
    required this.borderColor,
    required this.onBuy,
    required this.onSell,
  });

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
      decoration: BoxDecoration(
        color: background.withValues(alpha: 0.96),
        border: Border(
          top: BorderSide(color: borderColor),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 22,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _TradeButton(
              label: 'Sell',
              icon: Icons.south_west_rounded,
              background: primary.withValues(alpha: 0.10),
              foreground: primary,
              onTap: onSell,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _TradeButton(
              label: 'Buy',
              icon: Icons.north_east_rounded,
              background: primary,
              foreground: Theme.of(context).colorScheme.onPrimary,
              onTap: onBuy,
              elevated: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _TradeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;
  final bool elevated;

  const _TradeButton({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
    this.elevated = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          elevation: elevated ? 6 : 0,
          shadowColor: Theme.of(context).colorScheme.primary.withValues(
            alpha: 0.25,
          ),
          backgroundColor: background,
          foregroundColor: foreground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}

class _OrderBottomSheet extends StatefulWidget {
  final String company;
  final String symbol;
  final String price;
  final bool isBuy;

  const _OrderBottomSheet({
    required this.company,
    required this.symbol,
    required this.price,
    required this.isBuy,
  });

  @override
  State<_OrderBottomSheet> createState() => _OrderBottomSheetState();
}

class _OrderBottomSheetState extends State<_OrderBottomSheet> {
  final TextEditingController _quantityController =
  TextEditingController(text: '1');
  bool _marketOrder = true;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    final Color movement = widget.isBuy
        ? colors.primary
        : (isDark ? const Color(0xFFFF7080) : const Color(0xFFE54B61));

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        10,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 42,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: colors.onSurfaceVariant.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.isBuy ? 'Buy ${widget.symbol}' : 'Sell ${widget.symbol}',
                        style: GoogleFonts.poppins(
                          color: colors.onSurface,
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.company,
                        style: GoogleFonts.poppins(
                          color: colors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  widget.price,
                  style: GoogleFonts.poppins(
                    color: colors.onSurface,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Quantity',
                style: GoogleFonts.poppins(
                  color: colors.onSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              style: GoogleFonts.poppins(
                color: colors.onSurface,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: colors.surfaceContainerHighest,
                prefixIcon: Icon(
                  Icons.stacked_bar_chart_rounded,
                  color: movement,
                ),
                hintText: 'Enter quantity',
                hintStyle: GoogleFonts.poppins(
                  color: colors.onSurfaceVariant,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 14),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: _marketOrder,
              onChanged: (bool value) {
                setState(() => _marketOrder = value);
              },
              title: Text(
                'Market order',
                style: GoogleFonts.poppins(
                  color: colors.onSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                _marketOrder
                    ? 'Execute at the available market price.'
                    : 'Limit-order flow can be connected to your broker API.',
                style: GoogleFonts.poppins(
                  color: colors.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
              activeThumbColor: movement,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Get.snackbar(
                    widget.isBuy ? 'Buy order' : 'Sell order',
                    'Broker order API connection is required before a real order can be placed.',
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(14),
                    borderRadius: 14,
                    backgroundColor: colors.inverseSurface,
                    colorText: colors.onInverseSurface,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: movement,
                  foregroundColor: colors.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),
                child: Text(
                  widget.isBuy ? 'Review Buy Order' : 'Review Sell Order',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
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
    Navigator.of(context).pop();

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
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 42,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: colors.onSurfaceVariant.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Row(
              children: <Widget>[
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    Icons.ios_share_rounded,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Share asset',
                        style: GoogleFonts.poppins(
                          color: colors.onSurface,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '$company • $symbol',
                        style: GoogleFonts.poppins(
                          color: colors.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _ShareAction(
                  icon: Icons.share_rounded,
                  label: 'Share',
                  color: colors.primary,
                  onTap: () => _share(context),
                ),
                _ShareAction(
                  icon: Icons.copy_rounded,
                  label: 'Copy',
                  color: const Color(0xFF5B7CFA),
                  onTap: () async {
                    await Clipboard.setData(
                      ClipboardData(
                        text: '$company ($symbol) • $price • $percent',
                      ),
                    );
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      Get.snackbar(
                        'Copied',
                        'Asset details copied to clipboard.',
                        snackPosition: SnackPosition.BOTTOM,
                        margin: const EdgeInsets.all(14),
                        borderRadius: 14,
                      );
                    }
                  },
                ),
                _ShareAction(
                  icon: Icons.message_rounded,
                  label: 'Message',
                  color: const Color(0xFF19A7CE),
                  onTap: () => _share(context),
                ),
                _ShareAction(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  color: const Color(0xFF8A68F6),
                  onTap: () => _share(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color textColor;
  final Color secondaryColor;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.textColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    color: secondaryColor,
                    fontSize: 11,
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

class _PositionData {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _PositionData({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}

class _StatData {
  final String label;
  final String value;
  final IconData icon;

  const _StatData(this.label, this.value, this.icon);
}

class _NewsData {
  final String source;
  final String title;
  final String time;

  const _NewsData({
    required this.source,
    required this.title,
    required this.time,
  });
}

class _HeroIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _HeroIconButton({
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    const double size = 42;

    return Material(
      color: Colors.white.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(size / 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size / 2),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            icon,
            color: color ?? Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _AssetLogo extends StatelessWidget {
  final String company;
  final Color primary;

  const _AssetLogo({
    required this.company,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final String letter = company.trim().isEmpty
        ? 'A'
        : company.trim().substring(0, 1).toUpperCase();

    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: primary.withValues(alpha: 0.20),
            blurRadius: 18,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: GoogleFonts.poppins(
          color: primary,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  final String label;
  final String value;
  final bool alignEnd;
  final Color? valueColor;

  const _HeroMetric({
    required this.label,
    required this.value,
    required this.alignEnd,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white.withValues(alpha: 0.55),
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: valueColor ?? Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color primary;
  final VoidCallback onTap;

  const _PeriodChip({
    required this.label,
    required this.selected,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: selected ? primary : Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            height: 34,
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  color: selected ? Colors.black : Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SentimentBar extends StatelessWidget {
  final String label;
  final double percentage;
  final String value;
  final Color color;
  final Color textColor;
  final Color secondaryColor;

  const _SentimentBar({
    required this.label,
    required this.percentage,
    required this.value,
    required this.color,
    required this.textColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 42,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: <Widget>[
                Container(
                  height: 11,
                  color: color.withValues(alpha: 0.10),
                ),
                FractionallySizedBox(
                  widthFactor: percentage,
                  child: Container(
                    height: 11,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 38,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final _StatData stat;
  final Color textColor;
  final Color secondaryColor;

  const _StatRow({
    required this.stat,
    required this.textColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              stat.icon,
              color: primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              stat.label,
              style: GoogleFonts.poppins(
                color: secondaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            stat.value,
            textAlign: TextAlign.right,
            style: GoogleFonts.poppins(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _NewsTile extends StatelessWidget {
  final _NewsData item;
  final Color textColor;
  final Color secondaryColor;
  final Color borderColor;
  final bool showDivider;

  const _NewsTile({
    required this.item,
    required this.textColor,
    required this.secondaryColor,
    required this.borderColor,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(bottom: BorderSide(color: borderColor))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              Icons.article_outlined,
              color: primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        item.source,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: secondaryColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      item.time,
                      style: GoogleFonts.poppins(
                        color: secondaryColor,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: textColor,
                    fontSize: 12,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right_rounded,
            color: secondaryColor,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _ShareAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ShareAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 68,
        child: Column(
          children: <Widget>[
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.11),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 7),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowOrb({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: color,
            blurRadius: 70,
            spreadRadius: 18,
          ),
        ],
      ),
    );
  }
}

class _HeroGridPainter extends CustomPainter {
  final Color lineColor;

  const _HeroGridPainter({required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1;

    const double gap = 46;

    for (double x = 0; x <= size.width; x += gap) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    for (double y = 0; y <= size.height; y += gap) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HeroGridPainter oldDelegate) {
    return oldDelegate.lineColor != lineColor;
  }
}

class _StockChartPainter extends CustomPainter {
  final Color color;

  const _StockChartPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final List<Offset> points = <Offset>[
      Offset(0, size.height * 0.69),
      Offset(size.width * 0.035, size.height * 0.79),
      Offset(size.width * 0.07, size.height * 0.60),
      Offset(size.width * 0.105, size.height * 0.73),
      Offset(size.width * 0.14, size.height * 0.50),
      Offset(size.width * 0.18, size.height * 0.64),
      Offset(size.width * 0.22, size.height * 0.45),
      Offset(size.width * 0.27, size.height * 0.60),
      Offset(size.width * 0.31, size.height * 0.38),
      Offset(size.width * 0.36, size.height * 0.54),
      Offset(size.width * 0.40, size.height * 0.32),
      Offset(size.width * 0.45, size.height * 0.49),
      Offset(size.width * 0.50, size.height * 0.28),
      Offset(size.width * 0.55, size.height * 0.42),
      Offset(size.width * 0.60, size.height * 0.30),
      Offset(size.width * 0.65, size.height * 0.43),
      Offset(size.width * 0.70, size.height * 0.24),
      Offset(size.width * 0.75, size.height * 0.37),
      Offset(size.width * 0.80, size.height * 0.19),
      Offset(size.width * 0.85, size.height * 0.31),
      Offset(size.width * 0.90, size.height * 0.16),
      Offset(size.width * 0.95, size.height * 0.27),
      Offset(size.width, size.height * 0.20),
    ];

    final Path path = Path()..moveTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    final Paint glow = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..strokeWidth = 11
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);

    canvas.drawPath(path, glow);

    final Paint line = Paint()
      ..color = color
      ..strokeWidth = 2.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, line);

    final Offset high = points[20];
    final Paint fill = Paint()..color = color;
    final Paint ring = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(high, 5, fill);
    canvas.drawCircle(high, 6, ring);
  }

  @override
  bool shouldRepaint(covariant _StockChartPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

TextStyle _smallStyle(Color color) {
  return GoogleFonts.poppins(
    color: color,
    fontSize: 10,
  );
}