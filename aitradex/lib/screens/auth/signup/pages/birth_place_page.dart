import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:aitradex/core/theme/app_colors.dart';
import 'package:aitradex/core/widgets/primary_button.dart';
import 'package:aitradex/core/widgets/signup_progress_header.dart';
import '../signup_controller.dart';

class BirthPlacePage extends StatefulWidget {
  const BirthPlacePage({super.key});

  @override
  State<BirthPlacePage> createState() => _BirthPlacePageState();
}

class _BirthPlacePageState extends State<BirthPlacePage> {
  final SignupController controller = Get.find();

  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();

    controller.birthPlaceController.addListener(() {
      if (mounted) {
        setState(() {
          isButtonEnabled =
              controller.birthPlaceController.text.trim().isNotEmpty;
        });
      }
    });

    isButtonEnabled =
        controller.birthPlaceController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SignupProgressHeader(
            progress: 0.20,
            onBack: controller.previousPage,
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  Text(
                    "Where were you born? 🌍",
                    style: GoogleFonts.poppins(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "Enter the city where you were born.",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 45),

                  Text(
                    "Birth Place",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: controller.birthPlaceController,
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: "New Delhi",
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 20,
                        color: Colors.grey.shade400,
                      ),
                      suffixIcon: const Icon(
                        Icons.location_on_outlined,
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

                if (controller.birthPlaceController.text.trim().isEmpty) {
                  return;
                }

                // Save all data to SignupModel
                await controller.saveCurrentDraft();

                // Go to next page
                await controller.nextPage();
              },
            ),
          ),
        ],
      ),
    );
  }
}