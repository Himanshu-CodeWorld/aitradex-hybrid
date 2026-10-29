import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:aitradex/services/market_data_service.dart';
import 'package:aitradex/screens/stockDetails/stock_details_screen.dart';
import '../account/add_broker.dart';

/// AiTradeX portfolio:
/// - No fake holdings are displayed.
/// - Before a broker is connected, the screen is an intentional onboarding
///   experience.
/// - After a real broker OAuth/backend sync returns holdings, those holdings
///   should populate _holdings.
/// - AI insight cards are designed around the user's real holdings.
class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  String _period = '1M';
  String _sort = 'Value';

  bool _isConnecting = false;
  bool _isLoadingMarket = true;
  String? _marketError;
  MarketQuote? _niftyQuote;

  // Keep this empty until the backend returns account-specific holdings.
  final List<_BrokerHolding> _holdings = <_BrokerHolding>[];

  bool get _hasPortfolio => _holdings.isNotEmpty;

  List<_BrokerHolding> get _sortedHoldings {
    final List<_BrokerHolding> items = List<_BrokerHolding>.from(_holdings);

    if (_sort == 'Returns') {
      items.sort((a, b) => b.pnl.compareTo(a.pnl));
    } else if (_sort == 'A-Z') {
      items.sort((a, b) => a.company.compareTo(b.company));
    } else {
      items.sort((a, b) => b.marketValue.compareTo(a.marketValue));
    }

    return items;
  }

  double get _totalValue =>
      _holdings.fold<double>(0, (double sum, _BrokerHolding e) => sum + e.marketValue);

  double get _investedValue =>
      _holdings.fold<double>(0, (double sum, _BrokerHolding e) => sum + e.investedValue);

  double get _totalPnl =>
      _holdings.fold<double>(0, (double sum, _BrokerHolding e) => sum + e.pnl);

  @override
  void initState() {
    super.initState();
    _loadMarketContext();
  }

  Future<void> _loadMarketContext() async {
    if (!mounted) return;

    setState(() {
      _isLoadingMarket = true;
      _marketError = null;
    });

    try {
      final Map<String, MarketQuote> quotes =
      await MarketDataService.fetchMarketData(
        const <String>['NSE_INDEX|Nifty 50'],
      );

      if (!mounted) return;

      setState(() {
        _niftyQuote = quotes['NSE_INDEX|Nifty 50'];
        _isLoadingMarket = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoadingMarket = false;
        _marketError = error.toString().replaceFirst('Exception: ', '').trim();
      });
    }
  }

  Future<void> _connectBroker() async {
    if (_isConnecting) return;

    HapticFeedback.mediumImpact();

    final dynamic result = await Navigator.of(context).push<dynamic>(
      MaterialPageRoute<dynamic>(
        builder: (_) => const AddBrokerScreen(),
      ),
    );

    if (!mounted) return;

    if (result is String && result.isNotEmpty) {
      _showMessage(
        'Broker selected',
        '$result authorization is ready. Complete OAuth and let the backend sync your holdings.',
      );
    }
  }

  void _showMessage(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      duration: const Duration(seconds: 4),
    );
  }

  void _openHolding(_BrokerHolding holding) {
    HapticFeedback.selectionClick();

    Get.to(
          () => StockDetailsScreen(
        company: holding.company,
        symbol: holding.symbol,
        price: MarketDataService.formatPrice(holding.lastPrice),
        percent: MarketDataService.formatPercent(holding.dayChangePercent),
        shares: '${holding.quantity} shares',
        avgCost: MarketDataService.formatPrice(holding.averagePrice),
        equity: _formatCurrency(holding.marketValue),
        totalReturns: _formatCurrency(holding.pnl),
        isPositive: holding.pnl >= 0,
      ),
      transition: Transition.cupertino,
    );
  }

  String _formatCurrency(double value) {
    final String sign = value < 0 ? '-' : '';
    final double absolute = value.abs();

    if (absolute >= 10000000) {
      return '$sign₹${(absolute / 10000000).toStringAsFixed(2)} Cr';
    }
    if (absolute >= 100000) {
      return '$sign₹${(absolute / 100000).toStringAsFixed(2)} L';
    }
    return '$sign₹${absolute.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;
    final bool dark = theme.brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
        statusBarBrightness: dark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: theme.scaffoldBackgroundColor,
        systemNavigationBarIconBrightness: dark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: RefreshIndicator(
          color: cs.primary,
          backgroundColor: cs.surface,
          onRefresh: _loadMarketContext,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: _buildHero(context),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _buildBrokerStatus(context),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: _buildMarketContext(context),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: _buildAdviceHub(context),
                ),
              ),
              if (_hasPortfolio) ...<Widget>[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 25, 20, 10),
                    child: _buildHoldingsHeader(context),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                  sliver: SliverList.separated(
                    itemCount: _sortedHoldings.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, int index) {
                      final _BrokerHolding holding = _sortedHoldings[index];
                      return _HoldingTile(
                        holding: holding,
                        formatCurrency: _formatCurrency,
                        onTap: () => _openHolding(holding),
                      );
                    },
                  ),
                ),
              ] else
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                    child: _buildNoBrokerState(context),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 16,
        20,
        22,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            cs.primary,
            Color.lerp(cs.primary, Colors.black, dark ? .32 : .12)!,
          ],
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'My Portfolio',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            _hasPortfolio ? 'Live portfolio value' : 'Portfolio intelligence',
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: .76),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _hasPortfolio ? _formatCurrency(_totalValue) : 'Connect → Sync → Understand',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: _hasPortfolio ? 34 : 23,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _hasPortfolio
                ? '${_totalPnl >= 0 ? '+' : ''}${_formatCurrency(_totalPnl)} total P&L'
                : 'Your real investments, risk and stock insights in one place.',
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: .90),
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: <Widget>[
              for (final String value in const <String>['1D', '1W', '1M', '1Y', 'All'])
                Padding(
                  padding: const EdgeInsets.only(right: 7),
                  child: _PeriodChip(
                    label: value,
                    selected: value == _period,
                    onTap: () => setState(() => _period = value),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBrokerStatus(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: .5)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(Icons.link_rounded, color: cs.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _hasPortfolio ? 'Broker connected' : 'Connect your broker',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _hasPortfolio
                      ? 'Your account holdings are available for analysis.'
                      : 'Bring your actual stocks into AiTradeX. No demo holdings.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 9.5,
                    height: 1.35,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: _isConnecting ? null : _connectBroker,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            child: Text(
              _hasPortfolio ? 'Manage' : 'Add broker',
              style: GoogleFonts.poppins(fontSize: 9.5, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketContext(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final MarketQuote? q = _niftyQuote;
    final bool positive = q == null || q.changePercent >= 0;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: .35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: .4)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: (positive ? cs.primary : cs.error).withValues(alpha: .10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              positive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
              color: positive ? cs.primary : cs.error,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Market context',
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _isLoadingMarket
                      ? 'Loading NIFTY 50…'
                      : q == null
                      ? (_marketError ?? 'NIFTY 50 unavailable')
                      : 'NIFTY 50 • ${MarketDataService.formatPrice(q.lastPrice)} • ${MarketDataService.formatPercent(q.changePercent)}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(fontSize: 9, color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: _isLoadingMarket ? null : _loadMarketContext,
            icon: _isLoadingMarket
                ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary),
            )
                : Icon(Icons.refresh_rounded, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceHub(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: <Color>[
            cs.primary.withValues(alpha: .12),
            cs.surface,
          ],
        ),
        border: Border.all(color: cs.primary.withValues(alpha: .17)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: .11),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.psychology_rounded, color: cs.primary),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  'Your Stock Intelligence',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
              ),
              Icon(Icons.auto_awesome_rounded, color: cs.primary, size: 18),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _hasPortfolio
                ? 'AiTradeX can turn your real holdings into stock-by-stock insights, risk notes and portfolio observations.'
                : 'Connect a broker first. Once real holdings are synced, this area becomes your personalized stock analysis layer.',
            style: GoogleFonts.poppins(
              fontSize: 9.5,
              height: 1.45,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 13),
          Row(
            children: <Widget>[
              _AdvicePill(icon: Icons.analytics_outlined, text: 'Stock health'),
              const SizedBox(width: 7),
              _AdvicePill(icon: Icons.warning_amber_rounded, text: 'Risk'),
              const SizedBox(width: 7),
              _AdvicePill(icon: Icons.lightbulb_outline_rounded, text: 'Insight'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoBrokerState(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 28),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(27),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: .5)),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  cs.primary.withValues(alpha: .18),
                  cs.primary.withValues(alpha: .05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              color: cs.primary,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Start with your real portfolio',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Add a broker to bring your actual investments into AiTradeX. We will not invent holdings or returns.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 10.5,
              height: 1.45,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 19),
          FilledButton.icon(
            onPressed: _connectBroker,
            icon: const Icon(Icons.add_link_rounded, size: 18),
            label: const Text('Add broker'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'OAuth connection • Your broker credentials stay with the broker',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 8.5,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoldingsHeader(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Your investments',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${_holdings.length} holdings • ${_formatCurrency(_investedValue)} invested',
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          initialValue: _sort,
          onSelected: (String value) => setState(() => _sort = value),
          itemBuilder: (_) => const <PopupMenuEntry<String>>[
            PopupMenuItem<String>(value: 'Value', child: Text('Value')),
            PopupMenuItem<String>(value: 'Returns', child: Text('Returns')),
            PopupMenuItem<String>(value: 'A-Z', child: Text('A-Z')),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.outlineVariant.withValues(alpha: .45)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  _sort,
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(width: 3),
                Icon(Icons.keyboard_arrow_down_rounded, size: 17, color: cs.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BrokerHolding {
  final String company;
  final String symbol;
  final String instrumentKey;
  final int quantity;
  final double averagePrice;
  final double lastPrice;
  final double marketValue;
  final double investedValue;
  final double pnl;
  final double dayChangePercent;

  const _BrokerHolding({
    required this.company,
    required this.symbol,
    required this.instrumentKey,
    required this.quantity,
    required this.averagePrice,
    required this.lastPrice,
    required this.marketValue,
    required this.investedValue,
    required this.pnl,
    required this.dayChangePercent,
  });
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PeriodChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? Colors.white : Colors.white.withValues(alpha: .13),
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.white.withValues(alpha: .88),
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _AdvicePill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _AdvicePill({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: .45)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 12, color: cs.primary),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 7.5,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HoldingTile extends StatelessWidget {
  final _BrokerHolding holding;
  final String Function(double) formatCurrency;
  final VoidCallback onTap;

  const _HoldingTile({
    required this.holding,
    required this.formatCurrency,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool positive = holding.pnl >= 0;
    final Color moveColor = positive ? cs.primary : cs.error;

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: .09),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(Icons.candlestick_chart_rounded, color: cs.primary),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          holding.symbol,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${holding.quantity} shares • Avg ${formatCurrency(holding.averagePrice)}',
                          style: GoogleFonts.poppins(
                            fontSize: 8.5,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        formatCurrency(holding.marketValue),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${positive ? '+' : ''}${formatCurrency(holding.pnl)}',
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: moveColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: .06),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.auto_awesome_rounded, color: cs.primary, size: 16),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        'Market signal • ${holding.dayChangePercent >= 0 ? 'Positive' : 'Negative'} daily movement',
                        style: GoogleFonts.poppins(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant, size: 17),
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
