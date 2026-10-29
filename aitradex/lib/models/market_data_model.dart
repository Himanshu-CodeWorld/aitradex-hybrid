class MarketDataModel {
  final String instrumentKey;
  final String symbol;
  final double lastPrice;
  final double change;
  final double changePercent;
  final double previousClose;
  final int volume;
  final DateTime? timestamp;

  const MarketDataModel({
    required this.instrumentKey,
    required this.symbol,
    required this.lastPrice,
    required this.change,
    required this.changePercent,
    required this.previousClose,
    required this.volume,
    this.timestamp,
  });

  factory MarketDataModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return MarketDataModel(
      instrumentKey:
      _readString(
        json,
        [
          'instrument_key',
          'instrumentKey',
        ],
      ),
      symbol:
      _readString(
        json,
        [
          'symbol',
          'trading_symbol',
          'tradingSymbol',
          'name',
        ],
      ),
      lastPrice:
      _readDouble(
        json,
        [
          'last_price',
          'lastPrice',
          'ltp',
        ],
      ),
      change:
      _readDouble(
        json,
        [
          'change',
          'net_change',
        ],
      ),
      changePercent:
      _readDouble(
        json,
        [
          'change_percent',
          'changePercent',
          'percentage_change',
        ],
      ),
      previousClose:
      _readDouble(
        json,
        [
          'previous_close',
          'previousClose',
          'prev_close',
        ],
      ),
      volume:
      _readInt(
        json,
        [
          'volume',
        ],
      ),
      timestamp:
      _readDateTime(
        json,
        [
          'timestamp',
          'last_trade_time',
          'lastTradeTime',
        ],
      ),
    );
  }

  static String _readString(
      Map<String, dynamic> json,
      List<String> keys,
      ) {
    for (final key in keys) {
      final value = json[key];

      if (value != null &&
          value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    return '';
  }

  static double _readDouble(
      Map<String, dynamic> json,
      List<String> keys,
      ) {
    for (final key in keys) {
      final value = json[key];

      if (value is num) {
        return value.toDouble();
      }

      if (value != null) {
        final parsed =
        double.tryParse(
          value.toString(),
        );

        if (parsed != null) {
          return parsed;
        }
      }
    }

    return 0;
  }

  static int _readInt(
      Map<String, dynamic> json,
      List<String> keys,
      ) {
    for (final key in keys) {
      final value = json[key];

      if (value is int) {
        return value;
      }

      if (value is num) {
        return value.toInt();
      }

      if (value != null) {
        final parsed =
        int.tryParse(
          value.toString(),
        );

        if (parsed != null) {
          return parsed;
        }
      }
    }

    return 0;
  }

  static DateTime? _readDateTime(
      Map<String, dynamic> json,
      List<String> keys,
      ) {
    for (final key in keys) {
      final value = json[key];

      if (value == null) {
        continue;
      }

      final date =
      DateTime.tryParse(
        value.toString(),
      );

      if (date != null) {
        return date;
      }
    }

    return null;
  }

  bool get isPositive =>
      changePercent > 0;

  bool get isNegative =>
      changePercent < 0;

  bool get isNeutral =>
      changePercent == 0;
}