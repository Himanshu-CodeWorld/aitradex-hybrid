

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/market_data_service.dart';
import '../../services/upstox_service.dart';
import '../stockDetails/stock_details_screen.dart';
import 'wishlist_store.dart';

/// AiTradeX live Upstox watchlist.
///
/// Data flow:
/// Flutter -> AiTradeX backend -> Upstox V3 -> Flutter
///
/// IMPORTANT:
/// - No Upstox client secret is stored in Flutter.
/// - No Upstox access token is stored in this screen.
/// - Prices are loaded from MarketDataService.
/// - The backend is responsible for Upstox authentication/token handling.
class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  late List<WishlistStock> _stocks;

  String _query = '';
  bool _searchVisible = false;
  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _hasError = false;
  String _errorMessage = '';

  WishlistSort _sort = WishlistSort.recent;

  /// Watchlist assets.
  ///
  /// The values are Upstox instrument keys. More instruments can be added
  /// when your backend/instrument-search flow is ready.
  static const List<WishlistAsset> _assetCatalog = <WishlistAsset>[
    WishlistAsset(
      company: 'NIFTY 50',
      symbol: 'NIFTY',
      instrumentKey: 'NSE_INDEX|Nifty 50',
      logoText: 'N',
      logoColor: Color(0xff4A5BD5),
    ),
    WishlistAsset(
      company: 'Reliance Industries',
      symbol: 'RELIANCE',
      instrumentKey: 'NSE_EQ|INE002A01018',
      logoText: 'R',
      logoColor: Color(0xff1565C0),
    ),
    WishlistAsset(
      company: 'HDFC Bank',
      symbol: 'HDFCBANK',
      instrumentKey: 'NSE_EQ|INE040A01034',
      logoText: 'H',
      logoColor: Color(0xff00897B),
    ),
    WishlistAsset(
      company: 'Tata Consultancy Services',
      symbol: 'TCS',
      instrumentKey: 'NSE_EQ|INE467B01029',
      logoText: 'T',
      logoColor: Color(0xff5E35B1),
    ),
    WishlistAsset(
      company: 'Infosys',
      symbol: 'INFY',
      instrumentKey: 'NSE_EQ|INE009A01021',
      logoText: 'I',
      logoColor: Color(0xff1565C0),
    ),
    WishlistAsset(
      company: 'ICICI Bank',
      symbol: 'ICICIBANK',
      instrumentKey: 'NSE_EQ|INE090A01021',
      logoText: 'I',
      logoColor: Color(0xffEF6C00),
    ),
    WishlistAsset(
      company: 'Bharti Airtel',
      symbol: 'BHARTIARTL',
      instrumentKey: 'NSE_EQ|INE397D01024',
      logoText: 'A',
      logoColor: Color(0xffE53935),
    ),
    WishlistAsset(
      company: 'NIFTYBEES',
      symbol: 'NIFTYBEES',
      instrumentKey: 'NSE_EQ|INF204KB14I2',
      logoText: 'N',
      logoColor: Color(0xff2E7D32),
    ),
  ];

  /// Default watchlist shown on first launch.
  static const List<String> _defaultInstrumentKeys = <String>[
    'NSE_INDEX|Nifty 50',
    'NSE_EQ|INE002A01018',
    'NSE_EQ|INE040A01034',
    'NSE_EQ|INE467B01029',
    'NSE_EQ|INE009A01021',
    'NSE_EQ|INE090A01021',
    'NSE_EQ|INE397D01024',
    'NSE_EQ|INF204KB14I2',
  ];

  @override
  void initState() {
    super.initState();

    _stocks = _assetCatalog
        .where(
          (asset) => _defaultInstrumentKeys.contains(asset.instrumentKey),
    )
        .map(WishlistStock.fromAsset)
        .toList(growable: true);

    _initializeWishlist();
  }

  Future<void> _initializeWishlist() async {
    final Set<String> symbols = await WishlistStore.load(
      defaultSymbols: _assetCatalog
          .where((asset) => _defaultInstrumentKeys.contains(asset.instrumentKey))
          .map((asset) => asset.symbol)
          .toList(),
    );

    if (!mounted) return;

    setState(() {
      _stocks = _assetCatalog
          .where((asset) => symbols.contains(asset.symbol.toUpperCase()))
          .map(WishlistStock.fromAsset)
          .toList(growable: true);
    });

    await _loadMarketData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  List<WishlistStock> get _filteredStocks {
    final query = _query.trim().toLowerCase();

    final result = _stocks.where((stock) {
      if (query.isEmpty) {
        return true;
      }

      return stock.company.toLowerCase().contains(query) ||
          stock.symbol.toLowerCase().contains(query);
    }).toList();

    switch (_sort) {
      case WishlistSort.recent:
        return result;

      case WishlistSort.name:
        result.sort(
              (a, b) => a.company.toLowerCase().compareTo(
            b.company.toLowerCase(),
          ),
        );
        return result;

      case WishlistSort.priceHigh:
        result.sort(
              (a, b) => b.lastPrice.compareTo(a.lastPrice),
        );
        return result;

      case WishlistSort.change:
        result.sort(
              (a, b) => b.changePercent.compareTo(a.changePercent),
        );
        return result;
    }
  }

  Future<void> _loadMarketData({
    bool refresh = false,
  }) async {
    if (refresh) {
      if (_isRefreshing) {
        return;
      }

      setState(() {
        _isRefreshing = true;
        _hasError = false;
        _errorMessage = '';
      });
    } else {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = '';
      });
    }

    try {
      final keys = _stocks
          .map((stock) => stock.instrumentKey)
          .where((key) => key.trim().isNotEmpty)
          .toList();

      if (keys.isEmpty) {
        throw Exception('Your watchlist is empty.');
      }

      final quotes = await MarketDataService.fetchMarketData(keys);

      if (!mounted) {
        return;
      }

      final updatedStocks = <WishlistStock>[];

      for (final stock in _stocks) {
        final quote = quotes[stock.instrumentKey];

        if (quote == null) {
          updatedStocks.add(stock);
          continue;
        }

        final double liveLastPrice =
            quote.lastPrice.toDouble() ?? 0.0;

        final double liveChangePercent =
            quote.changePercent.toDouble() ?? 0.0;

        final double livePreviousClose =
            quote.previousClose?.toDouble() ?? 0.0;

        final double liveVolume =
            quote.volume?.toDouble() ?? 0.0;

        updatedStocks.add(
          stock.copyWith(
            symbol: quote.symbol.trim().isNotEmpty
                ? quote.symbol
                : stock.symbol,
            lastPrice: liveLastPrice,
            changePercent: liveChangePercent,
            previousClose: livePreviousClose,
            volume: liveVolume,
          ),
        );
      }

      setState(() {
        _stocks = updatedStocks;
        _isLoading = false;
        _isRefreshing = false;
        _hasError = false;
        _errorMessage = '';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      final message = _cleanErrorMessage(error);

      setState(() {
        _isLoading = false;
        _isRefreshing = false;
        _hasError = true;
        _errorMessage = message;
      });
    }
  }

  Future<void> _refresh() async {
    HapticFeedback.lightImpact();
    await _loadMarketData(refresh: true);
  }

  Future<void> _connectUpstox() async {
    final opened = await UpstoxService.connectUpstox();

    if (!mounted) {
      return;
    }

    if (!opened) {
      _showSnackBar(
        'Unable to open Upstox login. Please try again.',
        isError: true,
      );
      return;
    }

    _showSnackBar(
      'Complete Upstox login, then refresh the watchlist.',
    );
  }

  void _toggleSearch() {
    setState(() {
      _searchVisible = !_searchVisible;

      if (!_searchVisible) {
        _query = '';
        _searchController.clear();
      }
    });

    if (_searchVisible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          FocusScope.of(context).requestFocus(_searchFocusNode);
        }
      });
    }
  }

  void _showSortMenu() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final scheme = Theme.of(sheetContext).colorScheme;

        return SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: scheme.onSurface.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Sort watchlist',
                    style: GoogleFonts.poppins(
                      color: scheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _SortOption(
                  title: 'Recently added',
                  icon: Icons.schedule_rounded,
                  selected: _sort == WishlistSort.recent,
                  onTap: () => _changeSort(
                    sheetContext,
                    WishlistSort.recent,
                  ),
                ),
                _SortOption(
                  title: 'Company name',
                  icon: Icons.sort_by_alpha_rounded,
                  selected: _sort == WishlistSort.name,
                  onTap: () => _changeSort(
                    sheetContext,
                    WishlistSort.name,
                  ),
                ),
                _SortOption(
                  title: 'Price: high to low',
                  icon: Icons.trending_up_rounded,
                  selected: _sort == WishlistSort.priceHigh,
                  onTap: () => _changeSort(
                    sheetContext,
                    WishlistSort.priceHigh,
                  ),
                ),
                _SortOption(
                  title: 'Daily change',
                  icon: Icons.show_chart_rounded,
                  selected: _sort == WishlistSort.change,
                  onTap: () => _changeSort(
                    sheetContext,
                    WishlistSort.change,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _changeSort(
      BuildContext sheetContext,
      WishlistSort sort,
      ) {
    setState(() {
      _sort = sort;
    });

    Navigator.of(sheetContext).pop();
  }

  void _showAddStockSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _AddStockSheet(
          assets: _assetCatalog,
          existingKeys: _stocks
              .map((stock) => stock.instrumentKey)
              .toSet(),
          onToggle: (asset) async {
            await _toggleStock(asset);
          },
        );
      },
    );
  }

  Future<void> _toggleStock(WishlistAsset asset) async {
    final bool exists = _stocks.any(
          (stock) => stock.instrumentKey == asset.instrumentKey,
    );

    if (exists) {
      setState(() {
        _stocks.removeWhere(
              (stock) => stock.instrumentKey == asset.instrumentKey,
        );
      });
      await WishlistStore.set(asset.symbol, false);
      _showSnackBar('${asset.symbol} removed from watchlist.');
    } else {
      setState(() {
        _stocks.add(WishlistStock.fromAsset(asset));
      });
      await WishlistStore.set(asset.symbol, true);
      _showSnackBar('${asset.symbol} added. Loading live price...');
    }

    if (_stocks.isNotEmpty) {
      await _loadMarketData(refresh: true);
    }
  }

  Future<void> _removeStock(WishlistStock stock) async {
    setState(() {
      _stocks.removeWhere(
            (item) => item.instrumentKey == stock.instrumentKey,
      );
    });

    await WishlistStore.set(stock.symbol, false);

    if (_stocks.isEmpty) {
      _showSnackBar('Watchlist is empty. Add a stock to continue.');
      return;
    }

    await _loadMarketData(refresh: true);
  }


  void _openStock(WishlistStock stock) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StockDetailsScreen(
          company: stock.company,
          symbol: stock.symbol,
          price: stock.formattedPrice,
          percent: stock.formattedPercent,
          shares: '0 shares',
          avgCost: '₹0.00',
          equity: '₹0.00',
          totalReturns: '₹0.00',
          isPositive: stock.isPositive,
        ),
      ),
    );
  }

  void _showStockActions(WishlistStock stock) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final scheme = Theme.of(sheetContext).colorScheme;

        return SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: scheme.onSurface.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: stock.logoColor,
                    child: Text(
                      stock.logoText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  title: Text(
                    stock.company,
                    style: GoogleFonts.poppins(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    stock.symbol,
                    style: GoogleFonts.poppins(
                      color: scheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                ListTile(
                  leading: Icon(
                    Icons.open_in_new_rounded,
                    color: scheme.primary,
                  ),
                  title: const Text('Open details'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _openStock(stock);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.delete_outline_rounded,
                    color: scheme.error,
                  ),
                  title: const Text('Remove from watchlist'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _removeStock(stock);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSnackBar(
      String message, {
        bool isError = false,
      }) {
    if (!mounted) {
      return;
    }

    final scheme = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor:
          isError ? scheme.error : scheme.inverseSurface,
          duration: const Duration(milliseconds: 1800),
        ),
      );
  }

  String _cleanErrorMessage(Object error) {
    var message = error.toString().trim();

    if (message.startsWith('Exception: ')) {
      message = message.substring('Exception: '.length);
    }

    if (message.isEmpty) {
      return 'Live market data is unavailable. Please try again.';
    }

    return message;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final stocks = _filteredStocks;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        title: Text(
          'My Watchlist',
          style: GoogleFonts.poppins(
            color: scheme.onSurface,
            fontSize: 23,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Search',
            onPressed: _toggleSearch,
            icon: Icon(
              _searchVisible
                  ? Icons.close_rounded
                  : Icons.search_rounded,
              color: scheme.onSurface,
              size: 25,
            ),
          ),
          IconButton(
            tooltip: 'Add stock',
            onPressed: _showAddStockSheet,
            icon: Icon(
              Icons.add_rounded,
              color: scheme.onSurface,
              size: 28,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: scheme.primary,
        backgroundColor: scheme.surface,
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              sliver: SliverToBoxAdapter(
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  child: _searchVisible
                      ? Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _SearchField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      onChanged: (value) {
                        setState(() {
                          _query = value;
                        });
                      },
                    ),
                  )
                      : const SizedBox.shrink(),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
              sliver: SliverToBoxAdapter(
                child: _SummaryCard(
                  count: _stocks.length,
                  visibleCount: stocks.length,
                  primary: scheme.primary,
                  isLive: !_hasError && !_isLoading,
                  onConnect: _connectUpstox,
                ),
              ),
            ),
            if (_hasError)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                sliver: SliverToBoxAdapter(
                  child: _ErrorCard(
                    message: _errorMessage,
                    onRetry: () => _loadMarketData(),
                    onConnect: _connectUpstox,
                  ),
                ),
              ),
            if (_isLoading)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                sliver: SliverList.builder(
                  itemCount: _stocks.length,
                  itemBuilder: (context, index) {
                    return const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: _WishlistLoadingTile(),
                    );
                  },
                ),
              )
            else ...[
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Text(
                        '${stocks.length} '
                            '${stocks.length == 1 ? 'Company' : 'Companies'}',
                        style: GoogleFonts.poppins(
                          color: scheme.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: _showSortMenu,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 7,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _sort.label,
                                style: GoogleFonts.poppins(
                                  color: scheme.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Icon(
                                Icons.swap_vert_rounded,
                                color: scheme.primary,
                                size: 19,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (stocks.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyWatchlist(
                    query: _query,
                    onClear: () {
                      _searchController.clear();
                      setState(() {
                        _query = '';
                      });
                    },
                    onAdd: _showAddStockSheet,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 120),
                  sliver: SliverList.builder(
                    itemCount: stocks.length,
                    itemBuilder: (context, index) {
                      final stock = stocks[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: WishlistStockTile(
                          stock: stock,
                          onTap: () => _openStock(stock),
                          onLongPress: () => _showStockActions(stock),
                          onToggle: () => _removeStock(stock),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

enum WishlistSort {
  recent,
  name,
  priceHigh,
  change;

  String get label {
    switch (this) {
      case WishlistSort.recent:
        return 'Recently';
      case WishlistSort.name:
        return 'Name';
      case WishlistSort.priceHigh:
        return 'Price';
      case WishlistSort.change:
        return 'Change';
    }
  }
}

class WishlistAsset {
  const WishlistAsset({
    required this.company,
    required this.symbol,
    required this.instrumentKey,
    required this.logoText,
    required this.logoColor,
  });

  final String company;
  final String symbol;
  final String instrumentKey;
  final String logoText;
  final Color logoColor;
}

class WishlistStock {
  const WishlistStock({
    required this.company,
    required this.symbol,
    required this.instrumentKey,
    required this.logoText,
    required this.logoColor,
    this.lastPrice = 0,
    this.changePercent = 0,
    this.previousClose = 0,
    this.volume = 0,
  });

  factory WishlistStock.fromAsset(WishlistAsset asset) {
    return WishlistStock(
      company: asset.company,
      symbol: asset.symbol,
      instrumentKey: asset.instrumentKey,
      logoText: asset.logoText,
      logoColor: asset.logoColor,
    );
  }

  final String company;
  final String symbol;
  final String instrumentKey;
  final String logoText;
  final Color logoColor;

  final double lastPrice;
  final double changePercent;
  final double previousClose;
  final double volume;

  bool get isPositive => changePercent >= 0;

  String get formattedPrice {
    if (lastPrice <= 0) {
      return '—';
    }

    return '₹${_formatNumber(lastPrice)}';
  }

  String get formattedPercent {
    if (lastPrice <= 0 && changePercent == 0) {
      return '—';
    }

    final sign = changePercent > 0 ? '+' : '';
    return '$sign${changePercent.toStringAsFixed(2)}%';
  }

  WishlistStock copyWith({
    String? symbol,
    double? lastPrice,
    double? changePercent,
    double? previousClose,
    double? volume,
  }) {
    return WishlistStock(
      company: company,
      symbol: symbol ?? this.symbol,
      instrumentKey: instrumentKey,
      logoText: logoText,
      logoColor: logoColor,
      lastPrice: lastPrice ?? this.lastPrice,
      changePercent: changePercent ?? this.changePercent,
      previousClose: previousClose ?? this.previousClose,
      volume: volume ?? this.volume,
    );
  }

  static String _formatNumber(double value) {
    final abs = value.abs();

    if (abs >= 10000000) {
      return value.toStringAsFixed(2);
    }

    if (abs >= 100000) {
      return value.toStringAsFixed(2);
    }

    if (abs >= 1000) {
      return value.toStringAsFixed(2);
    }

    if (abs >= 100) {
      return value.toStringAsFixed(2);
    }

    return value.toStringAsFixed(2);
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      style: GoogleFonts.poppins(
        color: scheme.onSurface,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: 'Search stocks or symbols',
        hintStyle: GoogleFonts.poppins(
          color: scheme.onSurfaceVariant,
          fontSize: 12,
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: scheme.primary,
        ),
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide(
            color: scheme.primary.withValues(alpha: 0.45),
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.count,
    required this.visibleCount,
    required this.primary,
    required this.isLive,
    required this.onConnect,
  });

  final int count;
  final int visibleCount;
  final Color primary;
  final bool isLive;
  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.60),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: dark ? 0.16 : 0.045,
            ),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: primary.withValues(
                alpha: dark ? 0.15 : 0.09,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              isLive
                  ? Icons.wifi_tethering_rounded
                  : Icons.star_rounded,
              color: primary,
              size: 25,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your market watchlist',
                  style: GoogleFonts.poppins(
                    color: scheme.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  visibleCount == count
                      ? 'Track $count live Upstox quotes.'
                      : 'Showing $visibleCount of $count companies.',
                  style: GoogleFonts.poppins(
                    color: scheme.onSurfaceVariant,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          if (!isLive)
            TextButton(
              onPressed: onConnect,
              child: const Text('Connect'),
            ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    required this.message,
    required this.onRetry,
    required this.onConnect,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.errorContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: scheme.error.withValues(alpha: 0.20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.cloud_off_rounded,
                color: scheme.error,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Live market data unavailable',
                  style: GoogleFonts.poppins(
                    color: scheme.onErrorContainer,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            message,
            style: GoogleFonts.poppins(
              color: scheme.onErrorContainer,
              fontSize: 11,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(
                  Icons.refresh_rounded,
                  size: 17,
                ),
                label: const Text('Retry'),
              ),
              OutlinedButton.icon(
                onPressed: onConnect,
                icon: const Icon(
                  Icons.link_rounded,
                  size: 17,
                ),
                label: const Text('Connect Upstox'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyWatchlist extends StatelessWidget {
  const _EmptyWatchlist({
    required this.query,
    required this.onClear,
    required this.onAdd,
  });

  final String query;
  final VoidCallback onClear;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              query.isNotEmpty
                  ? Icons.search_off_rounded
                  : Icons.star_border_rounded,
              color: scheme.onSurfaceVariant,
              size: 44,
            ),
            const SizedBox(height: 12),
            Text(
              query.isNotEmpty
                  ? 'No stocks found'
                  : 'Your watchlist is empty',
              style: GoogleFonts.poppins(
                color: scheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              query.isNotEmpty
                  ? 'Try another company name or symbol.'
                  : 'Add an instrument and load its live Upstox price.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: scheme.onSurfaceVariant,
                fontSize: 11.5,
              ),
            ),
            const SizedBox(height: 14),
            if (query.isNotEmpty)
              OutlinedButton(
                onPressed: onClear,
                child: const Text('Clear search'),
              )
            else
              FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add instrument'),
              ),
          ],
        ),
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  const _SortOption({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: selected ? scheme.primary : scheme.onSurfaceVariant,
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: scheme.onSurface,
          fontSize: 13,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      trailing: selected
          ? Icon(
        Icons.check_circle_rounded,
        color: scheme.primary,
      )
          : null,
    );
  }
}

class _WishlistLoadingTile extends StatelessWidget {
  const _WishlistLoadingTile();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 86,
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        children: [
          _SkeletonBox(
            width: 54,
            height: 54,
            radius: 27,
            dark: dark,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonBox(
                  width: 130,
                  height: 11,
                  radius: 5,
                  dark: dark,
                ),
                const SizedBox(height: 8),
                _SkeletonBox(
                  width: 72,
                  height: 8,
                  radius: 4,
                  dark: dark,
                ),
              ],
            ),
          ),
          _SkeletonBox(
            width: 62,
            height: 24,
            radius: 7,
            dark: dark,
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _SkeletonBox(
                width: 65,
                height: 10,
                radius: 5,
                dark: dark,
              ),
              const SizedBox(height: 8),
              _SkeletonBox(
                width: 46,
                height: 8,
                radius: 4,
                dark: dark,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.width,
    required this.height,
    required this.radius,
    required this.dark,
  });

  final double width;
  final double height;
  final double radius;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: scheme.onSurface.withValues(
          alpha: dark ? 0.08 : 0.055,
        ),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class WishlistStockTile extends StatelessWidget {
  const WishlistStockTile({
    super.key,
    required this.stock,
    this.onTap,
    this.onLongPress,
    this.onToggle,
  });

  final WishlistStock stock;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;

    final chartColor =
    stock.isPositive ? scheme.primary : scheme.error;

    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 86,
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.58),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: dark ? 0.10 : 0.025,
                ),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: stock.logoColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  stock.logoText,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: stock.logoText.length > 1 ? 15 : 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 13),
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
                        color: scheme.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      stock.symbol,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: scheme.onSurfaceVariant,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 64,
                height: 34,
                child: CustomPaint(
                  painter: _WishlistSparklinePainter(
                    color: chartColor,
                    positive: stock.isPositive,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 78,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      stock.formattedPrice,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: scheme.onSurface,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      stock.formattedPercent,
                      style: GoogleFonts.poppins(
                        color: chartColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                tooltip: 'Remove from watchlist',
                onPressed: onToggle,
                icon: Icon(
                  Icons.check_circle_rounded,
                  color: scheme.primary,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WishlistSparklinePainter extends CustomPainter {
  const _WishlistSparklinePainter({
    required this.color,
    required this.positive,
  });

  final Color color;
  final bool positive;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) {
      return;
    }

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 1.45
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    final points = positive
        ? <double>[
      .52,
      .42,
      .58,
      .35,
      .50,
      .45,
      .64,
      .34,
      .55,
      .40,
      .68,
      .46,
      .55,
      .30,
      .48,
      .26,
      .40,
    ]
        : <double>[
      .30,
      .46,
      .36,
      .62,
      .44,
      .70,
      .38,
      .55,
      .42,
      .72,
      .48,
      .62,
      .40,
      .68,
      .50,
      .72,
      .55,
    ];

    for (var i = 0; i < points.length; i++) {
      final x = size.width * (i / (points.length - 1));
      final y = size.height * points[i];

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, linePaint);

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.12),
          color.withValues(alpha: 0),
        ],
      ).createShader(
        Rect.fromLTWH(
          0,
          0,
          size.width,
          size.height,
        ),
      );

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(
      covariant _WishlistSparklinePainter oldDelegate,
      ) {
    return oldDelegate.color != color ||
        oldDelegate.positive != positive;
  }
}

class _AddStockSheet extends StatefulWidget {
  const _AddStockSheet({
    required this.assets,
    required this.existingKeys,
    required this.onToggle,
  });

  final List<WishlistAsset> assets;
  final Set<String> existingKeys;
  final Future<void> Function(WishlistAsset asset) onToggle;

  @override
  State<_AddStockSheet> createState() => _AddStockSheetState();
}

class _AddStockSheetState extends State<_AddStockSheet> {
  final TextEditingController _controller = TextEditingController();

  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<WishlistAsset> get _filteredAssets {
    final query = _query.trim().toLowerCase();

    if (query.isEmpty) {
      return widget.assets;
    }

    return widget.assets.where((asset) {
      return asset.company.toLowerCase().contains(query) ||
          asset.symbol.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.78,
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.onSurface.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Manage watchlist',
                style: GoogleFonts.poppins(
                  color: scheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              onChanged: (value) {
                setState(() {
                  _query = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search supported instruments',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor:
                scheme.surfaceContainerHighest.withValues(alpha: 0.55),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                itemCount: _filteredAssets.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final asset = _filteredAssets[index];
                  final alreadyAdded =
                  widget.existingKeys.contains(asset.instrumentKey);

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: asset.logoColor,
                      child: Text(
                        asset.logoText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    title: Text(
                      asset.company,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: scheme.onSurface,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      asset.symbol,
                      style: GoogleFonts.poppins(
                        color: scheme.onSurfaceVariant,
                        fontSize: 10.5,
                      ),
                    ),
                    trailing: Checkbox(
                      value: alreadyAdded,
                      activeColor: scheme.primary,
                      onChanged: (_) => widget.onToggle(asset),
                    ),
                    onTap: () => widget.onToggle(asset),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
