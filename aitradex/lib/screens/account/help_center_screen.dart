
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color kAiTradeXGreen = Color(0xFF18C48F);

TextStyle _titleStyle(BuildContext context) {
  return GoogleFonts.poppins(
    fontSize: 23,
    fontWeight: FontWeight.w600,
    color: Theme.of(context).colorScheme.onSurface,
  );
}

TextStyle _bodyStyle(BuildContext context) {
  return GoogleFonts.poppins(
    fontSize: 15,
    color: Theme.of(context).colorScheme.onSurface,
  );
}

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
    final Color textColor = Theme.of(context).colorScheme.onSurface;

    return Row(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(24),
            child: SizedBox(
              width: 34,
              height: 34,
              child: Icon(
                Icons.arrow_back_rounded,
                size: 28,
                color: textColor,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: _titleStyle(context),
          ),
        ),
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
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 61,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: _bodyStyle(context),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: scheme.primary,
            inactiveThumbColor: scheme.onSurfaceVariant,
            inactiveTrackColor: scheme.surfaceContainerHighest,
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
    'General',
    'Account',
    'Service',
    'Stocks',
  ];

  final List<String> questions = [
    'What is AiTradeX?',
    'How to buy stock on AiTradeX?',
    'How to sell stock on AiTradeX?',
    'How to exchange stock on AiTradeX?',
    'How to close an AiTradeX account?',
  ];

  Color _primary(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  Color _background(BuildContext context) {
    return Theme.of(context).scaffoldBackgroundColor;
  }

  Color _card(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  Color _textPrimary(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  Color _textSecondary(BuildContext context) {
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  Color _border(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return scheme.outline.withValues(
      alpha: Theme.of(context).brightness == Brightness.dark ? 0.34 : 0.18,
    );
  }

  Color _searchBackground(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Theme.of(context).brightness == Brightness.dark
        ? scheme.surfaceContainerHighest.withValues(alpha: 0.55)
        : scheme.surfaceContainerHighest.withValues(alpha: 0.55);
  }

  Color _softPrimary(
      BuildContext context, {
        double alpha = 0.10,
      }) {
    return _primary(context).withValues(alpha: alpha);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background(context),
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
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => contactTab = false),
            child: _tab('FAQ', !contactTab),
          ),
        ),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => contactTab = true),
            child: _tab('Contact us', contactTab),
          ),
        ),
      ],
    );
  }

  Widget _tab(String label, bool active) {
    final Color primary = _primary(context);

    return Container(
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: active ? primary : _border(context),
            width: active ? 3 : 1,
          ),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 16,
          color: active ? primary : _textSecondary(context),
          fontWeight: active ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }

  Widget _faqView() {
    final Color primary = _primary(context);

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
              final bool active = categories[i] == category;

              return ChoiceChip(
                label: Text(categories[i]),
                selected: active,
                onSelected: (_) {
                  setState(() => category = categories[i]);
                },
                labelStyle: GoogleFonts.poppins(
                  color: active ? Colors.white : primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                selectedColor: primary,
                backgroundColor: _card(context),
                side: BorderSide(
                  color: primary,
                  width: 1,
                ),
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
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: _textPrimary(context),
          ),
          cursorColor: primary,
          decoration: InputDecoration(
            hintText: 'Search',
            hintStyle: GoogleFonts.poppins(
              color: _textSecondary(context).withValues(alpha: 0.70),
              fontSize: 14,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: _textSecondary(context),
            ),
            suffixIcon: Icon(
              Icons.tune_rounded,
              color: primary,
            ),
            filled: true,
            fillColor: _searchBackground(context),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: primary.withValues(alpha: 0.45),
                width: 1.2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        ...questions.asMap().entries.map((entry) {
          final int index = entry.key;
          final String question = entry.value;

          if (search.isNotEmpty &&
              !question.toLowerCase().contains(search.toLowerCase())) {
            return const SizedBox.shrink();
          }

          final bool open = expanded == index;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: _card(context),
              border: Border.all(
                color: _border(context),
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: Theme.of(context).brightness == Brightness.light
                  ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.025),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    expanded = open ? -1 : index;
                  });
                },
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
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
                                color: _textPrimary(context),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            open
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: primary,
                          ),
                        ],
                      ),
                      if (open) ...[
                        const SizedBox(height: 18),
                        Divider(
                          height: 1,
                          color: _border(context),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          question == 'What is AiTradeX?'
                              ? 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.'
                              : 'This help article explains the steps and information you need to complete this action.',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            height: 1.45,
                            color: _textSecondary(context),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _contactView() {
    final Color primary = _primary(context);

    final List<(IconData, String)> items = [
      (Icons.headset_mic_outlined, 'Customer Service'),
      (Icons.chat_outlined, 'WhatsApp'),
      (Icons.language_rounded, 'Website'),
      (Icons.facebook, 'Facebook'),
      (Icons.alternate_email_rounded, 'Twitter'),
      (Icons.camera_alt_outlined, 'Instagram'),
    ];

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, i) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Theme.of(context).colorScheme.inverseSurface,
                  content: Text(
                    '${items[i].$2} selected.',
                    style: GoogleFonts.poppins(
                      color: Theme.of(context).colorScheme.onInverseSurface,
                    ),
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(18),
            child: Container(
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: _card(context),
                border: Border.all(
                  color: _border(context),
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: _softPrimary(
                        context,
                        alpha: 0.10,
                      ),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      items[i].$1,
                      color: primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      items[i].$2,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary(context),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: _textSecondary(context),
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}