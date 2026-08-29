import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'signup_controller.dart';

import 'pages/name_page.dart';
import 'pages/email_page.dart';
import 'pages/phone_number_page.dart';
import 'pages/gender_page.dart';
import 'pages/dob_page.dart';
import 'pages/birth_place_page.dart';
import 'pages/profile_image_page.dart';
import 'pages/investment_goal_page.dart';
import 'pages/investment_experience_page.dart';
import 'pages/occupation_page.dart';
import 'pages/monthly_income_page.dart';
import 'pages/company_details_page.dart';
import 'pages/job_title_page.dart';
import 'pages/pannumber_page.dart';
import 'pages/aadharnumber_page.dart';
import 'pages/pan_card_upload_page.dart';
import 'pages/aadhar_upload_page.dart';
import 'pages/selfie_verification_page.dart';
import 'pages/address_details_page.dart';
import 'pages/bankaccountdetails_page.dart';
import 'pages/nomineedetails_page.dart';
import 'pages/review_information_page.dart';
import 'pages/create_mpin_page.dart';
import 'pages/signup_success_page.dart';
import 'pages/digital_signature_page.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {

  late final SignupController controller;

  @override
  void initState() {
    super.initState();

    controller = Get.find<SignupController>(); // binding already created it

    debugPrint("SignupController Hash: ${controller.hashCode}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView(
        controller: controller.pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: controller.onPageChanged,
        children: const [
          EmailPage(),
          NamePage(),
          PhoneNumberPage(),
          ProfileImagePage(),
          GenderPage(),
          DobPage(),
          BirthPlacePage(),
          InvestmentGoalPage(),
          InvestmentExperiencePage(),
          OccupationPage(),
          MonthlyIncomePage(),
          CompanyDetailsPage(),
          JobTitlePage(),
          PanNumberPage(),
          AadhaarNumberPage(),
          PanCardUploadPage(),
          AadhaarUploadPage(),
          SelfieVerificationPage(),
          AddressDetailsPage(),
          BankAccountDetailsPage(),
          NomineeDetailsPage(),
          ReviewInformationPage(),
          DigitalSignaturePage(),
          CreateMpinPage(),
          SignupSuccessPage(),
        ],
      ),
    );
  }
}
