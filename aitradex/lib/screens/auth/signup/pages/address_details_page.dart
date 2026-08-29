import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:aitradex/core/theme/app_colors.dart';
import 'package:aitradex/core/widgets/primary_button.dart';
import 'package:aitradex/core/widgets/signup_progress_header.dart';
import '../signup_controller.dart';

class AddressDetailsPage extends StatefulWidget {
  const AddressDetailsPage({super.key});

  @override
  State<AddressDetailsPage> createState() =>
      _AddressDetailsPageState();
}

class _AddressDetailsPageState extends State<AddressDetailsPage> {
  final SignupController controller = Get.find();

  String country = "India";

  bool get isValid =>
      controller.addressController.text.trim().isNotEmpty &&
          controller.cityController.text.trim().isNotEmpty &&
          controller.stateController.text.trim().isNotEmpty &&
          controller.pincodeController.text.trim().length == 6;

  @override
  void initState() {
    super.initState();

    for (final c in [
      controller.addressController,
      controller.cityController,
      controller.stateController,
      controller.pincodeController,
    ]) {
      c.addListener(() {
        if (mounted) setState(() {});
      });
    }
  }

  Widget buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        textCapitalization: TextCapitalization.words,
        style: GoogleFonts.poppins(
          fontSize: 17,
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
            progress: 0.70,
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
                    "Where do you live? 🏠",
                    style: GoogleFonts.poppins(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "Enter your current residential address for KYC verification.",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 32),

                  buildField(
                    label: "House / Flat No.",
                    controller: controller.addressController,
                    icon: Icons.home_outlined,
                  ),

                  buildField(
                    label: "City",
                    controller: controller.cityController,
                    icon: Icons.location_city_outlined,
                  ),

                  buildField(
                    label: "State",
                    controller: controller.stateController,
                    icon: Icons.map_outlined,
                  ),

                  buildField(
                    label: "Pincode",
                    controller: controller.pincodeController,
                    icon: Icons.pin_drop_outlined,
                    keyboard: TextInputType.number,
                  ),

                  DropdownButtonFormField<String>(
                    value: country,
                    decoration: InputDecoration(
                      labelText: "Country",
                      prefixIcon: const Icon(
                        Icons.public,
                        color: AppColors.primary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(16),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: "India",
                        child: Text("India"),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          country = value;
                        });
                      }
                    },
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