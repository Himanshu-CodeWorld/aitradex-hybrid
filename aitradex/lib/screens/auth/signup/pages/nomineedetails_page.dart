import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:aitradex/core/theme/app_colors.dart';
import 'package:aitradex/core/widgets/primary_button.dart';
import 'package:aitradex/core/widgets/signup_progress_header.dart';
import '../signup_controller.dart';

class NomineeDetailsPage extends StatefulWidget {
  const NomineeDetailsPage({super.key});

  @override
  State<NomineeDetailsPage> createState() =>
      _NomineeDetailsPageState();
}

class _NomineeDetailsPageState
    extends State<NomineeDetailsPage> {
  final SignupController controller = Get.find();

  Future<void> pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1995),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      controller.nomineeDobController.text =
          DateFormat("yyyy-MM-dd").format(picked);

      setState(() {});
    }
  }

  String relationship = "Father";

  bool get isValid =>
      controller.nomineeNameController.text.trim().isNotEmpty &&
          controller.nomineeDobController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();

    relationship = controller.selectedNomineeRelation.value.isEmpty
        ? "Father"
        : controller.selectedNomineeRelation.value;

    controller.nomineeNameController.addListener(() {
      if (mounted) setState(() {});
    });

    controller.nomineeDobController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  Widget buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
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
            progress: 0.80,
            onBack: controller.previousPage,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  Text(
                    "Nominee Details 👨‍👩‍👧",
                    style: GoogleFonts.poppins(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "Add a nominee who will receive your investments in case of unforeseen circumstances.",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 30),

                  buildField(
                    label: "Nominee Full Name",
                    controller: controller.nomineeNameController,
                    icon: Icons.person_outline,
                  ),

                  DropdownButtonFormField<String>(
                    value: relationship,
                    decoration: InputDecoration(
                      labelText: "Relationship",
                      prefixIcon: const Icon(
                        Icons.family_restroom,
                        color: AppColors.primary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(16),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: "Father",
                        child: Text("Father"),
                      ),
                      DropdownMenuItem(
                        value: "Mother",
                        child: Text("Mother"),
                      ),
                      DropdownMenuItem(
                        value: "Spouse",
                        child: Text("Spouse"),
                      ),
                      DropdownMenuItem(
                        value: "Brother",
                        child: Text("Brother"),
                      ),
                      DropdownMenuItem(
                        value: "Sister",
                        child: Text("Sister"),
                      ),
                      DropdownMenuItem(
                        value: "Son",
                        child: Text("Son"),
                      ),
                      DropdownMenuItem(
                        value: "Daughter",
                        child: Text("Daughter"),
                      ),
                      DropdownMenuItem(
                        value: "Other",
                        child: Text("Other"),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          relationship = value;
                        });

                        controller.selectedNomineeRelation.value = value;
                      }
                    },
                  ),

                  const SizedBox(height: 18),

                  GestureDetector(
                    onTap: pickDob,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade400,
                        ),
                        borderRadius:
                        BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              controller.nomineeDobController.text.isEmpty
                                  ? "Select Date of Birth"
                                  : DateFormat("dd MMM yyyy").format(
                                DateTime.parse(controller.nomineeDobController.text),
                              ),
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // buildField(
                  //   label: "Mobile Number",
                  //   controller: mobileController,
                  //   keyboard: TextInputType.phone,
                  //   icon: Icons.phone_android,
                  // ),
                  //
                  // buildField(
                  //   label: "Email (Optional)",
                  //   controller: emailController,
                  //   keyboard:
                  //   TextInputType.emailAddress,
                  //   icon: Icons.email_outlined,
                  // ),

                  // const SizedBox(height: 24),
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

                controller.selectedNomineeRelation.value = relationship;

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