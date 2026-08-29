import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _exchangePrimary = Color(0xff18C48F);

class ExchangeStocksScreen extends StatefulWidget {
  const ExchangeStocksScreen({super.key});

  @override
  State<ExchangeStocksScreen> createState() => _ExchangeStocksScreenState();
}

class _ExchangeStocksScreenState extends State<ExchangeStocksScreen> {
  final TextEditingController _amountController =
  TextEditingController(text: '10,000');

  String _fromSymbol = 'SPOT';
  String _fromCompany = 'Spotify';
  String _toSymbol = 'TSLA';
  String _toCompany = 'Tesla';

  final Map<String, String> _companies = const {
    'SPOT': 'Spotify',
    'TSLA': 'Tesla',
    'AAPL': 'Apple',
    'META': 'Meta',
    'AMZN': 'Amazon',
  };

  final Map<String, String> _prices = const {
    'SPOT': '71.05',
    'TSLA': '207.47',
    'AAPL': '260.45',
    'META': '744.85',
    'AMZN': '90.96',
  };

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double get _amount {
    final cleaned = _amountController.text.replaceAll(',', '').trim();
    return double.tryParse(cleaned) ?? 0;
  }

  String _money(double value) {
    return '\$${value.toStringAsFixed(2)}';
  }

  void _continue() {
    final amount = _amount;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter an exchange amount.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PreviewExchangeScreen(
          amount: amount,
          fromCompany: _fromCompany,
          fromSymbol: _fromSymbol,
          toCompany: _toCompany,
          toSymbol: _toSymbol,
          fromPrice: double.parse(_prices[_fromSymbol]!),
          toPrice: double.parse(_prices[_toSymbol]!),
        ),
      ),
    );
  }

  void _showStockPicker({
    required bool from,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: _companies.entries.map((entry) {
              final selected =
              from ? entry.key == _fromSymbol : entry.key == _toSymbol;

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                leading: _CompanyLogo(symbol: entry.key),
                title: Text(
                  entry.value,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  entry.key,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xff777777),
                  ),
                ),
                trailing: selected
                    ? const Icon(
                  Icons.check_circle_rounded,
                  color: _exchangePrimary,
                )
                    : null,
                onTap: () {
                  setState(() {
                    if (from) {
                      _fromSymbol = entry.key;
                      _fromCompany = entry.value;
                    } else {
                      _toSymbol = entry.key;
                      _toCompany = entry.value;
                    }
                  });
                  Navigator.of(sheetContext).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _ExchangeHeader(
              title: 'Exchange Stocks',
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 25, 24, 20),
                child: Column(
                  children: [
                    _AmountStockField(
                      controller: _amountController,
                      symbol: _fromSymbol,
                      onStockTap: () => _showStockPicker(from: true),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    _ExchangeDivider(),
                    const SizedBox(height: 16),
                    _AmountStockField(
                      controller: TextEditingController(text: '\$ ${_money(_amount).substring(1)}'),
                      enabled: false,
                      symbol: _toSymbol,
                      onStockTap: () => _showStockPicker(from: false),
                    ),
                    const SizedBox(height: 23),
                    const Divider(
                      color: Color(0xffE8E8E8),
                      height: 1,
                    ),
                    const SizedBox(height: 26),
                    Text(
                      'Balance stock available in $_fromSymbol : \$22,935.46',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        color: const Color(0xff5F5F5F),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _BottomActionButton(
              text: 'Continue',
              onPressed: _continue,
            ),
            const SizedBox(height: 22),
            const _NumberPad(),
          ],
        ),
      ),
    );
  }
}

class PreviewExchangeScreen extends StatelessWidget {
  const PreviewExchangeScreen({
    super.key,
    required this.amount,
    required this.fromCompany,
    required this.fromSymbol,
    required this.toCompany,
    required this.toSymbol,
    required this.fromPrice,
    required this.toPrice,
  });

  final double amount;
  final String fromCompany;
  final String fromSymbol;
  final String toCompany;
  final String toSymbol;
  final double fromPrice;
  final double toPrice;

  void _exchange(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ExchangeSuccessScreen(
          amount: amount,
          fromCompany: fromCompany,
          fromSymbol: fromSymbol,
          toCompany: toCompany,
          toSymbol: toSymbol,
        ),
      ),
    );
  }

  String _money(double value) => '\$${value.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    const fee = 25.0;
    final proceeds = amount + fee;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _ExchangeHeader(
              title: 'Preview Exchange',
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 27, 24, 30),
                child: Column(
                  children: [
                    _CompactExchangePair(
                      fromCompany: fromCompany,
                      fromSymbol: fromSymbol,
                      toCompany: toCompany,
                      toSymbol: toSymbol,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(24, 25, 24, 24),
                      decoration: BoxDecoration(
                        color: const Color(0xffFBFBFB),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: const Color(0xffE7E7E7),
                        ),
                      ),
                      child: Column(
                        children: [
                          _PreviewRow(
                            label: 'Market Price $fromSymbol',
                            value: _money(fromPrice),
                          ),
                          _PreviewRow(
                            label: 'Market Price $toSymbol',
                            value: _money(toPrice),
                          ),
                          _PreviewRow(
                            label: 'Number of Shares',
                            value: '0.017365862',
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 9),
                            child: Divider(
                              color: Color(0xffE8E8E8),
                              height: 1,
                            ),
                          ),
                          _PreviewRow(
                            label: 'Amount',
                            value: _money(amount),
                          ),
                          _PreviewRow(
                            label: 'Exchange Fee',
                            value: _money(fee),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 9),
                            child: Divider(
                              color: Color(0xffE8E8E8),
                              height: 1,
                            ),
                          ),
                          _PreviewRow(
                            label: 'Total Proceeds',
                            value: _money(proceeds),
                            valueColor: _exchangePrimary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _BottomActionButton(
              text: 'Exchanging Now',
              onPressed: () => _exchange(context),
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}

class ExchangeSuccessScreen extends StatelessWidget {
  const ExchangeSuccessScreen({
    super.key,
    required this.amount,
    required this.fromCompany,
    required this.fromSymbol,
    required this.toCompany,
    required this.toSymbol,
  });

  final double amount;
  final String fromCompany;
  final String fromSymbol;
  final String toCompany;
  final String toSymbol;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 38, 24, 20),
                child: Column(
                  children: [
                    _LargeExchangePair(
                      fromCompany: fromCompany,
                      fromSymbol: fromSymbol,
                      toCompany: toCompany,
                      toSymbol: toSymbol,
                    ),
                    const SizedBox(height: 24),
                    const Divider(
                      color: Color(0xffE8E8E8),
                      height: 1,
                    ),
                    const SizedBox(height: 29),
                    const _CelebrationArt(),
                    const SizedBox(height: 19),
                    Text(
                      '\$${amount.toStringAsFixed(0).replaceAllMapped(
                        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                            (m) => '${m[1]},',
                      )}',
                      style: GoogleFonts.poppins(
                        color: _exchangePrimary,
                        fontSize: 46,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -1.5,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'Exchange Order Received!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Your order has been received and will be\nexecuted as soon as the market opens',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: const Color(0xff666666),
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(
              color: Color(0xffEEEEEE),
              height: 1,
            ),
            const SizedBox(height: 22),
            _BottomActionButton(
              text: 'View My Portfolio',
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
            const SizedBox(height: 22),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 57,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xffE8FAF5),
                    foregroundColor: _exchangePrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Back to Menu',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _ExchangeHeader extends StatelessWidget {
  const _ExchangeHeader({
    required this.title,
    required this.onBack,
  });

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            icon: const Icon(
              Icons.arrow_back_rounded,
              size: 27,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 23,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
              ),
            ),
          ),
          if (title == 'Exchange Stocks')
            const Icon(
              Icons.more_horiz_rounded,
              size: 27,
            ),
        ],
      ),
    );
  }
}

