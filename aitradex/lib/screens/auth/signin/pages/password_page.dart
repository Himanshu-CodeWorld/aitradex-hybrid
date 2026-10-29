import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:aitradex/core/theme/app_colors.dart';
import 'package:aitradex/core/widgets/primary_button.dart';
import 'package:aitradex/core/widgets/signin_progress_header.dart';

import '../signin_controller.dart';

class PasswordPage extends StatefulWidget {
  const PasswordPage({super.key});

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  late final SignInController controller;

  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();

    controller = Get.isRegistered<SignInController>()
        ? Get.find<SignInController>()
        : Get.put(SignInController());

    controller.passwordController.addListener(
      _validatePassword,
    );

    _validatePassword();
  }

  // ---------------------------------------------------------------------------
  // Password validation
  // ---------------------------------------------------------------------------

  void _validatePassword() {
    if (!mounted) {
      return;
    }

    final password = controller.passwordController.text;

    final isValid = password.length >= 6;

    if (isButtonEnabled != isValid) {
      setState(() {
        isButtonEnabled = isValid;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Sign in
  // ---------------------------------------------------------------------------

  Future<void> _continue() async {
    FocusScope.of(context).unfocus();

    if (!isButtonEnabled) {
      return;
    }

    if (controller.isLoading.value) {
      return;
    }

    await controller.signIn();
  }

  // ---------------------------------------------------------------------------
  // Forgot password
  // ---------------------------------------------------------------------------

  Future<void> _forgotPassword() async {
    FocusScope.of(context).unfocus();

    if (controller.isSendingResetEmail.value) {
      return;
    }

    await controller.forgotPassword();
  }

  // ---------------------------------------------------------------------------
  // Back
  // ---------------------------------------------------------------------------

  void _goBack() {
    FocusScope.of(context).unfocus();
    Get.back();
  }

  // ---------------------------------------------------------------------------
  // Dispose
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    controller.passwordController.removeListener(
      _validatePassword,
    );

    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final String email =
    controller.emailController.text.trim();

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // ---------------------------------------------------------------
            // Progress header
            // ---------------------------------------------------------------

            SignInProgressHeader(
              currentStep: 1,
              totalSteps: 2,
              onBack: _goBack,
            ),

            // ---------------------------------------------------------------
            // Main content
            // ---------------------------------------------------------------

            Expanded(
              child: LayoutBuilder(
                builder: (
                    BuildContext context,
                    BoxConstraints constraints,
                    ) {
                  return SingleChildScrollView(
                    keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(
                      24,
                      20,
                      24,
                      30,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 50,
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),

                          Text(
                            'Enter Your Password 🔐',
                            style: GoogleFonts.poppins(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: AppColors.black,
                              height: 1.2,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Text(
                            'Enter your password to continue to your AITradeX account.',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: Colors.grey.shade600,
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 30),

                          // -------------------------------------------------
                          // Email card
                          // -------------------------------------------------

                          Container(
                            width: double.infinity,
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary
                                  .withValues(alpha: 0.06),
                              borderRadius:
                              BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.primary
                                    .withValues(alpha: 0.15),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.email_outlined,
                                    color: AppColors.primary,
                                    size: 22,
                                  ),
                                ),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Email address',
                                        style:
                                        GoogleFonts.poppins(
                                          fontSize: 11,
                                          color:
                                          Colors.grey.shade600,
                                        ),
                                      ),

                                      const SizedBox(height: 2),

                                      Text(
                                        email.isEmpty
                                            ? 'No email entered'
                                            : email,
                                        maxLines: 1,
                                        overflow:
                                        TextOverflow.ellipsis,
                                        style:
                                        GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight:
                                          FontWeight.w600,
                                          color: AppColors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 35),

                          // -------------------------------------------------
                          // Password label
                          // -------------------------------------------------

                          Text(
                            'Password',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.black,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // -------------------------------------------------
                          // Password field
                          // -------------------------------------------------

                          Obx(
                                () => TextField(
                              controller:
                              controller.passwordController,
                              autofocus: true,
                              obscureText:
                              !controller
                                  .isPasswordVisible
                                  .value,
                              keyboardType:
                              TextInputType.visiblePassword,
                              textInputAction:
                              TextInputAction.done,
                              autocorrect: false,
                              enableSuggestions: false,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.black,
                              ),
                              decoration: InputDecoration(
                                hintText:
                                'Enter your password',
                                hintStyle:
                                GoogleFonts.poppins(
                                  color: Colors.grey.shade400,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                ),
                                contentPadding:
                                const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                suffixIcon: IconButton(
                                  onPressed: controller
                                      .togglePasswordVisibility,
                                  tooltip: controller
                                      .isPasswordVisible
                                      .value
                                      ? 'Hide password'
                                      : 'Show password',
                                  icon: Icon(
                                    controller
                                        .isPasswordVisible
                                        .value
                                        ? Icons
                                        .visibility_outlined
                                        : Icons
                                        .visibility_off_outlined,
                                    color:
                                    Colors.grey.shade600,
                                  ),
                                ),
                                enabledBorder:
                                const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                ),
                                focusedBorder:
                                const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                ),
                                border:
                                const UnderlineInputBorder(),
                              ),
                              onSubmitted: (_) {
                                if (isButtonEnabled) {
                                  _continue();
                                }
                              },
                            ),
                          ),

                          const SizedBox(height: 14),

                          // -------------------------------------------------
                          // Password requirement
                          // -------------------------------------------------

                          Row(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.lock_outline_rounded,
                                size: 16,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 7),
                              Expanded(
                                child: Text(
                                  'Password must contain at least 6 characters.',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 22),

                          // -------------------------------------------------
                          // Forgot password
                          // -------------------------------------------------

                          Align(
                            alignment: Alignment.centerRight,
                            child: Obx(
                                  () => TextButton(
                                onPressed: controller
                                    .isSendingResetEmail
                                    .value
                                    ? null
                                    : _forgotPassword,
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                  MaterialTapTargetSize
                                      .shrinkWrap,
                                ),
                                child: Text(
                                  controller
                                      .isSendingResetEmail
                                      .value
                                      ? 'Sending...'
                                      : 'Forgot password?',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight:
                                    FontWeight.w600,
                                    color:
                                    AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // ---------------------------------------------------------------
            // Bottom Sign In button
            // ---------------------------------------------------------------

            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                24,
                10,
                24,
                24,
              ),
              color: Colors.white,
              child: SafeArea(
                top: false,
                child: Obx(
                      () => PrimaryButton(
                    text: controller.isLoading.value
                        ? 'Signing in...'
                        : 'Sign In',
                    enabled: isButtonEnabled &&
                        !controller.isLoading.value,
                    onPressed:
                    isButtonEnabled &&
                        !controller.isLoading.value
                        ? _continue
                        : null,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}