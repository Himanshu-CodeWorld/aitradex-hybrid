import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool loading;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.enabled = true,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = enabled && !loading;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isActive ? onPressed : null,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor:
          isActive ? AppColors.primary : Colors.grey.shade300,
          disabledBackgroundColor: Colors.grey.shade300,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          shadowColor: AppColors.primary.withOpacity(0.30),
        ).copyWith(
          elevation: WidgetStateProperty.resolveWith<double>(
                (states) => isActive ? 8 : 0,
          ),
        ),
        child: loading
            ? const SizedBox(
          height: 22,
          width: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation(Colors.white),
          ),
        )
            : Text(
          text,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}