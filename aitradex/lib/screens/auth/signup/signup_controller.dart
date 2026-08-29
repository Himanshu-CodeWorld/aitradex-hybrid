import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../services/auth_service.dart';
import '../../../models/signup_model.dart';
import '../../../services/upload_service.dart';
import '../../../services/shared_preferences_service.dart';

import 'package:aitradex/screens/auth/signup/signup_service.dart';
import '../otp/otp_service.dart';

class SignupController extends GetxController {
  // ==========================================================
  // PAGE CONTROLLER
  // ==========================================================

  final PageController pageController = PageController();
  final ImagePicker picker = ImagePicker();


  /// Current page index
  final RxInt currentPage = 0.obs;

  /// Total signup pages
  static const int totalPages = 25;

  // ==========================================================
  // SIGNUP MODEL
  // ==========================================================

  /// Holds all signup data
  final Rx<SignupModel> signup = SignupModel().obs;

  // ==========================================================
// TEXT EDITING CONTROLLERS
// ==========================================================

// Personal Details
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController birthPlaceController = TextEditingController();

// Company Details
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController jobTitleController = TextEditingController();

// PAN & Aadhaar
  final TextEditingController panNumberController = TextEditingController();
  final TextEditingController aadhaarNumberController = TextEditingController();

// Address
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();

// Bank
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController confirmAccountNumberController =
  TextEditingController();
  final TextEditingController ifscController = TextEditingController();
  final TextEditingController accountHolderNameController =
  TextEditingController();

// Nominee
  final TextEditingController nomineeNameController =
  TextEditingController();

  final TextEditingController nomineeDobController =
  TextEditingController();

// Digital Signature
  final TextEditingController signatureNameController =
  TextEditingController();

// MPIN
  final TextEditingController mpinController = TextEditingController();
  final TextEditingController confirmMpinController =
  TextEditingController();


// ==========================================================
// REACTIVE VARIABLES
// ==========================================================

// Personal
  final RxString selectedGender = "".obs;

// Investment
  final RxString selectedInvestmentGoal = "".obs;
  final RxString selectedInvestmentExperience = "".obs;

// Occupation
  final RxString selectedOccupation = "".obs;

// Income
  final RxString selectedMonthlyIncome = "".obs;

// Bank
  final RxBool isPrimaryBank = true.obs;
  final RxString selectedAccountType = "Savings".obs;

// Nominee
  final RxString selectedNomineeRelation = "".obs;

// Upload Status
  final RxString profileImagePath = "".obs;
  final RxString panImagePath = "".obs;
  final RxString aadhaarFrontImagePath = "".obs;
  final RxString aadhaarBackImagePath = "".obs;
  final RxString selfieImagePath = "".obs;
  final RxString signatureImagePath = "".obs;


// ==========================================================
// VALIDATION
// ==========================================================

  bool get isBankValid {
    return bankNameController.text.isNotEmpty &&
        accountHolderNameController.text.isNotEmpty &&
        accountNumberController.text.isNotEmpty &&
        confirmAccountNumberController.text ==
            accountNumberController.text &&
        ifscController.text.length >= 11;
  }

  bool get isMpinValid {
    return mpinController.text.length == 6 &&
        confirmMpinController.text.length == 6 &&
        confirmMpinController.text == mpinController.text;
  }

  bool get isNomineeValid {
    return nomineeNameController.text.isNotEmpty &&
        selectedNomineeRelation.value.isNotEmpty;
  }

  bool get isAddressValid {
    return addressController.text.isNotEmpty &&
        cityController.text.isNotEmpty &&
        stateController.text.isNotEmpty &&
        pincodeController.text.length == 6;
  }

  bool get isPanValid {
    return panNumberController.text.length == 10;
  }

  bool get isAadhaarValid {
    return aadhaarNumberController.text.length == 12;
  }

  bool get isNameValid {
    return fullNameController.text.trim().length >= 3;
  }

  // ==========================================================
  // LOADING
  // ==========================================================

  final RxBool isLoading = false.obs;