class _AmountStockField extends StatelessWidget {
  const _AmountStockField({
    required this.controller,
    required this.symbol,
    required this.onStockTap,
    this.enabled = true,
    this.onChanged,
  });

  final TextEditingController controller;
  final String symbol;
  final VoidCallback onStockTap;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      decoration: BoxDecoration(
        color: enabled ? const Color(0xffFBFFFD) : const Color(0xffFBFBFB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: enabled ? _exchangePrimary : const Color(0xffF0F0F0),
          width: enabled ? 1 : 0.8,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              onChanged: onChanged,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: GoogleFonts.poppins(
                fontSize: 21,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                prefixText: '\$ ',
                prefixStyle: GoogleFonts.poppins(
                  fontSize: 21,
                  color: const Color(0xff555555),
                ),
                contentPadding: const EdgeInsets.only(left: 18),
              ),
            ),
          ),
          InkWell(
            onTap: onStockTap,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  _CompanyLogo(symbol: symbol, size: 34),
                  const SizedBox(width: 10),
                  Text(
                    symbol,
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExchangeDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            color: Color(0xffE6E6E6),
            height: 1,
          ),
        ),
        Container(
          width: 56,
          height: 56,
          margin: const EdgeInsets.symmetric(horizontal: 14),
          decoration: const BoxDecoration(
            color: Color(0xffEEF9F5),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.swap_vert_rounded,
            color: _exchangePrimary,
            size: 25,
          ),
        ),
        const Expanded(
          child: Divider(
            color: Color(0xffE6E6E6),
            height: 1,
          ),
        ),
      ],
    );
  }
}

