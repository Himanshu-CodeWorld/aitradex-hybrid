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

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String selected = 'English (US)';

  final List<String> suggested = ['English (US)', 'English (UK)'];
  final List<String> languages = [
    'Mandarin',
    'Hindi',
    'Spanish',
    'French',
    'Arabic',
    'Bengali',
    'Russian',
    'Indonesia',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SettingsHeader(
                title: 'Language',
                onBack: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 27),
              Text('Suggested', style: GoogleFonts.poppins(
                fontSize: 18, fontWeight: FontWeight.w600,
              )),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    ...suggested.map(_languageRow),
                    const Divider(height: 1, color: Color(0xffE8E8E8)),
                    const SizedBox(height: 27),
                    Text('Language', style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.w600,
                    )),
                    const SizedBox(height: 17),
                    ...languages.map(_languageRow),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _languageRow(String language) {
    final isSelected = selected == language;
    return InkWell(
      onTap: () => setState(() => selected = language),
      child: SizedBox(
        height: 65,
        child: Row(
          children: [
            Expanded(child: Text(language, style: _bodyStyle())),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: kAiTradeXGreen, width: 2),
              ),
              child: isSelected
                  ? Center(
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: kAiTradeXGreen,
                  ),
                ),
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
