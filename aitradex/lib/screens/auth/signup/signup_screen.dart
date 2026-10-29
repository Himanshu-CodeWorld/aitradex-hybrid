import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'signup_controller.dart';

import 'pages/name_page.dart';
import 'pages/email_page.dart';
import 'pages/phone_number_page.dart';
import 'pages/username_page.dart';
import 'pages/password_page.dart';
import 'pages/profile_image_screen.dart';
import 'pages/referral_code_screen.dart';
import 'pages/review_information_page.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({
    super.key,
  });

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late final SignupController controller;

  @override
  void initState() {
    super.initState();

    // ----------------------------------------------------------
    // GET EXISTING SIGNUP CONTROLLER
    // ----------------------------------------------------------
    //
    // IMPORTANT:
    // Do NOT create another SignupController here.
    //
    // The same controller must remain active through the entire
    // signup process so that all entered information is retained.
    //
    // Flow:
    //
    // Name
    //   ↓
    // Email + Firebase Verification
    //   ↓
    // Phone + OTP
    //   ↓
    // Username
    //   ↓
    // Password + Confirm Password
    //   ↓
    // Profile Image
    //   ↓
    // Referral Code
    //   ↓
    // Review
    //   ↓
    // Create Firebase Account
    //   ↓
    // Save / Update MongoDB
    //   ↓
    // Login
    //
    // ----------------------------------------------------------

    controller = Get.find<SignupController>();

    debugPrint(
      '========================================',
    );
    debugPrint(
      'SIGNUP SCREEN INITIALIZED',
    );
    debugPrint(
      'SignupController Hash: ${controller.hashCode}',
    );
    debugPrint(
      'Current Signup Page: ${controller.currentPage.value}',
    );
    debugPrint(
      'Total Signup Pages: ${SignupController.totalPages}',
    );
    debugPrint(
      '========================================',
    );
  }

  @override
  void dispose() {
    // ----------------------------------------------------------
    // IMPORTANT
    // ----------------------------------------------------------
    //
    // Do NOT delete SignupController here.
    //
    // Its lifecycle is controlled by the GetX binding / parent
    // flow. Deleting it here can cause entered signup data to
    // disappear when moving between pages.
    //
    // ----------------------------------------------------------

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,

      // --------------------------------------------------------
      // SIGNUP PAGE VIEW
      // --------------------------------------------------------
      //
      // Manual swipe navigation is disabled.
      //
      // Each page is responsible for validation and should call:
      //
      //     controller.nextPage();
      //
      // when the current step is successfully completed.
      //
      // --------------------------------------------------------

      body: PageView(
        controller: controller.pageController,

        // Prevent the user from swiping between signup steps.
        physics: const NeverScrollableScrollPhysics(),

        // Keep SignupController.currentPage synchronized
        // with the actual PageView page.
        onPageChanged: controller.onPageChanged,

        children: const [
          // ====================================================
          // PAGE 1
          // ====================================================
          //
          // Full Name
          //
          NamePage(),

          // ====================================================
          // PAGE 2
          // ====================================================
          //
          // Email
          // Firebase email verification
          //
          EmailPage(),

          // ====================================================
          // PAGE 3
          // ====================================================
          //
          // Phone Number
          // Message Central OTP verification
          //
          PhoneNumberPage(),

          // ====================================================
          // PAGE 4
          // ====================================================
          //
          // Username
          //
          UsernamePage(),

          // ====================================================
          // PAGE 5
          // ====================================================
          //
          // Password
          // Confirm Password
          //
          PasswordPage(),

          // ====================================================
          // PAGE 6
          // ====================================================
          //
          // Optional Profile Image
          //
          ProfileImageScreen(),

          // ====================================================
          // PAGE 7
          // ====================================================
          //
          // Optional Referral Code
          //
          ReferralCodeScreen(),

          // ====================================================
          // PAGE 8
          // ====================================================
          //
          // Review all signup information
          //
          // Final action:
          //
          // Firebase account creation
          //        ↓
          // MongoDB user creation/update
          //        ↓
          // Clear signup draft
          //        ↓
          // Redirect to /login
          //
          ReviewInformationPage(),
        ],
      ),
    );
  }
}