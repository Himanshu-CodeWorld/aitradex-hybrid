import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:aitradex/core/theme/app_colors.dart';
import 'package:aitradex/core/widgets/primary_button.dart';
import 'package:aitradex/core/widgets/signup_progress_header.dart';
import '../signup_controller.dart';

class CompanyDetailsPage extends StatefulWidget {
  const CompanyDetailsPage({super.key});

  @override
  State<CompanyDetailsPage> createState() => _CompanyDetailsPageState();
}

class _CompanyDetailsPageState extends State<CompanyDetailsPage> {
  final SignupController controller = Get.find();

  final TextEditingController companyController = TextEditingController();

  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();

    controller.companyNameController.addListener(() {
      if (mounted) {
        setState(() {
          isButtonEnabled =
              controller.companyNameController.text.trim().isNotEmpty;
        });
      }
    });

    isButtonEnabled =
        controller.companyNameController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          /// Header
          SignupProgressHeader(
            progress: 0.45,
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
                    "Where do you work? 🏢",
                    style: GoogleFonts.poppins(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "Tell us the name of your company.",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 45),

                  Text(
                    "Company Name",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: controller.companyNameController,
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: "OpenAI Technologies",
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 20,
                        color: Colors.grey.shade400,
                      ),
                      suffixIcon: const Icon(
                        Icons.business_rounded,
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

                    if (controller.companyNameController.text.trim().isEmpty) {
                      return;
                    }

                    // Save all signup data
                    await controller.saveCurrentDraft();

                    // Next page
                    await controller.nextPage();
                  },
                ),

                const SizedBox(height: 12),

                TextButton(
                  onPressed: () async {
                    FocusScope.of(context).unfocus();

                    // Save current draft (company name will remain empty)
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