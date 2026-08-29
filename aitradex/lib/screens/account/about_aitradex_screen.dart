import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color kAiTradeXGreen = Color(0xff18C48F);

TextStyle _titleStyle() => GoogleFonts.poppins(
  fontSize: 23,
  fontWeight: FontWeight.w600,
  color: const Color(0xff171717),
);

TextStyle _bodyStyle() => GoogleFonts.poppins(
  fontSize: 15,
  color: const Color(0xff222222),
);

class SettingsHeader extends StatelessWidget {
  const SettingsHeader({
    super.key,
    required this.title,
    required this.onBack,
    this.trailing,
  });

  final String title;
  final VoidCallback onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: onBack,
          borderRadius: BorderRadius.circular(24),
          child: const SizedBox(
            width: 34,
            height: 34,
            child: Icon(Icons.arrow_back_rounded, size: 28),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(title, style: _titleStyle())),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class SettingSwitchRow extends StatelessWidget {
  const SettingSwitchRow({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 61,
      child: Row(
        children: [
          Expanded(child: Text(title, style: _bodyStyle())),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: kAiTradeXGreen,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xffECECEC),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}

class AboutAiTradeXScreen extends StatelessWidget {
  const AboutAiTradeXScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      'Job Vacancy',
      'Fees',
      'Developer',
      'Partner',
      'Privacy Policy',
      'Accessibility',
      'Feedback',
      'Rate us',
      'Visit Our Website',
      'Follow us on Social Media',
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Column(
            children: [
              SettingsHeader(
                title: 'About AiTradeX',
                onBack: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 38),
              const _AiTradeXLogo(),
              const SizedBox(height: 27),
              Text(
                'AiTradeX v5.6.9',
                style: GoogleFonts.poppins(
                  fontSize: 23,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 22),
              const Divider(height: 1, color: Color(0xffE8E8E8)),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (_, index) {
                    return InkWell(
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${items[index]} selected.')),
                      ),
                      child: SizedBox(
                        height: 57,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(items[index], style: _bodyStyle()),
                            ),
                            const Icon(Icons.chevron_right_rounded, size: 24),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AiTradeXLogo extends StatelessWidget {
  const _AiTradeXLogo();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 115,
      height: 115,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 67,
            height: 67,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: kAiTradeXGreen,
            ),
          ),
          Container(
            width: 39,
            height: 39,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
          const Positioned(
            top: 8,
            right: 27,
            child: _Dot(size: 18),
          ),
          const Positioned(
            top: 24,
            right: 9,
            child: _Dot(size: 12),
          ),
          const Positioned(
            top: 5,
            left: 41,
            child: _Dot(size: 9),
          ),
          const Positioned(
            top: 38,
            right: 1,
            child: _Dot(size: 8),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: const BoxDecoration(
      color: kAiTradeXGreen,
      shape: BoxShape.circle,
    ),
  );
}
