import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CoinTransaction {
  final String id;
  final String title;
  final String subtitle;
  final int amount;
  final DateTime? createdAt;

  const CoinTransaction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    this.createdAt,
  });
}

class AiTradeXCoinsHistoryScreen extends StatefulWidget {
  final int coinBalance;
  final List<CoinTransaction> transactions;
  final Future<void> Function()? onRefresh;

  const AiTradeXCoinsHistoryScreen({
    super.key,
    required this.coinBalance,
    required this.transactions,
    this.onRefresh,
  });

  @override
  State<AiTradeXCoinsHistoryScreen> createState() =>
      _AiTradeXCoinsHistoryScreenState();
}

class _AiTradeXCoinsHistoryScreenState
    extends State<AiTradeXCoinsHistoryScreen> {
  Color _primary(BuildContext context) =>
      Theme.of(context).colorScheme.primary;

  Color _surface(BuildContext context) =>
      Theme.of(context).colorScheme.surface;

  Color _text(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  Color _muted(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.62);

  Color _border(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Coin History',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (widget.onRefresh != null) {
            await widget.onRefresh!();
            if (mounted) {
              setState(() {});
            }
          }
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
          children: <Widget>[
            _buildBalanceCard(context),
            const SizedBox(height: 16),
            if (widget.transactions.isEmpty)
              _buildEmptyState(context)
            else
              ...List<Widget>.generate(
                widget.transactions.length,
                    (int index) => Padding(
                  padding: EdgeInsets.only(
                    bottom: index == widget.transactions.length - 1 ? 0 : 9,
                  ),
                  child: _buildHistoryCard(
                    context,
                    widget.transactions[index],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    final Color primary = _primary(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            primary,
            primary.withValues(alpha: 0.70),
          ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: primary.withValues(alpha: 0.20),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.monetization_on_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Available balance',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.coinBalance} Coins',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '₹${widget.coinBalance} available',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.account_balance_wallet_rounded,
            color: Colors.white,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final Color primary = _primary(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      decoration: BoxDecoration(
        color: _surface(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border(context)),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history_rounded,
              color: primary,
              size: 35,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'No coin history yet',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: _text(context),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Your coin purchases, rewards, refunds and stock '
                'intelligence unlocks will appear here.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: _muted(context),
              fontSize: 10,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(
      BuildContext context,
      CoinTransaction transaction,
      ) {
    final bool isCredit = transaction.amount > 0;
    final bool isZero = transaction.amount == 0;

    final Color amountColor = isZero
        ? _muted(context)
        : isCredit
        ? _primary(context)
        : Theme.of(context).colorScheme.error;

    final IconData icon = isZero
        ? Icons.swap_horiz_rounded
        : isCredit
        ? Icons.south_west_rounded
        : Icons.north_east_rounded;

    final String amountText = isZero
        ? '0'
        : '${isCredit ? '+' : ''}${transaction.amount}';

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: _surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: amountColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: amountColor, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  transaction.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: _text(context),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  transaction.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: _muted(context),
                    fontSize: 8.5,
                    height: 1.3,
                  ),
                ),
                if (transaction.createdAt != null) ...<Widget>[
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(transaction.createdAt!),
                    style: GoogleFonts.poppins(
                      color: _muted(context),
                      fontSize: 7.8,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                amountText,
                style: GoogleFonts.poppins(
                  color: amountColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Coins',
                style: GoogleFonts.poppins(
                  color: _muted(context),
                  fontSize: 7.5,
                ),
              ),
              if (transaction.amount != 0)
                Text(
                  '₹${transaction.amount.abs()}',
                  style: GoogleFonts.poppins(
                    color: _muted(context),
                    fontSize: 7.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final DateTime local = dateTime.toLocal();

    String twoDigits(int value) => value.toString().padLeft(2, '0');

    return '${twoDigits(local.day)}/${twoDigits(local.month)}/${local.year} '
        '${twoDigits(local.hour)}:${twoDigits(local.minute)}';
  }
}
