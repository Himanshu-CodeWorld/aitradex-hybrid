import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:aitradex/core/widgets/primary_button.dart';

import '../otp_controller.dart';

class ConfirmButton extends GetView<OtpController> {
  const ConfirmButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => PrimaryButton(
        text: controller.isLoading.value ? "Verifying..." : "Confirm OTP",
        enabled: !controller.isLoading.value && !controller.isVerified.value,
        onPressed: () async {
          debugPrint("======== VERIFY BUTTON ========");

          if (controller.isLoading.value) return;

          final success = await controller.verifyOtp();

          debugPrint("VERIFY RESULT = $success");

          if (success) {
            debugPrint("CLOSING OTP SCREEN");

            Get.back(result: true);

            debugPrint("OTP SCREEN CLOSED");
          }
        }
      ),
    );
  }
}