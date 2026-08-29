import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:aitradex/core/theme/app_colors.dart';
import 'package:aitradex/core/widgets/primary_button.dart';
import 'package:aitradex/core/widgets/signup_progress_header.dart';
import '../signup_controller.dart';

class BankAccountDetailsPage extends StatefulWidget {
  const BankAccountDetailsPage({super.key});

  @override
  State<BankAccountDetailsPage> createState() =>
      _BankAccountDetailsPageState();
}

class _BankAccountDetailsPageState
    extends State<BankAccountDetailsPage> {
  final SignupController controller = Get.find();
  String accountType = "Savings";

  bool get isValid =>
      controller.accountHolderNameController.text.trim().isNotEmpty &&
          controller.bankNameController.text.trim().isNotEmpty &&
          controller.accountNumberController.text.trim().isNotEmpty &&
          controller.confirmAccountNumberController.text.trim().isNotEmpty &&
          controller.accountNumberController.text.trim() ==
              controller.confirmAccountNumberController.text.trim() &&
          controller.ifscController.text.trim().length >= 11;

  @override
  void initState() {
    super.initState();

    for (final c in [
      controller.accountHolderNameController,
      controller.bankNameController,
      controller.accountNumberController,
      controller.confirmAccountNumberController,
      controller.ifscController,
    ]) {
      c.addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  Widget buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        obscureText: obscure,
        textCapitalization: TextCapitalization.words,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon,
            color: AppColors.primary,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SignupProgressHeader(
            progress: 0.75,
            onBack: controller.previousPage,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding:
              const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  Text(
                    "Bank Account Details 🏦",
                    style: GoogleFonts.poppins(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "Your verified bank account will be used for deposits, withdrawals and settlements.",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 30),

                  buildField(
                    label: "Account Holder Name",
                    controller: controller.accountHolderNameController,
                    icon: Icons.person_outline,
                  ),

                  buildField(
                    label: "Bank Name",
                    controller: controller.bankNameController,
                    icon: Icons.account_balance_outlined,
                  ),

                  buildField(
                    label: "Account Number",
                    controller: controller.accountNumberController,
                    icon: Icons.credit_card_outlined,
                    keyboard: TextInputType.number,
                  ),

                  buildField(
                    label: "Confirm Account Number",
                    controller: controller.confirmAccountNumberController,
                    icon: Icons.verified_outlined,
                    keyboard: TextInputType.number,
                  ),

                  buildField(
                    label: "IFSC Code",
                    controller: controller.ifscController,
                    icon: Icons.qr_code_outlined,
                    keyboard: TextInputType.text,
                  ),

                  const SizedBox(height: 10),

                  DropdownButtonFormField<String>(
                    value: accountType,
                    decoration: InputDecoration(
                      labelText: "Account Type",
                      prefixIcon: const Icon(
                        Icons.account_balance_wallet_outlined,
                        color: AppColors.primary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(16),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: "Savings",
                        child: Text("Savings"),
                      ),
                      DropdownMenuItem(
                        value: "Current",
                        child: Text("Current"),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          accountType = value;
                        });

                        controller.selectedAccountType.value = value;
                      }
                    },
                  ),

                  if (controller.confirmAccountNumberController.text.isNotEmpty &&
                      controller.accountNumberController.text !=
                          controller.confirmAccountNumberController.text)
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 12,
                      ),
                      child: Text(
                        "Account numbers do not match.",
                        style: GoogleFonts.poppins(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          Padding(
            padding:
            const EdgeInsets.fromLTRB(
                24, 12, 24, 24),
            child: PrimaryButton(
              text: "Continue",
              enabled: isValid,
              onPressed: () async {
                FocusScope.of(context).unfocus();

                if (!isValid) return;

                controller.selectedAccountType.value = accountType;

                await controller.saveCurrentDraft();

                await controller.nextPage();
              },
            ),
          ),
        ],
      ),
    );
  }
}