import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:aitradex/core/theme/app_colors.dart';
import 'package:aitradex/core/widgets/primary_button.dart';
import 'package:aitradex/core/widgets/signup_progress_header.dart';

import '../signup_controller.dart';
import '../../captcha/captcha_screen.dart';

class EmailPage extends StatefulWidget {
  const EmailPage({super.key});

  @override
  State<EmailPage> createState() => _EmailPageState();
}

class _EmailPageState extends State<EmailPage> {
  late final SignupController controller;

  bool isButtonEnabled = false;
  bool isLoading = false;

  late final VoidCallback _emailListener;

  @override
  void initState() {
    super.initState();

    controller = Get.find<SignupController>();

    isButtonEnabled = _isValidEmail(
      controller.emailController.text.trim(),
    );

    _emailListener = () {
      if (!mounted) return;

      final enabled = _isValidEmail(
        controller.emailController.text.trim(),
      );

      if (enabled != isButtonEnabled) {
        setState(() {
          isButtonEnabled = enabled;
        });
      }
    };

    controller.emailController.addListener(_emailListener);
  }

  @override
  void dispose() {
    controller.emailController.removeListener(_emailListener);
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(
      r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,4}$',
    ).hasMatch(email);
  }

  Future<void> _continue() async {
    FocusScope.of(context).unfocus();

    final email = controller.emailController.text.trim().toLowerCase();

    if (!_isValidEmail(email)) {
      Get.snackbar(
        "Invalid Email",
        "Please enter a valid email address.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final exists = await controller.checkEmail(email);

      if (exists) {
        Get.snackbar(
          "Email Already Exists",
          "An account with this email already exists.",
          snackPosition: SnackPosition.BOTTOM,
        );

        return;
      }

      controller.emailController.text = email;

      controller.signup.update((user) {
        if (user == null) return;

        user.email = email;
        user.emailVerified = false;
      });

      await controller.saveCurrentDraft();

      final verified = await Get.to<bool>(
            () => CaptchaScreen(
          email: email,
        ),
      );

      if (verified == true && mounted) {
        controller.nextPage();
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SignupProgressHeader(
            progress: 0.10,
            onBack: controller.previousPage,
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 25),

                  Text(
                    "What's your email? 📧",
                    style: GoogleFonts.poppins(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "We'll use this email for login, verification and important updates.",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 45),

                  Text(
                    "Email Address",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    autofocus: true,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: "john@example.com",
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.grey.shade400,
                      ),
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: AppColors.primary,
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: PrimaryButton(
              text: isLoading ? "Checking..." : "Continue",
              enabled: isButtonEnabled && !isLoading,
              onPressed: isLoading ? null : _continue,
            ),
          ),
        ],
      ),
    );
  }
}