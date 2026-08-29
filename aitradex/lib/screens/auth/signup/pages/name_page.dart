
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:aitradex/core/theme/app_colors.dart';
import 'package:aitradex/core/widgets/primary_button.dart';
import 'package:aitradex/core/widgets/signup_progress_header.dart';
import '../signup_controller.dart';

class NamePage extends StatefulWidget {
  const NamePage({super.key});

  @override
  State<NamePage> createState() => _NamePageState();
}

class _NamePageState extends State<NamePage> {
  final SignupController controller = Get.find();

  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();

    controller.fullNameController.addListener(() {
      setState(() {
        isButtonEnabled =
            controller.fullNameController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          /// Header
          SignupProgressHeader(
            progress: 0.05,
            onBack: () {
              if (controller.currentPage.value > 0) {
                controller.previousPage();
              } else {
                Get.back();
              }
            },
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 25),

                  Text(
                    "What is your name? 👋",
                    style: GoogleFonts.poppins(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "Tell us your full name to personalize your experience.",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 45),

                  Text(
                    "Full Name",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: controller.fullNameController,
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: "Andrew Ainsley",
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.grey.shade400,
                        fontSize: 20,
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
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: PrimaryButton(
              text: "Continue",
              enabled: isButtonEnabled,
              onPressed: () async {
                FocusScope.of(context).unfocus();

                // Save latest values into SignupModel
                await controller.saveCurrentDraft();

                // Next Page
                await controller.nextPage();
              },
            ),
          ),
        ],
      ),
    );
  }
}