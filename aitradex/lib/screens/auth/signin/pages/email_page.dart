import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:aitradex/core/theme/app_colors.dart';
import 'package:aitradex/core/widgets/primary_button.dart';
import 'package:aitradex/core/widgets/signin_progress_header.dart';

import '../signin_controller.dart';
import 'password_page.dart';

class EmailPage extends StatefulWidget {
  const EmailPage({super.key});

  @override
  State<EmailPage> createState() => _EmailPageState();
}

class _EmailPageState extends State<EmailPage> {
  late final SignInController controller;

  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();

    controller = Get.isRegistered<SignInController>()
        ? Get.find<SignInController>()
        : Get.put(SignInController());

    controller.emailController.addListener(_validateEmail);

    _validateEmail();
  }

  // ---------------------------------------------------------------------------
  // Email validation
  // ---------------------------------------------------------------------------

  void _validateEmail() {
    if (!mounted) {
      return;
    }

    final email = controller.emailController.text.trim();

    final isValid = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(email);

    if (isButtonEnabled != isValid) {
      setState(() {
        isButtonEnabled = isValid;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Continue
  // ---------------------------------------------------------------------------

  void _continue() {
    FocusScope.of(context).unfocus();

    if (!isButtonEnabled) {
      return;
    }

    final email = controller.emailController.text.trim();

    if (email.isEmpty) {
      return;
    }

    // Keep the controller value clean.
    controller.emailController.value =
        controller.emailController.value.copyWith(
          text: email,
          selection: TextSelection.collapsed(
            offset: email.length,
          ),
          composing: TextRange.empty,
        );

    Get.to(
          () => const PasswordPage(),
      transition: Transition.rightToLeft,
      duration: const Duration(
        milliseconds: 250,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Back
  // ---------------------------------------------------------------------------

  void _goBack() {
    FocusScope.of(context).unfocus();

    if (Get.isOverlaysOpen) {
      Get.back();
      return;
    }

    Get.back();
  }

  // ---------------------------------------------------------------------------
  // Dispose
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    controller.emailController.removeListener(_validateEmail);
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
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
              currentStep: 0,
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
                            'Welcome back 👋',
                            style: GoogleFonts.poppins(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: AppColors.black,
                              height: 1.2,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Text(
                            'Enter your email to continue to AITradeX.',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: Colors.grey.shade600,
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 40),

                          Text(
                            'Email address',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.black,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // -------------------------------------------------
                          // Email field
                          // -------------------------------------------------

                          TextField(
                            controller:
                            controller.emailController,
                            autofocus: true,
                            textCapitalization:
                            TextCapitalization.none,
                            keyboardType:
                            TextInputType.emailAddress,
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
                              hintText: 'johnny@gmail.com',
                              hintStyle: GoogleFonts.poppins(
                                color: Colors.grey.shade400,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: AppColors.primary,
                              ),
                              contentPadding:
                              const EdgeInsets.symmetric(
                                vertical: 14,
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

                          const SizedBox(height: 14),

                          // -------------------------------------------------
                          // Information
                          // -------------------------------------------------

                          Row(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                size: 16,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 7),
                              Expanded(
                                child: Text(
                                  'Use the email address registered with your AITradeX account.',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          Text(
                            'Example: johnny@gmail.com',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                              height: 1.4,
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
            // Bottom button
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
                child: PrimaryButton(
                  text: 'Continue',
                  enabled: isButtonEnabled,
                  onPressed:
                  isButtonEnabled ? _continue : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}