  Future<bool> createAccount() async {
    if (isSubmitting.value) return false;

    try {
      isSubmitting.value = true;

      final success = await submitSignup();

      if (success) {
        await nextPage();
        return true;
      } else {
        Get.snackbar(
          "Signup Failed",
          "Unable to create your account.",
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // ==========================================================
  // LIFECYCLE
  // ==========================================================

  @override
  void onInit() {
    super.onInit();
    _loadDraft();
  }

  @override
  void onClose() {
    if (pageController.hasClients) {
      pageController.dispose();
    }

    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    dobController.dispose();
    birthPlaceController.dispose();

    companyNameController.dispose();
    jobTitleController.dispose();

    panNumberController.dispose();
    aadhaarNumberController.dispose();

    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    pincodeController.dispose();

    bankNameController.dispose();
    accountHolderNameController.dispose();
    accountNumberController.dispose();
    confirmAccountNumberController.dispose();
    ifscController.dispose();

    nomineeNameController.dispose();
    nomineeDobController.dispose();

    signatureNameController.dispose();

    mpinController.dispose();
    confirmMpinController.dispose();

    super.onClose();
  }

  // ==========================================================
  // PAGE EVENTS
  // ==========================================================

  Future<bool> checkEmail(String email) async {
    return await SignupService.checkEmail(email);
  }

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  Future<void> nextPage() async {
    debugPrint("nextPage() called. Current: ${currentPage.value}, hasClients: ${pageController.hasClients}");

    if (!pageController.hasClients) {
      debugPrint("⚠️ nextPage() ABORTED — pageController has no clients.");
      return;
    }

    final next = currentPage.value + 1;

    if (next >= totalPages) {
      debugPrint("nextPage() ABORTED — already at last page ($currentPage/$totalPages)");
      return;
    }

    try {
      await pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      currentPage.value = next;
      debugPrint("nextPage() SUCCESS — now on page $next");
    } catch (e, stack) {
      debugPrint("❌ nextPage() animateToPage THREW: $e");
      debugPrint(stack.toString());

      // Fallback: force jump without animation, in case animateToPage
      // failed due to a mid-transition/layout issue.
      if (pageController.hasClients) {
        pageController.jumpToPage(next);
        currentPage.value = next;
        debugPrint("nextPage() fallback jumpToPage($next) applied");
      }
    }
  }

  Future<void> previousPage() async {
    if (!pageController.hasClients) return;

    if (currentPage.value <= 0) return;

    await pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> goToPage(int page) async {
    if (!pageController.hasClients) return;

    if (page < 0 || page >= totalPages) return;

    await pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// Synchronous page advance — no animation, no awaitable Future to hang.
  /// Use this specifically right after a route pop (e.g. from OtpController),
  /// where animateToPage() can hang due to overlapping route-transition timing.
  void jumpToNextPage() {
    if (!pageController.hasClients) {
      debugPrint("⚠️ jumpToNextPage() aborted — pageController has no clients.");
      return;
    }

    final next = currentPage.value + 1;
    if (next >= totalPages) return;

    pageController.jumpToPage(next);
    currentPage.value = next;
  }

  // ==========================================================
  // SIGNUP DRAFT
  // ==========================================================

  Future<void> _loadDraft() async {
    try {
      isLoading.value = true;

      final SignupModel? draft =
      await SharedPreferencesService.getSignupData();

      if (draft != null) {
        signup.value = draft;
        fillControllersFromModel();
      }
    } catch (e) {
      debugPrint("Load signup draft error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveDraft() async {
    try {
      await SharedPreferencesService.saveSignupData(
        signup.value,
      );
    } catch (e) {
      debugPrint("Save signup draft error: $e");
    }
  }

  Future<void> clearDraft() async {
    signup.value = SignupModel();

    await SharedPreferencesService.clearSignupData();
  }

  // ==========================================================
// MODEL <-> UI SYNC
// ==========================================================

  /// Read all UI values into the SignupModel
  void updateSignupModel() {
    signup.value
    // Personal Details
      ..fullName = fullNameController.text.trim()
      ..email = emailController.text.trim()
      ..phone = phoneController.text.trim()
      ..countryCode = "+91"
      ..gender = selectedGender.value
      ..dob = dobController.text.trim()
      ..birthPlace = birthPlaceController.text.trim()
      ..profileImage = profileImagePath.value

    // Investment
      ..investmentGoal = selectedInvestmentGoal.value
      ..investmentExperience = selectedInvestmentExperience.value

    // Employment
      ..occupation = selectedOccupation.value
      ..monthlyIncome = selectedMonthlyIncome.value
      ..companyName = companyNameController.text.trim()
      ..jobTitle = jobTitleController.text.trim()

    // PAN & Aadhaar
      ..panNumber = panNumberController.text.trim().toUpperCase()
      ..aadhaarNumber = aadhaarNumberController.text.trim()

    // Uploads
      ..panImageUrl = panImagePath.value
      ..aadhaarFrontUrl = aadhaarFrontImagePath.value
      ..aadhaarBackUrl = aadhaarBackImagePath.value
      ..selfieUrl = selfieImagePath.value

    // Address
      ..address = addressController.text.trim()
      ..city = cityController.text.trim()
      ..state = stateController.text.trim()
      ..pincode = pincodeController.text.trim()

    // Bank
      ..bankName = bankNameController.text.trim()
      ..accountNumber = accountNumberController.text.trim()
      ..accountHolderName = accountHolderNameController.text.trim()
      ..ifscCode = ifscController.text.trim().toUpperCase()
      ..accountType = selectedAccountType.value

    // Nominee
      ..nomineeName = nomineeNameController.text.trim()
      ..nomineeRelation = selectedNomineeRelation.value
      ..nomineeDob = nomineeDobController.text.trim()

    // Signature
      ..signatureUrl = signatureImagePath.value

    // MPIN
      ..mpin = mpinController.text.trim();

    signup.refresh();
  }

  /// Fill all UI controllers from SignupModel
  void fillControllersFromModel() {
    final model = signup.value;

    fullNameController.text = model.fullName;
    emailController.text = model.email;
    phoneController.text = model.phone;
    dobController.text = model.dob;
    birthPlaceController.text = model.birthPlace;

    companyNameController.text = model.companyName;
    jobTitleController.text = model.jobTitle;

    panImagePath.value = model.panImageUrl;
    profileImagePath.value = model.profileImage;
    aadhaarFrontImagePath.value = model.aadhaarFrontUrl;
    aadhaarBackImagePath.value = model.aadhaarBackUrl;
    panNumberController.text = model.panNumber;
    aadhaarNumberController.text = model.aadhaarNumber;

    addressController.text = model.address;
    cityController.text = model.city;
    stateController.text = model.state;
    pincodeController.text = model.pincode;

    bankNameController.text = model.bankName;
    accountNumberController.text = model.accountNumber;
    confirmAccountNumberController.text = model.accountNumber;
    ifscController.text = model.ifscCode;
    selectedAccountType.value = model.accountType;

    nomineeNameController.text = model.nomineeName;

    signatureNameController.text = model.fullName;

    mpinController.text = model.mpin;
    confirmMpinController.text = model.mpin;

    selectedGender.value = model.gender;
    selectedInvestmentGoal.value = model.investmentGoal;
    selectedInvestmentExperience.value = model.investmentExperience;
    selectedOccupation.value = model.occupation;
    selectedMonthlyIncome.value = model.monthlyIncome;
    selectedNomineeRelation.value = model.nomineeRelation;

    selfieImagePath.value = model.selfieUrl;
    signatureImagePath.value = model.signatureUrl;
  }

  /// Save current draft
  Future<void> saveCurrentDraft() async {
    updateSignupModel();
    await saveDraft();
  }

  Future<bool> sendSignupEmailOtp() async {
    try {
      final email = emailController.text.trim();

      if (email.isEmpty) {
        Get.snackbar(
          "Email Required",
          "Please enter your email.",
        );
        return false;
      }

      print("========== SEND OTP ==========");
      print("Email: $email");

      final result = await OtpService.sendOtp(
        email: email,
      );

      print("OTP API Response: $result");

      if (result["success"] == true) {
        print("OTP sent successfully.");
        return true;
      }

      Get.snackbar(
        "Failed",
        result["message"] ?? "Unable to send OTP.",
      );

      return false;
    } catch (e, stackTrace) {
      print("SEND OTP ERROR: $e");
      print(stackTrace);

      Get.snackbar(
        "Error",
        e.toString(),
      );

      return false;
    }
  }

  Future<void> pickProfileImage(ImageSource source) async {
    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (image != null) {
      profileImagePath.value = image.path;

      signup.update((user) {
        user?.profileImage = image.path;
      });

      await saveCurrentDraft();
    }
  }

  Future<void> uploadAllImages() async {
    if (profileImagePath.value.isNotEmpty) {
      signup.value.profileImage =
      await UploadService.uploadProfile(
        File(profileImagePath.value),
      );
    }

    if (panImagePath.value.isNotEmpty) {
      signup.value.panImageUrl =
      await UploadService.uploadPan(
        File(panImagePath.value),
      );
    }

    if (aadhaarFrontImagePath.value.isNotEmpty) {
      signup.value.aadhaarFrontUrl =
      await UploadService.uploadAadhaarFront(
        File(aadhaarFrontImagePath.value),
      );
    }

    if (aadhaarBackImagePath.value.isNotEmpty) {
      signup.value.aadhaarBackUrl =
      await UploadService.uploadAadhaarBack(
        File(aadhaarBackImagePath.value),
      );
    }

    if (selfieImagePath.value.isNotEmpty) {
      signup.value.selfieUrl =
      await UploadService.uploadSelfie(
        File(selfieImagePath.value),
      );
    }

    if (signatureImagePath.value.isNotEmpty) {
      signup.value.signatureUrl =
      await UploadService.uploadSignature(
        File(signatureImagePath.value),
      );
    }
  }

  // ==========================================================
  // SUBMIT SIGNUP
  // ==========================================================

  final AuthService _authService = AuthService();
  final RxBool isSubmitting = false.obs;

  Future<bool> submitSignup() async {
    if (isLoading.value) return false;

    try {
      isLoading.value = true;

      // Update model from UI
      updateSignupModel();

      debugPrint("========== SIGNUP REQUEST ==========");

      const encoder = JsonEncoder.withIndent("  ");

      debugPrint(
        encoder.convert(signup.value.toJson()),
      );

      // Upload all images to Cloudinary
      await uploadAllImages();

      debugPrint("========== AFTER IMAGE UPLOAD ==========");

      debugPrint(
        encoder.convert(signup.value.toJson()),
      );

      // Save latest draft (Cloudinary URLs included)
      await saveCurrentDraft();

      // Signup API
      final result = await _authService.signup(
        signup.value,
      );

      debugPrint("========== SIGNUP RESPONSE ==========");
      debugPrint(result.toString());

      if (result["success"] != true) {
        debugPrint(
          "Signup Failed : ${result["message"]}",
        );

        Get.snackbar(
          "Signup Failed",
          result["message"] ?? "Unable to create account.",
        );

        return false;
      }

      final data = result["data"] ?? {};

      // Save JWT
      if (data["token"] != null) {
        await SharedPreferencesService.saveToken(
          data["token"].toString(),
        );
      }

      // Save User Id
      if (data["user"]?["_id"] != null) {
        await SharedPreferencesService.saveUserId(
          data["user"]["_id"].toString(),
        );
      }

      // Save Login State
      await SharedPreferencesService.setLoggedIn(true);

      // Remove draft after successful signup
      await clearDraft();

      debugPrint("========== SIGNUP SUCCESS ==========");

      return true;
    } catch (e, stackTrace) {
      debugPrint("========== SIGNUP ERROR ==========");
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());

      Get.snackbar(
        "Error",
        e.toString(),
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }
}