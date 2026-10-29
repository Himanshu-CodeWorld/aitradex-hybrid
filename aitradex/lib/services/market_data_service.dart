import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Normalized quote returned by the AiTradeX backend.
///
/// Flutter talks only to the AiTradeX backend. Upstox client secrets and
/// OAuth access tokens must remain on the Node.js/Render server.
class MarketQuote {
  final String instrumentKey;
  final String symbol;
  final double lastPrice;
  final double changePercent;
  final double? previousClose;
  final int? volume;

  const MarketQuote({
    required this.instrumentKey,
    required this.symbol,
    required this.lastPrice,
    required this.changePercent,
    this.previousClose,
    this.volume,
  });

  factory MarketQuote.fromJson(
      String instrumentKey,
      Map<String, dynamic> json,
      ) {
    final ohlc = _asMap(json['ohlc'] ?? json['OHLC']);

    final lastPrice = _toDouble(
      _firstValue(json, const [
        'last_price',
        'lastPrice',
        'ltp',
        'last_traded_price',
        'lastTradedPrice',
        'close',
        'price',
      ]),
    );

    final previousClose = _nullableDouble(
      _firstValue(json, const [
        'previous_close',
        'previousClose',
        'close_price',
        'closePrice',
        'prev_close',
        'prevClose',
        'previous_close_price',
      ]) ??
          _firstValue(ohlc, const ['close', 'previous_close', 'previousClose']),
    );

    final rawChangePercent = _firstValue(json, const [
      'change_percent',
      'changePercent',
      'percentage_change',
      'percentageChange',
      'percent_change',
      'change_percentage',
    ]);

    var changePercent = _toDouble(rawChangePercent);

    // Calculate percentage when the backend provides LTP and close price,
    // or only an absolute price change. Preserve an explicitly returned 0%.
    if (rawChangePercent == null &&
        previousClose != null &&
        previousClose > 0 &&
        lastPrice > 0) {
      changePercent = ((lastPrice - previousClose) / previousClose) * 100;
    } else if (rawChangePercent == null) {
      final rawChange = _nullableDouble(
        _firstValue(json, const ['change', 'price_change', 'priceChange']),
      );
      if (rawChange != null &&
          previousClose != null &&
          previousClose > 0) {
        changePercent = (rawChange / previousClose) * 100;
      }
    }

    return MarketQuote(
      instrumentKey: instrumentKey,
      symbol: _readString(
        _firstValue(json, const [
          'symbol',
          'trading_symbol',
          'tradingSymbol',
          'display_name',
          'displayName',
          'name',
        ]) ??
            '',
      ),
      lastPrice: lastPrice,
      changePercent: changePercent,
      previousClose: previousClose,
      volume: _nullableInt(
        _firstValue(json, const [
          'volume',
          'total_volume',
          'totalVolume',
          'volume_traded',
          'volumeTraded',
        ]),
      ),
    );
  }

  MarketQuote copyWith({
    String? symbol,
    double? lastPrice,
    double? changePercent,
    double? previousClose,
    int? volume,
  }) {
    return MarketQuote(
      instrumentKey: instrumentKey,
      symbol: symbol ?? this.symbol,
      lastPrice: lastPrice ?? this.lastPrice,
      changePercent: changePercent ?? this.changePercent,
      previousClose: previousClose ?? this.previousClose,
      volume: volume ?? this.volume,
    );
  }

  static dynamic _firstValue(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      if (map.containsKey(key) && map[key] != null) {
        return map[key];
      }
    }
    return null;
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }

  static String _readString(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();

    final raw = value?.toString().trim() ?? '';
    if (raw.isEmpty) return 0;

    return double.tryParse(raw.replaceAll(',', '')) ?? 0;
  }

  static double? _nullableDouble(dynamic value) {
    if (value == null) return null;

    if (value is num) {
      return value.toDouble();
    }

    final raw = value.toString().trim().replaceAll(',', '');
    if (raw.isEmpty) return null;

    return double.tryParse(raw);
  }

  static int? _nullableInt(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;

    if (value is num) return value.toInt();

    final raw = value.toString().trim().replaceAll(',', '');
    if (raw.isEmpty) return null;

    return int.tryParse(raw) ?? double.tryParse(raw)?.toInt();
  }
}

