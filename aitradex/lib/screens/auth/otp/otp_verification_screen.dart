import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:aitradex/core/theme/app_colors.dart';

import 'otp_controller.dart';

import 'widgets/confirm_button.dart';
import 'widgets/otp_box.dart';
import 'widgets/otp_timer.dart';

class OtpVerificationScreen extends StatelessWidget {
  final String phone;

  OtpVerificationScreen({
    super.key,
    required this.phone,
  });

  // Always start this screen with a FRESH controller.
  // Get.put() alone would reuse a stale instance (old timer state,
  // old OTP digits) if this screen is opened more than once.
  final OtpController controller = () {
    if (Get.isRegistered<OtpController>()) {
      Get.delete<OtpController>(force: true);
    }
    return Get.put(OtpController());
  }();

  @override
  Widget build(BuildContext context) {
    controller.phone = phone;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back Button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () {
                          if (controller.isVerified.value) return; // block back once verified
                          Get.back();
                        },
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Title
                    Text(
                      "Verify OTP",
                      style: GoogleFonts.poppins(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Description
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
                            "Enter the 6-digit OTP sent to your mobile number\n\n",
                          ),
                          TextSpan(
                            text: phone,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 45),

                    // OTP Boxes
                    const OtpBox(),

                    const SizedBox(height: 40),

                    // Timer
                    const OtpTimer(),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // Confirm Button
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  24,
                  10,
                  24,
                  24,
                ),
                child: const ConfirmButton(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}