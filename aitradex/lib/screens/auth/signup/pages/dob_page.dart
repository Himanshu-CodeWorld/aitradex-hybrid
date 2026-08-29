import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:aitradex/core/theme/app_colors.dart';
import 'package:aitradex/core/widgets/primary_button.dart';
import 'package:aitradex/core/widgets/signup_progress_header.dart';
import '../signup_controller.dart';

class DobPage extends StatefulWidget {
  const DobPage({super.key});

  @override
  State<DobPage> createState() => _DobPageState();
}

class _DobPageState extends State<DobPage> {
  final SignupController controller = Get.find();

  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();

    // Restore previous DOB if available
    if (controller.dobController.text.isNotEmpty) {
      try {
        final parts = controller.dobController.text.split('/');

        if (parts.length == 3) {
          selectedDate = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      } catch (_) {}
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      helpText: "Select Date of Birth",
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;

        controller.dobController.text =
        "${picked.day.toString().padLeft(2, '0')}/"
            "${picked.month.toString().padLeft(2, '0')}/"
            "${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SignupProgressHeader(
            progress: 0.15,
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
                    "When is your birthday? 🎂",
                    style: GoogleFonts.poppins(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "Your birthday helps us personalize your account.",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 40),

                  Text(
                    "Date of Birth",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: controller.dobController,
                    readOnly: true,
                    onTap: _pickDate,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: "DD/MM/YYYY",
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.grey.shade400,
                        fontSize: 20,
                      ),
                      suffixIcon: const Icon(
                        Icons.calendar_today_rounded,
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
              enabled: controller.dobController.text.isNotEmpty,
              onPressed: () async {
                if (controller.dobController.text.isEmpty) return;

                // Save all current data
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
}