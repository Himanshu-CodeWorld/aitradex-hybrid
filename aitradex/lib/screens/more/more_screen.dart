import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../exchange/exchange_stocks_screen.dart';
import '../deposit/deposit_to_aitradex_screen.dart';

const Color _morePrimary = Color(0xff18C48F);

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 110),
              sliver: SliverList.separated(
                itemCount: _moreItems.length,
                separatorBuilder: (_, __) => const Padding(
                  padding: EdgeInsets.only(left: 76),
                  child: Divider(
                    height: 1,
                    thickness: 0.8,
                    color: Color(0xffE9E9E9),
                  ),
                ),
                itemBuilder: (context, index) {
                  return _MoreItemTile(item: _moreItems[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 26, 24, 0),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xffE7FAF4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.bubble_chart_rounded,
              color: _morePrimary,
              size: 23,
            ),
          ),
          const SizedBox(width: 11),
          Text(
            'More',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
              color: const Color(0xff151515),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreItem {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;

  const _MoreItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
  });
}

const List<_MoreItem> _moreItems = [
  _MoreItem(
    title: 'Exchange Stocks',
    description: 'Exchange your stock from one\ncompany to another',
    icon: Icons.swap_vert_rounded,
    iconColor: Color(0xff45CFA7),
    iconBackground: Color(0xffEDF9F3),
  ),
  _MoreItem(
    title: 'Deposit to AiTradeX',
    description: 'Transfer funds instantly to your\nAiTradeX account',
    icon: Icons.download_rounded,
    iconColor: Color(0xffffa01a),
    iconBackground: Color(0xfffff6e9),
  ),
  _MoreItem(
    title: 'Withdraw from Otrade',
    description: 'Transfer money from your Otrade\naccount to your bank',
    icon: Icons.upload_rounded,
    iconColor: Color(0xffff6d7c),
    iconBackground: Color(0xffffeff1),
  ),
  _MoreItem(
    title: 'Funding Activity',
    description: 'Your historical & live fund details\nin and out of Otrade',
    icon: Icons.receipt_long_rounded,
    iconColor: Color(0xff7B5CFF),
    iconBackground: Color(0xffF1EEFF),
  ),
  _MoreItem(
    title: 'Financial Transaction',
    description: 'History of your stock transactions\nin the Otrade stock market',
    icon: Icons.description_rounded,
    iconColor: Color(0xff10B89A),
    iconBackground: Color(0xffEAF9F6),
  ),
  _MoreItem(
    title: 'Payment Methods',
    description: 'Other connected payment\nmethods other than banks',
    icon: Icons.account_balance_wallet_rounded,
    iconColor: Color(0xff3478F6),
    iconBackground: Color(0xffEDF3FF),
  ),
];

class _MoreItemTile extends StatelessWidget {
  const _MoreItemTile({
    required this.item,
  });

  final _MoreItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _handleTap(context, item),
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: 121,
        child: Row(
          children: [
            _buildIcon(),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xff171717),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xff686868),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.chevron_right_rounded,
              color: _morePrimary,
              size: 29,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: item.iconBackground,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: item.iconColor,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(
            item.icon,
            color: Colors.white,
            size: 23,
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, _MoreItem item) {
    if (item.title == 'Exchange Stocks') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const ExchangeStocksScreen(),
        ),
      );
      return;
    }

    if (item.title == 'Deposit to AiTradeX') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const DepositToAiTradeXScreen(),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          item.title,
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 900),
      ),
    );
  }
}
