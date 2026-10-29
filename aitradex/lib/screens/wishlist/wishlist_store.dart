import 'package:shared_preferences/shared_preferences.dart';

/// Shared, local watchlist state used by Dashboard/Invest/Markets/StockDetails.
class WishlistStore {
  WishlistStore._();

  static const String _key = 'aitradex_wishlist_symbols';

  static Future<Set<String>> load({
    required List<String> defaultSymbols,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_key)) {
      final Set<String> defaults =
      defaultSymbols.map(_normalize).where((e) => e.isNotEmpty).toSet();
      await prefs.setStringList(_key, defaults.toList());
      return defaults;
    }

    final List<String> values = prefs.getStringList(_key) ?? <String>[];
    return values.map(_normalize).where((e) => e.isNotEmpty).toSet();
  }

  static Future<bool> contains(String symbol) async {
    final Set<String> values = await load(defaultSymbols: <String>[]);
    return values.contains(_normalize(symbol));
  }

  static Future<void> set(String symbol, bool enabled) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Set<String> values =
    (prefs.getStringList(_key) ?? <String>[])
        .map(_normalize)
        .where((e) => e.isNotEmpty)
        .toSet();

    final String normalized = _normalize(symbol);
    if (normalized.isEmpty) return;

    if (enabled) {
      values.add(normalized);
    } else {
      values.remove(normalized);
    }

    await prefs.setStringList(_key, values.toList());
  }

  static String _normalize(String value) => value.trim().toUpperCase();
}
