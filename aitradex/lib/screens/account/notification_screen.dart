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

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final Map<String, bool> _settings = {
    'My Stock Goes up': true,
    'My Stock is Down': false,
    'Top Movers Updates': true,
    'I Bought Stock': true,
    'I Exchange Stock': true,
    'I Make Funding': false,
    'Otrade Announcements': true,
    'App Updates': false,
    'New Services Available': true,
    'New Tips Available': false,
  };

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
                title: 'Notification',
                onBack: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 25),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: _settings.keys.map((title) {
                    return SettingSwitchRow(
                      title: title,
                      value: _settings[title]!,
                      onChanged: (value) {
                        setState(() => _settings[title] = value);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
