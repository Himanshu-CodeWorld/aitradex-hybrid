import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:aitradex/core/theme/app_colors.dart';
import 'package:aitradex/core/widgets/primary_button.dart';
import 'package:aitradex/core/widgets/signup_progress_header.dart';
import '../signup_controller.dart';

class InvestmentGoalPage extends StatefulWidget {
  const InvestmentGoalPage({super.key});

  @override
  State<InvestmentGoalPage> createState() => _InvestmentGoalPageState();
}

class _InvestmentGoalPageState extends State<InvestmentGoalPage> {
  final SignupController controller = Get.find();

  String? selectedGoal;

  final List<Map<String, dynamic>> goals = [
    {
      "title": "Long-term Wealth",
      "icon": Icons.trending_up_rounded,
    },
    {
      "title": "Passive Income",
      "icon": Icons.account_balance_wallet_rounded,
    },
    {
      "title": "Retirement Planning",
      "icon": Icons.elderly_rounded,
    },
    {
      "title": "Short-term Trading",
      "icon": Icons.show_chart_rounded,
    },
    {
      "title": "Save for Education",
      "icon": Icons.school_rounded,
    },
    {
      "title": "Other Goal",
      "icon": Icons.flag_outlined,
    },
  ];

  @override
  void initState() {
    super.initState();

    if (controller.selectedInvestmentGoal.value.isNotEmpty) {
      selectedGoal = controller.selectedInvestmentGoal.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SignupProgressHeader(
            progress: 0.25,
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
                    "What is your investment goal? 📈",
                    style: GoogleFonts.poppins(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "Choose the option that best matches your financial goal.",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 30),

                  Expanded(
                    child: ListView.separated(
                      itemCount: goals.length,
                      separatorBuilder: (_, __) =>
                      const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final goal = goals[index];
                        final selected =
                            selectedGoal == goal["title"];

                        return InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            setState(() {
                              selectedGoal = goal["title"];
                            });

                            controller.selectedInvestmentGoal.value = goal["title"];
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
                                  radius: 24,
                                  backgroundColor: selected
                                      ? AppColors.primary
                                      : Colors.grey.shade200,
                                  child: Icon(
                                    goal["icon"],
                                    color: selected
                                        ? Colors.white
                                        : Colors.grey.shade700,
                                  ),
                                ),

                                const SizedBox(width: 16),

                                Expanded(
                                  child: Text(
                                    goal["title"],
                                    style: GoogleFonts.poppins(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),

                                if (selected)
                                  const Icon(
                                    Icons.check_circle,
                                    color: AppColors.primary,
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
              enabled: selectedGoal != null,
              onPressed: () async {
                if (selectedGoal == null) return;

                // Save selected investment goal
                controller.selectedInvestmentGoal.value = selectedGoal!;

                // Save all data to SignupModel & SharedPreferences
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