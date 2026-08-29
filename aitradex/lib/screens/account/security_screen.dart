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

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool rememberMe = true;
  bool biometricId = false;
  bool faceId = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            children: [
              SettingsHeader(
                title: 'Security',
                onBack: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 23),
              SettingSwitchRow(
                title: 'Remember me',
                value: rememberMe,
                onChanged: (v) => setState(() => rememberMe = v),
              ),
              SettingSwitchRow(
                title: 'Biometric ID',
                value: biometricId,
                onChanged: (v) => setState(() => biometricId = v),
              ),
              SettingSwitchRow(
                title: 'Face ID',
                value: faceId,
                onChanged: (v) => setState(() => faceId = v),
              ),
              SizedBox(
                height: 61,
                child: InkWell(
                  onTap: () => _showMessage(context, 'Two-Factor Authentication'),
                  child: Row(
                    children: [
                      Expanded(child: Text('Two-Factor Authentication', style: _bodyStyle())),
                      const Icon(Icons.chevron_right_rounded, size: 25),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 59,
                child: TextButton(
                  onPressed: () => _showMessage(context, 'Change PIN'),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xffE8FAF5),
                    foregroundColor: kAiTradeXGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Change PIN',
                    style: GoogleFonts.poppins(
                      color: kAiTradeXGreen,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$message is ready to configure.')),
    );
  }
}
