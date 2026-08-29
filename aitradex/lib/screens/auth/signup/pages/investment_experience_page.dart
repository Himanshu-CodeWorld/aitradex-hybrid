import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:aitradex/core/theme/app_colors.dart';
import 'package:aitradex/core/widgets/primary_button.dart';
import 'package:aitradex/core/widgets/signup_progress_header.dart';
import '../signup_controller.dart';

class InvestmentExperiencePage extends StatefulWidget {
  const InvestmentExperiencePage({super.key});

  @override
  State<InvestmentExperiencePage> createState() =>
      _InvestmentExperiencePageState();
}

class _InvestmentExperiencePageState
    extends State<InvestmentExperiencePage> {
  final SignupController controller = Get.find();

  String? selectedExperience;

  final List<Map<String, dynamic>> experiences = [
    {
      "title": "Beginner",
      "subtitle": "I'm just getting started.",
      "icon": Icons.school_outlined,
    },
    {
      "title": "Intermediate",
      "subtitle": "I have invested a few times.",
      "icon": Icons.trending_up,
    },
    {
      "title": "Advanced",
      "subtitle": "I actively invest in markets.",
      "icon": Icons.bar_chart_rounded,
    },
    {
      "title": "Expert",
      "subtitle": "Professional trader or investor.",
      "icon": Icons.workspace_premium_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();

    if (controller.selectedInvestmentExperience.value.isNotEmpty) {
      selectedExperience = controller.selectedInvestmentExperience.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SignupProgressHeader(
            progress: 0.30,
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
                    "How experienced are you? 📊",
                    style: GoogleFonts.poppins(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "Select your investment experience level.",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 30),

                  Expanded(
                    child: ListView.separated(
                      itemCount: experiences.length,
                      separatorBuilder: (_, __) =>
                      const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final item = experiences[index];
                        final selected =
                            selectedExperience == item["title"];

                        return InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            setState(() {
                              selectedExperience = item["title"];
                            });

                            controller.selectedInvestmentExperience.value = item["title"];
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
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 26,
                                  backgroundColor: selected
                                      ? AppColors.primary
                                      : Colors.grey.shade200,
                                  child: Icon(
                                    item["icon"],
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
                                        item["title"],
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight:
                                          FontWeight.w600,
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      Text(
                                        item["subtitle"],
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color:
                                          Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                AnimatedOpacity(
                                  duration:
                                  const Duration(milliseconds: 200),
                                  opacity: selected ? 1 : 0,
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
              enabled: selectedExperience != null,
              onPressed: () async {
                if (selectedExperience == null) return;

                // Save selected investment experience
                controller.selectedInvestmentExperience.value =
                selectedExperience!;

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