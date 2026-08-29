import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:aitradex/core/widgets/primary_button.dart';

import '../signin_controller.dart';

class ContinueButton extends GetView<SignInController> {
  const ContinueButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => PrimaryButton(
        text: controller.isLoading.value
            ? "Sending OTP..."
            : "Continue",
        enabled: controller.isPhoneValid.value &&
            !controller.isLoading.value,
        onPressed: () async {
          if (controller.isLoading.value) return;

          await controller.continueWithPhone();
        },
      ),
    );
  }
}