/// AiTradeX market-data API client.
///
/// Expected backend route:
/// GET /api/upstox/market-data?instrument_key=A,B,C
///
/// The backend is responsible for authenticating with Upstox and returning
/// safe market data. No Upstox secret/token is stored in this Flutter class.
class MarketDataService {
  MarketDataService._();

  static const String baseUrl = 'https://aitradex-api.onrender.com';
  static const String endpoint = '$baseUrl/api/upstox/market-data';

  static const Duration requestTimeout = Duration(seconds: 20);

  /// Brief in-memory cache to avoid repeated network calls from multiple
  /// screens. This cache is only for market quotes, not user or broker data.
  static const Duration cacheTtl = Duration(seconds: 20);
  static final Map<String, _CachedQuoteBatch> _cache =
  <String, _CachedQuoteBatch>{};
  static final Map<String, Future<Map<String, MarketQuote>>> _inFlight =
  <String, Future<Map<String, MarketQuote>>>{};

  static Future<Map<String, MarketQuote>> fetchMarketData(
      List<String> instrumentKeys, {
        Duration timeout = requestTimeout,
        bool forceRefresh = false,
      }) async {
    final keys = _normalizeKeys(instrumentKeys);

    if (keys.isEmpty) {
      return <String, MarketQuote>{};
    }

    // Use a stable key so identical requests share cached/in-flight work.
    final batchKey = (List<String>.from(keys)..sort()).join('||');
    final now = DateTime.now();
    final cached = _cache[batchKey];

    if (!forceRefresh &&
        cached != null &&
        now.difference(cached.savedAt) <= cacheTtl) {
      return Map<String, MarketQuote>.from(cached.quotes);
    }

    if (!forceRefresh) {
      final pending = _inFlight[batchKey];
      if (pending != null) {
        final result = await pending;
        return Map<String, MarketQuote>.from(result);
      }
    }

    final request = _fetchMarketDataUncached(keys, timeout: timeout);
    if (!forceRefresh) {
      _inFlight[batchKey] = request;
    }

    try {
      final result = await request;
      // Never cache an empty response. A transient upstream/parser issue must
      // not make the dashboard appear empty for the entire cache TTL.
      if (result.isNotEmpty) {
        _cache[batchKey] = _CachedQuoteBatch(
          savedAt: DateTime.now(),
          quotes: Map<String, MarketQuote>.from(result),
        );
      } else {
        _cache.remove(batchKey);
      }
      return result;
    } finally {
      if (!forceRefresh && identical(_inFlight[batchKey], request)) {
        _inFlight.remove(batchKey);
      }
    }
  }

  /// Removes cached quotes. Call before an explicit user-requested refresh
  /// when the latest server response is required.
  static void clearCache() {
    _cache.clear();
  }

