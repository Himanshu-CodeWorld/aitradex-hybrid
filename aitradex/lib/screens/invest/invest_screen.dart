import 'dart:convert';
import 'dart:ui' as ui;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aitradex/services/market_data_service.dart';
import '../stockDetails/stock_details_screen.dart';
import '../stockDetails/stock_ai_report_question.dart';

/// AiTradeX Invest screen.
///
/// Design goals:
/// - Dark/light mode follows the application's ThemeData.
/// - The app primary color is read from Theme.of(context).
/// - "All trades" and "Past trades" filters are included.
/// - Every opportunity is presented as an AI-locked trade card.
/// - Opening a locked card performs the authoritative server-side
///   100-coin stock unlock.
/// - The server remains responsible for the actual deduction and ledger entry.
/// - After unlocking, the existing AI report questionnaire opens.
/// - The backend unlock endpoint is idempotent, so an already-unlocked
///   stock is never charged twice.
/// - Revealed symbols are cached locally only for the visual state. The
///   backend remains the source of truth for the coin transaction.
class InvestScreen extends StatefulWidget {
  const InvestScreen({super.key});

  @override
  State<InvestScreen> createState() => _InvestScreenState();
}

class _InvestScreenState extends State<InvestScreen> {
  static const String _apiBaseUrl =
      'https://aitradex-api.onrender.com/api';

  static const int _reportCost = 100;
  static const String _revealedKeyPrefix =
      'aitradex_invest_revealed_';

  final TextEditingController _searchController =
  TextEditingController();

  String _selectedTab = 'All trades';
  String _selectedCategory = 'All';
  String _query = '';

  Map<String, MarketQuote> _quotes =
  const <String, MarketQuote>{};

  Set<String> _revealedSymbols = <String>{};

  bool _isLoadingMarketData = true;
  bool _isUnlocking = false;
  String? _marketDataError;

