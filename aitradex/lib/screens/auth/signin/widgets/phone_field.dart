import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:aitradex/core/theme/app_colors.dart';

import '../signin_controller.dart';

class PhoneField extends GetView<SignInController> {
  const PhoneField({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Mobile Number",
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 12),

        TextField(
          controller: controller.phoneController,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          autofocus: true,
          cursorColor: AppColors.primary,
          maxLength: 10,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            counterText: "",
            hintText: "9876543210",

            hintStyle: GoogleFonts.poppins(
              color: Colors.grey.shade400,
            ),

            prefixIcon: const Icon(
              Icons.phone_android_rounded,
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
      ],
    );
  }
}