  static Future<Map<String, MarketQuote>> _fetchMarketDataUncached(
      List<String> keys, {
        required Duration timeout,
      }) async {
    // Keep each request small. Large catalogue requests can exceed the mobile
    // timeout and make the dashboard fail even when individual quotes work.
    const batchSize = 20;
    if (keys.length > batchSize) {
      final combined = <String, MarketQuote>{};
      for (var start = 0; start < keys.length; start += batchSize) {
        final end = (start + batchSize < keys.length)
            ? start + batchSize
            : keys.length;
        final batch = keys.sublist(start, end);
        debugPrint(
          '[AiTradeX MarketData] fetching batch ${(start ~/ batchSize) + 1}: '
              '${batch.length} instruments',
        );
        final batchQuotes = await _fetchMarketDataUncached(
          batch,
          timeout: timeout,
        );
        combined.addAll(batchQuotes);
      }
      debugPrint(
        '[AiTradeX MarketData] combined batch quotes=${combined.length}/${keys.length}',
      );
      return combined;
    }

    final uri = Uri.parse(endpoint).replace(
      queryParameters: <String, String>{'instrument_key': keys.join(',')},
    );

    http.Response response;

    try {
      response = await http
          .get(
        uri,
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      )
          .timeout(timeout);
    } on TimeoutException {
      throw const MarketDataException(
        'Market data request timed out. Please try again.',
      );
    } on http.ClientException catch (error) {
      throw MarketDataException(
        'Unable to connect to AiTradeX market API: ${error.message}',
      );
    } catch (error) {
      throw MarketDataException('Unable to load market data: $error');
    }

    debugPrint('[AiTradeX MarketData] GET $uri');
    debugPrint('[AiTradeX MarketData] HTTP ${response.statusCode}; bytes=${response.bodyBytes.length}; requested=${keys.length}');
    debugPrint('[AiTradeX MarketData] requested keys: ${keys.take(8).join(' ; ')}');

    final body = _decodeBody(response.body);
    debugPrint('[AiTradeX MarketData] top-level response keys: ${body.keys.take(20).join(', ')}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw MarketDataException(
        _messageFromBody(
          body,
          fallback: 'Market data request failed (${response.statusCode}).',
        ),
        statusCode: response.statusCode,
      );
    }

    if (_isExplicitFailure(body)) {
      throw MarketDataException(
        _messageFromBody(
          body,
          fallback: 'Market data is currently unavailable.',
        ),
        statusCode: response.statusCode,
      );
    }

    final quotes = <String, MarketQuote>{};

    // Recursively supports direct Upstox maps, arrays, and nested wrappers such
    // as {success:true,data:{data:{"NSE_EQ|...":{last_price:123}}}}.
    _extractQuotes(body, quotes);

