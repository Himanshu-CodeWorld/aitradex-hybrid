import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:aitradex/core/theme/app_colors.dart';
import 'package:aitradex/core/widgets/primary_button.dart';
import 'package:aitradex/core/widgets/signup_progress_header.dart';

import '../signup_controller.dart';

class PanNumberPage extends StatefulWidget {
  const PanNumberPage({super.key});

  @override
  State<PanNumberPage> createState() => _PanNumberPageState();
}

class _PanNumberPageState extends State<PanNumberPage> {
  final SignupController controller = Get.find();

  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();

    controller.panNumberController.addListener(_validate);

    _validate();
  }

  void _validate() {
    final pan =
    controller.panNumberController.text.trim().toUpperCase();

    if (!mounted) return;

    setState(() {
      isButtonEnabled =
          RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(pan);
    });
  }

  @override
  void dispose() {
    controller.panNumberController.removeListener(_validate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          /// Header
          SignupProgressHeader(
            progress: 0.56,
            onBack: controller.previousPage,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                  MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      150,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 25),

                      Text(
                        "What's your PAN Number? 🪪",
                        style: GoogleFonts.poppins(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        "PAN is mandatory for opening your investment account and completing your KYC verification.",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Colors.grey.shade600,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 45),

                      Text(
                        "PAN Number",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextField(
                        controller: controller.panNumberController,
                        autofocus: true,
                        textCapitalization:
                        TextCapitalization.characters,
                        inputFormatters: [
                          UpperCaseTextFormatter(),
                          LengthLimitingTextInputFormatter(10),
                        ],
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                        ),
                        decoration: InputDecoration(
                          hintText: "ABCDE1234F",
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey.shade400,
                            fontSize: 20,
                          ),
                          suffixIcon: const Icon(
                            Icons.badge_outlined,
                            color: AppColors.primary,
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
                        ),
                      ),

                      const SizedBox(height: 18),

                      Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.lock_outline,
                            color: Colors.green,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Your PAN is securely encrypted and used only for KYC verification.",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      PrimaryButton(
                        text: "Continue",
                        enabled: isButtonEnabled,
                        onPressed: () async {
                          FocusScope.of(context).unfocus();

                          controller.signup.value.panNumber =
                              controller.panNumberController.text
                                  .trim()
                                  .toUpperCase();

                          await controller.saveCurrentDraft();

                          await controller.nextPage();
                        },
                      ),

                      const SizedBox(height: 12),

                      Center(
                        child: TextButton(
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
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UpperCaseTextFormatter
    extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}