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

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  bool contactTab = false;
  String category = 'General';
  String search = '';
  int expanded = 0;

  final List<String> categories = [
    'General', 'Account', 'Service', 'Stocks'
  ];

  final List<String> questions = [
    'What is Otrade?',
    'How to buy stock on Otrade?',
    'How to sell stock on Otrade?',
    'How to exchange stock on Otrade?',
    'How to close an Otrade account?',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          child: Column(
            children: [
              SettingsHeader(
                title: 'Help Center',
                onBack: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 23),
              _tabs(),
              const SizedBox(height: 20),
              Expanded(
                child: contactTab ? _contactView() : _faqView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabs() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => contactTab = false),
            child: _tab('FAQ', !contactTab),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => contactTab = true),
            child: _tab('Contact us', contactTab),
          ),
        ),
      ],
    );
  }

  Widget _tab(String label, bool active) {
    return Container(
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: active ? kAiTradeXGreen : const Color(0xffE8E8E8),
            width: active ? 3 : 1,
          ),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 16,
          color: active ? kAiTradeXGreen : const Color(0xff999999),
          fontWeight: active ? FontWeight.w500 : FontWeight.w400,
        ),
      ),
    );
  }

  Widget _faqView() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final active = categories[i] == category;
              return ChoiceChip(
                label: Text(categories[i]),
                selected: active,
                onSelected: (_) => setState(() => category = categories[i]),
                labelStyle: GoogleFonts.poppins(
                  color: active ? Colors.white : kAiTradeXGreen,
                  fontSize: 13,
                ),
                selectedColor: kAiTradeXGreen,
                backgroundColor: Colors.white,
                side: const BorderSide(color: kAiTradeXGreen),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          onChanged: (value) => setState(() => search = value),
          decoration: InputDecoration(
            hintText: 'Search',
            hintStyle: GoogleFonts.poppins(color: const Color(0xffAAAAAA)),
            prefixIcon: const Icon(Icons.search, color: Color(0xffAAAAAA)),
            suffixIcon: const Icon(Icons.tune_rounded, color: kAiTradeXGreen),
            filled: true,
            fillColor: const Color(0xffF6F6F6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 24),
        ...questions.asMap().entries.map((entry) {
          final index = entry.key;
          final question = entry.value;
          if (search.isNotEmpty &&
              !question.toLowerCase().contains(search.toLowerCase())) {
            return const SizedBox.shrink();
          }
          final open = expanded == index;
          return Container(
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xffE7E7E7)),
              borderRadius: BorderRadius.circular(18),
            ),
            child: InkWell(
              onTap: () => setState(() => expanded = open ? -1 : index),
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(23, 19, 18, 19),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            question,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Icon(
                          open
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: kAiTradeXGreen,
                        ),
                      ],
                    ),
                    if (open) ...[
                      const SizedBox(height: 18),
                      const Divider(height: 1),
                      const SizedBox(height: 16),
                      Text(
                        question == 'What is Otrade?'
                            ? 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.'
                            : 'This help article explains the steps and information you need to complete this action.',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          height: 1.45,
                          color: const Color(0xff444444),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _contactView() {
    final items = [
      (Icons.headset_mic_outlined, 'Customer Service'),
      (Icons.chat_outlined, 'WhatsApp'),
      (Icons.language_rounded, 'Website'),
      (Icons.facebook_rounded, 'Facebook'),
      (Icons.close, 'Twitter'),
      (Icons.camera_alt_outlined, 'Instagram'),
    ];

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 23),
      itemBuilder: (_, i) {
        return InkWell(
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${items[i].$2} selected.')),
          ),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xffE7E7E7)),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Icon(items[i].$1, color: kAiTradeXGreen, size: 23),
                const SizedBox(width: 20),
                Text(
                  items[i].$2,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
