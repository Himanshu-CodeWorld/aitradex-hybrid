
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:aitradex/core/theme/app_colors.dart';
import 'package:aitradex/core/widgets/primary_button.dart';
import 'package:aitradex/core/widgets/signup_progress_header.dart';

import '../signup_controller.dart';

class PasswordPage extends StatefulWidget {
  const PasswordPage({super.key});

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  late final SignupController controller;

  bool obscurePassword = true;
  bool obscureConfirm = true;

  // Use the controller's confirm-password field so the password data
  // remains available to SignupController when the page changes.
  late final TextEditingController confirmPasswordController;

  @override
  void initState() {
    super.initState();

    controller = Get.find<SignupController>();

    // Keep both password fields owned by SignupController.
    // This prevents the confirm password value from being lost when
    // PasswordPage is rebuilt/disposed.
    confirmPasswordController = controller.confirmPasswordController;

    controller.passwordController.addListener(_onTextChanged);
    confirmPasswordController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    controller.passwordController.removeListener(_onTextChanged);
    confirmPasswordController.removeListener(_onTextChanged);
    // Do NOT dispose confirmPasswordController here.
    // SignupController owns it for the complete signup flow.
    super.dispose();
  }

  bool get isPasswordValid {
    return controller.passwordController.text.length >= 8;
  }

  bool get passwordsMatch {
    final password = controller.passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    return password.isNotEmpty &&
        confirmPassword.isNotEmpty &&
        password == confirmPassword;
  }

  bool get isValid {
    return isPasswordValid && passwordsMatch;
  }

  Widget passwordField({
    required String label,
    required TextEditingController textController,
    required bool obscure,
    required VoidCallback onToggle,
    required TextInputAction textInputAction,
    VoidCallback? onSubmitted,
  }) {
    return TextField(
      controller: textController,
      obscureText: obscure,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: textInputAction,
      onSubmitted: (_) => onSubmitted?.call(),
      autocorrect: false,
      enableSuggestions: false,
      enableIMEPersonalizedLearning: false,
      autofillHints: const <String>[],
      inputFormatters: <TextInputFormatter>[
        LengthLimitingTextInputFormatter(64),
      ],
      style: GoogleFonts.poppins(
        fontSize: 17,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          color: Colors.grey.shade600,
        ),
        prefixIcon: const Icon(
          Icons.lock_outline_rounded,
          color: AppColors.primary,
        ),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
        ),
        filled: true,
        fillColor: const Color(0xffFAFAFA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Color(0xffE5E5E5),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Color(0xffE5E5E5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget requirement({
    required String text,
    required bool valid,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          valid
              ? Icons.check_circle_rounded
              : Icons.circle_outlined,
          size: 18,
          color: valid
              ? AppColors.primary
              : Colors.grey.shade400,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              color: valid
                  ? Colors.black87
                  : Colors.grey.shade600,
              fontWeight: valid
                  ? FontWeight.w500
                  : FontWeight.w400,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _continue() async {
    if (!isValid) {
      Get.snackbar(
        'Invalid Password',
        'Please enter a password of at least 8 characters and confirm it.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    final bool saved = await controller.submitPassword();

    if (!saved || !mounted) return;

    // PasswordPage only saves the password. The controller then advances
    // from page 5 (index 4) to ReviewInformationPage (index 5).
    await controller.nextPage();
  }

  @override
  Widget build(BuildContext context) {
    final bool showMismatch =
        confirmPasswordController.text.isNotEmpty &&
            controller.passwordController.text !=
                confirmPasswordController.text;

    return SafeArea(
      child: Column(
        children: [
          SignupProgressHeader(
            currentPage: controller.currentPage.value,
            totalPages: SignupController.totalPages,
            onBack: controller.previousPage,
          ),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create Your Password 🔐',
                    style: GoogleFonts.poppins(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Create a strong password to keep your AiTradeX account secure.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 32),

                  passwordField(
                    label: 'Create Password',
                    textController: controller.passwordController,
                    obscure: obscurePassword,
                    textInputAction: TextInputAction.next,
                    onToggle: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),

                  const SizedBox(height: 18),

                  passwordField(
                    label: 'Confirm Password',
                    textController: confirmPasswordController,
                    obscure: obscureConfirm,
                    textInputAction: TextInputAction.done,
                    onToggle: () {
                      setState(() {
                        obscureConfirm = !obscureConfirm;
                      });
                    },
                  ),

                  if (showMismatch)
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 10,
                        left: 4,
                      ),
                      child: Text(
                        'Passwords do not match.',
                        style: GoogleFonts.poppins(
                          color: Colors.red,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.security_rounded,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Firebase password security',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        requirement(
                          text: 'At least 8 characters',
                          valid: isPasswordValid,
                        ),

                        const SizedBox(height: 8),

                        requirement(
                          text: 'Passwords must match',
                          valid: passwordsMatch,
                        ),

                        const SizedBox(height: 8),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.verified_user_outlined,
                              size: 18,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Password is managed by Firebase Auth',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 12.5,
                                  color: Colors.black87,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
            child: Obx(
                  () => PrimaryButton(
                text: controller.isSubmitting.value
                    ? 'Please wait...'
                    : 'Continue',
                enabled:
                isValid && !controller.isSubmitting.value,
                onPressed: controller.isSubmitting.value
                    ? null
                    : _continue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
