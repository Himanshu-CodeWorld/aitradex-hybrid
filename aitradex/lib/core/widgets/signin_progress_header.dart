import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// AiTradeX Sign In Progress Header.
///
/// Sign-in flow:
///   Step 1 → Email
///   Step 2 → Password
///
/// `currentStep` is zero-based:
///   0 = Email
///   1 = Password
class SignInProgressHeader extends StatelessWidget {
  /// Zero-based current sign-in step.
  final int currentStep;

  /// Total number of sign-in steps.
  ///
  /// Defaults to 2:
  /// Email → Password
  final int totalSteps;

  /// Callback when the back button is pressed.
  final VoidCallback? onBack;

  const SignInProgressHeader({
    super.key,
    required this.currentStep,
    this.totalSteps = 2,
    this.onBack,
  });

  // ---------------------------------------------------------------------------
  // SAFE VALUES
  // ---------------------------------------------------------------------------

  int get _safeTotalSteps {
    return totalSteps < 1 ? 1 : totalSteps;
  }

  int get _safeCurrentStep {
    return currentStep
        .clamp(0, _safeTotalSteps - 1)
        .toInt();
  }

  // ---------------------------------------------------------------------------
  // PROGRESS
  // ---------------------------------------------------------------------------

  double get _progress {
    return ((_safeCurrentStep + 1) / _safeTotalSteps)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  // ---------------------------------------------------------------------------
  // STEP NAME
  // ---------------------------------------------------------------------------

  String get _stepName {
    const List<String> stepNames = [
      'Email',
      'Password',
    ];

    if (_safeCurrentStep < stepNames.length) {
      return stepNames[_safeCurrentStep];
    }

    return 'Step ${_safeCurrentStep + 1}';
  }

  // ---------------------------------------------------------------------------
  // STEP LABEL
  // ---------------------------------------------------------------------------

  String get _stepLabel {
    return '$_stepName  •  ${_safeCurrentStep + 1}/$_safeTotalSteps';
  }

  // ---------------------------------------------------------------------------
  // BACK BUTTON
  // ---------------------------------------------------------------------------

  bool get _canGoBack {
    return onBack != null;
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          24,
          12,
          24,
          12,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // -----------------------------------------------------------------
            // BACK BUTTON
            // -----------------------------------------------------------------

            SizedBox(
              width: 40,
              height: 40,
              child: IconButton(
                onPressed: _canGoBack ? onBack : null,
                padding: EdgeInsets.zero,
                tooltip: _canGoBack ? 'Back' : null,
                splashRadius: 22,
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20,
                  color: _canGoBack
                      ? AppColors.black
                      : AppColors.grey,
                ),
              ),
            ),

            const SizedBox(width: 14),

            // -----------------------------------------------------------------
            // PROGRESS + STEP LABEL
            // -----------------------------------------------------------------

            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // -----------------------------------------------------------
                  // PROGRESS BAR
                  // -----------------------------------------------------------

                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(
                        milliseconds: 350,
                      ),
                      curve: Curves.easeOutCubic,
                      tween: Tween<double>(
                        begin: 0.0,
                        end: _progress,
                      ),
                      builder: (
                          BuildContext context,
                          double value,
                          Widget? child,
                          ) {
                        return LinearProgressIndicator(
                          value: value
                              .clamp(0.0, 1.0)
                              .toDouble(),
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

                  const SizedBox(height: 6),

                  // -----------------------------------------------------------
                  // STEP LABEL
                  // -----------------------------------------------------------

                  Text(
                    _stepLabel,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.grey,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}