class _CompactExchangePair extends StatelessWidget {
  const _CompactExchangePair({
    required this.fromCompany,
    required this.fromSymbol,
    required this.toCompany,
    required this.toSymbol,
  });

  final String fromCompany;
  final String fromSymbol;
  final String toCompany;
  final String toSymbol;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _PairStock(
          company: fromCompany,
          symbol: fromSymbol,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Icon(
            Icons.arrow_forward_rounded,
            size: 23,
          ),
        ),
        _PairStock(
          company: toCompany,
          symbol: toSymbol,
        ),
      ],
    );
  }
}

class _PairStock extends StatelessWidget {
  const _PairStock({
    required this.company,
    required this.symbol,
  });

  final String company;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          _CompanyLogo(symbol: symbol, size: 60),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  company,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  symbol,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xff777777),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LargeExchangePair extends StatelessWidget {
  const _LargeExchangePair({
    required this.fromCompany,
    required this.fromSymbol,
    required this.toCompany,
    required this.toSymbol,
  });

  final String fromCompany;
  final String fromSymbol;
  final String toCompany;
  final String toSymbol;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LargePairStock(
          company: fromCompany,
          symbol: fromSymbol,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 25),
          child: Icon(
            Icons.arrow_forward_rounded,
            size: 32,
          ),
        ),
        _LargePairStock(
          company: toCompany,
          symbol: toSymbol,
        ),
      ],
    );
  }
}

class _LargePairStock extends StatelessWidget {
  const _LargePairStock({
    required this.company,
    required this.symbol,
  });

