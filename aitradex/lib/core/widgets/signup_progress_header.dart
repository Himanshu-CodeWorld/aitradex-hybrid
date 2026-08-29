import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SignupProgressHeader extends StatelessWidget {
  final double progress;
  final VoidCallback? onBack;

  const SignupProgressHeader({
    super.key,
    required this.progress,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 22,
              color: AppColors.black,
            ),
          ),

          const SizedBox(width: 20),

          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 350),
                tween: Tween(begin: 0, end: progress),
                builder: (context, value, child) {
                  return LinearProgressIndicator(
                    value: value,
                    minHeight: 8,
                    backgroundColor: AppColors.grey,
                    valueColor: const AlwaysStoppedAnimation(
                      AppColors.primary,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}