import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'market_data_service.dart';

/// AiTradeX Upstox integration.
///
/// IMPORTANT:
/// - Never store UPSTOX_CLIENT_SECRET in Flutter.
/// - Never store the Upstox access token in Flutter.
/// - Flutter communicates with the AiTradeX backend.
/// - The AiTradeX backend communicates with Upstox.
class UpstoxService {
  UpstoxService._();

  // ============================================================
  // BACKEND
  // ============================================================

  static const String baseUrl = 'https://aitradex-api.onrender.com';

  /// Upstox OAuth login endpoint.
  static const String loginPath = '/api/upstox/login';

  /// AiTradeX stock report endpoint.
  static const String reportPath = '/api/upstox/report';

  static const Duration _reportTimeout = Duration(seconds: 30);

  /// Returns the Upstox OAuth login URI.
  static Uri get loginUri {
    return Uri.parse('$baseUrl$loginPath');
  }

  /// Returns the Upstox OAuth login URL.
  static String get loginUrl {
    return loginUri.toString();
  }

  // ============================================================
  // DEFAULT INSTRUMENTS
  // ============================================================

  static const List<String> defaultInstrumentKeys = <String>[
    'NSE_INDEX|Nifty 50',
    'NSE_INDEX|Nifty Bank',
    'NSE_EQ|INE002A01018',
    'NSE_EQ|INE040A01034',
    'NSE_EQ|INE467B01029',
    'NSE_EQ|INE009A01021',
    'NSE_EQ|INE090A01021',
    'NSE_EQ|INE397D01024',
    'NSE_EQ|INE155A01022', // TATAMOTORS
  ];

  // ============================================================
  // UPSTOX OAUTH
  // ============================================================

  /// Opens the AiTradeX backend Upstox OAuth login.
  static Future<bool> connectUpstox() async {
    try {
      return await launchUrl(loginUri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  // ============================================================
  // LIVE MARKET DATA
  // ============================================================

  /// Fetches live market data through the AiTradeX backend.
  ///
  /// The actual Upstox access token stays on the backend.
  static Future<Map<String, dynamic>> getMarketData({
    List<String>? instrumentKeys,
    bool forceRefresh = false,
  }) async {
    final keys = <String>[
      ...(instrumentKeys ?? defaultInstrumentKeys),
    ].map((key) => key.trim()).where((key) => key.isNotEmpty).toSet().toList();

    if (keys.isEmpty) {
      throw const FormatException('At least one instrument key is required.');
    }

    final quotes = await MarketDataService.fetchMarketData(
      keys,
      forceRefresh: forceRefresh,
    );

    final data = <String, dynamic>{};

    for (final entry in quotes.entries) {
      final quote = entry.value;

      data[entry.key] = <String, dynamic>{
        'instrument_key': quote.instrumentKey,
        'symbol': quote.symbol,
        'last_price': quote.lastPrice,
        'change_percent': quote.changePercent,
        'previous_close': quote.previousClose,
        'volume': quote.volume,
      };
    }

    return <String, dynamic>{
      'success': true,
      'source': 'upstox',
      'api_version': 'v3',
      'data': data,
    };
  }

  // ============================================================
  // STOCK REPORT
  // ============================================================

  /// Fetches the complete stock report from the AiTradeX backend.
  ///
  /// Example:
  ///
  /// final report = await UpstoxService.getReport(
  ///   symbol: 'RELIANCE',
  /// );
  ///
  /// Optional [instrumentKey] and [isin] can be supplied when
  /// the caller already knows them.
  ///
  /// The backend is responsible for communicating with Upstox.
  static Future<Map<String, dynamic>> getReport({
    required String symbol,
    String? instrumentKey,
    String? isin,
  }) async {
    final cleanSymbol = symbol.trim();

    final cleanInstrumentKey = instrumentKey?.trim() ?? '';

    final cleanIsin = isin?.trim() ?? '';

    if (cleanSymbol.isEmpty &&
        cleanInstrumentKey.isEmpty &&
        cleanIsin.isEmpty) {
      throw const FormatException(
        'Stock symbol is required to load the report.',
      );
    }

    final query = <String, String>{
      if (cleanSymbol.isNotEmpty) 'symbol': cleanSymbol.toUpperCase(),
      if (cleanInstrumentKey.isNotEmpty) 'instrument_key': cleanInstrumentKey,
      if (cleanIsin.isNotEmpty) 'isin': cleanIsin.toUpperCase(),
    };

    final uri = Uri.parse(
      '$baseUrl$reportPath',
    ).replace(queryParameters: query);

    late final http.Response response;

    try {
      response = await http
          .get(
        uri,
        headers: const <String, String>{'Accept': 'application/json'},
      )
          .timeout(_reportTimeout);
    } on http.ClientException catch (error) {
      throw Exception(
        'Network error while loading stock report: '
            '${error.message}',
      );
    } on FormatException {
      rethrow;
    } catch (error) {
      throw Exception('Unable to connect to AiTradeX report API: $error');
    }

    final body = _decodeResponseBody(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = _extractErrorMessage(body);

      throw Exception('$message (HTTP ${response.statusCode})');
    }

    if (body.isEmpty) {
      throw const FormatException('The report API returned an empty response.');
    }

    if (body['success'] == false) {
      throw Exception(
        _extractErrorMessage(
          body,
          fallback: 'Upstox report data is currently unavailable.',
        ),
      );
    }

    final data = body['data'];

    if (data is! Map) {
      throw const FormatException(
        'The report API returned an invalid data object.',
      );
    }

    return body;
  }

  // ============================================================
  // LIVE QUOTE FOR ONE STOCK
  // ============================================================

  /// Fetches a single live quote using an Upstox instrument key.
  static Future<Map<String, dynamic>?> getQuote({
    required String instrumentKey,
  }) async {
    final cleanInstrumentKey = instrumentKey.trim();

    if (cleanInstrumentKey.isEmpty) {
      throw const FormatException('Instrument key is required.');
    }

    final result = await getMarketData(
      instrumentKeys: <String>[cleanInstrumentKey],
    );

    final data = result['data'];

    if (data is! Map) {
      return null;
    }

    final quote = data[cleanInstrumentKey];

    if (quote is Map<String, dynamic>) {
      return quote;
    }

    if (quote is Map) {
      return Map<String, dynamic>.from(quote);
    }

    return null;
  }

  // ============================================================
  // RESPONSE HELPERS
  // ============================================================

  static Map<String, dynamic> _decodeResponseBody(String responseBody) {
    if (responseBody.trim().isEmpty) {
      return <String, dynamic>{};
    }

    try {
      final decoded = jsonDecode(responseBody);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }

      throw const FormatException('Server returned an invalid JSON object.');
    } on FormatException {
      rethrow;
    } catch (_) {
      throw const FormatException('Server returned invalid JSON.');
    }
  }

  static String _extractErrorMessage(
      Map<String, dynamic> body, {
        String fallback = 'Unable to load the stock report.',
      }) {
    final candidates = <dynamic>[
      body['message'],
      body['error'],
      body['detail'],
    ];

    for (final candidate in candidates) {
      if (candidate == null) {
        continue;
      }

      final value = candidate.toString().trim();

      if (value.isNotEmpty) {
        return value;
      }
    }

    return fallback;
  }
}
