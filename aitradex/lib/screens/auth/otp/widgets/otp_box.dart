import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:aitradex/core/theme/app_colors.dart';
import '../otp_controller.dart';

class OtpBox extends GetView<OtpController> {
  const OtpBox({super.key});

  @override
  Widget build(BuildContext context) {
    final otpLength = controller.otpControllers.length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        otpLength,
            (index) {
          return SizedBox(
            width: 48,
            height: 60,
            child: TextField(
              enabled: !controller.isVerified.value, // NEW — wrap OtpBox in Obx, or check per-field
              controller: controller.otpControllers[index],
              focusNode: controller.focusNodes[index],
              keyboardType: TextInputType.number,
              textInputAction: index == otpLength - 1
                  ? TextInputAction.done
                  : TextInputAction.next,
              textAlign: TextAlign.center,
              cursorColor: AppColors.primary,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
              maxLength: 1,
              decoration: InputDecoration(
                counterText: "",
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.grey.shade300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(1),
              ],
              onChanged: (value) async {
                // --------------------------------------------------
                // Handle OTP Paste
                // --------------------------------------------------

                if (value.length > 1) {
                  final chars = value.split("");

                  for (int i = 0;
                  i < chars.length &&
                      (index + i) < otpLength;
                  i++) {
                    controller
                        .otpControllers[index + i]
                        .text = chars[i];
                  }

                  FocusScope.of(context).unfocus();

                  if (controller.isOtpComplete) {
                    await Future.delayed(
                      const Duration(milliseconds: 150),
                    );

                    controller.autoVerifyOtp();
                  }

                  return;
                }

                // --------------------------------------------------
                // Single Digit Input
                // --------------------------------------------------

                if (value.isNotEmpty) {
                  if (index < otpLength - 1) {
                    controller.focusNodes[index + 1].requestFocus();
                  } else {
                    FocusScope.of(context).unfocus();

                    if (controller.isOtpComplete) {
                      await Future.delayed(
                        const Duration(milliseconds: 150),
                      );

                      controller.autoVerifyOtp();
                    }
                  }
                }

                // --------------------------------------------------
                // Delete
                // --------------------------------------------------

                if (value.isEmpty && index > 0) {
                  controller.focusNodes[index - 1].requestFocus();
                }
              },
            ),
          );
        },
      ),
    );
  }
}