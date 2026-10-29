import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:aitradex/core/theme/app_colors.dart';
import 'package:aitradex/core/widgets/primary_button.dart';
import 'package:aitradex/core/widgets/signup_progress_header.dart';

import '../signup_controller.dart';

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
        'Invalid Email',
        'Please enter a valid email address.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      controller.emailController.text = email;

      controller.signup.update((user) {
        if (user == null) return;

        user.email = email;
        user.emailVerified = false;
      });

      await controller.saveCurrentDraft();

      // Creates the temporary Firebase user and sends
      // Firebase's verification email to the entered Gmail address.
      final sent = await controller.startEmailVerification();

      if (!sent || !mounted) {
        return;
      }

      await _showEmailVerificationDialog();
    } catch (e) {
      Get.snackbar(
        'Email Verification Error',
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

  Future<void> _showEmailVerificationDialog() async {
    final email = controller.emailController.text.trim();
    bool checking = false;

    await Get.dialog(
      StatefulBuilder(
        builder: (context, setDialogState) {
          Future<void> checkVerification() async {
            if (checking) return;

            setDialogState(() {
              checking = true;
            });

            try {
              final verified = await controller.checkEmailVerification();

              if (verified) {
                if (Get.isDialogOpen == true) {
                  Get.back(result: true);
                }

                if (mounted) {
                  await controller.nextPage();
                }
              } else {
                Get.snackbar(
                  'Not Verified Yet',
                  'Please open Gmail and tap the verification link first.',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            } catch (e) {
              Get.snackbar(
                'Verification Error',
                e.toString(),
                snackPosition: SnackPosition.BOTTOM,
              );
            } finally {
              if (Get.isDialogOpen == true) {
                setDialogState(() {
                  checking = false;
                });
              }
            }
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mark_email_read_outlined,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Verify your email',
                    style: GoogleFonts.poppins(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            content: Text(
              'We sent a verification link to:\n\n$email\n\n'
                  'Open Gmail, find the AITradeX verification email, '
                  'and tap the verification link.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                height: 1.5,
                color: Colors.grey.shade700,
              ),
            ),
            actions: [
              TextButton(
                onPressed: checking
                    ? null
                    : () {
                  Get.back();
                },
                child: Text(
                  'Close',
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: checking ? null : checkVerification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: checking
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : Text(
                  'I Verified',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SignupProgressHeader(
            progress: 0.33,
            onBack: controller.previousPage,
          ),

          Expanded(
            child: SingleChildScrollView(
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
                    "We'll send a verification link to your Gmail address.",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 45),

                  Text(
                    'Email Address',
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
                    autocorrect: false,
                    enableSuggestions: false,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: 'john@gmail.com',
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
                    onSubmitted: (_) {
                      if (isButtonEnabled && !isLoading) {
                        _continue();
                      }
                    },
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: PrimaryButton(
              text: isLoading ? 'Sending...' : 'Send Verification Email',
              enabled: isButtonEnabled && !isLoading,
              onPressed: isLoading ? null : _continue,
            ),
          ),
        ],
      ),
    );
  }
}
