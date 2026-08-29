import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:aitradex/core/theme/app_colors.dart';
import 'package:aitradex/core/widgets/primary_button.dart';
import 'package:aitradex/core/widgets/signup_progress_header.dart';
import '../signup_controller.dart';

class JobTitlePage extends StatefulWidget {
  const JobTitlePage({super.key});

  @override
  State<JobTitlePage> createState() => _JobTitlePageState();
}

class _JobTitlePageState extends State<JobTitlePage> {
  final SignupController controller = Get.find();
  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();

    controller.jobTitleController.addListener(() {
      if (mounted) {
        setState(() {
          isButtonEnabled =
              controller.jobTitleController.text.trim().isNotEmpty;
        });
      }
    });

    isButtonEnabled =
        controller.jobTitleController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          /// Header
          SignupProgressHeader(
            progress: 0.50,
            onBack: controller.previousPage,
          ),

          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  Text(
                    "What's your job title? 👔",
                    style: GoogleFonts.poppins(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "Tell us your current designation or profession.",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 45),

                  Text(
                    "Job Title",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: controller.jobTitleController,
                    autofocus: false, // Prevent keyboard from opening automatically
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.done,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: "Software Engineer",
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

                  // Extra bottom space for keyboard
                  SizedBox(
                    height: MediaQuery.of(context).viewInsets.bottom + 80,
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding:
            const EdgeInsets.fromLTRB(
                24, 12, 24, 24),
            child: Column(
              children: [
                PrimaryButton(
                  text: "Continue",
                  enabled: isButtonEnabled,
                  onPressed: () async {
                    FocusScope.of(context).unfocus();

                    if (controller.jobTitleController.text.trim().isEmpty) {
                      return;
                    }

                    // Save current page data
                    await controller.saveCurrentDraft();

                    // Next page
                    await controller.nextPage();
                  },
                ),

                const SizedBox(height: 12),

                TextButton(
                  onPressed: () async {
                    FocusScope.of(context).unfocus();

                    // Save draft with empty job title
                    await controller.saveCurrentDraft();

                    // Next page
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