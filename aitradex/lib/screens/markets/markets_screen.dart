import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:aitradex/screens/stockDetails/stock_details_screen.dart';
import 'package:aitradex/services/market_data_service.dart';
import 'package:aitradex/services/upstox_service.dart';

class MarketsScreen extends StatefulWidget {
  const MarketsScreen({super.key});

  @override
  State<MarketsScreen> createState() => _MarketsScreenState();
}

class _MarketsScreenState extends State<MarketsScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _query = '';
  String _segment = 'Stocks';

  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastUpdated;

  Map<String, MarketQuote> _quotes = <String, MarketQuote>{};

  static const List<_MarketItem> _stocks = <_MarketItem>[
    _MarketItem(
      name: 'Reliance Industries',
      symbol: 'RELIANCE',
      instrumentKey: 'NSE_EQ|INE002A01018',
    ),
    _MarketItem(
      name: 'HDFC Bank',
      symbol: 'HDFCBANK',
      instrumentKey: 'NSE_EQ|INE040A01034',
    ),
    _MarketItem(
      name: 'Tata Consultancy',
      symbol: 'TCS',
      instrumentKey: 'NSE_EQ|INE467B01029',
    ),
    _MarketItem(
      name: 'Infosys',
      symbol: 'INFY',
      instrumentKey: 'NSE_EQ|INE009A01021',
    ),
    _MarketItem(
      name: 'ICICI Bank',
      symbol: 'ICICIBANK',
      instrumentKey: 'NSE_EQ|INE090A01021',
    ),
    _MarketItem(
      name: 'Bharti Airtel',
      symbol: 'BHARTIARTL',
      instrumentKey: 'NSE_EQ|INE397D01024',
    ),
    _MarketItem(
      name: 'ITC',
      symbol: 'ITC',
      instrumentKey: 'NSE_EQ|INE154A01025',
    ),
    _MarketItem(
      name: 'Larsen & Toubro',
      symbol: 'LT',
      instrumentKey: 'NSE_EQ|INE018A01030',
    ),
  ];

  static const List<_MarketItem> _indices = <_MarketItem>[
    _MarketItem(
      name: 'NIFTY 50',
      symbol: 'NIFTY',
      instrumentKey: 'NSE_INDEX|Nifty 50',
    ),
    _MarketItem(
      name: 'SENSEX',
      symbol: 'SENSEX',
      instrumentKey: 'BSE_INDEX|SENSEX',
    ),
    _MarketItem(
      name: 'NIFTY BANK',
      symbol: 'BANKNIFTY',
      instrumentKey: 'NSE_INDEX|Nifty Bank',
    ),
    _MarketItem(
      name: 'NIFTY IT',
      symbol: 'NIFTYIT',
      instrumentKey: 'NSE_INDEX|Nifty IT',
    ),
  ];

  List<_MarketItem> get _filtered {
    final source = _segment == 'Indices' ? _indices : _stocks;
    final query = _query.trim().toLowerCase();

    if (query.isEmpty) {
      return source;
    }

    return source
        .where(
          (item) =>
      item.name.toLowerCase().contains(query) ||
          item.symbol.toLowerCase().contains(query),
    )
        .toList(growable: false);
  }

  List<_MarketItem> get _currentItems =>
      _segment == 'Indices' ? _indices : _stocks;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMarketData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMarketData({bool showLoader = true}) async {
    if (_isLoading) return;

    if (showLoader && mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    } else if (mounted) {
      setState(() {
        _errorMessage = null;
      });
    }

    try {
      final keys = _stocks
          .followedBy(_indices)
          .map((item) => item.instrumentKey)
          .toSet()
          .toList(growable: false);

      final quotes = await MarketDataService.fetchMarketData(keys);

      if (!mounted) return;

      setState(() {
        _quotes = quotes;
        _lastUpdated = DateTime.now();
        _isLoading = false;
        _errorMessage = quotes.isEmpty
            ? 'No live market data was returned by Upstox.'
            : null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = _cleanError(error);
      });
    }
  }

  String _cleanError(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '').trim();

    if (message.isEmpty) {
      return 'Unable to load live market data.';
    }

    return message;
  }

  void _openDetails(_MarketItem item) {
    HapticFeedback.selectionClick();

    final quote = _quotes[item.instrumentKey];
    final price = quote == null
        ? '—'
        : MarketDataService.formatPrice(quote.lastPrice);
    final change = quote == null
        ? '—'
        : MarketDataService.formatPercent(quote.changePercent);

    Get.to(
          () => StockDetailsScreen(
        company: item.name,
        symbol: item.symbol,
        price: price,
        percent: change,
        shares: '0 shares',
        avgCost: '₹0.00',
        equity: '₹0.00',
        totalReturns: '₹0.00',
        isPositive: quote == null ? true : quote.changePercent >= 0,
      ),
      transition: Transition.cupertino,
    );
  }

  String _priceFor(_MarketItem item) {
    final quote = _quotes[item.instrumentKey];

    if (quote == null || quote.lastPrice == 0) {
      return '—';
    }

    return MarketDataService.formatPrice(quote.lastPrice);
  }

  String _changeFor(_MarketItem item) {
    final quote = _quotes[item.instrumentKey];

    if (quote == null) {
      return '—';
    }

    return MarketDataService.formatPercent(quote.changePercent);
  }

  bool _isPositive(_MarketItem item) {
    final quote = _quotes[item.instrumentKey];
    return quote == null || quote.changePercent >= 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
        isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness:
        isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: theme.scaffoldBackgroundColor,
        systemNavigationBarIconBrightness:
        isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            color: cs.primary,
            backgroundColor: cs.surface,
            onRefresh: () => _loadMarketData(showLoader: false),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                    child: _MarketHeader(
                      lastUpdated: _lastUpdated,
                      isLoading: _isLoading,
                      onRefresh: () => _loadMarketData(),
                    ),
                  ),
                ),

                if (_errorMessage != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                      child: _MarketStatusCard(
                        message: _errorMessage!,
                        onRetry: () => _loadMarketData(),
                        onConnect: UpstoxService.connectUpstox,
                      ),
                    ),
                  ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() => _query = value);
                      },
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Search market or symbol',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _query.isEmpty
                            ? null
                            : IconButton(
                          tooltip: 'Clear',
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                        filled: true,
                        fillColor:
                        cs.surfaceContainerHighest.withValues(alpha: .65),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: cs.primary.withValues(alpha: .35),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _SegmentButton(
                            label: 'Stocks',
                            selected: _segment == 'Stocks',
                            onTap: () {
                              setState(() => _segment = 'Stocks');
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SegmentButton(
                            label: 'Indices',
                            selected: _segment == 'Indices',
                            onTap: () {
                              setState(() => _segment = 'Indices');
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _segment == 'Stocks'
                                ? 'Popular stocks'
                                : 'Major indices',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                            ),
                          ),
                        ),
                        Text(
                          '${_filtered.length} items',
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (_isLoading && _quotes.isEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                    sliver: SliverList.separated(
                      itemCount: _currentItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, __) => const _MarketTileSkeleton(),
                    ),
                  )
                else if (_filtered.isEmpty)
                  const SliverToBoxAdapter(
                    child: _NoMarkets(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                    sliver: SliverList.separated(
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) =>
                      const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = _filtered[index];

                        return _MarketTile(
                          item: item,
                          price: _priceFor(item),
                          change: _changeFor(item),
                          positive: _isPositive(item),
                          onTap: () => _openDetails(item),
                        );
                      },
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

class _MarketHeader extends StatelessWidget {
  final DateTime? lastUpdated;
  final bool isLoading;
  final VoidCallback onRefresh;

  const _MarketHeader({
    required this.lastUpdated,
    required this.isLoading,
    required this.onRefresh,
  });

  String _updatedText() {
    if (lastUpdated == null) {
      return 'Live market data';
    }

    final local = lastUpdated!.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');

    return 'Updated $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Markets',
                style: GoogleFonts.poppins(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -.7,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    _updatedText(),
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Material(
          color: cs.primary.withValues(alpha: .10),
          shape: const CircleBorder(),
          child: InkWell(
            onTap: isLoading ? null : onRefresh,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: 44,
              height: 44,
              child: isLoading
                  ? Padding(
                padding: const EdgeInsets.all(13),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: cs.primary,
                ),
              )
                  : Icon(
                Icons.refresh_rounded,
                color: cs.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MarketStatusCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final Future<bool> Function() onConnect;

  const _MarketStatusCard({
    required this.message,
    required this.onRetry,
    required this.onConnect,
  });

  Future<void> _connect(BuildContext context) async {
    HapticFeedback.selectionClick();

    final opened = await onConnect();

    if (!context.mounted) return;

    if (!opened) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open the Upstox login page.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.errorContainer.withValues(alpha: .55),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: cs.error.withValues(alpha: .18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: 20,
                color: cs.error,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Live market data unavailable',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: cs.onErrorContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            message,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 11,
              height: 1.45,
              color: cs.onErrorContainer,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 17),
                label: const Text('Retry'),
              ),
              FilledButton.icon(
                onPressed: () => _connect(context),
                icon: const Icon(Icons.link_rounded, size: 17),
                label: const Text('Connect Upstox'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: selected
          ? cs.primary.withValues(alpha: .11)
          : cs.surfaceContainerHighest.withValues(alpha: .50),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? cs.primary.withValues(alpha: .30)
                  : cs.outline.withValues(alpha: .07),
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: selected ? cs.primary : cs.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _MarketTile extends StatelessWidget {
  final _MarketItem item;
  final String price;
  final String change;
  final bool positive;
  final VoidCallback onTap;

  const _MarketTile({
    required this.item,
    required this.price,
    required this.change,
    required this.positive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final movement = positive ? cs.primary : cs.error;

    return Material(
      color: cs.surfaceContainerHighest.withValues(alpha: .38),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: movement.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  positive
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  color: movement,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.symbol,
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    change,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: change == '—'
                          ? cs.onSurfaceVariant
                          : movement,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right_rounded,
                color: cs.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MarketTileSkeleton extends StatelessWidget {
  const _MarketTileSkeleton();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: .38),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Padding(
        padding: EdgeInsets.all(14),
        child: Row(
          children: [
            _SkeletonBox(width: 48, height: 48, radius: 15),
            SizedBox(width: 13),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SkeletonBox(width: 135, height: 13, radius: 5),
                  SizedBox(height: 8),
                  _SkeletonBox(width: 55, height: 9, radius: 4),
                ],
              ),
            ),
            SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _SkeletonBox(width: 70, height: 13, radius: 5),
                SizedBox(height: 8),
                _SkeletonBox(width: 45, height: 9, radius: 4),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _SkeletonBox({
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: cs.onSurface.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _NoMarkets extends StatelessWidget {
  const _NoMarkets();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 120),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 52,
            color: cs.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            'No market results',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Try another stock or symbol.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketItem {
  final String name;
  final String symbol;
  final String instrumentKey;

  const _MarketItem({
    required this.name,
    required this.symbol,
    required this.instrumentKey,
  });
}
