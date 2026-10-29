import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:aitradex/core/theme/app_colors.dart';

import 'otp_controller.dart';
import 'widgets/confirm_button.dart';
import 'widgets/otp_box.dart';
import 'widgets/otp_timer.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phone;

  const OtpVerificationScreen({
    super.key,
    required this.phone,
  });

  @override
  State<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  late final OtpController controller;

  /// Prevents multiple navigation calls.
  bool _isFinishing = false;

  @override
  void initState() {
    super.initState();

    // Always create a fresh OTP controller.
    if (Get.isRegistered<OtpController>()) {
      Get.delete<OtpController>(
        force: true,
      );
    }

    controller = Get.put(
      OtpController(),
    );

    controller.phone = widget.phone;
  }

  @override
  void dispose() {
    if (Get.isRegistered<OtpController>()) {
      Get.delete<OtpController>(
        force: true,
      );
    }

    super.dispose();
  }

  // ------------------------------------------------------------
  // VERIFY OTP
  // ------------------------------------------------------------

  Future<void> _verifyOtp() async {
    // Prevent double tap / duplicate navigation.
    if (_isFinishing) {
      return;
    }

    if (controller.isLoading.value) {
      return;
    }

    if (controller.isVerified.value) {
      return;
    }

    _isFinishing = true;

    try {
      final bool verified = await controller.verifyOtp();

      if (!mounted) {
        return;
      }

      if (!verified) {
        // Verification failed.
        // Keep the user on this screen so they can retry.
        _isFinishing = false;
        return;
      }

      // ----------------------------------------------------------
      // OTP SUCCESS
      // ----------------------------------------------------------
      //
      // IMPORTANT:
      // Do NOT navigate directly to UsernamePage here.
      //
      // Return true to PhoneNumberPage.
      //
      // PhoneNumberPage will receive:
      //
      // final verified = await Get.to<bool>(...);
      //
      // and then call:
      //
      // await controller.nextPage();
      //
      // which moves:
      //
      // PhoneNumberPage -> UsernamePage
      // ----------------------------------------------------------

      Get.back<bool>(
        result: true,
      );
    } catch (e) {
      debugPrint(
        'OTP verification screen error: $e',
      );

      if (mounted) {
        _isFinishing = false;
      }
    }
  }

  // ------------------------------------------------------------
  // BACK BUTTON
  // ------------------------------------------------------------

  void _handleBack() {
    // Do not allow another navigation while verification
    // is currently finishing.
    if (_isFinishing) {
      return;
    }

    // IMPORTANT:
    // Do NOT check isVerified here.
    //
    // Once verification succeeds, Get.back(result: true)
    // immediately closes this screen anyway.
    //
    // If the user manually presses back before verification,
    // simply return to PhoneNumberPage.
    Get.back<bool>(
      result: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // ----------------------------------------------------
            // MAIN CONTENT
            // ----------------------------------------------------

            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ------------------------------------------------
                    // BACK BUTTON
                    // ------------------------------------------------

                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: _handleBack,
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 22,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 36,
                    ),

                    // ------------------------------------------------
                    // TITLE
                    // ------------------------------------------------

                    Text(
                      'Verify OTP',
                      style: GoogleFonts.poppins(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    // ------------------------------------------------
                    // DESCRIPTION
                    // ------------------------------------------------

                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Colors.grey.shade600,
                          height: 1.7,
                        ),
                        children: [
                          const TextSpan(
                            text:
                            'Enter the 6-digit OTP sent to your mobile number\n\n',
                          ),
                          TextSpan(
                            text: widget.phone,
                            style: GoogleFonts.poppins(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 45,
                    ),

                    // ------------------------------------------------
                    // OTP BOXES
                    // ------------------------------------------------

                    const OtpBox(),

                    const SizedBox(
                      height: 40,
                    ),

                    // ------------------------------------------------
                    // TIMER / RESEND
                    // ------------------------------------------------

                    const OtpTimer(),

                    const SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ),
            ),

            // ------------------------------------------------------
            // VERIFY BUTTON
            // ------------------------------------------------------

            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  24,
                  10,
                  24,
                  24,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Obx(
                        () => ElevatedButton(
                      onPressed:
                      controller.isLoading.value || _isFinishing
                          ? null
                          : _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor:
                        AppColors.primary.withValues(alpha: 0.5),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor:
                          AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                          : Text(
                        'Verify OTP',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}