  final String company;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _CompanyLogo(symbol: symbol, size: 80),
        const SizedBox(height: 14),
        Text(
          company,
          style: GoogleFonts.poppins(
            fontSize: 23,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          symbol,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: const Color(0xff666666),
          ),
        ),
      ],
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({
    required this.label,
    required this.value,
    this.valueColor = const Color(0xff181818),
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: const Color(0xff555555),
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: valueColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActionButton extends StatelessWidget {
  const _BottomActionButton({
    required this.text,
    required this.onPressed,
  });

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 59,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: _exchangePrimary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _CompanyLogo extends StatelessWidget {
  const _CompanyLogo({
    required this.symbol,
    this.size = 76,
  });

  final String symbol;
  final double size;

  @override
  Widget build(BuildContext context) {
    Color background;
    String mark;

    switch (symbol) {
      case 'SPOT':
        background = const Color(0xff1ED760);
        mark = 'S';
        break;
      case 'TSLA':
        background = const Color(0xffD90000);
        mark = 'T';
        break;
      case 'AAPL':
        background = const Color(0xff111111);
        mark = 'A';
        break;
      case 'META':
        background = const Color(0xff1877F2);
        mark = '∞';
        break;
      case 'AMZN':
        background = const Color(0xff222222);
        mark = 'a';
        break;
      default:
        background = _exchangePrimary;
        mark = symbol.substring(0, 1);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        mark,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: size * 0.32,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _NumberPad extends StatelessWidget {
  const _NumberPad();

  @override
  Widget build(BuildContext context) {
    const keys = [
      '1', '2', '3',
      '4', '5', '6',
      '7', '8', '9',
      '*', '0', '⌫',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(35, 12, 35, 22),
      decoration: const BoxDecoration(
        color: Color(0xffFBFBFB),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(38),
        ),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: keys.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisExtent: 64,
          crossAxisSpacing: 25,
          mainAxisSpacing: 0,
        ),
        itemBuilder: (_, index) {
          return Center(
            child: Text(
              keys[index],
              style: GoogleFonts.poppins(
                fontSize: keys[index] == '⌫' ? 18 : 22,
                fontWeight: FontWeight.w400,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CelebrationArt extends StatelessWidget {
  const _CelebrationArt();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 38,
            top: 38,
            child: _Burst(
              color: const Color(0xff7E73FF),
              size: 52,
            ),
          ),
          Positioned(
            right: 28,
            top: 25,
            child: _Burst(
              color: const Color(0xff51DAB2),
              size: 70,
            ),
          ),
          Positioned(
            left: 28,
            top: 105,
            child: _Burst(
              color: const Color(0xffffa126),
              size: 62,
            ),
          ),
          Positioned(
            right: 27,
            top: 112,
            child: _Burst(
              color: const Color(0xffff777f),
              size: 52,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _Umbrella(
                color: const Color(0xffffa900),
                flip: false,
              ),
              const SizedBox(width: 2),
              _Umbrella(
                color: const Color(0xffffa900),
                flip: true,
              ),
            ],
          ),
          Positioned(
            left: 143,
            bottom: 14,
            child: _ConfettiLine(
              color: const Color(0xffF85F70),
              height: 53,
            ),
          ),
          Positioned(
            left: 176,
            bottom: 12,
            child: _ConfettiLine(
              color: const Color(0xff735AFF),
              height: 45,
            ),
          ),
          Positioned(
            right: 137,
            bottom: 13,
            child: _ConfettiLine(
              color: const Color(0xffF85F70),
              height: 55,
            ),
          ),
        ],
      ),
    );
  }
}

class _Burst extends StatelessWidget {
  const _Burst({
    required this.color,
    required this.size,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _BurstPainter(color),
      ),
    );
  }
}

class _BurstPainter extends CustomPainter {
  const _BurstPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * .42;

    for (int i = 0; i < 16; i++) {
      final angle = i * 3.1415926535 * 2 / 16;
      final start = Offset(
        center.dx + radius * .35 * _cos(angle),
        center.dy + radius * .35 * _sin(angle),
      );
      final end = Offset(
        center.dx + radius * _cos(angle),
        center.dy + radius * _sin(angle),
      );
      canvas.drawLine(start, end, paint);
    }
  }

  double _cos(double value) {
    // Small approximation is sufficient for this decorative illustration.
    return math.cos(value);
  }

  double _sin(double value) {
    return math.sin(value);
  }

  @override
  bool shouldRepaint(covariant _BurstPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _Umbrella extends StatelessWidget {
  const _Umbrella({
    required this.color,
    required this.flip,
  });

  final Color color;
  final bool flip;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleX: flip ? -1 : 1,
      child: SizedBox(
        width: 105,
        height: 125,
        child: Stack(
          children: [
            Positioned(
              left: 2,
              right: 2,
              top: 20,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(60),
                    bottom: Radius.circular(18),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 51,
              top: 0,
              child: Container(
                width: 4,
                height: 34,
                color: const Color(0xff222222),
              ),
            ),
            Positioned(
              left: 48,
              top: 1,
              child: Container(
                width: 10,
                height: 12,
                decoration: const BoxDecoration(
                  color: Color(0xff222222),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: 52,
              top: 31,
              child: Container(
                width: 4,
                height: 70,
                color: const Color(0xff222222),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfettiLine extends StatelessWidget {
  const _ConfettiLine({
    required this.color,
    required this.height,
  });

  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9,
      height: height,
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: color,
            width: 6,
          ),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
