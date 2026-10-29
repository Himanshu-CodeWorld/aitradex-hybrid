import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/upstox_service.dart';

/// AiTradeX saved-report details screen.
///
/// Data flow:
///   My Reports -> MyReportsScreen -> UpstoxService.getReport()
///   -> AiTradeX backend -> Upstox
///
/// No Upstox secret or access token is stored in this screen.
class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({
    super.key,
    required this.symbol,
    required this.date,
    this.logo = '',
    this.company = '',
    this.report = '',
    this.remainingCoins = 0,
    this.instrumentKey,
    this.isin,
    this.onBuy,
  });

  final String symbol;
  final String date;
  final String logo;
  final String company;
  final String report;
  final int remainingCoins;
  final String? instrumentKey;
  final String? isin;
  final VoidCallback? onBuy;

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  Map<String, dynamic>? _data;
  Object? _error;
  bool _loading = true;

  bool _financialsOpen = true;
  bool _priceVolumeOpen = true;
  bool _shareholdingOpen = true;
  bool _fundamentalsOpen = true;

  bool _revenueSelected = true;
  bool _yearlySelected = true;
  bool _returnsSelected = true;

  ThemeData get _theme => Theme.of(context);
  ColorScheme get _colors => _theme.colorScheme;
  Color get _primary => _colors.primary;
  Color get _background => _theme.scaffoldBackgroundColor;
  Color get _surface => _colors.surface;
  Color get _text => _colors.onSurface;
  Color get _muted => _colors.onSurface.withValues(alpha: .58);
  bool get _dark => _theme.brightness == Brightness.dark;

  Color get _secondary {
    final hsl = HSLColor.fromColor(_primary);
    return hsl
        .withHue((hsl.hue + 38) % 360)
        .withSaturation((hsl.saturation + .08).clamp(0.0, 1.0).toDouble())
        .withLightness(_dark ? .58 : .48)
        .toColor();
  }

  LinearGradient get _gradient => LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[_primary, _secondary],
  );

  Map<String, dynamic> get _root {
    final response = _data ?? const <String, dynamic>{};
    final payload = _map(response['data']);

    // Your backend may wrap the report inside `data`.
    // Use the payload when it contains report fields; otherwise use the
    // response itself.
    if (payload.isNotEmpty &&
        (payload.containsKey('quote') ||
            payload.containsKey('financials') ||
            payload.containsKey('ratios') ||
            payload.containsKey('shareholding') ||
            payload.containsKey('returns') ||
            payload.containsKey('volumes'))) {
      return payload;
    }

    return response;
  }

  Map<String, dynamic> _map(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  dynamic _first(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      if (map.containsKey(key) && map[key] != null) return map[key];
    }
    return null;
  }

  double _num(dynamic value, [double fallback = 0]) {
    if (value is num) return value.toDouble();
    if (value == null) return fallback;
    final cleaned = value
        .toString()
        .replaceAll(',', '')
        .replaceAll('₹', '')
        .replaceAll('%', '')
        .trim();
    return double.tryParse(cleaned) ?? fallback;
  }

  String _string(dynamic value, [String fallback = '']) {
    if (value == null) return fallback;
    return value.toString().trim();
  }

  Map<String, dynamic> get _quote {
    final quote = _map(_root['quote']);
    if (quote.isNotEmpty) return quote;

    final market = _map(_root['market']);
    if (market.isNotEmpty) return market;

    return _map(_root['data']);
  }

  Map<String, dynamic> get _ratios {
    final ratios = _map(
      _first(_root, <String>['ratios', 'ratio', 'fundamentals']),
    );
    return ratios;
  }

  Map<String, dynamic> get _financials {
    return _map(
      _first(_root, <String>['financials', 'financial', 'income_statement']),
    );
  }

  List<Map<String, dynamic>> _listMaps(dynamic value) {
    if (value is! List) return <Map<String, dynamic>>[];

    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  List<Map<String, dynamic>> _history(String type) {
    final financials = _financials;

    dynamic raw;
    if (_yearlySelected) {
      raw = type == 'revenue'
          ? _first(financials, <String>[
        'yearlyRevenue',
        'revenue',
        'annualRevenue',
      ])
          : _first(financials, <String>[
        'yearlyNetProfit',
        'netProfit',
        'annualNetProfit',
      ]);
    } else {
      raw = type == 'revenue'
          ? _first(financials, <String>['quarterlyRevenue', 'revenueQuarterly'])
          : _first(financials, <String>[
        'quarterlyNetProfit',
        'netProfitQuarterly',
      ]);
    }

    if (raw is List) return _listMaps(raw);

    final nested = _map(raw);
    if (nested.isNotEmpty) {
      return nested.entries.map((entry) {
        return <String, dynamic>{'period': entry.key, 'value': entry.value};
      }).toList();
    }

    return <Map<String, dynamic>>[];
  }

  List<Map<String, dynamic>> get _returns {
    final raw = _first(_root, <String>[
      'returns',
      'historicalReturns',
      'pastReturns',
    ]);

    if (raw is List) return _listMaps(raw);

    final map = _map(raw);
    if (map.isEmpty) return <Map<String, dynamic>>[];

    return map.entries
        .map(
          (entry) => <String, dynamic>{
        'period': entry.key,
        'value': entry.value,
      },
    )
        .toList();
  }

  List<Map<String, dynamic>> get _volumes {
    final raw = _first(_root, <String>[
      'volumes',
      'volumeHistory',
      'historicalVolume',
      'pastVolume',
    ]);

    if (raw is List) return _listMaps(raw);

    final map = _map(raw);
    if (map.isEmpty) return <Map<String, dynamic>>[];

    return map.entries
        .map(
          (entry) => <String, dynamic>{
        'period': entry.key,
        'value': entry.value,
      },
    )
        .toList();
  }

  Map<String, dynamic> get _shareholding {
    return _map(
      _first(_root, <String>['shareholding', 'shareHoldings', 'holdings']),
    );
  }

  List<Map<String, dynamic>> get _holdingRows {
    final raw = _first(_shareholding, <String>[
      'latest',
      'latestQuarter',
      'data',
      'holders',
    ]);

    if (raw is List) return _listMaps(raw);

    if (raw is Map) {
      return raw.entries
          .map(
            (entry) => <String, dynamic>{
          'category': entry.key,
          'value': entry.value,
        },
      )
          .toList();
    }

    if (_shareholding.isNotEmpty) {
      const keys = <String>[
        'promoters',
        'promoter',
        'fii',
        'foreignInstitutionalInvestors',
        'dii',
        'domesticInstitutionalInvestors',
        'mutual_funds',
        'mutualFunds',
        'retail_and_other',
        'retailAndOther',
        'public',
      ];

      return keys
          .where((key) => _shareholding.containsKey(key))
          .map(
            (key) => <String, dynamic>{
          'category': key,
          'value': _shareholding[key],
        },
      )
          .toList();
    }

    return <Map<String, dynamic>>[];
  }

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response =
      await UpstoxService.getReport(
        symbol: widget.symbol.trim().toUpperCase(),
        instrumentKey: widget.instrumentKey,
        isin: widget.isin,
      ).timeout(
        const Duration(seconds: 14),
        onTimeout: () => throw Exception(
          'Live market data could not be loaded in time. Your saved AI analysis remains available below.',
        ),
      );

      if (!mounted) return;

      // Reject an empty payload instead of rendering a misleading all-zero report.
      if (response.isEmpty) {
        throw Exception('The server returned an empty report. Please retry.');
      }

      setState(() {
        _data = response;
        _error = null;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          tooltip: 'Close',
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.close_rounded, color: _text),
        ),
        title: Text(
          'Report',
          style: GoogleFonts.poppins(
            color: _text,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: <Widget>[
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _loadReport,
            icon: Icon(
              Icons.refresh_rounded,
              color: _loading ? _muted : _primary,
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Stack(
          children: <Widget>[
            RefreshIndicator(
              color: _primary,
              onRefresh: _loadReport,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(14, 2, 14, 120),
                children: <Widget>[
                  _buildHeader(),
                  const SizedBox(height: 12),
                  if (_data == null) ...<Widget>[
                    // Keep the saved AI report visible immediately. Live
                    // market data is supplementary and must not block it.
                    if (_loading) _buildLoading() else _buildError(),
                    if (widget.report.trim().isNotEmpty) ...<Widget>[
                      const SizedBox(height: 12),
                      _buildTextAnalysis(),
                    ],
                    const SizedBox(height: 18),
                    _buildDisclaimer(),
                  ] else ...<Widget>[
                    if (_error != null) ...<Widget>[
                      _buildRefreshWarning(),
                      const SizedBox(height: 12),
                    ],
                    _buildFundamentals(),
                    const SizedBox(height: 12),
                    _buildFinancials(),
                    const SizedBox(height: 12),
                    _buildPriceVolume(),
                    const SizedBox(height: 12),
                    _buildShareholding(),
                    const SizedBox(height: 12),
                    _buildTextAnalysis(),
                    const SizedBox(height: 18),
                    _buildDisclaimer(),
                  ],
                ],
              ),
            ),
            _buildBottomAction(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final lastPrice = _num(
      _first(_quote, <String>[
        'last_price',
        'lastPrice',
        'ltp',
        'last_traded_price',
      ]),
    );
    final changePercent = _num(
      _first(_quote, <String>[
        'change_percent',
        'changePercent',
        'percent_change',
      ]),
    );
    final previousClose = _num(
      _first(_quote, <String>['previous_close', 'previousClose', 'prev_close']),
    );
    final dayChange = _num(
      _first(_quote, <String>['change', 'day_change', 'dayChange']),
      lastPrice - previousClose,
    );
    final volume = _num(_first(_quote, <String>['volume', 'total_volume']));
    final positive = changePercent >= 0;

    final apiSymbol = _string(
      _first(_root, <String>['symbol', 'trading_symbol']),
      widget.symbol,
    );
    final apiName = _string(
      _first(_root, <String>['company', 'companyName', 'name']),
    );
    final title = widget.company.trim().isNotEmpty
        ? widget.company.trim()
        : (apiName.isNotEmpty ? apiName : widget.symbol);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            _primary.withValues(alpha: _dark ? .24 : .12),
            _surface,
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _primary.withValues(alpha: .16)),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              _logo(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: _text,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$apiSymbol • Upstox market data',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: _muted,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (widget.date.trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          widget.date,
                          style: GoogleFonts.poppins(
                            color: _muted,
                            fontSize: 8.5,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              _smallIcon(
                _loading ? Icons.sync_rounded : Icons.auto_awesome_rounded,
              ),
            ],
          ),
          if (_data != null) ...<Widget>[
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  _money(lastPrice),
                  style: GoogleFonts.poppins(
                    color: _text,
                    fontSize: 28,
                    height: 1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 9),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    '${positive ? '+' : ''}${changePercent.toStringAsFixed(2)}%',
                    style: GoogleFonts.poppins(
                      color: positive ? Colors.green : Colors.redAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            Row(
              children: <Widget>[
                Expanded(
                  child: _miniStat(
                    'Day change',
                    '${dayChange >= 0 ? '+' : ''}${_money(dayChange)}',
                    dayChange >= 0 ? Colors.green : Colors.redAccent,
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: _miniStat(
                    'Previous close',
                    _money(previousClose),
                    null,
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: _miniStat('Volume', _compactNumber(volume), null),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _logo() {
    final value = widget.logo.trim();
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return ClipOval(
        child: Image.network(
          value,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _logoFallback(),
        ),
      );
    }

    if (value.isNotEmpty) {
      return Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _primary.withValues(alpha: .12),
          shape: BoxShape.circle,
        ),
        child: Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            color: _primary,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    return _logoFallback();
  }

  Widget _logoFallback() {
    final symbol = widget.symbol.trim().toUpperCase();
    final initials = symbol.length > 3 ? symbol.substring(0, 3) : symbol;

    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _primary.withValues(alpha: .12),
        shape: BoxShape.circle,
        border: Border.all(color: _primary.withValues(alpha: .22)),
      ),
      child: Text(
        initials.isEmpty ? 'AI' : initials,
        style: GoogleFonts.poppins(
          color: _primary,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return _reportCard(
      title: 'Loading live report',
      icon: Icons.sync_rounded,
      expanded: true,
      onToggle: null,
      child: Column(
        children: <Widget>[
          LinearProgressIndicator(
            minHeight: 4,
            borderRadius: BorderRadius.circular(4),
            color: _primary,
            backgroundColor: _colors.surfaceContainerHighest,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading live price, financials, ratios and shareholding from Upstox…',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: _muted,
              fontSize: 11,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return _reportCard(
      title: 'Market data unavailable',
      icon: Icons.cloud_off_rounded,
      expanded: true,
      onToggle: null,
      child: Column(
        children: <Widget>[
          Text(
            _errorMessage(),
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: _muted,
              fontSize: 11,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: _loadReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: _colors.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                'Retry',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefreshWarning() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange.withValues(alpha: .25)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.cloud_off_rounded, color: Colors.orange, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Could not refresh live market data. Showing the last available data.',
              style: GoogleFonts.poppins(
                color: _text,
                fontSize: 10,
                height: 1.4,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Retry',
            visualDensity: VisualDensity.compact,
            onPressed: _loading ? null : _loadReport,
            icon: Icon(Icons.refresh_rounded, color: _primary),
          ),
        ],
      ),
    );
  }

  String _errorMessage() {
    if (_error == null) {
      return 'Live report data is unavailable right now.';
    }

    final message = _error
        .toString()
        .replaceFirst('Exception: ', '')
        .replaceFirst('ReportApiException: ', '')
        .trim();

    if (message.isEmpty) {
      return 'Live report data is unavailable right now. Please try again.';
    }

    final lower = message.toLowerCase();
    if (lower.contains('http 404') ||
        lower.contains('route not found') ||
        lower.contains('not found')) {
      return 'The live-report API route is not available on the backend yet. '
          'Your saved AI analysis is shown below; deploy the /api/upstox/report '
          'route on the AiTradeX server to enable live financial data.';
    }

    if (lower.contains('taking too long') || lower.contains('timeout')) {
      return 'The live-report request timed out. Your saved AI analysis is '
          'still available below. Check the backend and try again.';
    }

    return message;
  }

  Widget _buildFundamentals() {
    final ratios = _ratios;
    final isin = _string(
      _first(_root, <String>['isin', 'instrument_isin']),
      widget.isin ?? '',
    );

    return _reportCard(
      title: 'Fundamentals',
      icon: Icons.bolt_rounded,
      expanded: _fundamentalsOpen,
      onToggle: () {
        setState(() => _fundamentalsOpen = !_fundamentalsOpen);
      },
      child: Column(
        children: <Widget>[
          _pillRow(<String>[
            _string(
              _first(_root, <String>['sector', 'industry']),
              'NSE Equity',
            ),
            isin.isEmpty ? 'Live fundamentals' : isin,
          ]),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: _metric('P/E', _ratio(ratios, <String>['pe', 'p_e'])),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _metric(
                  'Sector P/E',
                  _ratio(ratios, <String>[
                    'sector_pe',
                    'sectorPe',
                    'sector_p_e',
                  ]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            children: <Widget>[
              Expanded(
                child: _metric('P/B', _ratio(ratios, <String>['pb', 'p_b'])),
              ),
              const SizedBox(width: 7),
              Expanded(child: _metric('ROE', _ratio(ratios, <String>['roe']))),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            children: <Widget>[
              Expanded(
                child: _metric('ROCE', _ratio(ratios, <String>['roce'])),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _metric(
                  'EV/EBITDA',
                  _ratio(ratios, <String>['ev_ebitda', 'evEbitda']),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Ratios are supplied by the AiTradeX backend / Upstox.',
              style: GoogleFonts.poppins(color: _muted, fontSize: 8),
            ),
          ),
        ],
      ),
    );
  }

  String _ratio(Map<String, dynamic> ratios, List<String> keys) {
    final value = _first(ratios, keys);
    if (value == null) return '—';

    final number = _num(value, double.nan);
    if (!number.isFinite) return '—';

    return number.toStringAsFixed(2);
  }

  Widget _buildFinancials() {
    final type = _revenueSelected ? 'revenue' : 'profit';
    final rows = _history(type);

    return _reportCard(
      title: 'Financials',
      icon: Icons.bar_chart_rounded,
      expanded: _financialsOpen,
      onToggle: () {
        setState(() => _financialsOpen = !_financialsOpen);
      },
      child: Column(
        children: <Widget>[
          _segmented(
            first: 'Revenue',
            second: 'Net profit',
            firstSelected: _revenueSelected,
            onFirst: () => setState(() => _revenueSelected = true),
            onSecond: () => setState(() => _revenueSelected = false),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '₹ Cr • Upstox Fundamentals',
              style: GoogleFonts.poppins(color: _muted, fontSize: 9),
            ),
          ),
          const SizedBox(height: 8),
          if (rows.isEmpty)
            _emptyData(
              'No ${_yearlySelected ? 'yearly' : 'quarterly'} financial data returned by Upstox.',
            )
          else
            SizedBox(height: 210, child: _financialChart(rows)),
          const SizedBox(height: 12),
          _segmented(
            first: 'Yearly',
            second: 'Quarterly',
            firstSelected: _yearlySelected,
            onFirst: () => setState(() => _yearlySelected = true),
            onSecond: () => setState(() => _yearlySelected = false),
            compact: true,
          ),
        ],
      ),
    );
  }

  Widget _financialChart(List<Map<String, dynamic>> rows) {
    final visible = rows.length > 6 ? rows.sublist(rows.length - 6) : rows;

    final values = visible.map((row) {
      return _num(
        _first(row, <String>['value', 'amount', 'revenue', 'net_profit']),
      );
    }).toList();

    final maxValue = values.fold<double>(
      0,
          (maxValue, value) => math.max(maxValue, value.abs()),
    );

    if (maxValue <= 0) {
      return _emptyData('No numeric financial values available.');
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List<Widget>.generate(visible.length, (index) {
        final row = visible[index];
        final value = values[index];
        final factor = (value.abs() / maxValue).clamp(0.08, 1.0).toDouble();
        final height = 105 * factor;
        final period = _string(
          _first(row, <String>['period', 'year', 'quarter', 'label']),
          '—',
        );

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  _compactNumber(value.abs()),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: _text,
                    fontSize: 7,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  height: height,
                  decoration: BoxDecoration(
                    gradient: _gradient,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(7),
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  period.replaceAll(' ', '\n'),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: GoogleFonts.poppins(
                    color: _muted,
                    fontSize: 7,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPriceVolume() {
    return _reportCard(
      title: 'Price & volume',
      icon: Icons.currency_rupee_rounded,
      expanded: _priceVolumeOpen,
      onToggle: () {
        setState(() => _priceVolumeOpen = !_priceVolumeOpen);
      },
      child: Column(
        children: <Widget>[
          _segmented(
            first: 'Past returns',
            second: 'Past volume',
            firstSelected: _returnsSelected,
            onFirst: () => setState(() => _returnsSelected = true),
            onSecond: () => setState(() => _returnsSelected = false),
          ),
          const SizedBox(height: 16),
          if (_returnsSelected) _returnsBars() else _volumeBars(),
        ],
      ),
    );
  }

  Widget _returnsBars() {
    final rows = _returns
        .map(
          (row) => <String, dynamic>{
        'period': _string(
          _first(row, <String>['period', 'label', 'range']),
          '—',
        ),
        'value': _num(
          _first(row, <String>[
            'value',
            'return',
            'return_percent',
            'change_percent',
          ]),
        ),
      },
    )
        .toList();

    if (rows.isEmpty) {
      return _emptyData('No historical return data available.');
    }

    final maxAbs = rows.fold<double>(
      1,
          (maxValue, row) => math.max(maxValue, _num(row['value']).abs()),
    );

    return Column(
      children: rows.map((row) {
        final value = _num(row['value']);
        final positive = value >= 0;
        final factor = (value.abs() / maxAbs).clamp(0.03, 1.0).toDouble();

        return Padding(
          padding: const EdgeInsets.only(bottom: 11),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 42,
                child: Text(
                  _string(row['period'], '—'),
                  style: GoogleFonts.poppins(
                    color: _muted,
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 18,
                  decoration: BoxDecoration(
                    color: _colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: factor,
                    child: Container(
                      decoration: BoxDecoration(
                        color: positive ? _primary : Colors.redAccent,
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 9),
              SizedBox(
                width: 54,
                child: Text(
                  '${positive ? '+' : ''}${value.toStringAsFixed(2)}%',
                  textAlign: TextAlign.right,
                  style: GoogleFonts.poppins(
                    color: positive ? Colors.green : Colors.redAccent,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _volumeBars() {
    final rows = _volumes
        .map(
          (row) => <String, dynamic>{
        'period': _string(
          _first(row, <String>['period', 'label', 'date']),
          '—',
        ),
        'value': _num(_first(row, <String>['value', 'volume', 'qty'])),
      },
    )
        .where((row) => _num(row['value']) > 0)
        .toList();

    if (rows.isEmpty) {
      return _emptyData('No historical volume data available.');
    }

    final maxValue = rows.fold<double>(
      1,
          (maxValue, row) => math.max(maxValue, _num(row['value'])),
    );

    return Column(
      children: rows.map((row) {
        final value = _num(row['value']);
        final factor = (value / maxValue).clamp(0.03, 1.0).toDouble();

        return Padding(
          padding: const EdgeInsets.only(bottom: 11),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 42,
                child: Text(
                  _string(row['period'], '—'),
                  style: GoogleFonts.poppins(color: _muted, fontSize: 8),
                ),
              ),
              Expanded(
                child: Container(
                  height: 18,
                  decoration: BoxDecoration(
                    color: _colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: factor,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: _gradient,
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 9),
              SizedBox(
                width: 54,
                child: Text(
                  _compactNumber(value),
                  textAlign: TextAlign.right,
                  style: GoogleFonts.poppins(
                    color: _text,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildShareholding() {
    final rows = _holdingRows;

    if (rows.isEmpty) {
      return _reportCard(
        title: 'Shareholding',
        icon: Icons.pie_chart_rounded,
        expanded: _shareholdingOpen,
        onToggle: () {
          setState(() => _shareholdingOpen = !_shareholdingOpen);
        },
        child: _emptyData('No shareholding data available from Upstox.'),
      );
    }

    final values = rows
        .map(
          (row) => math.max(
        0.0,
        _num(_first(row, <String>['value', 'percentage', 'percent'])),
      ),
    )
        .toList();
    final colors = _shareColors(values.length);
    final total = values.fold<double>(0, (sum, value) => sum + value);
    final period = _string(
      _first(_shareholding, <String>['period', 'date', 'quarter']),
      'Latest quarter',
    );

    return _reportCard(
      title: 'Shareholding',
      icon: Icons.pie_chart_rounded,
      expanded: _shareholdingOpen,
      onToggle: () {
        setState(() => _shareholdingOpen = !_shareholdingOpen);
      },
      child: Column(
        children: <Widget>[
          Text(
            period,
            style: GoogleFonts.poppins(
              color: _text,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 190,
            child: CustomPaint(
              painter: _DonutPainter(
                values: values,
                colors: colors,
                background: _colors.surfaceContainerHighest,
              ),
              child: Center(
                child: Text(
                  '${total.toStringAsFixed(1)}%',
                  style: GoogleFonts.poppins(
                    color: _text,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: List<Widget>.generate(rows.length, (index) {
              final label = _shareLabel(
                _string(
                  _first(rows[index], <String>['category', 'type', 'name']),
                  'Other',
                ),
              );
              return _legend(
                label,
                colors[index],
                '${values[index].toStringAsFixed(2)}%',
              );
            }),
          ),
        ],
      ),
    );
  }

  List<Color> _shareColors(int count) {
    final colors = <Color>[
      _primary,
      _secondary,
      Colors.orange,
      Colors.pinkAccent,
      Colors.blueAccent,
      Colors.teal,
    ];

    return List<Color>.generate(
      count,
          (index) => colors[index % colors.length],
    );
  }

  String _shareLabel(String value) {
    switch (value.toLowerCase()) {
      case 'fii':
      case 'foreign_institutional_investors':
      case 'foreigninstitutionalinvestors':
        return 'FII';
      case 'dii':
      case 'domestic_institutional_investors':
      case 'domesticinstitutionalinvestors':
        return 'DII';
      case 'mutual_funds':
      case 'mutualfunds':
        return 'Mutual funds';
      case 'retail_and_other':
      case 'retailandother':
        return 'Retail & other';
      case 'promoters':
      case 'promoter':
        return 'Promoters';
      case 'public':
        return 'Public';
      default:
        return value;
    }
  }

  Widget _buildTextAnalysis() {
    final String report = widget.report.trim();

    return _reportCard(
      title: 'AI analysis',
      icon: Icons.auto_awesome_rounded,
      expanded: true,
      onToggle: null,
      child: report.isEmpty
          ? Text(
        'No saved AI analysis is available for this report.',
        style: GoogleFonts.poppins(
          color: _muted,
          fontSize: 11.5,
          height: 1.55,
        ),
      )
          : MarkdownBody(
        data: report,
        selectable: true,
        styleSheet: MarkdownStyleSheet.fromTheme(_theme).copyWith(
          p: GoogleFonts.poppins(
            color: _text,
            fontSize: 11.5,
            height: 1.55,
          ),
          h1: GoogleFonts.poppins(
            color: _text,
            fontSize: 17,
            fontWeight: FontWeight.w800,
            height: 1.3,
          ),
          h2: GoogleFonts.poppins(
            color: _text,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            height: 1.3,
          ),
          h3: GoogleFonts.poppins(
            color: _text,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            height: 1.3,
          ),
          listBullet: GoogleFonts.poppins(
            color: _primary,
            fontSize: 11.5,
          ),
          code: GoogleFonts.robotoMono(
            color: _text,
            fontSize: 10.5,
          ),
          blockquote: GoogleFonts.poppins(
            color: _muted,
            fontSize: 11,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomAction() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 9, 14, 12),
        decoration: BoxDecoration(
          color: _background.withValues(alpha: .96),
          border: Border(
            top: BorderSide(color: _colors.onSurface.withValues(alpha: .06)),
          ),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: _colors.surfaceContainerHighest,
                shape: BoxShape.circle,
                border: Border.all(
                  color: _colors.onSurface.withValues(alpha: .15),
                ),
              ),
              child: Icon(Icons.savings_rounded, color: _primary, size: 24),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: widget.onBuy ?? _defaultBuy,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: _colors.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                  child: Text(
                    'Buy now',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _defaultBuy() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Connect your existing Upstox order flow here.',
          style: GoogleFonts.poppins(fontSize: 11),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Text(
      'Market data is supplied by Upstox. AI-generated information is educational only and does not guarantee investment returns.',
      textAlign: TextAlign.center,
      style: GoogleFonts.poppins(color: _muted, fontSize: 8.5, height: 1.45),
    );
  }

  Widget _smallIcon(IconData icon) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: _primary.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: _primary, size: 18),
    );
  }

  Widget _miniStat(String label, String value, Color? valueColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 10),
      decoration: BoxDecoration(
        color: _colors.surfaceContainerHighest.withValues(alpha: .55),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(color: _muted, fontSize: 8),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: valueColor ?? _text,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _reportCard({
    required String title,
    required IconData icon,
    required bool expanded,
    required Widget child,
    VoidCallback? onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _colors.onSurface.withValues(alpha: .07)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: _dark ? .08 : .025),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _primary.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: _primary, size: 19),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: _text,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (onToggle != null)
                    Icon(
                      expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: _muted,
                    ),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 15),
              child: child,
            ),
        ],
      ),
    );
  }

  Widget _pillRow(List<String> labels) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 7,
        runSpacing: 7,
        children: labels
            .where((label) => label.trim().isNotEmpty)
            .map(
              (label) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: .09),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: _primary.withValues(alpha: .15)),
            ),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: _primary,
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        )
            .toList(),
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: _colors.surfaceContainerHighest.withValues(alpha: .45),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: GoogleFonts.poppins(color: _muted, fontSize: 8.5),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: _text,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _segmented({
    required String first,
    required String second,
    required bool firstSelected,
    required VoidCallback onFirst,
    required VoidCallback onSecond,
    bool compact = false,
  }) {
    Widget option(String label, bool selected, VoidCallback onTap) {
      return Expanded(
        child: Material(
          color: selected ? _primary : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(11),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: compact ? 8 : 10, horizontal: 6),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: selected ? _colors.onPrimary : _muted,
                  fontSize: compact ? 9 : 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _colors.surfaceContainerHighest.withValues(alpha: .6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: <Widget>[
          option(first, firstSelected, onFirst),
          const SizedBox(width: 4),
          option(second, !firstSelected, onSecond),
        ],
      ),
    );
  }

  Widget _emptyData(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 22),
      decoration: BoxDecoration(
        color: _colors.surfaceContainerHighest.withValues(alpha: .35),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: <Widget>[
          Icon(Icons.query_stats_rounded, color: _muted, size: 25),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: _muted, fontSize: 10, height: 1.45),
          ),
        ],
      ),
    );
  }

  Widget _legend(String label, Color color, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: _colors.surfaceContainerHighest.withValues(alpha: .4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(color: _muted, fontSize: 8.5),
          ),
          const SizedBox(width: 5),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: _text,
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  String _money(double value) {
    if (!value.isFinite || value == 0) return '—';
    return '₹${value.toStringAsFixed(2)}';
  }

  String _compactNumber(double value) {
    if (!value.isFinite) return '—';

    final abs = value.abs();
    if (abs >= 10000000) {
      return '${(value / 10000000).toStringAsFixed(2)} Cr';
    }
    if (abs >= 100000) {
      return '${(value / 100000).toStringAsFixed(2)} L';
    }
    if (abs >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter({
    required this.values,
    required this.colors,
    required this.background,
  });

  final List<double> values;
  final List<Color> colors;
  final Color background;

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<double>(0, (sum, value) => sum + value);

    if (total <= 0) return;

    final radius = size.shortestSide * .32;
    final stroke = radius * .42;
    final center = size.center(Offset.zero);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    var start = -math.pi / 2;

    for (var i = 0; i < values.length; i++) {
      final sweep = (values[i] / total) * math.pi * 2;
      paint.color = colors[i % colors.length];

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        math.max(0, sweep - .025),
        false,
        paint,
      );

      start += sweep;
    }

    paint
      ..color = background.withValues(alpha: .45)
      ..strokeWidth = 1;

    canvas.drawCircle(center, radius - stroke * .53, paint);
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.colors != colors ||
        oldDelegate.background != background;
  }
}
