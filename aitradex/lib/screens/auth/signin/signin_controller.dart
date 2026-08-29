import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'signin_service.dart';
import '../otp/otp_verification_screen.dart';

class SignInController extends GetxController {
  /// Phone Controller
  final TextEditingController phoneController = TextEditingController();

  /// Loading
  final RxBool isLoading = false.obs;

  /// Phone Validation
  final RxBool isPhoneValid = false.obs;

  @override
  void onInit() {
    super.onInit();
    phoneController.addListener(_validatePhone);
  }

  /// Validate Phone Number
  void _validatePhone() {
    final phone = phoneController.text.trim();

    // Indian Mobile Number Validation
    isPhoneValid.value = RegExp(r'^[6-9]\d{9}$').hasMatch(phone);
  }

  /// Continue Button
  Future<void>continueWithPhone() async {
    if (!isPhoneValid.value) {
      Get.snackbar(
        "Invalid Phone Number",
        "Please enter a valid 10-digit mobile number.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (isLoading.value) return;

    try {
      isLoading.value = true;

      final result = await SignInService.sendPhoneOtp(
        phone: phoneController.text.trim(),
      );

      if (result["success"] == true) {
        Get.snackbar(
          "Success",
          result["message"] ?? "OTP sent successfully.",
          snackPosition: SnackPosition.BOTTOM,
        );

        Get.to(
              () => OtpVerificationScreen(
            phone: phoneController.text.trim(),
          ),
        );
      } else {
        Get.snackbar(
          "Failed",
          result["message"] ?? "Unable to send OTP.",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }
}