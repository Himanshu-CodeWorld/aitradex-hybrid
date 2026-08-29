import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:aitradex/core/theme/app_colors.dart';
import 'package:aitradex/core/widgets/primary_button.dart';
import 'package:aitradex/core/widgets/signup_progress_header.dart';

import '../signup_controller.dart';

class AadhaarNumberPage extends StatefulWidget {
  const AadhaarNumberPage({super.key});

  @override
  State<AadhaarNumberPage> createState() => _AadhaarNumberPageState();
}

class _AadhaarNumberPageState extends State<AadhaarNumberPage> {
  final SignupController controller = Get.find();

  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();

    controller.aadhaarNumberController.addListener(_validate);

    _validate();
  }

  void _validate() {
    final text = controller.aadhaarNumberController.text.trim();

    if (!mounted) return;

    setState(() {
      isButtonEnabled =
          RegExp(r'^[0-9]{12}$').hasMatch(text);
    });
  }

  @override
  void dispose() {
    controller.aadhaarNumberController.removeListener(_validate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          /// Header
          SignupProgressHeader(
            progress: 0.60,
            onBack: controller.previousPage,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  Text(
                    "What's your Aadhaar Number?",
                    style: GoogleFonts.poppins(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "Your Aadhaar number is securely used for KYC verification. It will never be shared without your permission.",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 45),

                  Text(
                    "Aadhaar Number",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: controller.aadhaarNumberController,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(12),
                    ],
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                    decoration: InputDecoration(
                      hintText: "1234 5678 9012",
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 20,
                        color: Colors.grey.shade400,
                      ),
                      suffixIcon: const Icon(
                        Icons.badge_outlined,
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

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      const Icon(
                        Icons.lock_outline,
                        color: Colors.green,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Your Aadhaar information is encrypted and securely stored.",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              children: [
                PrimaryButton(
                  text: "Continue",
                  enabled: isButtonEnabled,
                  onPressed: () async {
                    FocusScope.of(context).unfocus();

                    if (!isButtonEnabled) return;

                    controller.signup.value.aadhaarNumber =
                        controller.aadhaarNumberController.text.trim();

                    await controller.saveCurrentDraft();

                    await controller.nextPage();
                  },
                ),

                const SizedBox(height: 12),

                TextButton(
                  onPressed: () async {
                    FocusScope.of(context).unfocus();

                    await controller.saveCurrentDraft();

                    await controller.nextPage();
                  },
                  child: Text(
                    "Skip for now",
                    style: GoogleFonts.poppins(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}