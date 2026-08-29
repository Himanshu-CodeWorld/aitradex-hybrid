import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:aitradex/core/widgets/primary_button.dart';
import '../captcha_controller.dart';

class ContinueButton extends GetView<CaptchaController> {
  const ContinueButton({
    super.key,
    required this.email,
  });

  final String email;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return PrimaryButton(
        text: controller.isLoading.value
            ? "Opening Browser..."
            : "Continue",
        onPressed: controller.isLoading.value
            ? null
            : () async {
          await controller.openCaptcha(
            email: email,
          );
        },
      );
    });
  }
}