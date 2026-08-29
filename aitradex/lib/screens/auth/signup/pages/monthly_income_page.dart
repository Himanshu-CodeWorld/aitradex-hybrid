import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:aitradex/core/theme/app_colors.dart';
import 'package:aitradex/core/widgets/primary_button.dart';
import 'package:aitradex/core/widgets/signup_progress_header.dart';
import '../signup_controller.dart';

class MonthlyIncomePage extends StatefulWidget {
  const MonthlyIncomePage({super.key});

  @override
  State<MonthlyIncomePage> createState() => _MonthlyIncomePageState();
}

class _MonthlyIncomePageState extends State<MonthlyIncomePage> {
  final SignupController controller = Get.find();

  String? selectedIncome;

  final List<Map<String, dynamic>> incomeRanges = [
    {
      "title": "Below ₹25,000",
      "subtitle": "Entry level income",
      "icon": Icons.account_balance_wallet_outlined,
    },
    {
      "title": "₹25,000 - ₹50,000",
      "subtitle": "Lower-middle income",
      "icon": Icons.savings_outlined,
    },
    {
      "title": "₹50,000 - ₹1,00,000",
      "subtitle": "Middle income",
      "icon": Icons.currency_rupee,
    },
    {
      "title": "₹1,00,000 - ₹2,50,000",
      "subtitle": "Upper-middle income",
      "icon": Icons.trending_up_rounded,
    },
    {
      "title": "Above ₹2,50,000",
      "subtitle": "High income",
      "icon": Icons.workspace_premium_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();

    if (controller.selectedMonthlyIncome.value.isNotEmpty) {
      selectedIncome = controller.selectedMonthlyIncome.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SignupProgressHeader(
            progress: 0.40,
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
                    "What's your monthly income? 💰",
                    style: GoogleFonts.poppins(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "This helps us recommend investment plans that match your financial profile.",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 30),

                  Expanded(
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: incomeRanges.length,
                      separatorBuilder: (_, __) =>
                      const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final item = incomeRanges[index];
                        final selected =
                            selectedIncome == item["title"];

                        return InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            setState(() {
                              selectedIncome = item["title"];
                            });

                            controller.selectedMonthlyIncome.value = item["title"];
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
                                  color:
                                  Colors.black.withOpacity(0.04),
                                  blurRadius: 12,
                                  offset: const Offset(0, 5),
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
                                          fontSize: 17,
                                          fontWeight:
                                          FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item["subtitle"],
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color:
                                          Colors.grey.shade600,
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
              enabled: selectedIncome != null,
              onPressed: () async {
                if (selectedIncome == null) return;

                // Save selected monthly income
                controller.selectedMonthlyIncome.value = selectedIncome!;

                // Save current page data to SignupModel
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