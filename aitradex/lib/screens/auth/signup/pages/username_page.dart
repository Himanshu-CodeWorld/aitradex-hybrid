import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:aitradex/core/theme/app_colors.dart';
import 'package:aitradex/core/widgets/primary_button.dart';
import 'package:aitradex/core/widgets/signup_progress_header.dart';
import '../signup_controller.dart';

class UsernamePage extends StatefulWidget {
  const UsernamePage({super.key});

  @override
  State<UsernamePage> createState() => _UsernamePageState();
}

class _UsernamePageState extends State<UsernamePage> {
  late final SignupController controller;

  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();

    controller = Get.find<SignupController>();

    controller.usernameController.addListener(_validateUsername);
    _validateUsername();
  }

  void _validateUsername() {
    if (!mounted) return;

    final username = controller.usernameController.text.trim();

    final isValid = RegExp(
      r'^[a-zA-Z0-9_]{3,20}$',
    ).hasMatch(username);

    if (isButtonEnabled != isValid) {
      setState(() {
        isButtonEnabled = isValid;
      });
    }
  }

  @override
  void dispose() {
    controller.usernameController.removeListener(_validateUsername);
    super.dispose();
  }

  Future<void> _continue() async {
    FocusScope.of(context).unfocus();

    final success = await controller.submitUsername();

    if (!success || !mounted) return;

    await controller.nextPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            SignupProgressHeader(
              progress: 0.60,
              onBack: () {
                if (controller.currentPage.value > 0) {
                  controller.previousPage();
                } else {
                  Get.back();
                }
              },
            ),

            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(
                      24,
                      25,
                      24,
                      30,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 55,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Choose a username ✨',
                            style: GoogleFonts.poppins(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: AppColors.black,
                              height: 1.2,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Text(
                            "Create a unique username that you'll use on AITradeX.",
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: Colors.grey.shade600,
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 40),

                          Text(
                            'Username',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.black,
                            ),
                          ),

                          const SizedBox(height: 12),

                          TextField(
                            controller: controller.usernameController,
                            autofocus: true,
                            textCapitalization: TextCapitalization.none,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.done,
                            autocorrect: false,
                            enableSuggestions: false,
                            maxLength: 20,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppColors.black,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              hintText: 'johnny123',
                              hintStyle: GoogleFonts.poppins(
                                color: Colors.grey.shade400,
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                              prefixText: '@',
                              prefixStyle: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 10,
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
                              border: const UnderlineInputBorder(),
                            ),
                            onSubmitted: (_) {
                              if (isButtonEnabled) {
                                _continue();
                              }
                            },
                          ),

                          const SizedBox(height: 14),

                          Text(
                            'Use 3–20 characters. Letters, numbers and underscores are allowed.',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            'Example: johnny_123',
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
                  onPressed: isButtonEnabled ? _continue : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
