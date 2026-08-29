import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'otp_service.dart';
import 'package:aitradex/screens/auth/signup/signup_controller.dart';
import 'package:aitradex/screens/home/dashboard_screen.dart';

class OtpController extends GetxController {
  String phone = "";

  final List<TextEditingController> otpControllers =
  List.generate(6, (_) => TextEditingController());

  final List<FocusNode> focusNodes =
  List.generate(6, (_) => FocusNode());

  final RxBool isLoading = false.obs;
  final RxBool canResend = false.obs;
  final RxInt secondsRemaining = 60.obs;
  final RxBool isVerified = false.obs;

  Timer? _timer;
  bool _isAutoVerifying = false;

  @override
  void onInit() {
    super.onInit();
    startTimer();
  }

  void startTimer() {
    _timer?.cancel();
    secondsRemaining.value = 60;
    canResend.value = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining.value > 0) {
        secondsRemaining.value--;
      } else {
        timer.cancel();
        canResend.value = true;
      }
    });
  }

  String get otp => otpControllers.map((e) => e.text.trim()).join();

  bool get isOtpComplete => otp.length == 6;

  Future<void> autoVerifyOtp() async {
    if (_isAutoVerifying) return;
    if (!isOtpComplete) return;

    _isAutoVerifying = true;
    final success = await verifyOtp();
    _isAutoVerifying = false;

    if (!success) return;

    final result = await OtpService.verifyPhoneOtp(
      phone: phone,
      otp: otp,
    );

    if (result["userExists"] == true) {
      return;
    }

    await completeAndAdvance();
  }

  Future<bool> verifyOtp() async {
    if (isVerified.value) return true;

    if (!isOtpComplete) {
      Get.snackbar(
        "Invalid OTP",
        "Please enter all 6 digits.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (isLoading.value) return false;

    try {
      isLoading.value = true;

      debugPrint("==================================");
      debugPrint("VERIFY PHONE OTP");
      debugPrint("Phone : $phone");
      debugPrint("OTP   : $otp");

      final result = await OtpService.verifyPhoneOtp(
        phone: phone,
        otp: otp,
      );

      debugPrint(result.toString());

      if (result["success"] == true) {

        isVerified.value = true;

        final bool userExists = result["userExists"] ?? false;

        if (userExists) {

          Get.offAll(() => const DashboardScreen());
          return true;

        }

        return true;
      }

      Get.snackbar(
        "Verification Failed",
        result["message"] ?? "Invalid OTP.",
        snackPosition: SnackPosition.BOTTOM,
      );

      return false;
    } catch (e) {
      debugPrint(e.toString());

      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  //======================================================
  // Advance Signup + Close OTP Screen
  //======================================================
  // Pop first, then advance the signup PageView using a synchronous
  // jump (not animateToPage), since animateToPage's Future can hang
  // when started right after a route-pop transition.

  Future<void> completeAndAdvance() async {
    debugPrint("completeAndAdvance() called — popping OTP screen");

    Get.back(result: true);

    await Future.delayed(const Duration(milliseconds: 50));

    if (Get.isRegistered<SignupController>()) {
      debugPrint("Advancing signup page (jump, no animation)");
      Get.find<SignupController>().jumpToNextPage();
      debugPrint("jumpToNextPage() finished");
    } else {
      debugPrint("⚠️ completeAndAdvance() — SignupController not found.");
    }
  }

  Future<void> resendOtp() async {
    if (!canResend.value) return;

    try {
      final result = await OtpService.resendPhoneOtp(phone: phone);

      if (result["success"] == true) {
        startTimer();
        for (final c in otpControllers) {
          c.clear();
        }
        focusNodes.first.requestFocus();
        Get.snackbar("Success", result["message"] ?? "OTP sent successfully.",
            snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar("Failed", result["message"] ?? "Unable to resend OTP.",
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    for (final controller in otpControllers) {
      controller.dispose();
    }
    for (final node in focusNodes) {
      node.dispose();
    }
    super.onClose();
  }
}