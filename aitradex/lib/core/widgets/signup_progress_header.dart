import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Signup progress header.
///
/// AiTradeX signup flow:
///   Page 1 → Name
///   Page 2 → Email
///   Page 3 → Phone
///   Page 4 → Username
///   Page 5 → Password
///   Page 6 → Review Information
///
/// You can use this widget in either of these ways:
///
/// 1. Recommended - page based:
///    SignupProgressHeader(
///      currentPage: controller.currentPage.value,
///      totalPages: SignupController.totalPages,
///      onBack: controller.previousPage,
///    )
///
/// 2. Existing progress based usage:
///    SignupProgressHeader(
///      progress: 3 / 6,
///      onBack: ...,
///    )
///
/// `currentPage` is zero-based.
class SignupProgressHeader extends StatelessWidget {
  /// Existing progress API. Value must be between 0.0 and 1.0.
  ///
  /// When [currentPage] and [totalPages] are supplied, they take priority.
  final double? progress;

  /// Zero-based current signup page.
  final int? currentPage;

  /// Total number of signup pages.
  final int totalPages;

  final VoidCallback? onBack;

  const SignupProgressHeader({
    super.key,
    this.progress,
    this.currentPage,
    this.totalPages = 6,
    this.onBack,
  });

  /// Converts the current zero-based page into a 0.0–1.0 progress value.
  double get _pageProgress {
    final int safeTotalPages = totalPages < 1 ? 1 : totalPages;

    if (currentPage == null) {
      return _safeProgress(progress ?? 0.0);
    }

    final int safePage = currentPage!.clamp(0, safeTotalPages - 1);

    // Page 1 of 6 = 1/6
    // Page 2 of 6 = 2/6
    // ...
    // Page 6 of 6 = 6/6
    return _safeProgress((safePage + 1) / safeTotalPages);
  }

  double _safeProgress(double value) {
    if (value.isNaN || value.isInfinite) {
      return 0.0;
    }

    return value.clamp(0.0, 1.0).toDouble();
  }

  String get _pageLabel {
    if (currentPage == null) {
      return '';
    }

    final int safeTotalPages = totalPages < 1 ? 1 : totalPages;
    final int safePage = currentPage!.clamp(0, safeTotalPages - 1);

    const List<String> pageNames = [
      'Name',
      'Email',
      'Phone',
      'Username',
      'Password',
      'Review',
    ];

    final String name = safePage < pageNames.length
        ? pageNames[safePage]
        : 'Step ${safePage + 1}';

    return '$name  •  ${safePage + 1}/$safeTotalPages';
  }

  @override
  Widget build(BuildContext context) {
    final double safeProgress = _pageProgress;

    final bool canGoBack =
        onBack != null && (currentPage == null || currentPage! > 0);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ---------------------------------------------------------
            // BACK BUTTON
            // ---------------------------------------------------------
            SizedBox(
              width: 40,
              height: 40,
              child: IconButton(
                onPressed: canGoBack ? onBack : null,
                padding: EdgeInsets.zero,
                tooltip: canGoBack ? 'Back' : null,
                splashRadius: 22,
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20,
                  color: canGoBack
                      ? AppColors.black
                      : AppColors.grey,
                ),
              ),
            ),

            const SizedBox(width: 14),

            // ---------------------------------------------------------
            // PROGRESS + PAGE LABEL
            // ---------------------------------------------------------
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                      tween: Tween<double>(
                        begin: 0.0,
                        end: safeProgress,
                      ),
                      builder: (
                          BuildContext context,
                          double value,
                          Widget? child,
                          ) {
                        return LinearProgressIndicator(
                          value: value.clamp(0.0, 1.0).toDouble(),
                          minHeight: 8,
                          backgroundColor: AppColors.grey,
                          valueColor:
                          const AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        );
                      },
                    ),
                  ),

                  if (_pageLabel.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      _pageLabel,
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.grey,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
