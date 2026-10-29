
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:aitradex/core/theme/app_colors.dart';
import 'package:aitradex/core/widgets/primary_button.dart';
import 'package:aitradex/core/widgets/signup_progress_header.dart';

import 'package:aitradex/screens/auth/otp/otp_verification_screen.dart';
import 'package:aitradex/screens/auth/signup/signup_controller.dart';

class PhoneNumberPage extends StatefulWidget {
  const PhoneNumberPage({
    super.key,
  });

  @override
  State<PhoneNumberPage> createState() =>
      _PhoneNumberPageState();
}

class _PhoneNumberPageState
    extends State<PhoneNumberPage> {
  late final SignupController controller;

  bool isButtonEnabled = false;
  bool isLoading = false;

  /// Prevents the phone page from starting another complete
  /// OTP flow while one is already running.
  bool _otpFlowInProgress = false;

  /// Prevents calling nextPage() more than once after
  /// successful OTP verification.
  bool _movingToUsername = false;

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();

    controller = Get.find<SignupController>();

    controller.phoneController.addListener(
      _updateButtonState,
    );

    _updateButtonState();
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    controller.phoneController.removeListener(
      _updateButtonState,
    );

    super.dispose();
  }

  // ==========================================================
  // PHONE VALIDATION
  // ==========================================================

  bool _isValidIndianPhone(
      String phone,
      ) {
    return RegExp(
      r'^[6-9][0-9]{9}$',
    ).hasMatch(phone);
  }

  String _getFullPhoneNumber(
      String phone,
      ) {
    return '+91$phone';
  }

  // ==========================================================
  // UPDATE BUTTON STATE
  // ==========================================================

  void _updateButtonState() {
    final phone =
    controller.phoneController.text.trim();

    final valid =
    _isValidIndianPhone(phone);

    if (!mounted) {
      return;
    }

    if (isButtonEnabled != valid) {
      setState(() {
        isButtonEnabled = valid;
      });
    }
  }

  // ==========================================================
  // SHOW MESSAGE
  // ==========================================================

  void _showMessage(
      String title,
      String message, {
        bool isError = true,
      }) {
    if (!mounted) {
      return;
    }

    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      backgroundColor: isError
          ? Colors.red.shade50
          : Colors.green.shade50,
      colorText: isError
          ? Colors.red.shade900
          : Colors.green.shade900,
      icon: Icon(
        isError
            ? Icons.error_outline_rounded
            : Icons.check_circle_outline_rounded,
        color: isError
            ? Colors.red.shade700
            : Colors.green.shade700,
      ),
      duration: const Duration(
        seconds: 3,
      ),
    );
  }

  // ==========================================================
  // SEND OTP
  // ==========================================================

  Future<void> _sendOtp() async {
    // ----------------------------------------------------------
    // Prevent duplicate calls
    // ----------------------------------------------------------

    if (isLoading ||
        _otpFlowInProgress ||
        _movingToUsername) {
      return;
    }

    FocusScope.of(context).unfocus();

    final phone =
    controller.phoneController.text.trim();

    // ----------------------------------------------------------
    // Validate phone
    // ----------------------------------------------------------

    if (!_isValidIndianPhone(phone)) {
      _showMessage(
        'Invalid Mobile Number',
        'Please enter a valid 10-digit Indian mobile number.',
      );

      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      isLoading = true;
      _otpFlowInProgress = true;
    });

    try {
      // ========================================================
      // RESET OLD VERIFICATION STATE
      // ========================================================

      controller.phoneVerified.value = false;

      controller.verificationId.value = '';

      // ========================================================
      // SAVE PHONE TO SIGNUP MODEL
      // ========================================================

      controller.signup.update(
            (user) {
          if (user == null) {
            return;
          }

          user.phone = phone;
          user.countryCode = '+91';
          user.phoneVerified = false;
        },
      );

      await controller.saveCurrentDraft();

      // ========================================================
      // SEND OTP
      // ========================================================

      debugPrint('');
      debugPrint(
        '========================================',
      );
      debugPrint(
        'AITRADEX SEND PHONE OTP',
      );
      debugPrint(
        '========================================',
      );
      debugPrint(
        'Phone: ${_getFullPhoneNumber(phone)}',
      );
      debugPrint(
        'Provider: Message Central',
      );
      debugPrint(
        '========================================',
      );

      final sent =
      await controller.sendPhoneOtp();

      debugPrint(
        'sendPhoneOtp result: $sent',
      );

      // --------------------------------------------------------
      // OTP SEND FAILED
      // --------------------------------------------------------

      if (!sent) {
        _showMessage(
          'OTP Failed',
          'Unable to send OTP. Please try again.',
        );

        return;
      }

      // ========================================================
      // GET VERIFICATION ID
      // ========================================================

      final verificationId =
      controller.verificationId.value.trim();

      debugPrint(
        'Message Central verification ID: '
            '$verificationId',
      );

      if (verificationId.isEmpty) {
        throw Exception(
          'OTP was sent, but the verification ID was not returned by the server.',
        );
      }

      final fullPhone =
      _getFullPhoneNumber(phone);

      // ========================================================
      // OPEN OTP SCREEN
      // ========================================================

      if (!mounted) {
        return;
      }

      debugPrint('');
      debugPrint(
        '========================================',
      );
      debugPrint(
        'PHONE OTP SENT',
      );
      debugPrint(
        '========================================',
      );
      debugPrint(
        'Phone: $fullPhone',
      );
      debugPrint(
        'Verification ID received.',
      );
      debugPrint(
        'Opening OTP screen...',
      );
      debugPrint(
        '========================================',
      );

      final bool? verified =
      await Get.to<bool>(
            () => OtpVerificationScreen(
          phone: fullPhone,
        ),
      );

      // ========================================================
      // OTP SCREEN RESULT
      // ========================================================

      debugPrint('');
      debugPrint(
        '========================================',
      );
      debugPrint(
        'OTP SCREEN RESULT',
      );
      debugPrint(
        'Result: $verified',
      );
      debugPrint(
        '========================================',
      );

      // --------------------------------------------------------
      // USER LEFT OTP SCREEN / VERIFICATION FAILED
      // --------------------------------------------------------

      if (verified != true) {
        debugPrint(
          'Phone verification cancelled or failed.',
        );

        return;
      }

      if (!mounted) {
        return;
      }

      // ========================================================
      // OTP VERIFIED
      // ========================================================

      debugPrint('');
      debugPrint(
        '========================================',
      );
      debugPrint(
        'PHONE VERIFICATION SUCCESS',
      );
      debugPrint(
        '========================================',
      );

      controller.phoneVerified.value = true;

      // ========================================================
      // UPDATE SIGNUP MODEL
      // ========================================================

      controller.signup.update(
            (user) {
          if (user == null) {
            return;
          }

          user.phone = phone;
          user.countryCode = '+91';
          user.phoneVerified = true;
        },
      );

      // ========================================================
      // SAVE VERIFIED PHONE STATE
      // ========================================================

      await controller.saveCurrentDraft();

      if (!mounted) {
        return;
      }

      debugPrint(
        'Phone: $fullPhone',
      );
      debugPrint(
        'phoneVerified: ${controller.phoneVerified.value}',
      );
      debugPrint(
        'Moving to Username page...',
      );
      debugPrint(
        '========================================',
      );

      // ========================================================
      // PHONE PAGE -> USERNAME PAGE
      // ========================================================

      if (_movingToUsername) {
        return;
      }

      _movingToUsername = true;

      await controller.nextPage();

      debugPrint(
        'Username page opened successfully.',
      );
    } catch (error, stackTrace) {
      debugPrint('');
      debugPrint(
        '========================================',
      );
      debugPrint(
        'PHONE OTP ERROR',
      );
      debugPrint(
        '========================================',
      );
      debugPrint(
        'Error: $error',
      );
      debugPrint(
        'StackTrace: $stackTrace',
      );
      debugPrint(
        '========================================',
      );

      if (mounted) {
        final message = error
            .toString()
            .replaceFirst(
          'Exception: ',
          '',
        )
            .trim();

        _showMessage(
          'OTP Error',
          message.isEmpty
              ? 'Unable to process phone verification.'
              : message,
        );
      }
    } finally {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
        _otpFlowInProgress = false;
      });
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return SafeArea(
      child: Column(
        children: [
          // ====================================================
          // PROGRESS HEADER
          // ====================================================

          SignupProgressHeader(
            progress: 0.15,
            onBack: _movingToUsername
                ? null
                : controller.previousPage,
          ),

          // ====================================================
          // MAIN CONTENT
          // ====================================================

          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 24,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // TITLE
                  // ==================================================

                  Text(
                    "What's your phone number? 📱",
                    style: GoogleFonts.poppins(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  // ==================================================
                  // DESCRIPTION
                  // ==================================================

                  Text(
                    "We'll send a verification OTP to this mobile number.",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(
                    height: 40,
                  ),

                  // ==================================================
                  // LABEL
                  // ==================================================

                  Text(
                    'Mobile Number',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  // ==================================================
                  // PHONE FIELD
                  // ==================================================

                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                      borderRadius:
                      BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        // ============================================
                        // COUNTRY CODE
                        // ============================================

                        SizedBox(
                          width: 70,
                          child: Center(
                            child: Text(
                              '+91',
                              style:
                              GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight:
                                FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        // ============================================
                        // DIVIDER
                        // ============================================

                        Container(
                          width: 1,
                          height: 30,
                          color: Colors.grey.shade300,
                        ),

                        // ============================================
                        // PHONE INPUT
                        // ============================================

                        Expanded(
                          child: TextField(
                            controller:
                            controller.phoneController,
                            keyboardType:
                            TextInputType.phone,
                            textInputAction:
                            TextInputAction.done,
                            autofillHints: const [
                              AutofillHints.telephoneNumber,
                            ],
                            inputFormatters: [
                              FilteringTextInputFormatter
                                  .digitsOnly,
                              LengthLimitingTextInputFormatter(
                                10,
                              ),
                            ],
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight:
                              FontWeight.w600,
                            ),
                            decoration:
                            const InputDecoration(
                              hintText: '9876543210',
                              border: InputBorder.none,
                              counterText: '',
                              contentPadding:
                              EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 18,
                              ),
                            ),
                            onChanged: (_) {
                              _updateButtonState();
                            },
                            onSubmitted: (_) {
                              if (isButtonEnabled &&
                                  !isLoading &&
                                  !_otpFlowInProgress) {
                                _sendOtp();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  // ==================================================
                  // SECURITY MESSAGE
                  // ==================================================

                  Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.security,
                        color: AppColors.primary,
                        size: 18,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: Text(
                          'Your mobile number is used for OTP verification and account security.',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 40,
                  ),
                ],
              ),
            ),
          ),

          // ====================================================
          // BOTTOM ACTION
          // ====================================================

          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                24,
                0,
                24,
                24,
              ),
              child: PrimaryButton(
                text: isLoading
                    ? 'Sending OTP...'
                    : 'Continue',
                enabled:
                isButtonEnabled &&
                    !isLoading &&
                    !_otpFlowInProgress &&
                    !_movingToUsername,
                onPressed:
                isLoading ||
                    _otpFlowInProgress ||
                    _movingToUsername
                    ? null
                    : _sendOtp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
