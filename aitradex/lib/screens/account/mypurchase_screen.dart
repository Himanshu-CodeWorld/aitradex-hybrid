import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyPurchaseScreen extends StatelessWidget {
  const MyPurchaseScreen({super.key});

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
        title: Text('My Purchases',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _surface(context),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: _text(context).withValues(alpha: .08)),
            ),
            child: Row(
              children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: .10),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(Icons.shopping_bag_outlined,
                      color: primary, size: 24),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your purchases',
                          style: GoogleFonts.poppins(
                              color: _text(context), fontSize: 13, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 3),
                      Text('Subscriptions, digital products and eligible orders.',
                          style: GoogleFonts.poppins(
                              color: _muted(context), fontSize: 9, height: 1.35)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _filterBar(context, primary),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.fromLTRB(22, 30, 22, 30),
            decoration: BoxDecoration(
              color: _surface(context),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _text(context).withValues(alpha: .08)),
            ),
            child: Column(
              children: [
                Container(
                  width: 68, height: 68,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: .10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.receipt_long_outlined,
                      color: primary, size: 31),
                ),
                const SizedBox(height: 14),
                Text('No purchases yet',
                    style: GoogleFonts.poppins(
                        color: _text(context), fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 5),
                Text(
                  'Your completed AiTradeX purchases will appear here.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      color: _muted(context), fontSize: 9.5, height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Purchase information',
              style: GoogleFonts.poppins(
                  color: _text(context), fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(
            'This screen is ready for your authenticated purchase-history API.',
            style: GoogleFonts.poppins(
                color: _muted(context), fontSize: 9.5, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _filterBar(BuildContext context, Color primary) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _text(context).withValues(alpha: .08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: primary.withValues(alpha: .10),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text('All',
                  style: GoogleFonts.poppins(
                      color: primary, fontSize: 9.5, fontWeight: FontWeight.w700)),
            ),
          ),
          Expanded(
            child: Center(
              child: Text('Subscriptions',
                  style: GoogleFonts.poppins(
                      color: _muted(context), fontSize: 9, fontWeight: FontWeight.w600)),
            ),
          ),
          Expanded(
            child: Center(
              child: Text('Products',
                  style: GoogleFonts.poppins(
                      color: _muted(context), fontSize: 9, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
