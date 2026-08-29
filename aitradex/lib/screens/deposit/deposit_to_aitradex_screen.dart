import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _depositPrimary = Color(0xff18C48F);

class DepositToAiTradeXScreen extends StatelessWidget {
  const DepositToAiTradeXScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const _DepositHeader(title: 'Deposit to AiTradeX'),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connected Payment Methods',
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const _PaymentMethodRow(
                      title: 'PayPal',
                      kind: _PaymentLogoKind.paypal,
                    ),
                    const _PaymentMethodRow(
                      title: 'Google Pay',
                      kind: _PaymentLogoKind.google,
                    ),
                    const _PaymentMethodRow(
                      title: 'Apple Pay',
                      kind: _PaymentLogoKind.apple,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 3, bottom: 34),
                      child: Divider(
                        color: Color(0xffE8E8E8),
                        height: 1,
                      ),
                    ),
                    Text(
                      'Or Use a Bank Account',
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _PaymentMethodRow(
                      title: 'Bank of America',
                      subtitle: '⚡ Instant | Free',
                      kind: _PaymentLogoKind.boa,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const DepositAmountScreen(),
                        ),
                      ),
                    ),
                    const _PaymentMethodRow(
                      title: 'JPMorgan Chase Bank',
                      subtitle: '⚡ Instant | Free',
                      kind: _PaymentLogoKind.chase,
                    ),
                    const _PaymentMethodRow(
                      title: 'Citibank',
                      subtitle: '⚡ Instant | Free',
                      kind: _PaymentLogoKind.citi,
                    ),
                    const _PaymentMethodRow(
                      title: 'Wells Fargo Bank',
                      subtitle: '⚡ Instant | Free',
                      kind: _PaymentLogoKind.wells,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DepositAmountScreen extends StatefulWidget {
  const DepositAmountScreen({super.key});

  @override
  State<DepositAmountScreen> createState() => _DepositAmountScreenState();
}

class _DepositAmountScreenState extends State<DepositAmountScreen> {
  final TextEditingController _amountController =
  TextEditingController(text: '20,000');

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double get _amount {
    final value = _amountController.text.replaceAll(',', '').trim();
    return double.tryParse(value) ?? 0;
  }

  String _formatAmount(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^0-9.]'), '');
    if (cleaned.isEmpty) return '';
    final parts = cleaned.split('.');
    final whole = parts.first;
    final buffer = StringBuffer();

    for (int i = 0; i < whole.length; i++) {
      final position = whole.length - i;
      buffer.write(whole[i]);
      if (position > 1 && position % 3 == 1) {
        buffer.write(',');
      }
    }

    if (parts.length > 1) {
      buffer.write('.');
      buffer.write(parts[1]);
    }

    return buffer.toString();
  }

  void _continue() {
    if (_amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a deposit amount.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DepositAwaitingFundsScreen(
          amount: _amount,
        ),
      ),
    );
  }

  void _showCurrencyPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(26),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(
                    '(\$) Deposit in Dollars',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.check_circle_rounded,
                    color: _depositPrimary,
                  ),
                  onTap: () => Navigator.of(sheetContext).pop(),
                ),
                ListTile(
                  title: Text(
                    '€ Deposit in Euros',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () => Navigator.of(sheetContext).pop(),
                ),
                ListTile(
                  title: Text(
                    '£ Deposit in Pounds',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () => Navigator.of(sheetContext).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatted = _amountController.text;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const _DepositHeader(
              title: 'Deposit to AiTradeX',
              showMenu: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
                child: Column(
                  children: [
                    const _SelectedBankRow(),
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Divider(
                        color: Color(0xffE8E8E8),
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: _showCurrencyPicker,
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _depositPrimary,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '(\$) Deposit in Dollars',
                              style: GoogleFonts.poppins(
                                color: _depositPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: _depositPrimary,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      height: 158,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _depositPrimary,
                          width: 2,
                        ),
                      ),
                      child: TextField(
                        controller: _amountController,
                        onChanged: (value) {
                          final formattedValue = _formatAmount(value);
                          if (formattedValue != value) {
                            _amountController.value =
                                _amountController.value.copyWith(
                                  text: formattedValue,
                                  selection: TextSelection.collapsed(
                                    offset: formattedValue.length,
                                  ),
                                );
                          }
                          setState(() {});
                        },
                        textAlign: TextAlign.center,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9.,]'),
                          ),
                        ],
                        style: GoogleFonts.poppins(
                          fontSize: 46,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -1.2,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixText: '\$',
                          prefixStyle: GoogleFonts.poppins(
                            fontSize: 46,
                            fontWeight: FontWeight.w500,
                          ),
                          hintText: '0',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 46,
                            color: const Color(0xffBBBBBB),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'You will get USD \$${formatted.isEmpty ? '0' : formatted} instantly to your AiTradeX\ncash balance.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xff555555),
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _DepositButton(
              text: 'Make a Deposit',
              onPressed: _continue,
            ),
            const SizedBox(height: 20),
            const _NumberPad(),
          ],
        ),
      ),
    );
  }
}

