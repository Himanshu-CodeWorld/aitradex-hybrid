import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:aitradex/core/theme/app_colors.dart';
import 'package:aitradex/core/widgets/primary_button.dart';
import 'package:aitradex/core/widgets/signup_progress_header.dart';
import '../signup_controller.dart';

class OccupationPage extends StatefulWidget {
  const OccupationPage({super.key});

  @override
  State<OccupationPage> createState() => _OccupationPageState();
}

class _OccupationPageState extends State<OccupationPage> {
  final SignupController controller = Get.find();

  String? selectedOccupation;

  final List<Map<String, dynamic>> occupations = [
    {
      "title": "Student",
      "subtitle": "Currently studying",
      "icon": Icons.school_rounded,
    },
    {
      "title": "Salaried Employee",
      "subtitle": "Working in a company",
      "icon": Icons.badge_rounded,
    },
    {
      "title": "Self Employed",
      "subtitle": "Running my own profession",
      "icon": Icons.work_outline_rounded,
    },
    {
      "title": "Business Owner",
      "subtitle": "Own or manage a business",
      "icon": Icons.business_center_rounded,
    },
    {
      "title": "Retired",
      "subtitle": "No longer working",
      "icon": Icons.elderly_rounded,
    },
    {
      "title": "Other",
      "subtitle": "Something else",
      "icon": Icons.more_horiz_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();

    if (controller.selectedOccupation.value.isNotEmpty) {
      selectedOccupation = controller.selectedOccupation.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SignupProgressHeader(
            progress: 0.35,
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
                    "What is your occupation? 💼",
                    style: GoogleFonts.poppins(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "Choose the option that best describes your current occupation.",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 30),

                  Expanded(
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: occupations.length,
                      separatorBuilder: (_, __) =>
                      const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final occupation = occupations[index];
                        final selected =
                            selectedOccupation == occupation["title"];

                        return InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            setState(() {
                              selectedOccupation = occupation["title"];
                            });

                            controller.selectedOccupation.value = occupation["title"];
                          },
                          child: AnimatedContainer(
                            duration:
                            const Duration(milliseconds: 250),
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primary.withOpacity(0.08)
                                  : Colors.white,
                              borderRadius:
                              BorderRadius.circular(18),
                              border: Border.all(
                                color: selected
                                    ? AppColors.primary
                                    : Colors.grey.shade300,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 26,
                                  backgroundColor: selected
                                      ? AppColors.primary
                                      : Colors.grey.shade200,
                                  child: Icon(
                                    occupation["icon"],
                                    color: selected
                                        ? Colors.white
                                        : Colors.grey.shade700,
                                    size: 28,
                                  ),
                                ),

                                const SizedBox(width: 18),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        occupation["title"],
                                        style: GoogleFonts.poppins(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      Text(
                                        occupation["subtitle"],
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                AnimatedOpacity(
                                  opacity: selected ? 1 : 0,
                                  duration: const Duration(
                                      milliseconds: 200),
                                  child: const Icon(
                                    Icons.check_circle,
                                    color: AppColors.primary,
                                    size: 28,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: PrimaryButton(
              text: "Continue",
              enabled: selectedOccupation != null,
              onPressed: () async {
                if (selectedOccupation == null) return;

                // Save selected occupation
                controller.selectedOccupation.value = selectedOccupation!;

                // Save current draft
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