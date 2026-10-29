
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import '../account/account_screen.dart';
import '../account/AiTradeX_coins.dart';
import '../chatbot/aitradex_chatbot_screen.dart';
import '../../services/market_data_service.dart';
import '../stockDetails/stock_details_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  bool _isLoading = false;
  bool _isMarketRequestInProgress = false;
  String? _errorMessage;
  DateTime? _lastUpdated;
  Map<String, MarketQuote> _quotes = <String, MarketQuote>{};
  int _coinBalance = 0;
  final Set<String> _revealedPotentialSymbols = <String>{};
  bool _isLoadingCoins = false;
  static const String _apiBaseUrl = 'https://aitradex-api.onrender.com/api';

  static const Color _purple = Color(0xFF8B5CF6);
  static const Color _blue = Color(0xFF4F8CFF);
  static const Color _orange = Color(0xFFFF9F32);
  static const Color _gold = Color(0xFFFFB52E);

  final List<_MarketItem> _marketItems = <_MarketItem>[
    const _MarketItem('Nifty 50', 'NIFTY 50', 'NSE_INDEX|Nifty 50', Icons.show_chart_rounded, _orange, category: 'index'),
    const _MarketItem('Nifty Bank', 'BANKNIFTY', 'NSE_INDEX|Nifty Bank', Icons.account_balance_rounded, _orange, category: 'index'),
    const _MarketItem('Reliance Industries', 'RELIANCE', 'NSE_EQ|INE002A01018', Icons.business_rounded, _blue),
    const _MarketItem('HDFC Bank', 'HDFCBANK', 'NSE_EQ|INE040A01034', Icons.business_rounded, _blue),
    const _MarketItem('Tata Consultancy Services', 'TCS', 'NSE_EQ|INE467B01029', Icons.business_rounded, _blue),
    const _MarketItem('Infosys', 'INFY', 'NSE_EQ|INE009A01021', Icons.business_rounded, _blue),
    const _MarketItem('ICICI Bank', 'ICICIBANK', 'NSE_EQ|INE090A01021', Icons.business_rounded, _blue),
    const _MarketItem('Avenue Supermarts', 'DMART', 'NSE_EQ|INE397D01024', Icons.business_rounded, _blue),
    const _MarketItem('Tata Motors', 'TATAMOTORS', 'NSE_EQ|INE155A01022', Icons.business_rounded, _blue),
  ];
  Timer? _marketRefreshTimer;

  // Curated stock watchlist used by dashboard cards and search.
  List<_MarketItem> get _stocks =>
      _marketItems.where((item) => item.category == 'stock').toList();

  // Show six stocks on the dashboard; the remaining watchlist entries stay searchable.
  List<_MarketItem> get _dashboardStocks => _stocks.take(6).toList();

  List<_MarketItem> get _indices =>
      _marketItems.where((item) => item.category == 'index').toList();

  List<_PotentialStock> get _potentialStocks => _stocks
      .take(2)
      .map((item) => _PotentialStock(item.symbol, '—', 'Market instrument'))
      .toList();

  List<_MarketItem> get _allItems => List<_MarketItem>.unmodifiable(_marketItems);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadMarket();
      await _loadCoinBalance();
      _marketRefreshTimer?.cancel();
      _marketRefreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
        if (mounted && !_isMarketRequestInProgress) {
          _loadMarket(showLoader: false);
        }
      });
    });
  }

  @override
  void dispose() {
    _marketRefreshTimer?.cancel();
    _marketRefreshTimer = null;
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadMarket({
    bool showLoader = true,
    bool forceRefresh = false,
  }) async {
    if (_isMarketRequestInProgress || !mounted) return;
    _isMarketRequestInProgress = true;

    if (mounted) {
      setState(() {
        _isLoading = showLoader;
        _errorMessage = null;
      });
    }

    try {
      // Request only the dashboard watchlist. No instrument catalogue is
      // downloaded by Flutter; the backend maps Upstox response aliases.
      final List<String> keys = _marketItems
          .map((item) => item.instrumentKey.trim())
          .where((key) => key.isNotEmpty)
          .toSet()
          .toList(growable: false);

      final Map<String, MarketQuote> quotes =
          await MarketDataService.fetchMarketData(
        keys,
        forceRefresh: forceRefresh,
      ).timeout(const Duration(seconds: 25));

      debugPrint(
        '[AiTradeX Dashboard] Market quotes received: ${quotes.length}/${keys.length}',
      );
      for (final _MarketItem item in _marketItems) {
        final MarketQuote? quote = quotes[item.instrumentKey];
        debugPrint(
          '[AiTradeX Dashboard] ${item.symbol}: '
          '${quote == null ? "NO QUOTE" : "₹${quote.lastPrice.toStringAsFixed(2)}"}',
        );
      }

      if (!mounted) return;
      setState(() {
        _quotes = quotes;
        _lastUpdated = DateTime.now();
        _isLoading = false;
        if (quotes.isEmpty) {
          _errorMessage =
              'No market quotes received. Check Upstox connection and API response.';
        } else if (quotes.length < keys.length) {
          _errorMessage =
              'Market data returned ${quotes.length} of ${keys.length} quotes. '
              'Some prices may be unavailable; retry after checking Render logs.';
        } else {
          _errorMessage = null;
        }
      });
    } catch (error, stackTrace) {
      debugPrint('AiTradeX market-data error: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = error.toString().replaceFirst('Exception: ', '').trim();
      });
    } finally {
      _isMarketRequestInProgress = false;
      if (mounted && _isLoading) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadCoinBalance() async {
    if (_isLoadingCoins) return;
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (mounted) setState(() => _isLoadingCoins = true);
    try {
      final String? token = await user.getIdToken();
      if (token == null || token.isEmpty) return;

      final http.Response response = await http.get(
        Uri.parse('$_apiBaseUrl/coins/balance'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode < 200 || response.statusCode >= 300) return;

      final dynamic decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final dynamic balance =
            decoded['balance'] ??
                (decoded['data'] is Map ? decoded['data']['balance'] : null);
        if (balance is num && mounted) {
          setState(() => _coinBalance = balance.toInt());
        }
      }
    } catch (error) {
      debugPrint('Dashboard coin balance error: $error');
    } finally {
      if (mounted) setState(() => _isLoadingCoins = false);
    }
  }

  void _openCoins() {
    HapticFeedback.lightImpact();
    Navigator.of(context)
        .push(
      MaterialPageRoute<void>(builder: (_) => const AiTradeXCoinsScreen()),
    )
        .then((_) => _loadCoinBalance());
  }

  void _dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
  }

  void _openChatbot() {
    _dismissKeyboard();
    HapticFeedback.mediumImpact();
    if (_coinBalance <= 0) {
      _openCoins();
      _message('Add AiTradeX Coins to activate AiTradeX Chatbot access.');
      return;
    }

    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => AiTradeXChatbotScreen()));
  }

  MarketQuote? _quote(String key) => _quotes[key];

  String _price(String key) {
    final MarketQuote? q = _quote(key);
    if (q == null || q.lastPrice == 0) return '—';
    return MarketDataService.formatPrice(q.lastPrice);
  }

  String _change(String key) {
    final MarketQuote? q = _quote(key);
    return q == null ? '—' : MarketDataService.formatPercent(q.changePercent);
  }

  void _openAccount() {
    HapticFeedback.lightImpact();
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const AccountScreen()));
  }

  void _search(String value) {
    final String query = value.trim().toLowerCase();
    if (query.isEmpty) return;

    final _MarketItem? match = _allItems.cast<_MarketItem?>().firstWhere(
          (item) =>
      item!.symbol.toLowerCase() == query ||
          item.name.toLowerCase().contains(query),
      orElse: () => null,
    );

    if (match == null) {
      _message('No stock or index found for "$value".');
      return;
    }

    _openLockedStock(match);
  }

  void _openLockedStock(_MarketItem item) {
    HapticFeedback.selectionClick();
    _showCoinGate(
      title: '${item.symbol} analysis',
      subtitle:
      'Unlock the complete AiTradeX stock report with AiTradeX Coins.',
    );
  }

  void _showCoinGate({required String title, required String subtitle}) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: .45),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.onSurfaceVariant.withValues(alpha: .25),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[cs.primary, _purple],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    height: 1.45,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(
                      color: cs.primary.withValues(alpha: .16),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.monetization_on_rounded, color: cs.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'AiTradeX Coins are required to unlock this report.',
                          style: GoogleFonts.poppins(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                      Text(
                        'Unlock',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: cs.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const AiTradeXCoinsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.monetization_on_rounded, size: 18),
                    label: const Text('Get AiTradeX Coins'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You can still view the live market overview without unlocking a report.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _message(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
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
        systemNavigationBarIconBrightness: dark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: <Widget>[
            SafeArea(
              bottom: false,
              child: RefreshIndicator(
                color: cs.primary,
                backgroundColor: cs.surface,
                onRefresh: () async {
                  _dismissKeyboard();
                  await _loadMarket(showLoader: false, forceRefresh: true);
                  await _loadCoinBalance();
                },
                child: CustomScrollView(
                  keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: <Widget>[
                    SliverToBoxAdapter(child: _buildHeader()),
                    SliverToBoxAdapter(child: _buildWelcomeHero()),
                    if (_errorMessage != null)
                      SliverToBoxAdapter(child: _buildErrorCard()),
                    SliverToBoxAdapter(child: _buildMarketPulse()),
                    SliverToBoxAdapter(child: _buildQuickActions()),
                    SliverToBoxAdapter(child: _buildMarketOverview()),
                    SliverToBoxAdapter(child: _buildLockedStocks()),
                    SliverToBoxAdapter(child: _buildPotentialStocks()),
                    const SliverToBoxAdapter(child: SizedBox(height: 150)),
                  ],
                ),
              ),
            ),
            Positioned(right: 18, bottom: 88, child: _buildFloatingAiButton()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
      child: Row(
        children: <Widget>[
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _openAccount,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: .55),
                ),
              ),
              child: Icon(Icons.person_outline_rounded, color: cs.onSurface),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: .55),
                ),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                autofocus: false,
                onSubmitted: (value) {
                  _search(value);
                  _dismissKeyboard();
                },
                onTapOutside: (_) => _dismissKeyboard(),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: cs.onSurfaceVariant,
                  ),
                  hintText: 'Search stocks, indices...',
                  hintStyle: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 12,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: cs.surface,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _openCoins,
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: .55),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.monetization_on_rounded,
                      color: cs.primary,
                      size: 19,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isLoadingCoins ? '...' : '$_coinBalance',
                      style: GoogleFonts.poppins(
                        color: cs.onSurface,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeHero() {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: dark
                ? <Color>[
              cs.primary.withValues(alpha: .28),
              const Color(0xFF181522),
              cs.surface,
            ]
                : <Color>[cs.primary.withValues(alpha: .15), Colors.white],
          ),
          border: Border.all(color: cs.primary.withValues(alpha: .18)),
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
                    color: cs.primary.withValues(alpha: .14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.auto_awesome_rounded, color: cs.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'AiTradeX market cockpit',
                    style: GoogleFonts.poppins(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              'AI-powered stock insights, live market data and investment research in one place.',
              style: GoogleFonts.poppins(
                fontSize: 11,
                height: 1.45,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 17),
            Row(
              children: <Widget>[
                _HeroChip(
                  icon: Icons.flash_on_rounded,
                  text: 'Live data',
                  color: cs.primary,
                ),
                const SizedBox(width: 8),
                _HeroChip(
                  icon: Icons.lock_outline_rounded,
                  text: 'Coin unlocks',
                  color: _purple,
                ),
                const SizedBox(width: 8),
                _HeroChip(
                  icon: Icons.psychology_rounded,
                  text: 'AI',
                  color: _orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.errorContainer.withValues(alpha: .45),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: <Widget>[
            Icon(Icons.cloud_off_rounded, color: cs.error),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _errorMessage!,
                style: TextStyle(color: cs.onErrorContainer, fontSize: 10.5),
              ),
            ),
            TextButton(
              onPressed: _isLoading
                  ? null
                  : () => _loadMarket(forceRefresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketPulse() {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final MarketQuote? nifty = _quote('NSE_INDEX|Nifty 50');
    final bool positive = nifty == null || nifty.changePercent >= 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: .5)),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (positive ? cs.primary : cs.error).withValues(
                  alpha: .10,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                positive
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                color: positive ? cs.primary : cs.error,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Market pulse',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    nifty == null
                        ? 'NIFTY 50 • waiting for live quote'
                        : 'NIFTY 50 • ${_price(nifty.instrumentKey)} • ${_change(nifty.instrumentKey)}',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  if (_lastUpdated != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        'Updated ${_time(_lastUpdated!)}',
                        style: GoogleFonts.poppins(
                          fontSize: 8.5,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Refresh',
              onPressed: _isLoading
                  ? null
                  : () => _loadMarket(forceRefresh: true),
              icon: _isLoading
                  ? SizedBox(
                width: 17,
                height: 17,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: cs.primary,
                ),
              )
                  : Icon(Icons.refresh_rounded, color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  String _time(DateTime value) {
    final DateTime t = value.toLocal();
    final int hour = t.hour % 12 == 0 ? 12 : t.hour % 12;
    return '$hour:${t.minute.toString().padLeft(2, '0')} ${t.hour >= 12 ? 'PM' : 'AM'}';
  }

  Widget _buildQuickActions() {
    final ColorScheme cs = Theme.of(context).colorScheme;

    final List<_Action> actions = <_Action>[
      _Action(Icons.analytics_rounded, 'Stock X-ray', _purple),
      _Action(Icons.screen_search_desktop_rounded, 'Screener', cs.primary),
      _Action(Icons.auto_graph_rounded, 'AI signals', _orange),
      _Action(Icons.account_balance_wallet_rounded, 'Portfolio', cs.primary),
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: SizedBox(
        height: 82,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: actions.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, int index) {
            final _Action action = actions[index];
            return Material(
              color: cs.surface,
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  HapticFeedback.selectionClick();
                  if (action.label == 'Portfolio') {
                    _message('Open Portfolio from the bottom navigation.');
                    return;
                  }
                  _showCoinGate(
                    title: action.label,
                    subtitle: 'This premium research tool uses AiTradeX Coins.',
                  );
                },
                child: SizedBox(
                  width: 105,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(action.icon, color: action.color, size: 23),
                        const SizedBox(height: 7),
                        Text(
                          action.label,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMarketOverview() {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 26, 0, 0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              children: <Widget>[
                Text(
                  'Market Overview',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
                const Spacer(),
                Text(
                  'Free',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: cs.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 145,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _indices.length,
              itemBuilder: (_, int index) => _buildIndexCard(_indices[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndexCard(_MarketItem item) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final MarketQuote? quote = _quote(item.instrumentKey);
    final bool positive = quote == null || quote.changePercent >= 0;
    final Color color = positive ? cs.primary : cs.error;

    return Container(
      width: 190,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: .5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(item.icon, color: item.iconColor, size: 20),
              const Spacer(),
              Icon(
                positive
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                color: color,
                size: 17,
              ),
            ],
          ),
          const Spacer(),
          Text(
            item.name,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            _price(item.instrumentKey),
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            _change(item.instrumentKey),
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openPotentialStock(_PotentialStock stock) async {
    HapticFeedback.mediumImpact();

    final _MarketItem? item = _allItems.cast<_MarketItem?>().firstWhere(
          (value) => value?.symbol.toUpperCase() == stock.symbol.toUpperCase(),
      orElse: () => null,
    );

    final String symbol = stock.symbol.toUpperCase();
    final String company = item?.name ?? symbol;
    final String instrumentKey =
        item?.instrumentKey ?? _instrumentKeyForPotential(symbol);
    final MarketQuote? quote = _quote(instrumentKey);

    final String price = quote == null || quote.lastPrice <= 0
        ? '—'
        : MarketDataService.formatPrice(quote.lastPrice);
    final String percent = quote == null
        ? '0.00%'
        : MarketDataService.formatPercent(quote.changePercent);
    final bool isPositive = quote == null || quote.changePercent >= 0;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StockDetailsScreen(
          company: company,
          symbol: symbol,
          price: price,
          percent: percent,
          shares: '0 shares',
          avgCost: '₹0.00',
          equity: '₹0.00',
          totalReturns: '₹0.00',
          isPositive: isPositive,
        ),
      ),
    );

    if (mounted) {
      await _loadCoinBalance();
    }
  }

  String _instrumentKeyForPotential(String symbol) {
    for (final _MarketItem item in _stocks) {
      if (item.symbol.toUpperCase() == symbol.toUpperCase()) {
        return item.instrumentKey;
      }
    }
    return '';
  }

  Widget _buildLockedStocks() {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                'Stock Intelligence',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),
              const Spacer(),
              _LockBadge(),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            'Live stocks stay visible. Deep stock reports are unlocked with Coins.',
            style: GoogleFonts.poppins(
              fontSize: 9.5,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 13),
          ..._dashboardStocks.map(_buildLockedStockTile),
        ],
      ),
    );
  }

  Widget _buildLockedStockTile(_MarketItem item) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final MarketQuote? quote = _quote(item.instrumentKey);
    final bool positive = quote == null || quote.changePercent >= 0;
    final Color moveColor = positive ? cs.primary : cs.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      child: Material(
        color: cs.surface,
        borderRadius: BorderRadius.circular(19),
        child: InkWell(
          borderRadius: BorderRadius.circular(19),
          onTap: () => _openLockedStock(item),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
            child: Row(
              children: <Widget>[
                Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    color: item.iconColor.withValues(alpha: .10),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(item.icon, color: item.iconColor, size: 21),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        item.symbol,
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                        ),
                      ),
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                      _price(item.instrumentKey),
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                      ),
                    ),
                    Text(
                      _change(item.instrumentKey),
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: moveColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: .09),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(Icons.lock_rounded, size: 16, color: cs.primary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPotentialStocks() {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 30, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'AI stock opportunities',
                    style: GoogleFonts.poppins(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: .10),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: cs.primary,
                    size: 19,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Text(
              'Explore potential opportunities. Tap once to reveal, then open the stock details.',
              style: GoogleFonts.poppins(
                fontSize: 10,
                height: 1.45,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 228,
            child: ListView.separated(
              padding: const EdgeInsets.only(right: 20, bottom: 3),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _potentialStocks.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, int index) {
                final _PotentialStock stock = _potentialStocks[index];
                final String symbol = stock.symbol.toUpperCase();
                final bool revealed = _revealedPotentialSymbols.contains(
                  symbol,
                );
                final String key = _instrumentKeyForPotential(symbol);
                final MarketQuote? quote = _quote(key);
                final bool positive = quote == null || quote.changePercent >= 0;
                final Color moveColor = positive ? cs.primary : cs.error;
                final Color cardStart = dark
                    ? const Color(0xFF102D24)
                    : cs.surface;
                final Color cardEnd = dark
                    ? const Color(0xFF111A18)
                    : cs.primary.withValues(alpha: .055);

                return SizedBox(
                  width: 258,
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        if (!revealed) {
                          setState(() => _revealedPotentialSymbols.add(symbol));
                        } else {
                          _openPotentialStock(stock);
                        }
                      },
                      child: Ink(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: <Color>[cardStart, cardEnd],
                          ),
                          border: Border.all(
                            color: cs.primary.withValues(
                              alpha: revealed ? .34 : .22,
                            ),
                          ),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: cs.primary.withValues(
                                alpha: dark ? .08 : .045,
                              ),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: cs.primary.withValues(alpha: .12),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    revealed
                                        ? Icons.show_chart_rounded
                                        : Icons.auto_graph_rounded,
                                    color: cs.primary,
                                    size: 21,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'AITRADEX AI',
                                        style: GoogleFonts.poppins(
                                          fontSize: 8,
                                          letterSpacing: .8,
                                          fontWeight: FontWeight.w800,
                                          color: cs.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        revealed ? symbol : 'Stock opportunity',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: cs.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: cs.primary.withValues(alpha: .11),
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  child: Text(
                                    'AI',
                                    style: GoogleFonts.poppins(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: cs.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 13),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: cs.primary.withValues(alpha: .075),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: cs.primary.withValues(alpha: .17),
                                ),
                              ),
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    revealed
                                        ? Icons.check_circle_rounded
                                        : Icons.lock_rounded,
                                    color: cs.primary,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 9),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          revealed
                                              ? stock.label
                                              : 'Tap to reveal',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            color: cs.onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          revealed
                                              ? 'Illustrative potential upside: ${stock.upside}'
                                              : 'See the opportunity details',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.poppins(
                                            fontSize: 8.5,
                                            height: 1.35,
                                            color: cs.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    revealed
                                        ? Icons.open_in_new_rounded
                                        : Icons.arrow_forward_rounded,
                                    color: cs.primary,
                                    size: 17,
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'LIVE MARKET PRICE',
                                        style: GoogleFonts.poppins(
                                          fontSize: 7.5,
                                          fontWeight: FontWeight.w700,
                                          color: cs.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        quote == null || quote.lastPrice <= 0
                                            ? '—'
                                            : MarketDataService.formatPrice(
                                          quote.lastPrice,
                                        ),
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: cs.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: moveColor.withValues(alpha: .10),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    quote == null
                                        ? '—'
                                        : MarketDataService.formatPercent(
                                      quote.changePercent,
                                    ),
                                    style: GoogleFonts.poppins(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: moveColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingAiButton() {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      elevation: 8,
      shadowColor: cs.primary.withValues(alpha: .35),
      child: InkWell(
        onTap: _openChatbot,
        customBorder: const CircleBorder(),
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Color(0xFF7C3AED), Color(0xFFEC4899)],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: .80),
              width: 2,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: cs.primary.withValues(alpha: .28),
                blurRadius: 18,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            color: Colors.white,
            size: 27,
          ),
        ),
      ),
    );
  }
}

class _MarketItem {
  final String name;
  final String symbol;
  final String instrumentKey;
  final IconData icon;
  final Color iconColor;
  final String category;

  const _MarketItem(
      this.name,
      this.symbol,
      this.instrumentKey,
      this.icon,
      this.iconColor, {
        this.category = 'stock',
      });

  factory _MarketItem.fromJson(Map<String, dynamic> json) {
    final String category =
    (json['category'] ?? 'stock').toString().toLowerCase();
    final String symbol = (json['symbol'] ?? json['trading_symbol'] ??
        json['tradingSymbol'] ?? json['short_name'] ?? '').toString().trim();
    final String name = (json['name'] ?? json['company_name'] ??
        json['companyName'] ?? json['display_name'] ?? symbol).toString().trim();
    final String instrumentKey = (json['instrumentKey'] ??
        json['instrument_key'] ?? json['instrument_token'] ??
        json['instrumentToken'] ?? json['key'] ?? '').toString().trim();

    return _MarketItem(
      name.isEmpty ? symbol : name,
      symbol,
      instrumentKey,
      category == 'index' ? Icons.show_chart_rounded : Icons.business_rounded,
      category == 'index'
          ? const Color(0xFFFF9F32)
          : const Color(0xFF4F8CFF),
      category: category,
    );
  }
}

class _PotentialStock {
  final String symbol;
  final String upside;
  final String label;

  const _PotentialStock(this.symbol, this.upside, this.label);
}

class _Action {
  final IconData icon;
  final String label;
  final Color color;

  const _Action(this.icon, this.label, this.color);
}

class _HeroChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _HeroChip({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, color: color, size: 12),
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

class _LockBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.lock_rounded, size: 12, color: cs.primary),
          const SizedBox(width: 4),
          Text(
            'COINS',
            style: GoogleFonts.poppins(
              fontSize: 8,
              fontWeight: FontWeight.w800,
              color: cs.primary,
            ),
          ),
        ],
      ),
    );
  }
}