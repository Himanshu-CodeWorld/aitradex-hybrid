import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:aitradex/core/theme/app_colors.dart';
import 'package:aitradex/core/widgets/primary_button.dart';
import 'package:aitradex/core/widgets/signup_progress_header.dart';
import '../signup_controller.dart';

class ReviewInformationPage extends StatefulWidget {
  const ReviewInformationPage({super.key});

  @override
  State<ReviewInformationPage> createState() =>
      _ReviewInformationPageState();
}

class _ReviewInformationPageState
    extends State<ReviewInformationPage> {
  final SignupController controller = Get.find();

  final agreed = false.obs;

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget infoTile(
      String title,
      String value,
      IconData icon,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor:
            AppColors.primary.withValues(alpha: 0.10),
            child: Icon(
              icon,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget statusTile(
      String title,
      bool verified,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            verified
                ? Icons.verified
                : Icons.pending,
            color:
            verified ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            verified ? "Verified" : "Pending",
            style: GoogleFonts.poppins(
              color: verified
                  ? Colors.green
                  : Colors.orange,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Replace these with values from SignupController later.
    final fullName = controller.fullNameController.text;
    final gender = controller.selectedGender.value;
    final dob = controller.dobController.text;
    final birthPlace = controller.birthPlaceController.text;

    final occupation = controller.selectedOccupation.value;
    final company = controller.companyNameController.text;
    final income = controller.selectedMonthlyIncome.value;

    final address =
        "${controller.addressController.text}, "
        "${controller.cityController.text}, "
        "${controller.stateController.text} - "
        "${controller.pincodeController.text}";

    final bank =
        "${controller.bankNameController.text} •••• ${controller.accountNumberController.text.length >= 4 ? controller.accountNumberController.text.substring(controller.accountNumberController.text.length - 4) : controller.accountNumberController.text}";

    final nominee =
        "${controller.nomineeNameController.text} (${controller.selectedNomineeRelation.value})";

    return SafeArea(
      child: Column(
        children: [
          SignupProgressHeader(
            progress: 0.90,
            onBack: controller.previousPage,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    "Review Your Information",
                    style: GoogleFonts.poppins(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Please verify all the information before submitting your account application.",
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 28),

                  sectionTitle("Personal Details"),

                  infoTile(
                    "Full Name",
                    fullName,
                    Icons.person,
                  ),

                  infoTile(
                    "Gender",
                    gender,
                    Icons.wc,
                  ),

                  infoTile(
                    "Date of Birth",
                    dob,
                    Icons.calendar_today,
                  ),

                  infoTile(
                    "Birth Place",
                    birthPlace,
                    Icons.location_city,
                  ),

                  const SizedBox(height: 20),

                  sectionTitle("Employment"),

                  infoTile(
                    "Occupation",
                    occupation,
                    Icons.work,
                  ),

                  infoTile(
                    "Company",
                    company,
                    Icons.business,
                  ),

                  infoTile(
                    "Monthly Income",
                    income,
                    Icons.currency_rupee,
                  ),

                  const SizedBox(height: 20),

                  sectionTitle("KYC Status"),
                  sectionTitle("Verification Status"),

                  statusTile(
                    "Email Verification",
                    controller.signup.value.emailVerified,
                  ),

                  statusTile(
                    "Phone Verification",
                    controller.signup.value.phoneVerified,
                  ),

                  statusTile(
                    "PAN Card Uploaded",
                    controller.panImagePath.value.isNotEmpty,
                  ),

                  statusTile(
                    "Aadhaar Card Uploaded",
                    controller.aadhaarFrontImagePath.value.isNotEmpty &&
                        controller.aadhaarBackImagePath.value.isNotEmpty,
                  ),

                  statusTile(
                    "Selfie Verification",
                    controller.selfieImagePath.value.isNotEmpty,
                  ),

                  statusTile(
                    "Digital Signature",
                    controller.signup.value.signatureUrl.isNotEmpty,
                  ),

                  const SizedBox(height: 20),

                  sectionTitle("Address"),

                  infoTile(
                    "Residential Address",
                    address,
                    Icons.home,
                  ),

                  const SizedBox(height: 20),

                  sectionTitle("Bank"),

                  infoTile(
                    "Primary Account",
                    bank,
                    Icons.account_balance,
                  ),

                  const SizedBox(height: 20),

                  sectionTitle("Nominee"),

                  infoTile(
                    "Nominee",
                    nominee,
                    Icons.family_restroom,
                  ),

                  const SizedBox(height: 16),

                  Obx(
                        () => CheckboxListTile(
                      value: agreed.value,
                      activeColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        "I confirm that all the above information is correct.",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                        ),
                      ),
                      onChanged: (value) {
                        agreed.value = value ?? false;
                      },
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child:Obx(
                () => PrimaryButton(
              text: "Continue",
              enabled: agreed.value,
              onPressed: agreed.value
                  ? () {
                controller.nextPage();
              }
                  : null,
            ),
          )
          ),
        ],
      ),
    );
  }
}