  final List<_InvestAsset> _assets =
  const <_InvestAsset>[
    _InvestAsset(
      name: 'Reliance Industries',
      symbol: 'RELIANCE',
      type: 'Stocks',
      instrumentKey: 'NSE_EQ|INE002A01018',
      icon: Icons.business_rounded,
    ),
    _InvestAsset(
      name: 'HDFC Bank',
      symbol: 'HDFCBANK',
      type: 'Stocks',
      instrumentKey: 'NSE_EQ|INE040A01034',
      icon: Icons.account_balance_rounded,
    ),
    _InvestAsset(
      name: 'Tata Consultancy Services',
      symbol: 'TCS',
      type: 'Stocks',
      instrumentKey: 'NSE_EQ|INE467B01029',
      icon: Icons.code_rounded,
    ),
    _InvestAsset(
      name: 'Infosys',
      symbol: 'INFY',
      type: 'Stocks',
      instrumentKey: 'NSE_EQ|INE009A01021',
      icon: Icons.devices_rounded,
    ),
    _InvestAsset(
      name: 'ICICI Bank',
      symbol: 'ICICIBANK',
      type: 'Stocks',
      instrumentKey: 'NSE_EQ|INE090A01021',
      icon: Icons.account_balance_wallet_rounded,
    ),
    _InvestAsset(
      name: 'Bharti Airtel',
      symbol: 'BHARTIARTL',
      type: 'Stocks',
      instrumentKey: 'NSE_EQ|INE397D01024',
      icon: Icons.cell_tower_rounded,
    ),
    _InvestAsset(
      name: 'ITC',
      symbol: 'ITC',
      type: 'Stocks',
      instrumentKey: 'NSE_EQ|INE154A01025',
      icon: Icons.local_mall_rounded,
    ),
    _InvestAsset(
      name: 'Larsen & Toubro',
      symbol: 'LT',
      type: 'Stocks',
      instrumentKey: 'NSE_EQ|INE018A01030',
      icon: Icons.engineering_rounded,
    ),
    _InvestAsset(
      name: 'State Bank of India',
      symbol: 'SBIN',
      type: 'Stocks',
      instrumentKey: 'NSE_EQ|INE062A01020',
      icon: Icons.account_balance_rounded,
    ),
    _InvestAsset(
      name: 'Tata Steel',
      symbol: 'TATASTEEL',
      type: 'Stocks',
      instrumentKey: 'NSE_EQ|INE081A01020',
      icon: Icons.factory_rounded,
    ),
    _InvestAsset(
      name: 'Bharat Electronics',
      symbol: 'BEL',
      type: 'Stocks',
      instrumentKey: 'NSE_EQ|INE263A01024',
      icon: Icons.memory_rounded,
    ),
    _InvestAsset(
      name: 'NIFTYBEES',
      symbol: 'NIFTYBEES',
      type: 'ETFs',
      instrumentKey: 'NSE_EQ|INF204KB14I2',
      icon: Icons.pie_chart_rounded,
    ),
    _InvestAsset(
      name: 'NIFTY 50',
      symbol: 'NIFTY',
      type: 'Index',
      instrumentKey: 'NSE_INDEX|Nifty 50',
      icon: Icons.auto_graph_rounded,
    ),
    _InvestAsset(
      name: 'Gold',
      symbol: 'GOLD',
      type: 'Commodities',
      icon: Icons.workspace_premium_rounded,
    ),
    _InvestAsset(
      name: 'Crude Oil',
      symbol: 'CRUDEOIL',
      type: 'Commodities',
      icon: Icons.local_fire_department_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadMarketData();
    _loadRevealedSymbols();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMarketData() async {
    if (!mounted) return;

    setState(() {
      _isLoadingMarketData = true;
      _marketDataError = null;
    });

    try {
      final List<String> keys = _assets
          .map((asset) => asset.instrumentKey)
          .whereType<String>()
          .toList();

      final Map<String, MarketQuote> quotes =
      await MarketDataService.fetchMarketData(keys)
          .timeout(const Duration(seconds: 20));

      if (!mounted) return;

      setState(() {
        _quotes = quotes;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _marketDataError = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMarketData = false;
        });
      }
    }
  }

  Future<void> _loadRevealedSymbols() async {
    final User? user =
        FirebaseAuth.instance.currentUser;

    if (user == null) return;

    try {
      final SharedPreferences prefs =
      await SharedPreferences.getInstance();

      final List<String> values =
          prefs.getStringList(
            '$_revealedKeyPrefix${user.uid}',
          ) ??
              <String>[];

      if (!mounted) return;

      setState(() {
        _revealedSymbols =
            values
                .map((value) => value.toUpperCase())
                .toSet();
      });
    } catch (_) {
      // Local visual cache is optional. Backend unlock state is authoritative.
    }
  }

  Future<void> _saveRevealedSymbol(
      String symbol,
      ) async {
    final User? user =
        FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final String normalized =
    symbol.trim().toUpperCase();

    setState(() {
      _revealedSymbols = <String>{
        ..._revealedSymbols,
        normalized,
      };
    });

    try {
      final SharedPreferences prefs =
      await SharedPreferences.getInstance();

      final List<String> values =
      _revealedSymbols.toList()..sort();

      await prefs.setStringList(
        '$_revealedKeyPrefix${user.uid}',
        values,
      );
    } catch (_) {}
  }

  _InvestAsset _withQuote(
      _InvestAsset asset,
      ) {
    final String? key = asset.instrumentKey;

    if (key == null) return asset;

    final MarketQuote? quote = _quotes[key];

    if (quote == null) return asset;

    return asset.copyWith(
      price: MarketDataService.formatPrice(
        quote.lastPrice,
      ),
      change: MarketDataService.formatPercent(
        quote.changePercent,
      ),
      positive: quote.changePercent >= 0,
      rawPrice: quote.lastPrice.toDouble(),
    );
  }

  List<_InvestAsset> get _visibleAssets {
    final String query =
    _query.trim().toLowerCase();

    return _assets
        .where((asset) {
      final bool categoryMatch =
          _selectedCategory == 'All' ||
              asset.type == _selectedCategory;

      final bool queryMatch =
          query.isEmpty ||
              asset.name.toLowerCase().contains(query) ||
              asset.symbol.toLowerCase().contains(query);

      final bool tabMatch =
          _selectedTab == 'All trades' ||
              _revealedSymbols.contains(
                asset.symbol.toUpperCase(),
              );

      return categoryMatch &&
          queryMatch &&
          tabMatch;
    })
        .map(_withQuote)
        .toList();
  }

  Future<void> _openAsset(
      _InvestAsset asset,
      ) async {
    HapticFeedback.mediumImpact();

    if (_revealedSymbols.contains(
      asset.symbol.toUpperCase(),
    )) {
      _openUnlockedStock(asset);
      return;
    }

    await _showUnlockSheet(asset);
  }

  Future<void> _openUnlockedStock(
      _InvestAsset asset,
      ) async {
    final double price =
        asset.rawPrice ??
            _parsePrice(asset.price);

    await Get.to(
          () => StockDetailsScreen(
        company: asset.name,
        symbol: asset.symbol,
        price: asset.price,
        percent: asset.change,
        shares: '0 shares',
        avgCost: '₹0.00',
        equity: '₹0.00',
        totalReturns: '₹0.00',
        isPositive: asset.positive,
      ),
      transition: Transition.cupertino,
    );

    if (mounted) {
      await _loadMarketData();
    }
  }

  double _parsePrice(String value) {
    final String cleaned = value
        .replaceAll('₹', '')
        .replaceAll(',', '')
        .trim();

    return double.tryParse(cleaned) ?? 0;
  }

  Future<void> _showUnlockSheet(
      _InvestAsset asset,
      ) async {
    final ColorScheme colors =
        Theme.of(context).colorScheme;

    final _UnlockResult? result =
    await Get.bottomSheet<_UnlockResult>(
      _AiTradeUnlockSheet(
        asset: asset,
        reportCost: _reportCost,
        apiBaseUrl: _apiBaseUrl,
        primary: colors.primary,
        onUnlock: () => _unlockStock(asset),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enterBottomSheetDuration:
      const Duration(milliseconds: 240),
      exitBottomSheetDuration:
      const Duration(milliseconds: 180),
    );

    if (result != null && mounted) {
      await _loadRevealedSymbols();

      await Get.to(
            () => StockAiReportScreen(
          company: asset.name,
          symbol: asset.symbol,
          report: result.report,
          remainingCoins: result.remainingCoins,
        ),
        transition: Transition.cupertino,
      );

      await _loadMarketData();
    }
  }

  Future<_UnlockResult?> _unlockStock(
      _InvestAsset asset,
      ) async {
    if (_isUnlocking) return null;

    final User? user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      Get.snackbar(
        'Sign in required',
        'Please sign in again to unlock AI stock reports.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }

    setState(() {
      _isUnlocking = true;
    });

    try {
      final String? token =
      await user.getIdToken(true);

      if (token == null || token.isEmpty) {
        throw Exception(
          'Authentication expired. Please sign in again.',
        );
      }

      // Generate the AI report before charging. If the AI request fails,
      // the user keeps the 100 coins.
      final String report =
      await _generateAiTradeReport(
        asset: asset,
        token: token,
      );

      final http.Response response =
      await http.post(
        Uri.parse(
          '$_apiBaseUrl/coins/unlock-stock',
        ),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          <String, dynamic>{
            'symbol': asset.symbol,
          },
        ),
      ).timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw Exception(
          'Unlock request timed out. Check your coin balance before retrying.',
        ),
      );

      dynamic decoded;

      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        decoded = null;
      }

      if (response.statusCode == 402) {
        final int balance =
        _extractBalance(decoded);

        Get.snackbar(
          'Not enough AiTradeX Coins',
          'You need $_reportCost coins. Current balance: $balance.',
          snackPosition: SnackPosition.BOTTOM,
        );

        return null;
      }

      if (response.statusCode == 401 ||
          response.statusCode == 403) {
        throw Exception(
          decoded is Map
              ? decoded['message']?.toString() ??
              'Authentication failed.'
              : 'Authentication failed.',
        );
      }

      if (response.statusCode != 200) {
        throw Exception(
          decoded is Map
              ? decoded['message']?.toString() ??
              'Unable to unlock this AI report.'
              : 'Unable to unlock this AI report.',
        );
      }

      final int remainingCoins =
      _extractBalance(decoded);

      await _saveCompletedInvestReport(
        asset: asset,
        report: report,
        remainingCoins: remainingCoins,
      );

      await _saveRevealedSymbol(
        asset.symbol,
      );

      final bool alreadyUnlocked =
          decoded is Map &&
              (decoded['alreadyUnlocked'] == true ||
                  (decoded['data'] is Map &&
                      decoded['data']['alreadyUnlocked'] ==
                          true));

      Get.snackbar(
        alreadyUnlocked
            ? 'AI report unlocked'
            : '100 coins deducted',
        alreadyUnlocked
            ? '${asset.symbol} was already unlocked.'
            : '100 coins deducted. Remaining balance: $remainingCoins.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

      return _UnlockResult(
        report: report,
        remainingCoins: remainingCoins,
      );
    } catch (error) {
      Get.snackbar(
        'Unable to unlock report',
        error
            .toString()
            .replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } finally {
      if (mounted) {
        setState(() {
          _isUnlocking = false;
        });
      }
    }
  }

  Future<String> _generateAiTradeReport({
    required _InvestAsset asset,
    required String token,
  }) async {
    final double currentPrice =
        asset.rawPrice ??
            _parsePrice(asset.price);

    final String message = '''
Create an AiTradeX premium stock intelligence report.

Stock:
${asset.name} (${asset.symbol})

Current market price:
₹${currentPrice.toStringAsFixed(2)}

User context:
The user is reviewing this stock as a possible investment.
Do not assume that the user already owns the stock.
Use a medium-term research horizon of approximately 3-12 months.

Return a concise but useful report with these sections:
1. AI Prediction: clearly state Buy, Wait, or Avoid as an AI research signal.
2. Why this signal: 3-5 evidence-based points.
3. Potential upside / downside considerations.
4. Possible buying range or entry considerations, if supported by the available information.
5. Target / scenario discussion without presenting certainty.
6. Key risks.
7. What to monitor next.
8. Final summary.

Clearly say that this is AI-generated research, not guaranteed financial advice,
and that the user should make their own investment decision.
''';

    final http.Response response =
    await http.post(
      Uri.parse('$_apiBaseUrl/ai/chat'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(
        <String, dynamic>{
          'message': message,
          'userId': userIdForAiReport,
          'expenses': <dynamic>[],
          'income': 0,
        },
      ),
    ).timeout(
      const Duration(seconds: 45),
      onTimeout: () => throw Exception(
        'AI report generation timed out. No coins should be charged. Please retry.',
      ),
    );

    dynamic decoded;

    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      decoded = null;
    }

    if (response.statusCode != 200) {
      throw Exception(
        decoded is Map
            ? decoded['message']?.toString() ??
            'AI report generation failed.'
            : 'AI report generation failed.',
      );
    }

    final String report =
    _extractAiReportText(decoded);

    if (report.trim().isEmpty) {
      throw Exception(
        'AI returned an empty stock report. Please try again.',
      );
    }

    return report.trim();
  }

  String get userIdForAiReport {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  String _extractAiReportText(dynamic decoded) {
    if (decoded is String) {
      return decoded;
    }

    if (decoded is Map) {
      final List<dynamic> candidates =
      <dynamic>[
        decoded['reply'],
        decoded['message'],
        decoded['response'],
        decoded['content'],
        decoded['text'],
        decoded['answer'],
        if (decoded['data'] is Map)
          decoded['data']['reply'],
        if (decoded['data'] is Map)
          decoded['data']['message'],
        if (decoded['data'] is Map)
          decoded['data']['response'],
        if (decoded['data'] is Map)
          decoded['data']['content'],
      ];

      for (final dynamic candidate in candidates) {
        if (candidate is String &&
            candidate.trim().isNotEmpty) {
          return candidate;
        }
      }

      final dynamic choices = decoded['choices'];

      if (choices is List &&
          choices.isNotEmpty) {
        final dynamic first = choices.first;

        if (first is Map) {
          final dynamic message =
          first['message'];

          if (message is Map &&
              message['content'] is String) {
            return message['content'].toString();
          }

          if (first['text'] is String) {
            return first['text'].toString();
          }
        }
      }
    }

    return '';
  }

  Future<void> _saveCompletedInvestReport({
    required _InvestAsset asset,
    required String report,
    required int remainingCoins,
  }) async {
    final User? user =
        FirebaseAuth.instance.currentUser;

    final String? uid = user?.uid;

    if (uid == null || uid.trim().isEmpty) {
      return;
    }

    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    final String key =
        'aitradex_my_reports_${uid.trim()}';

    final List<String> raw =
        prefs.getStringList(key) ??
            <String>[];

    final List<Map<String, dynamic>> reports =
    <Map<String, dynamic>>[];

    for (final String item in raw) {
      try {
        final dynamic decoded =
        jsonDecode(item);

        if (decoded is Map) {
          reports.add(
            Map<String, dynamic>.from(decoded),
          );
        }
      } catch (_) {}
    }

    reports.removeWhere(
          (item) =>
      item['symbol']
          ?.toString()
          .toUpperCase() ==
          asset.symbol.toUpperCase(),
    );

    final DateTime now = DateTime.now();

    String twoDigits(int value) =>
        value.toString().padLeft(2, '0');

    const List<String> months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final String date =
        '${twoDigits(now.day)} ${months[now.month - 1]} '
        '${now.year}, ${twoDigits(now.hour)}:${twoDigits(now.minute)}';

    reports.insert(
      0,
      <String, dynamic>{
        'symbol': asset.symbol,
        'company': asset.name,
        'logo': asset.symbol.length >= 3
            ? asset.symbol.substring(0, 3)
            : asset.symbol,
        'date': date,
        'report': report,
        'remainingCoins': remainingCoins,
      },
    );

    if (reports.length > 30) {
      reports.removeRange(
        30,
        reports.length,
      );
    }

    await prefs.setStringList(
      key,
      reports
          .map(
            (item) => jsonEncode(item),
      )
          .toList(),
    );
  }

  int _extractBalance(dynamic decoded) {
    if (decoded is Map) {
      final dynamic direct =
          decoded['remainingCoins'] ??
              decoded['balance'];

      if (direct is num) {
        return direct.toInt();
      }

      final dynamic data = decoded['data'];

      if (data is Map) {
        final dynamic nested =
            data['remainingCoins'] ??
                data['balance'];

        if (nested is num) {
          return nested.toInt();
        }

        final dynamic wallet = data['wallet'];

        if (wallet is Map &&
            wallet['balance'] is num) {
          return (wallet['balance'] as num).toInt();
        }
      }
    }

    return 0;
  }

  void _selectTab(String tab) {
    HapticFeedback.selectionClick();

    setState(() {
      _selectedTab = tab;
    });
  }

  void _selectCategory(String category) {
    HapticFeedback.selectionClick();

    setState(() {
      _selectedCategory = category;
    });
  }

  String _potentialLabel(
      _InvestAsset asset,
      ) {
    final double? change =
    _quotes[asset.instrumentKey]?.changePercent
        .toDouble();

    if (change == null) {
      return 'AI opportunity';
    }

    if (change >= 0) {
      return 'Positive momentum';
    }

    return 'Recovery setup';
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme =
    Theme.of(context);

    final ColorScheme colors =
        theme.colorScheme;

    final bool isDark =
        theme.brightness == Brightness.dark;

    final List<_InvestAsset> assets =
        _visibleAssets;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
        isDark
            ? Brightness.light
            : Brightness.dark,
        statusBarBrightness:
        isDark
            ? Brightness.dark
            : Brightness.light,
        systemNavigationBarColor:
        theme.scaffoldBackgroundColor,
        systemNavigationBarIconBrightness:
        isDark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor:
        theme.scaffoldBackgroundColor,
        body: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            color: colors.primary,
            backgroundColor: colors.surface,
            onRefresh: () async {
              await _loadMarketData();
              await _loadRevealedSymbols();
            },
            child: CustomScrollView(
              physics:
              const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: _InvestTopHeader(
                    selectedTab: _selectedTab,
                    onBack: () => Get.back(),
                    onTabSelected: _selectTab,
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                    const EdgeInsets.fromLTRB(
                      20,
                      12,
                      20,
                      0,
                    ),
                    child: _TradeFilterBar(
                      selectedTab: _selectedTab,
                      onTabChanged: _selectTab,
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                    const EdgeInsets.fromLTRB(
                      20,
                      12,
                      20,
                      0,
                    ),
                    child: _InvestSearchField(
                      controller:
                      _searchController,
                      query: _query,
                      onChanged: (value) {
                        setState(() {
                          _query = value;
                        });
                      },
                      onClear: () {
                        _searchController.clear();
                        setState(() {
                          _query = '';
                        });
                      },
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                    const EdgeInsets.fromLTRB(
                      20,
                      15,
                      20,
                      0,
                    ),
                    child: _AiTradeBanner(
                      primary: colors.primary,
                      isDark: isDark,
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                    const EdgeInsets.fromLTRB(
                      20,
                      18,
                      20,
                      4,
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            _selectedTab ==
                                'Past trades'
                                ? 'Past AI trades'
                                : 'AI trade opportunities',
                            style:
                            GoogleFonts.poppins(
                              fontSize: 19,
                              fontWeight:
                              FontWeight.w800,
                              color: colors.onSurface,
                            ),
                          ),
                        ),
                        if (_isLoadingMarketData)
                          SizedBox(
                            width: 18,
                            height: 18,
                            child:
                            CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.primary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                if (_marketDataError != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                      const EdgeInsets.fromLTRB(
                        20,
                        5,
                        20,
                        4,
                      ),
                      child: Text(
                        'Live market data is temporarily unavailable.',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: colors.error,
                        ),
                      ),
                    ),
                  ),

                if (assets.isEmpty)
                  SliverToBoxAdapter(
                    child: _EmptyTradeState(
                      pastTrades:
                      _selectedTab ==
                          'Past trades',
                    ),
                  )
                else
                  SliverPadding(
                    padding:
                    const EdgeInsets.fromLTRB(
                      20,
                      8,
                      20,
                      120,
                    ),
                    sliver:
                    SliverList.separated(
                      itemCount: assets.length,
                      separatorBuilder:
                          (_, __) =>
                      const SizedBox(
                        height: 14,
                      ),
                      itemBuilder:
                          (context, index) {
                        final _InvestAsset asset =
                        assets[index];

                        final bool revealed =
                        _revealedSymbols
                            .contains(
                          asset.symbol
                              .toUpperCase(),
                        );

                        return _AiTradeCard(
                          asset: asset,
                          revealed: revealed,
                          potentialLabel:
                          _potentialLabel(
                            asset,
                          ),
                          primary:
                          colors.primary,
                          onTap: () =>
                              _openAsset(asset),
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

class _InvestTopHeader extends StatelessWidget {
  final String selectedTab;
  final ValueChanged<String> onTabSelected;
  final VoidCallback onBack;

  const _InvestTopHeader({
    required this.selectedTab,
    required this.onTabSelected,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors =
        Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        14,
        20,
        6,
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
            ),
            color: colors.onSurface,
            tooltip: 'Back',
          ),
          Expanded(
            child: SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics:
                const BouncingScrollPhysics(),
                children: <Widget>[
                  _TopTab(
                    label: 'Stocks',
                    selected: true,
                    primary: colors.primary,
                    onTap: () =>
                        onTabSelected(
                          'All trades',
                        ),
                  ),
                  const SizedBox(width: 10),
                  _TopTab(
                    label: 'F&O',
                    selected: false,
                    primary: colors.primary,
                    onTap: () {},
                  ),
                  const SizedBox(width: 10),
                  _TopTab(
                    label: 'Baskets',
                    selected: false,
                    primary: colors.primary,
                    onTap: () {},
                  ),
                  const SizedBox(width: 10),
                  _TopTab(
                    label: 'AI Trades',
                    selected: false,
                    primary: colors.primary,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopTab extends StatelessWidget {
  final String label;
  final bool selected;
  final Color primary;
  final VoidCallback onTap;

  const _TopTab({
    required this.label,
    required this.selected,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors =
        Theme.of(context).colorScheme;

    return Material(
      color: selected
          ? primary
          : colors.surfaceContainerHighest
          .withValues(alpha: .55),
      borderRadius:
      BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(16),
        child: Padding(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 13,
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: selected
                  ? colors.onPrimary
                  : colors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _TradeFilterBar extends StatelessWidget {
  final String selectedTab;
  final ValueChanged<String> onTabChanged;

  const _TradeFilterBar({
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors =
        Theme.of(context).colorScheme;

    return Row(
      children: <Widget>[
        Expanded(
          child: _TradeFilterPill(
            label: 'All trades',
            selected: selectedTab == 'All trades',
            icon: Icons.keyboard_arrow_down_rounded,
            onTap: () => onTabChanged('All trades'),
          ),
        ),
        const SizedBox(width: 9),
        Container(
          width: 70,
          height: 48,
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest
                .withValues(alpha: .68),
            borderRadius:
            BorderRadius.circular(25),
          ),
          child: Icon(
            Icons.view_carousel_rounded,
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _TradeFilterPill(
            label: 'Past trades',
            selected: selectedTab == 'Past trades',
            icon: Icons.history_rounded,
            onTap: () => onTabChanged('Past trades'),
          ),
        ),
      ],
    );
  }
}

class _TradeFilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final IconData icon;
  final VoidCallback onTap;

  const _TradeFilterPill({
    required this.label,
    required this.selected,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors =
        Theme.of(context).colorScheme;

    return Material(
      color: selected
          ? colors.surfaceContainerHighest
          .withValues(alpha: .82)
          : Colors.transparent,
      borderRadius:
      BorderRadius.circular(25),
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(25),
        child: Container(
          height: 48,
          padding:
          const EdgeInsets.symmetric(
            horizontal: 14,
          ),
          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(25),
            border: Border.all(
              color: selected
                  ? Colors.transparent
                  : colors.outline
                  .withValues(alpha: .45),
            ),
          ),
          child: Row(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: <Widget>[
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color:
                    colors.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                icon,
                size: 18,
                color: selected
                    ? colors.primary
                    : colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InvestSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _InvestSearchField({
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors =
        Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText:
        'Search stocks, ETFs or commodities',
        prefixIcon:
        const Icon(Icons.search_rounded),
        suffixIcon: query.isEmpty
            ? null
            : IconButton(
          onPressed: onClear,
          icon: const Icon(
            Icons.close_rounded,
          ),
        ),
        filled: true,
        fillColor: colors
            .surfaceContainerHighest
            .withValues(alpha: .58),
        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _AiTradeBanner extends StatelessWidget {
  final Color primary;
  final bool isDark;

  const _AiTradeBanner({
    required this.primary,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors =
        Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: <Color>[
            primary,
            Color.lerp(
              primary,
              isDark
                  ? Colors.black
                  : Colors.white,
              isDark ? .25 : .08,
            )!,
          ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color:
            primary.withValues(alpha: .18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color:
              Colors.white.withValues(
                alpha: .14,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 25,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'AiTradeX AI Trades',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Unlock an AI stock report for 100 coins.',
                  style: GoogleFonts.poppins(
                    color: Colors.white
                        .withValues(alpha: .82),
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white,
            size: 17,
          ),
        ],
      ),
    );
  }
}

class _AiTradeCard extends StatelessWidget {
  final _InvestAsset asset;
  final bool revealed;
  final String potentialLabel;
  final Color primary;
  final VoidCallback onTap;

  const _AiTradeCard({
    required this.asset,
    required this.revealed,
    required this.potentialLabel,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors =
        Theme.of(context).colorScheme;

    final bool positive = asset.positive;
    final Color movementColor =
    positive ? primary : colors.error;

    return Material(
      color: Colors.transparent,
      borderRadius:
      BorderRadius.circular(28),
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(28),
        child: ClipRRect(
          borderRadius:
          BorderRadius.circular(28),
          child: Container(
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest
                  .withValues(
                alpha:
                colors.brightness ==
                    Brightness.dark
                    ? .65
                    : .82,
              ),
              border: Border.all(
                color: colors.outline
                    .withValues(alpha: .11),
              ),
            ),
            child: Stack(
              children: <Widget>[
                if (revealed)
                  _RevealedTradeContent(
                    asset: asset,
                    potentialLabel:
                    potentialLabel,
                    primary: primary,
                    movementColor:
                    movementColor,
                  )
                else
                  _LockedTradeContent(
                    asset: asset,
                    primary: primary,
                    movementColor:
                    movementColor,
                  ),

                Positioned(
                  top: 0,
                  right: 0,
                  child: _TradeTypeBadge(
                    label: _tradeType(asset),
                    primary: primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _tradeType(_InvestAsset asset) {
    if (asset.type == 'Stocks') {
      return asset.symbol == 'TCS' ||
          asset.symbol == 'INFY'
          ? 'Medium term'
          : 'AI Trade';
    }

    return asset.type;
  }
}

class _LockedTradeContent extends StatelessWidget {
  final _InvestAsset asset;
  final Color primary;
  final Color movementColor;

  const _LockedTradeContent({
    required this.asset,
    required this.primary,
    required this.movementColor,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors =
        Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        28,
        18,
        14,
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  ClipOval(
                    child: ImageFiltered(
                      imageFilter:
                      ui.ImageFilter.blur(
                        sigmaX: 7,
                        sigmaY: 7,
                      ),
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: primary
                              .withValues(alpha: .13),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          asset.icon,
                          color: movementColor,
                          size: 27,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: colors.surface
                          .withValues(alpha: .58),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: primary
                            .withValues(alpha: .38),
                      ),
                    ),
                    child: Icon(
                      Icons.lock_rounded,
                      color: primary,
                      size: 23,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 13),
              Expanded(
                child: ImageFiltered(
                  imageFilter:
                  ui.ImageFilter.blur(
                    sigmaX: 6,
                    sigmaY: 6,
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        asset.name,
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight:
                          FontWeight.w800,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${asset.symbol} • ${asset.type}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: colors
                              .onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            height: 76,
            width: double.infinity,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: .10),
              borderRadius:
              BorderRadius.circular(18),
              border: Border.all(
                color:
                primary.withValues(alpha: .32),
              ),
            ),
            child: Center(
              child: ImageFiltered(
                imageFilter:
                ui.ImageFilter.blur(
                  sigmaX: 5,
                  sigmaY: 5,
                ),
                child: Text(
                  'Potential left    •••',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight:
                    FontWeight.w800,
                    color: primary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 13),
          Row(
            children: <Widget>[
              Expanded(
                child: _MiniBlurValue(
                  title: 'Buying range',
                  value: '₹••••',
                ),
              ),
              _VerticalDivider(),
              Expanded(
                child: _MiniBlurValue(
                  title: 'Target',
                  value: '₹••••',
                ),
              ),
              _VerticalDivider(),
              Expanded(
                child: _MiniBlurValue(
                  title: 'Returns',
                  value: '••%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: colors.onSurface
                  .withValues(alpha: .035),
              borderRadius:
              BorderRadius.circular(15),
            ),
            child: Row(
              children: <Widget>[
                const SizedBox(width: 14),
                Icon(
                  Icons.auto_awesome_rounded,
                  color: primary,
                  size: 20,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'AI prediction is locked',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight:
                      FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),
                ),
                _CoinBadge(
                  coins: 100,
                  primary: primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 13),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Buy / Wait / Avoid • AI report',
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    color:
                    colors.onSurfaceVariant,
                    fontWeight:
                    FontWeight.w500,
                  ),
                ),
              ),
              _TapToReveal(primary: primary),
            ],
          ),
        ],
      ),
    );
  }
}

class _RevealedTradeContent extends StatelessWidget {
  final _InvestAsset asset;
  final String potentialLabel;
  final Color primary;
  final Color movementColor;

  const _RevealedTradeContent({
    required this.asset,
    required this.potentialLabel,
    required this.primary,
    required this.movementColor,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors =
        Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        28,
        18,
        15,
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color:
                  primary.withValues(alpha: .12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: primary
                        .withValues(alpha: .28),
                  ),
                ),
                child: Icon(
                  asset.icon,
                  color: movementColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      asset.name,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight:
                        FontWeight.w800,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${asset.symbol} • ${asset.price}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color:
                        colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: movementColor
                      .withValues(alpha: .11),
                  borderRadius:
                  BorderRadius.circular(10),
                ),
                child: Text(
                  asset.change,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight:
                    FontWeight.w800,
                    color: movementColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 13,
            ),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: .10),
              borderRadius:
              BorderRadius.circular(17),
              border: Border.all(
                color:
                primary.withValues(alpha: .30),
              ),
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.trending_up_rounded,
                  color: primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    potentialLabel,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight:
                      FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),
                ),
                Text(
                  'Unlocked',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight:
                    FontWeight.w800,
                    color: primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 13),
          Row(
            children: <Widget>[
              Expanded(
                child: _InfoValue(
                  title: 'Market',
                  value: asset.price,
                ),
              ),
              _VerticalDivider(),
              Expanded(
                child: _InfoValue(
                  title: 'Signal',
                  value: 'AI report',
                ),
              ),
              _VerticalDivider(),
              Expanded(
                child: _InfoValue(
                  title: 'Access',
                  value: '100 coins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                // The parent card callback is intentionally used for both
                // locked and unlocked states.
              },
              icon: Icon(
                Icons.check_circle_rounded,
                size: 18,
              ),
              label: const Text('AI report unlocked'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniBlurValue extends StatelessWidget {
  final String title;
  final String value;

  const _MiniBlurValue({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors =
        Theme.of(context).colorScheme;

    return Column(
      mainAxisAlignment:
      MainAxisAlignment.center,
      children: <Widget>[
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 5),
        ImageFiltered(
          imageFilter:
          ui.ImageFilter.blur(
            sigmaX: 5,
            sigmaY: 5,
          ),
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoValue extends StatelessWidget {
  final String title;
  final String value;

  const _InfoValue({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors =
        Theme.of(context).colorScheme;

    return Column(
      children: <Widget>[
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: colors.onSurface,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ColorScheme colors =
        Theme.of(context).colorScheme;

    return Container(
      width: 1,
      height: 38,
      color: colors.outline
          .withValues(alpha: .18),
    );
  }
}

class _TapToReveal extends StatelessWidget {
  final Color primary;

  const _TapToReveal({
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          Icons.chevron_left_rounded,
          color: primary,
          size: 21,
        ),
        Text(
          'Tap to reveal',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: primary,
          ),
        ),
        Icon(
          Icons.chevron_right_rounded,
          color: primary,
          size: 21,
        ),
      ],
    );
  }
}

class _TradeTypeBadge extends StatelessWidget {
  final String label;
  final Color primary;

  const _TradeTypeBadge({
    required this.label,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors =
        Theme.of(context).colorScheme;

    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: colors.onSurface
            .withValues(alpha: .10),
        borderRadius:
        const BorderRadius.only(
          bottomLeft: Radius.circular(18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _CoinBadge extends StatelessWidget {
  final int coins;
  final Color primary;

  const _CoinBadge({
    required this.coins,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors =
        Theme.of(context).colorScheme;

    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: .11),
        borderRadius:
        BorderRadius.circular(11),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.monetization_on_rounded,
            size: 16,
            color: primary,
          ),
          const SizedBox(width: 4),
          Text(
            '$coins',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _UnlockResult {
  final String report;
  final int remainingCoins;

  const _UnlockResult({
    required this.report,
    required this.remainingCoins,
  });
}

class _AiTradeUnlockSheet extends StatefulWidget {
  final _InvestAsset asset;
  final int reportCost;
  final String apiBaseUrl;
  final Color primary;
  final Future<_UnlockResult?> Function() onUnlock;

  const _AiTradeUnlockSheet({
    required this.asset,
    required this.reportCost,
    required this.apiBaseUrl,
    required this.primary,
    required this.onUnlock,
  });

  @override
  State<_AiTradeUnlockSheet> createState() =>
      _AiTradeUnlockSheetState();
}

class _AiTradeUnlockSheetState
    extends State<_AiTradeUnlockSheet> {
  bool _loading = false;
  int? _balance;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    try {
      final User? user =
          FirebaseAuth.instance.currentUser;

      if (user == null) return;

      final String? token =
      await user.getIdToken(true);

      if (token == null || token.isEmpty) return;

      final http.Response response =
      await http.get(
        Uri.parse(
          '${widget.apiBaseUrl}/coins/balance',
        ),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      dynamic data;

      try {
        data = jsonDecode(response.body);
      } catch (_) {
        data = null;
      }

      if (!mounted) return;

      setState(() {
        _balance = _extractBalance(data);
      });
    } catch (_) {}
  }

  int _extractBalance(dynamic data) {
    if (data is Map) {
      final dynamic direct =
          data['balance'] ??
              data['remainingCoins'];

      if (direct is num) {
        return direct.toInt();
      }

      final dynamic nested = data['data'];

      if (nested is Map) {
        final dynamic value =
            nested['balance'] ??
                nested['remainingCoins'];

        if (value is num) {
          return value.toInt();
        }
      }
    }

    return 0;
  }

  Future<void> _unlock() async {
    if (_loading) return;

    if ((_balance ?? 0) < widget.reportCost) {
      Get.snackbar(
        'Insufficient coins',
        'You need ${widget.reportCost} AiTradeX Coins to reveal this report.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final _UnlockResult? result =
      await widget.onUnlock();

      if (!mounted) return;

      if (result != null) {
        Get.back(result: result);
        return;
      }

      setState(() {
        _loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors =
        Theme.of(context).colorScheme;

    final bool enoughCoins =
        (_balance ?? 0) >= widget.reportCost;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          20,
          10,
          20,
          24,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius:
          const BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: colors.outline
                    .withValues(alpha: .25),
                borderRadius:
                BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: widget.primary
                    .withValues(alpha: .12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_open_rounded,
                color: widget.primary,
                size: 30,
              ),
            ),
            const SizedBox(height: 13),
            Text(
              'Reveal ${widget.asset.symbol} AI trade',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'AiTradeX will unlock the stock report and AI prediction access for this stock.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11.5,
                height: 1.5,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding:
              const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest
                    .withValues(alpha: .6),
                borderRadius:
                BorderRadius.circular(18),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: _SheetValue(
                      title: 'Cost',
                      value:
                      '${widget.reportCost} coins',
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 34,
                    color: colors.outline
                        .withValues(alpha: .2),
                  ),
                  Expanded(
                    child: _SheetValue(
                      title: 'Balance',
                      value: _balance == null
                          ? 'Loading…'
                          : '$_balance coins',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 13),
            if (!enoughCoins &&
                _balance != null)
              Align(
                alignment:
                Alignment.centerLeft,
                child: Text(
                  'Add coins to continue.',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colors.error,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed:
                _loading || !enoughCoins
                    ? null
                    : _unlock,
                icon: _loading
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(
                  Icons.auto_awesome_rounded,
                ),
                label: Text(
                  _loading
                      ? 'Unlocking…'
                      : 'Reveal for ${widget.reportCost} Coins',
                ),
              ),
            ),
            const SizedBox(height: 9),
            Text(
              'AI-generated information is for research and education and is not guaranteed financial advice.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 9.5,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetValue extends StatelessWidget {
  final String title;
  final String value;

  const _SheetValue({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors =
        Theme.of(context).colorScheme;

    return Column(
      children: <Widget>[
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: colors.onSurface,
          ),
        ),
      ],
    );
  }
}

class _EmptyTradeState extends StatelessWidget {
  final bool pastTrades;

  const _EmptyTradeState({
    required this.pastTrades,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors =
        Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        30,
        55,
        30,
        130,
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              color: colors.primary
                  .withValues(alpha: .10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              pastTrades
                  ? Icons.history_rounded
                  : Icons.search_off_rounded,
              size: 34,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            pastTrades
                ? 'No past AI trades yet'
                : 'No AI trades found',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            pastTrades
                ? 'Reveal a stock report and it will appear here.'
                : 'Try another search or category.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              height: 1.5,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _InvestAsset {
  final String name;
  final String symbol;
  final String type;
  final String price;
  final String change;
  final bool positive;
  final IconData icon;
  final String? instrumentKey;
  final double? rawPrice;

  const _InvestAsset({
    required this.name,
    required this.symbol,
    required this.type,
    this.price = '—',
    this.change = '—',
    this.positive = true,
    required this.icon,
    this.instrumentKey,
    this.rawPrice,
  });

  _InvestAsset copyWith({
    String? price,
    String? change,
    bool? positive,
    double? rawPrice,
  }) {
    return _InvestAsset(
      name: name,
      symbol: symbol,
      type: type,
      price: price ?? this.price,
      change: change ?? this.change,
      positive: positive ?? this.positive,
      icon: icon,
      instrumentKey: instrumentKey,
      rawPrice: rawPrice ?? this.rawPrice,
    );
  }
}