    debugPrint('[AiTradeX MarketData] extracted quote objects=${quotes.length}; keys=${quotes.keys.take(8).join(' ; ')}');
    final filtered = _filterRequestedQuotes(quotes, keys);
    debugPrint('[AiTradeX MarketData] matched requested quotes=${filtered.length}/${keys.length}');
    if (filtered.isEmpty && quotes.isNotEmpty) {
      debugPrint('[AiTradeX MarketData] no key matches; requested normalized=${keys.take(8).map(_canonicalKey).join(' ; ')}');
    }
    return filtered;
  }

  static Map<String, MarketQuote> _filterRequestedQuotes(
      Map<String, MarketQuote> quotes,
      List<String> requestedKeys,
      ) {
    if (quotes.isEmpty || requestedKeys.isEmpty) {
      return <String, MarketQuote>{};
    }

    final requestedExact = <String, String>{};
    final requestedCanonical = <String, String>{};
    for (final raw in requestedKeys) {
      final key = raw.trim();
      if (key.isEmpty) continue;
      requestedExact[key] = key;
      requestedCanonical.putIfAbsent(_canonicalKey(key), () => key);
    }

    final filtered = <String, MarketQuote>{};
    for (final entry in quotes.entries) {
      final responseKey = entry.key.trim();
      if (responseKey.isEmpty) continue;

      // Prefer exact matches. If the provider has encoded or normalized a key,
      // canonical matching maps it back to the exact requested key used by UI.
      final matchedKey = requestedExact[responseKey] ??
          requestedCanonical[_canonicalKey(responseKey)];
      if (matchedKey == null) continue;

      final quote = entry.value;
      filtered[matchedKey] = MarketQuote(
        instrumentKey: matchedKey,
        symbol: quote.symbol,
        lastPrice: quote.lastPrice,
        changePercent: quote.changePercent,
        previousClose: quote.previousClose,
        volume: quote.volume,
      );
    }
    return filtered;
  }

  static String _canonicalKey(String value) {
    var key = value.trim();
    try {
      key = Uri.decodeComponent(key);
    } catch (_) {
      // Keep the original key if it contains malformed percent escapes.
    }
    key = key.replaceAll('+', ' ');
    key = key.replaceAll(RegExp(r'\s+'), ' ').trim().toLowerCase();
    // Some wrappers serialize exchange/instrument separators as a colon.
    key = key.replaceFirst(RegExp(r'^(nse_eq|bse_eq|nse_index|bse_index):'), r'$1|');
    return key;
  }

  /// Fetch one quote.
  static Future<MarketQuote?> fetchQuote(
      String instrumentKey, {
        Duration timeout = requestTimeout,
      }) async {
    final key = instrumentKey.trim();
    if (key.isEmpty) return null;

    final quotes = await fetchMarketData(<String>[key], timeout: timeout);

    return quotes[key];
  }

  static List<String> _normalizeKeys(List<String> keys) {
    final result = <String>[];
    final seen = <String>{};

    for (final raw in keys) {
      final key = raw.trim();
      if (key.isEmpty || !seen.add(key)) continue;
      result.add(key);
    }

    return result;
  }

  static Map<String, dynamic> _decodeBody(String rawBody) {
    if (rawBody.trim().isEmpty) {
      throw const MarketDataException('Market API returned an empty response.');
    }

    try {
      final decoded = jsonDecode(rawBody);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }

      throw const MarketDataException(
        'Market API returned an invalid JSON object.',
      );
    } on MarketDataException {
      rethrow;
    } on FormatException catch (error) {
      throw MarketDataException('Invalid market-data JSON response: $error');
    } catch (error) {
      throw MarketDataException('Unable to read market-data response: $error');
    }
  }

  static bool _isExplicitFailure(Map<String, dynamic> body) {
    final success = body['success'];

    if (success is bool && !success) {
      return true;
    }

    final ok = body['ok'];

    if (ok is bool && !ok) {
      return true;
    }

    final status = body['status']?.toString().toLowerCase();

    return status == 'error' || status == 'failed';
  }

  static String _messageFromBody(
      Map<String, dynamic> body, {
        required String fallback,
      }) {
    for (final key in const [
      'message',
      'error',
      'error_description',
      'detail',
    ]) {
      final value = body[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    final errorObject = body['errors'];

    if (errorObject is List && errorObject.isNotEmpty) {
      return errorObject.first.toString();
    }

    if (errorObject is Map) {
      final map = Map<String, dynamic>.from(errorObject);

      for (final key in const ['message', 'error', 'description']) {
        final value = map[key];

        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString().trim();
        }
      }
    }

    return fallback;
  }

  static void _extractQuotes(dynamic value, Map<String, MarketQuote> result) {
    if (value == null) return;

    if (value is List) {
      for (final item in value) {
        if (item is Map) {
          final itemMap = Map<String, dynamic>.from(item);
          final before = result.length;
          _extractSingleQuote(itemMap, result);
          if (result.length == before) {
            // A list item can itself wrap its quote in data/quote/result.
            _extractQuotes(itemMap, result);
          }
        }
      }
      return;
    }

    if (value is! Map) return;
    final map = Map<String, dynamic>.from(value);

    final explicitKey = _firstString(map, const [
      'instrument_key', 'instrumentKey', 'instrument_token', 'instrumentToken', 'key',
    ]);
    final normalized = _unwrapQuote(map);
    if (explicitKey != null && _looksLikeQuote(normalized)) {
      result[explicitKey.trim()] = MarketQuote.fromJson(explicitKey.trim(), normalized);
      return;
    }

    // Known wrapper properties should be traversed explicitly.
    bool traversedWrapper = false;
    for (final wrapper in const [
      'data', 'market_data', 'marketData', 'quotes', 'results', 'items', 'response', 'result',
    ]) {
      final nested = map[wrapper];
      if (nested is Map || nested is List) {
        traversedWrapper = true;
        _extractQuotes(nested, result);
      }
    }
    if (traversedWrapper) return;

    // Upstox quote endpoint: { "NSE_EQ|...": { last_price: ..., ... } }
    for (final entry in map.entries) {
      final entryKey = entry.key.trim();
      if (entryKey.isEmpty) continue;
      final entryValue = entry.value;
      if (entryValue is Map) {
        final quoteMap = Map<String, dynamic>.from(entryValue);
        final nestedKey = _firstString(quoteMap, const [
          'instrument_key', 'instrumentKey', 'instrument_token', 'instrumentToken', 'key',
        ]);
        final key = (nestedKey ?? entryKey).trim();
        final unwrapped = _unwrapQuote(quoteMap);
        if (_looksLikeQuote(unwrapped)) {
          result[key] = MarketQuote.fromJson(key, unwrapped);
        } else {
          _extractQuotes(quoteMap, result);
        }
      }
    }
  }

  static void _extractSingleQuote(
      Map<String, dynamic> map,
      Map<String, MarketQuote> result,
      ) {
    final key = _firstString(map, const [
      'instrument_key',
      'instrumentKey',
      'key',
    ]);

    if (key == null) return;

    final normalized = _unwrapQuote(map);

    if (!_looksLikeQuote(normalized)) return;

    result[key] = MarketQuote.fromJson(key, normalized);
  }

  static Map<String, dynamic> _unwrapQuote(Map<String, dynamic> value) {
    // Do not unwrap an `ltp` numeric value. Only unwrap nested maps.
    for (final key in const ['data', 'quote', 'result', 'market_quote', 'marketQuote']) {
      final nested = value[key];

      if (nested is Map) {
        return Map<String, dynamic>.from(nested);
      }
    }

    return value;
  }

  static bool _looksLikeQuote(Map<String, dynamic> map) {
    return map.containsKey('last_price') ||
        map.containsKey('lastPrice') ||
        map.containsKey('ltp') ||
        map.containsKey('last_traded_price') ||
        map.containsKey('lastTradedPrice') ||
        map.containsKey('close') ||
        map.containsKey('price');
  }

  static String? _firstString(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];

      if (value == null) continue;

      final text = value.toString().trim();

      if (text.isNotEmpty) {
        return text;
      }
    }

    return null;
  }

  /// Formats a market price in Indian rupees.
  static String formatPrice(double value, {bool compact = false}) {
    if (!value.isFinite || value == 0) return '—';

    return '₹${_formatNumber(value, compact: compact)}';
  }

  /// Formats percentage change with a sign.
  static String formatPercent(double value) {
    if (!value.isFinite) return '—';

    if (value.abs() < 0.000001) {
      return '0.00%';
    }

    final sign = value > 0 ? '+' : '';

    return '$sign${value.toStringAsFixed(2)}%';
  }

  /// Formats an absolute rupee amount.
  static String formatAmount(double value) {
    if (!value.isFinite) return '—';

    final sign = value < 0 ? '-' : '';
    final absolute = value.abs();

    return '$sign₹${_formatNumber(absolute)}';
  }

  static String _formatNumber(double value, {bool compact = false}) {
    if (!value.isFinite) return '—';

    if (compact) {
      if (value >= 10000000) {
        return '${(value / 10000000).toStringAsFixed(2)} Cr';
      }

      if (value >= 100000) {
        return '${(value / 100000).toStringAsFixed(2)} L';
      }

      if (value >= 1000) {
        return '${(value / 1000).toStringAsFixed(2)} K';
      }
    }

    return value.toStringAsFixed(2);
  }
}

class _CachedQuoteBatch {
  final DateTime savedAt;
  final Map<String, MarketQuote> quotes;

  const _CachedQuoteBatch({required this.savedAt, required this.quotes});
}

/// Typed exception used by the market-data screens.
class MarketDataException implements Exception {
  final String message;
  final int? statusCode;

  const MarketDataException(this.message, {this.statusCode});

  @override
  String toString() {
    if (statusCode == null) {
      return message;
    }

    return '$message (HTTP $statusCode)';
  }
}