class DepositAwaitingFundsScreen extends StatelessWidget {
  const DepositAwaitingFundsScreen({
    super.key,
    required this.amount,
  });

  final double amount;

  String _money() {
    return '\$${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
    )}';
  }

  void _copy(BuildContext context, String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(milliseconds: 900),
      ),
    );
  }

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
                padding: const EdgeInsets.fromLTRB(24, 42, 24, 30),
                child: Column(
                  children: [
                    const _BankLogo(size: 100),
                    const SizedBox(height: 18),
                    Text(
                      'Bank of America',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Awaiting funds ⌛',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: const Color(0xff666666),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'We have created a virtual account for you.\nLog into your online banking and make the\ntransfer.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 23),
                      child: Divider(
                        color: Color(0xffE7E7E7),
                        height: 1,
                      ),
                    ),
                    Text(
                      'Instructions',
                      style: GoogleFonts.poppins(
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.7,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(24, 19, 18, 19),
                      decoration: BoxDecoration(
                        color: const Color(0xffFCFCFC),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: const Color(0xffE5E5E5),
                        ),
                      ),
                      child: Column(
                        children: [
                          _InstructionRow(
                            label: 'Amount',
                            value: _money(),
                            onCopy: () => _copy(context, amount.toStringAsFixed(0)),
                          ),
                          const SizedBox(height: 21),
                          _InstructionRow(
                            label: 'Virtual Account no',
                            value: '777791524465',
                            onCopy: () => _copy(context, '777791524465'),
                          ),
                        ],
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
            _DepositButton(
              text: "I've Made the Payment",
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Payment marked as made.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            const SizedBox(height: 22),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 57,
                child: TextButton(
                  onPressed: () => Navigator.of(context).popUntil(
                        (route) => route.isFirst,
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xffE8FAF5),
                    foregroundColor: _depositPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Make Payment Later',
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

class _DepositHeader extends StatelessWidget {
  const _DepositHeader({
    required this.title,
    this.showMenu = false,
  });

  final String title;
  final bool showMenu;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
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
                fontSize: 22,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
              ),
            ),
          ),
          if (showMenu)
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 1.6,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.more_horiz_rounded,
                size: 18,
              ),
            ),
        ],
      ),
    );
  }
}

class _SelectedBankRow extends StatelessWidget {
  const _SelectedBankRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _BankLogo(size: 60),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bank of America',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '⚡ Instant | Free',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xff777777),
                ),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.edit_outlined,
          color: _depositPrimary,
          size: 22,
        ),
      ],
    );
  }
}

enum _PaymentLogoKind {
  paypal,
  google,
  apple,
  boa,
  chase,
  citi,
  wells,
}

class _PaymentMethodRow extends StatelessWidget {
  const _PaymentMethodRow({
    required this.title,
    required this.kind,
    this.subtitle,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final _PaymentLogoKind kind;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 91,
        child: Row(
          children: [
            _PaymentLogo(kind: kind),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle!,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        color: const Color(0xff777777),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: _depositPrimary,
              size: 26,
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentLogo extends StatelessWidget {
  const _PaymentLogo({required this.kind});

  final _PaymentLogoKind kind;

  @override
  Widget build(BuildContext context) {
    Color background;
    String text;

    switch (kind) {
      case _PaymentLogoKind.paypal:
        background = const Color(0xff287BEA);
        text = 'P';
        break;
      case _PaymentLogoKind.google:
        background = Colors.white;
        text = 'G';
        break;
      case _PaymentLogoKind.apple:
        background = const Color(0xff111111);
        text = '●';
        break;
      case _PaymentLogoKind.boa:
        background = const Color(0xffE31837);
        text = 'B';
        break;
      case _PaymentLogoKind.chase:
        background = const Color(0xff1162A5);
        text = 'J';
        break;
      case _PaymentLogoKind.citi:
        background = const Color(0xff073B82);
        text = 'citi';
        break;
      case _PaymentLogoKind.wells:
        background = const Color(0xffD71920);
        text = 'W';
        break;
    }

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: kind == _PaymentLogoKind.google
            ? Border.all(color: const Color(0xffEEEEEE))
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: kind == _PaymentLogoKind.google
              ? const Color(0xff4285F4)
              : Colors.white,
          fontSize: kind == _PaymentLogoKind.citi ? 18 : 28,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _BankLogo extends StatelessWidget {
  const _BankLogo({this.size = 76});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xffE31837),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.account_balance_rounded,
          color: Colors.white,
          size: 43,
        ),
      ),
    );
  }
}

class _InstructionRow extends StatelessWidget {
  const _InstructionRow({
    required this.label,
    required this.value,
    required this.onCopy,
  });

  final String label;
  final String value;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Row(
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
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: onCopy,
          child: const Icon(
            Icons.copy_outlined,
            color: _depositPrimary,
            size: 22,
          ),
        ),
      ],
    );
  }
}

class _DepositButton extends StatelessWidget {
  const _DepositButton({
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
            backgroundColor: _depositPrimary,
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
              ),
            ),
          );
        },
      ),
    );
  }
}
