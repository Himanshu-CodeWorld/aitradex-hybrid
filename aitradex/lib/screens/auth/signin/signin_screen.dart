import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'signin_controller.dart';
import 'pages/email_page.dart';
import 'pages/password_page.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({
    super.key,
  });

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  late final SignInController controller;

  @override
  void initState() {
    super.initState();

    // ---------------------------------------------------------
    // GET OR CREATE SIGN-IN CONTROLLER
    // ---------------------------------------------------------

    if (Get.isRegistered<SignInController>()) {
      controller = Get.find<SignInController>();
    } else {
      controller = Get.put(
        SignInController(),
        permanent: false,
      );
    }

    debugPrint(
      'SignInController initialized: ${controller.hashCode}',
    );
  }

  @override
  void dispose() {
    // ---------------------------------------------------------
    // DO NOT manually dispose the controller here.
    //
    // GetX manages the controller lifecycle.
    // SignInController.onClose() disposes:
    //   - emailController
    //   - passwordController
    // ---------------------------------------------------------

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,

      body: PageView(
        physics: const NeverScrollableScrollPhysics(),

        children: const [
          // -----------------------------------------------------
          // STEP 1
          // EMAIL
          // -----------------------------------------------------

          EmailPage(),

          // -----------------------------------------------------
          // STEP 2
          // PASSWORD
          // -----------------------------------------------------

          PasswordPage(),
        ],
      ),
    );
  }
}