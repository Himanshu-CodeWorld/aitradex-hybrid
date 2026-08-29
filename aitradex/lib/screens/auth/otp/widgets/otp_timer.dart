import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aitradex/core/theme/app_colors.dart';
import '../otp_controller.dart';

class OtpTimer extends GetView<OtpController> {
  const OtpTimer({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Obx(
            () {
          if (controller.canResend.value) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Didn't receive the code? ",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                GestureDetector(
                  onTap: controller.resendOtp,
                  child: Text(
                    "Resend OTP",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              Text(
                "Resend OTP in",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "00:${controller.secondsRemaining.value.toString().padLeft(2, '0')}",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}