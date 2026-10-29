import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AddBrokerScreen extends StatefulWidget {
  const AddBrokerScreen({super.key});

  @override
  State<AddBrokerScreen> createState() => _AddBrokerScreenState();
}

class _AddBrokerScreenState extends State<AddBrokerScreen> {
  String? _connectingBroker;

  Color _primary(BuildContext c) => Theme.of(c).colorScheme.primary;
  Color _surface(BuildContext c) => Theme.of(c).colorScheme.surface;
  Color _text(BuildContext c) => Theme.of(c).colorScheme.onSurface;
  Color _muted(BuildContext c) =>
      Theme.of(c).colorScheme.onSurface.withValues(alpha: .62);

  @override
  Widget build(BuildContext context) {
    final primary = _primary(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Broker',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: LinearGradient(
                  colors: [primary.withValues(alpha: .16), _surface(context)],
                ),
                border: Border.all(color: primary.withValues(alpha: .20)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 54, height: 54,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: Icon(Icons.account_balance_rounded,
                        color: primary, size: 27),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Connect your broker',
                            style: GoogleFonts.poppins(
                              color: _text(context),
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            )),
                        const SizedBox(height: 4),
                        Text(
                          'Bring your real holdings and positions into AiTradeX.',
                          style: GoogleFonts.poppins(
                            color: _muted(context), fontSize: 10, height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Popular brokers',
                style: GoogleFonts.poppins(
                    color: _text(context), fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            _broker(context, 'Upstox', 'Holdings and positions',
                Icons.trending_up_rounded, const Color(0xFF5B35D5), 'upstox'),
            _broker(context, 'Dhan', 'Connect your Dhan portfolio',
                Icons.account_balance_wallet_outlined, const Color(0xFF1565C0), 'dhan'),
            _broker(context, 'Zerodha', 'Kite portfolio connection',
                Icons.show_chart_rounded, const Color(0xFF387ED1), 'zerodha'),
            _broker(context, 'Groww', 'Investment portfolio connection',
                Icons.savings_outlined, const Color(0xFF00A86B), 'groww'),
            _broker(context, 'Angel One', 'Connect your Angel One account',
                Icons.currency_rupee_rounded, const Color(0xFFE53935), 'angel_one'),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: _surface(context),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _text(context).withValues(alpha: .08)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lock_outline_rounded, color: primary, size: 19),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Use the broker OAuth flow. Never paste a broker password or API secret into the mobile app.',
                      style: GoogleFonts.poppins(
                        color: _muted(context), fontSize: 9.5, height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _broker(BuildContext context, String name, String subtitle, IconData icon,
      Color color, String id) {
    final loading = _connectingBroker == id;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _text(context).withValues(alpha: .08)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: loading ? null : () => _connect(id, name),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .11),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: GoogleFonts.poppins(
                              color: _text(context), fontSize: 12, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 3),
                      Text(subtitle,
                          style: GoogleFonts.poppins(
                              color: _muted(context), fontSize: 8.5, height: 1.25)),
                    ],
                  ),
                ),
                loading
                    ? SizedBox(
                        width: 21, height: 21,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: _primary(context)))
                    : Icon(Icons.chevron_right_rounded, color: _muted(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _connect(String id, String name) async {
    HapticFeedback.lightImpact();
    setState(() => _connectingBroker = id);
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    setState(() => _connectingBroker = null);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name OAuth connection is ready to integrate.',
            style: GoogleFonts.poppins(fontSize: 10)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
