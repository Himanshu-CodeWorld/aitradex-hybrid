import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:aitradex/core/theme/app_colors.dart';
import 'package:aitradex/core/widgets/primary_button.dart';
import 'package:aitradex/core/widgets/signup_progress_header.dart';
import '../signup_controller.dart';

class GenderPage extends StatefulWidget {
  const GenderPage({super.key});

  @override
  State<GenderPage> createState() => _GenderPageState();
}

class _GenderPageState extends State<GenderPage> {
  final SignupController controller = Get.find();

  String? selectedGender;

  @override
  void initState() {
    super.initState();

    // Restore previously selected gender
    if (controller.selectedGender.value.isNotEmpty) {
      selectedGender = controller.selectedGender.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SignupProgressHeader(
            progress: 0.10,
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
                    "What is your gender? 🚻",
                    style: GoogleFonts.poppins(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "Select the option that best describes you.",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 40),

                  _genderTile(
                    title: "I am male",
                    value: "Male",
                  ),

                  const Divider(),

                  _genderTile(
                    title: "I am female",
                    value: "Female",
                  ),

                  const Divider(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: PrimaryButton(
              text: "Continue",
              enabled: selectedGender != null,
              onPressed: () async {
                if (selectedGender == null) return;

                // Save to controller
                controller.selectedGender.value = selectedGender!;

                // Save all data into SignupModel
                await controller.saveCurrentDraft();

                // Next page
                await controller.nextPage();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _genderTile({
    required String title,
    required String value,
  }) {
    final bool selected = selectedGender == value;

    return InkWell(
      onTap: () {
        setState(() {
          selectedGender = value;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 70,
        alignment: Alignment.center,
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? AppColors.primary
                      : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              )
                  : null,
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}