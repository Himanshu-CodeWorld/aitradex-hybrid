import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OutlineButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double height;
  final double borderRadius;
  final bool isLoading;
  final IconData? icon;

  const OutlineButtonWidget({
    super.key,
    required this.text,
    required this.onPressed,
    this.height = 56,
    this.borderRadius = 16,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF4F5DFF),
          side: const BorderSide(
            color: Color(0xFF4F5DFF),
            width: 1.8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: isLoading
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Color(0xFF4F5DFF),
            ),
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
                color: const Color(0xFF4F5DFF),
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 8),
              Icon(
                icon,
                size: 20,
                color: const Color(0xFF4F5DFF),
              ),
            ],
          ],
        ),
      ),
    );
  }
}