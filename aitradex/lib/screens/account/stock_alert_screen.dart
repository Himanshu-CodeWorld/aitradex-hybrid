import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// AiTradeX Stock Alerts
///
/// UI-first screen for managing price/percentage alerts.
/// The list is kept locally in this screen for now; a backend/API can be
/// connected later without changing the navigation from Account.
class StockAlertScreen extends StatefulWidget {
  const StockAlertScreen({super.key});

  @override
  State<StockAlertScreen> createState() => _StockAlertScreenState();
}

class _StockAlertScreenState extends State<StockAlertScreen> {
  final List<_StockAlert> _alerts = [];

  Color _primary(BuildContext context) =>
      Theme.of(context).colorScheme.primary;

  Color _surface(BuildContext context) =>
      Theme.of(context).colorScheme.surface;

  Color _text(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  Color _secondary(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.62);

  Color _border(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.10);

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final primary = _primary(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(
          'Stock Alerts',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Add alert',
            onPressed: _openAddAlert,
            icon: const Icon(Icons.add_alert_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: _alerts.isEmpty
            ? _buildEmptyState(context)
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
                itemCount: _alerts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, index) {
                  final alert = _alerts[index];
                  return _buildAlertCard(context, alert, index);
                },
              ),
      ),
      floatingActionButton: _alerts.isEmpty
          ? FloatingActionButton.extended(
              onPressed: _openAddAlert,
              backgroundColor: primary,
              foregroundColor: _isDark(context) ? Colors.black : Colors.white,
              icon: const Icon(Icons.add_alert_rounded),
              label: Text(
                'Create Alert',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final primary = _primary(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 34),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
                border: Border.all(
                  color: primary.withValues(alpha: 0.18),
                ),
              ),
              child: Icon(
                Icons.notifications_active_outlined,
                color: primary,
                size: 38,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No stock alerts yet',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: _text(context),
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'Create an alert to get notified when a stock reaches your target price or percentage.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: _secondary(context),
                fontSize: 10.5,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(
    BuildContext context,
    _StockAlert alert,
    int index,
  ) {
    final primary = _primary(context);

    return Dismissible(
      key: ValueKey(alert.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
        ),
      ),
      onDismissed: (_) {
        setState(() => _alerts.removeAt(index));
        _showMessage('Alert deleted.');
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showAlertDetails(alert),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _surface(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _border(context)),
              boxShadow: [
                if (!_isDark(context))
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.035),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.notifications_active_rounded,
                    color: primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert.symbol,
                        style: GoogleFonts.poppins(
                          color: _text(context),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        alert.condition,
                        style: GoogleFonts.poppins(
                          color: _secondary(context),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: alert.enabled,
                  activeColor: primary,
                  onChanged: (value) {
                    setState(() => alert.enabled = value);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openAddAlert() async {
    HapticFeedback.lightImpact();

    final result = await showModalBottomSheet<_StockAlert>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _surface(context),
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const _CreateAlertSheet(),
    );

    if (!mounted || result == null) return;

    setState(() => _alerts.add(result));
    _showMessage('Stock alert created.');
  }

  void _showAlertDetails(_StockAlert alert) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _surface(context),
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        final primary = _primary(sheetContext);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  alert.symbol,
                  style: GoogleFonts.poppins(
                    color: _text(sheetContext),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  alert.condition,
                  style: GoogleFonts.poppins(
                    color: _secondary(sheetContext),
                    fontSize: 10.5,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      _showMessage('Alert settings are ready to edit.');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor:
                          _isDark(sheetContext) ? Colors.black : Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Manage Alert',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.poppins(fontSize: 10.5),
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }
}

class _StockAlert {
  _StockAlert({
    required this.id,
    required this.symbol,
    required this.condition,
  }) : enabled = true;

  final String id;
  final String symbol;
  final String condition;
  bool enabled;
}

class _CreateAlertSheet extends StatefulWidget {
  const _CreateAlertSheet();

  @override
  State<_CreateAlertSheet> createState() => _CreateAlertSheetState();
}

class _CreateAlertSheetState extends State<_CreateAlertSheet> {
  final _symbolController = TextEditingController();
  final _targetController = TextEditingController();
  String _condition = 'Price reaches';
  String _direction = 'above';

  @override
  void dispose() {
    _symbolController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  Color _primary(BuildContext context) =>
      Theme.of(context).colorScheme.primary;

  @override
  Widget build(BuildContext context) {
    final primary = _primary(context);
    final text = Theme.of(context).colorScheme.onSurface;
    final secondary = text.withValues(alpha: 0.62);

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          8,
          20,
          MediaQuery.viewInsetsOf(context).bottom + 25,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create Stock Alert',
              style: GoogleFonts.poppins(
                color: text,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Choose a stock and the condition you want to track.',
              style: GoogleFonts.poppins(
                color: secondary,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _symbolController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Stock symbol',
                hintText: 'Example: RELIANCE',
                prefixIcon: Icon(Icons.show_chart_rounded),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _condition,
              decoration: const InputDecoration(
                labelText: 'Alert type',
                prefixIcon: Icon(Icons.tune_rounded),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Price reaches',
                  child: Text('Price reaches'),
                ),
                DropdownMenuItem(
                  value: 'Percentage changes',
                  child: Text('Percentage changes'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _condition = value);
                }
              },
            ),
            const SizedBox(height: 12),
            if (_condition == 'Price reaches')
              DropdownButtonFormField<String>(
                initialValue: _direction,
                decoration: const InputDecoration(
                  labelText: 'Direction',
                  prefixIcon: Icon(Icons.trending_up_rounded),
                ),
                items: const [
                  DropdownMenuItem(value: 'above', child: Text('Above')),
                  DropdownMenuItem(value: 'below', child: Text('Below')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _direction = value);
                  }
                },
              ),
            if (_condition == 'Price reaches') const SizedBox(height: 12),
            TextField(
              controller: _targetController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Target value',
                hintText: _condition == 'Price reaches' ? '2500' : '5',
                prefixIcon: const Icon(Icons.flag_outlined),
                suffixText:
                    _condition == 'Price reaches' ? '₹' : '%',
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _create,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor:
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.black
                          : Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Create Alert',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _create() {
    final symbol = _symbolController.text.trim().toUpperCase();
    final target = _targetController.text.trim();

    if (symbol.isEmpty || target.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a stock symbol and target value.')),
      );
      return;
    }

    final condition = _condition == 'Price reaches'
        ? 'Price ${_direction == 'above' ? 'above' : 'below'} ₹$target'
        : 'Daily change reaches $target%';

    Navigator.of(context).pop(
      _StockAlert(
        id: '${DateTime.now().microsecondsSinceEpoch}',
        symbol: symbol,
        condition: condition,
      ),
    );
  }
}
