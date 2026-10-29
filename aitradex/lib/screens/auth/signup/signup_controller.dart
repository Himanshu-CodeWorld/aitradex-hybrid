import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../models/signup_model.dart';
import '../../../services/shared_preferences_service.dart';

class SignupController extends GetxController {
  // ==========================================================
  // SIGNUP FLOW
  // ==========================================================
  //
  // 1. Name
  // 2. Email -> Firebase email verification
  // 3. Phone -> Message Central SMS OTP
  // 4. Username
  // 5. Password + Confirm Password
  // 6. Profile Image (optional)
  // 7. Referral Code (optional)
  // 8. Review -> Create Account
  //
  // Email verification and phone OTP are sub-flows.
  // They are NOT separate PageView pages.
  //
  // IMPORTANT:
  // PasswordPage must only call:
  //   submitPassword()
  //   nextPage()
  //
  // ReviewInformationPage is the ONLY place that calls:
  //   createAccount()
  //
  // ==========================================================

  static const int totalPages = 8;

  // ==========================================================
  // API
  // ==========================================================

  static const String _apiBaseUrl =
      'https://aitradex-api.onrender.com/api';

  // ==========================================================
  // PAGE CONTROLLER
  // ==========================================================

  final PageController pageController = PageController();

  final RxInt currentPage = 0.obs;

  // ==========================================================
  // SIGNUP MODEL
  // ==========================================================

  final Rx<SignupModel> signup = SignupModel().obs;

  // ==========================================================
  // TEXT CONTROLLERS
  // ==========================================================

  final TextEditingController nameController =
  TextEditingController();

  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController phoneController =
  TextEditingController();

  final TextEditingController usernameController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  final TextEditingController confirmPasswordController =
  TextEditingController();

  // ==========================================================
  // STATE
  // ==========================================================

  final RxBool isLoading = false.obs;

  final RxBool isSubmitting = false.obs;

  final RxBool emailVerified = false.obs;

  final RxBool phoneVerified = false.obs;

  final RxBool isNameValid = false.obs;

  final RxBool isEmailValid = false.obs;

  final RxBool isPhoneValid = false.obs;

  final RxBool isUsernameValid = false.obs;

  final RxBool isPasswordValid = false.obs;

  final RxBool isConfirmPasswordValid = false.obs;

  final RxString verificationId = ''.obs;

  // Optional profile image selected during signup.
  // This is kept as a local path until the image is uploaded
  // to permanent backend/cloud storage.
  final RxString profileImagePath = ''.obs;

  // Optional referral code.
  final RxString referralCodeRx = ''.obs;

  String get referralCode => referralCodeRx.value;

  // ==========================================================
  // FIREBASE
  // ==========================================================

  final FirebaseAuth _firebaseAuth =
      FirebaseAuth.instance;

  // Firebase requires a Firebase Auth user before
  // sendEmailVerification() can be called.
  //
  // Therefore a temporary Firebase account is created
  // during email verification.
  //
  // This password exists ONLY in memory.
  // It is never stored in SharedPreferences.
  String? _temporaryFirebasePassword;

  // ==========================================================
  // LIFECYCLE
  // ==========================================================

  @override
  void onInit() {
    super.onInit();

    nameController.addListener(_validateFields);
    emailController.addListener(_validateFields);
    phoneController.addListener(_validateFields);
    usernameController.addListener(_validateFields);
    passwordController.addListener(_validateFields);
    confirmPasswordController.addListener(_validateFields);

    _loadDraft();
  }

  @override
  void onClose() {
    nameController.removeListener(_validateFields);
    emailController.removeListener(_validateFields);
    phoneController.removeListener(_validateFields);
    usernameController.removeListener(_validateFields);
    passwordController.removeListener(_validateFields);
    confirmPasswordController.removeListener(_validateFields);

    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    pageController.dispose();

    super.onClose();
  }

  // ==========================================================
  // VALIDATION
  // ==========================================================

  bool get isNameFieldValid {
    return nameController.text.trim().length >= 2;
  }

  bool get isEmailFieldValid {
    return RegExp(
      r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,}$',
    ).hasMatch(
      emailController.text.trim().toLowerCase(),
    );
  }

  bool get isPhoneFieldValid {
    final digits = _phoneDigits(
      phoneController.text,
    );

    return RegExp(
      r'^[6-9]\d{9}$',
    ).hasMatch(digits);
  }

  bool get isUsernameFieldValid {
    return RegExp(
      r'^[a-zA-Z0-9_]{3,20}$',
    ).hasMatch(
      usernameController.text.trim(),
    );
  }

  bool get isPasswordFieldValid {
    return passwordController.text.length >= 8;
  }

  bool get isConfirmPasswordFieldValid {
    return passwordController.text.isNotEmpty &&
        passwordController.text ==
            confirmPasswordController.text;
  }

  bool get isCurrentPageValid {
    switch (currentPage.value) {
      case 0:
        return isNameFieldValid;

      case 1:
        return isEmailFieldValid &&
            emailVerified.value;

      case 2:
        return isPhoneFieldValid &&
            phoneVerified.value;

      case 3:
        return isUsernameFieldValid;

      case 4:
        return isPasswordFieldValid &&
            isConfirmPasswordFieldValid;

      case 5:
      // Profile image is optional.
        return true;

      case 6:
      // Referral code is optional.
        return true;

      case 7:
        return isReviewValid;

      default:
        return false;
    }
  }

  bool get isReviewValid {
    return isNameFieldValid &&
        isEmailFieldValid &&
        emailVerified.value &&
        isPhoneFieldValid &&
        phoneVerified.value &&
        isUsernameFieldValid &&
        isPasswordFieldValid &&
        isConfirmPasswordFieldValid;
  }

  void _validateFields() {
    isNameValid.value = isNameFieldValid;

    isEmailValid.value = isEmailFieldValid;

    isPhoneValid.value = isPhoneFieldValid;

    isUsernameValid.value = isUsernameFieldValid;

    isPasswordValid.value = isPasswordFieldValid;

    isConfirmPasswordValid.value =
        isConfirmPasswordFieldValid;
  }

  // ==========================================================
  // PAGE NAVIGATION
  // ==========================================================

  void onPageChanged(int index) {
    if (index < 0 || index >= totalPages) {
      return;
    }

    currentPage.value = index;

    _validateFields();

    debugPrint(
      'Signup PageView changed: '
          'index=$index (${_pageName(index)})',
    );
  }

  String _pageName(int index) {
    const pages = <String>[
      'Name',
      'Email',
      'Phone',
      'Username',
      'Password',
      'Profile Image',
      'Referral Code',
      'Review',
    ];

    if (index >= 0 && index < pages.length) {
      return pages[index];
    }

    return 'Unknown';
  }

  Future<void> nextPage() async {
    _validateFields();

    final int page = currentPage.value;

    if (!isCurrentPageValid) {
      _showValidationMessage(
        title: 'Incomplete Step',
        message: _currentPageValidationMessage(),
      );
      return;
    }

    await saveCurrentDraft();

    if (page >= totalPages - 1) {
      return;
    }

    final int next = page + 1;

    debugPrint(
      'Signup navigation: '
          '${_pageName(page)} ($page) -> '
          '${_pageName(next)} ($next)',
    );

    await goToPage(next);
  }

  Future<void> previousPage() async {
    if (currentPage.value <= 0) {
      return;
    }

    await goToPage(
      currentPage.value - 1,
    );
  }

  Future<void> goToPage(int page) async {
    if (page < 0 || page >= totalPages) {
      return;
    }

    if (!pageController.hasClients) {
      currentPage.value = page;

      _validateFields();

      debugPrint(
        'PageView has no clients. '
            'currentPage=$page (${_pageName(page)})',
      );

      return;
    }

    try {
      await pageController.animateToPage(
        page,
        duration: const Duration(
          milliseconds: 300,
        ),
        curve: Curves.easeInOut,
      );

      currentPage.value = page;

      _validateFields();
    } catch (error, stackTrace) {
      debugPrint(
        'Signup page navigation error: $error',
      );

      debugPrint(
        stackTrace.toString(),
      );
    }
  }

  void jumpToNextPage() {
    _validateFields();

    if (!isCurrentPageValid) {
      _showValidationMessage(
        title: 'Incomplete Step',
        message: _currentPageValidationMessage(),
      );
      return;
    }

    if (currentPage.value >= totalPages - 1) {
      return;
    }

    final int next = currentPage.value + 1;

    if (pageController.hasClients) {
      pageController.animateToPage(
        next,
        duration: const Duration(
          milliseconds: 300,
        ),
        curve: Curves.easeInOut,
      );
    }

    currentPage.value = next;

    _validateFields();
  }

  // ==========================================================
  // 1. NAME
  // ==========================================================

  Future<bool> submitName() async {
    final String name =
    nameController.text.trim();

    if (name.length < 2) {
      _showValidationMessage(
        title: 'Invalid Name',
        message: 'Please enter your full name.',
      );

      return false;
    }

    updateSignupModel();

    await saveCurrentDraft();

    return true;
  }

  // ==========================================================
  // 2. EMAIL + FIREBASE VERIFICATION
  // ==========================================================

  Future<bool> startEmailVerification() async {
    final String email =
    emailController.text.trim().toLowerCase();

    if (!isEmailFieldValid) {
      _showValidationMessage(
        title: 'Invalid Email',
        message:
        'Please enter a valid email address.',
      );

      return false;
    }

    try {
      isLoading.value = true;

      User? user =
          _firebaseAuth.currentUser;

      // ------------------------------------------------------
      // EXISTING FIREBASE USER
      // ------------------------------------------------------

      if (user != null) {
        final String? currentEmail =
        user.email?.trim().toLowerCase();

        if (currentEmail == email) {
          await user.reload();

          user = _firebaseAuth.currentUser;

          if (user == null) {
            throw FirebaseAuthException(
              code: 'user-not-found',
              message:
              'Firebase signup session was not found.',
            );
          }

          if (user.emailVerified) {
            emailVerified.value = true;

            signup.update((model) {
              if (model == null) {
                return;
              }

              model.email = email;
              model.emailVerified = true;
            });

            await saveCurrentDraft();

            return true;
          }

          // Same Firebase account but not verified.
          await user.sendEmailVerification();

          emailVerified.value = false;

          signup.update((model) {
            if (model == null) {
              return;
            }

            model.email = email;
            model.emailVerified = false;
          });

          await saveCurrentDraft();

          Get.snackbar(
            'Verification Email Sent',
            'Check $email and tap the Firebase verification link.',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(
              seconds: 4,
            ),
          );

          return true;
        }

        // Different Firebase user is signed in.
        await _firebaseAuth.signOut();

        user = null;

        _temporaryFirebasePassword = null;
      }

      // ------------------------------------------------------
      // CREATE TEMPORARY FIREBASE ACCOUNT
      // ------------------------------------------------------

      _temporaryFirebasePassword =
          _generateTemporaryPassword();

      final UserCredential credential =
      await _firebaseAuth
          .createUserWithEmailAndPassword(
        email: email,
        password: _temporaryFirebasePassword!,
      );

      user = credential.user;

      if (user == null) {
        throw FirebaseAuthException(
          code: 'verification-user-not-created',
          message:
          'Firebase could not create the verification user.',
        );
      }

      // Set initial Firebase display name.
      await user.updateDisplayName(
        nameController.text.trim(),
      );

      // ------------------------------------------------------
      // SEND FIREBASE EMAIL VERIFICATION
      // ------------------------------------------------------

      await user.sendEmailVerification();

      emailVerified.value = false;

      signup.update((model) {
        if (model == null) {
          return;
        }

        model.fullName =
            nameController.text.trim();

        model.email = email;

        model.emailVerified = false;
      });

      await saveCurrentDraft();

      debugPrint(
        '========================================',
      );

      debugPrint(
        'FIREBASE VERIFICATION EMAIL SENT',
      );

      debugPrint(
        'EMAIL: $email',
      );

      debugPrint(
        'UID: ${user.uid}',
      );

      debugPrint(
        '========================================',
      );

      Get.snackbar(
        'Verification Email Sent',
        'Check your Gmail inbox and tap the Firebase verification link.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(
          seconds: 4,
        ),
      );

      return true;
    } on FirebaseAuthException catch (error) {
      debugPrint(
        'Firebase email verification error: '
            '${error.code} - ${error.message}',
      );

      Get.snackbar(
        'Email Verification',
        _firebaseErrorMessage(
          error.code,
          error.message,
        ),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(
          seconds: 5,
        ),
      );

      return false;
    } catch (error, stackTrace) {
      debugPrint(
        'Email verification error: $error',
      );

      debugPrint(
        stackTrace.toString(),
      );

      Get.snackbar(
        'Email Verification',
        'Unable to send the verification email.',
        snackPosition: SnackPosition.BOTTOM,
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> checkEmailVerification() async {
    try {
      User? user =
          _firebaseAuth.currentUser;

      if (user == null) {
        Get.snackbar(
          'Verification Error',
          'Firebase signup session was not found.',
          snackPosition: SnackPosition.BOTTOM,
        );

        return false;
      }

      // Refresh Firebase Auth user.
      await user.reload();

      user = _firebaseAuth.currentUser;

      if (user == null) {
        return false;
      }

      final bool verified =
          user.emailVerified;

      emailVerified.value = verified;

      signup.update((model) {
        if (model == null) {
          return;
        }

        model.email =
            user?.email ??
                emailController.text
                    .trim()
                    .toLowerCase();

        model.emailVerified = verified;
      });

      if (verified) {
        await saveCurrentDraft();

        debugPrint(
          'Firebase email verification confirmed.',
        );

        return true;
      }

      return false;
    } on FirebaseAuthException catch (error) {
      debugPrint(
        'Check Firebase email verification error: '
            '${error.code} - ${error.message}',
      );

      Get.snackbar(
        'Verification Error',
        _firebaseErrorMessage(
          error.code,
          error.message,
        ),
        snackPosition: SnackPosition.BOTTOM,
      );

      return false;
    } catch (error) {
      debugPrint(
        'Check email verification error: $error',
      );

      Get.snackbar(
        'Verification Error',
        'Could not check your email verification status.',
        snackPosition: SnackPosition.BOTTOM,
      );

      return false;
    }
  }

  Future<bool> resendEmailVerification() async {
    try {
      User? user =
          _firebaseAuth.currentUser;

      if (user == null) {
        Get.snackbar(
          'Verification',
          'Please start email verification again.',
          snackPosition: SnackPosition.BOTTOM,
        );

        return false;
      }

      await user.reload();

      user = _firebaseAuth.currentUser;

      if (user == null) {
        return false;
      }

      if (user.emailVerified) {
        emailVerified.value = true;

        Get.snackbar(
          'Already Verified',
          'This email address is already verified.',
          snackPosition: SnackPosition.BOTTOM,
        );

        return true;
      }

      await user.sendEmailVerification();

      Get.snackbar(
        'Email Sent',
        'A new Firebase verification email has been sent.',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } on FirebaseAuthException catch (error) {
      Get.snackbar(
        'Email Verification',
        _firebaseErrorMessage(
          error.code,
          error.message,
        ),
        snackPosition: SnackPosition.BOTTOM,
      );

      return false;
    } catch (error) {
      debugPrint(
        'Resend email verification error: $error',
      );

      return false;
    }
  }

  Future<bool> completeEmailVerification() async {
    final bool verified =
    await checkEmailVerification();

    if (!verified) {
      Get.snackbar(
        'Email Not Verified',
        'Please open Gmail and tap the Firebase verification link.',
        snackPosition: SnackPosition.BOTTOM,
      );

      return false;
    }

    return true;
  }

  // ==========================================================
  // 3. PHONE + MESSAGE CENTRAL OTP
  // ==========================================================

  Future<bool> sendPhoneOtp() async {
    final String digits =
    _phoneDigits(phoneController.text);

    if (!RegExp(
      r'^[6-9]\d{9}$',
    ).hasMatch(digits)) {
      _showValidationMessage(
        title: 'Invalid Mobile Number',
        message:
        'Please enter a valid 10-digit Indian mobile number.',
      );

      return false;
    }

    try {
      isLoading.value = true;

      final String phone = '+91$digits';

      debugPrint(
        '========================================',
      );

      debugPrint(
        'AITRADEX SEND PHONE OTP',
      );

      debugPrint(
        'Phone: $phone',
      );

      debugPrint(
        'Provider: Message Central',
      );

      debugPrint(
        '========================================',
      );

      final http.Response response =
      await http.post(
        Uri.parse(
          '$_apiBaseUrl/auth/send-phone-otp',
        ),
        headers: {
          'Content-Type':
          'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'phone': phone,
        }),
      );

      debugPrint(
        'Send Phone OTP Status: '
            '${response.statusCode}',
      );

      debugPrint(
        'Send Phone OTP Response: '
            '${response.body}',
      );

      final Map<String, dynamic> data =
      _decodeJsonMap(response.body);

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw Exception(
          data['message'] ??
              'Unable to send OTP.',
        );
      }

      final dynamic returnedVerificationId =
          data['data']?['verificationId'] ??
              data['verificationId'];

      if (returnedVerificationId == null ||
          returnedVerificationId
              .toString()
              .trim()
              .isEmpty) {
        throw Exception(
          'Message Central verification ID was not returned.',
        );
      }

      verificationId.value =
          returnedVerificationId.toString();

      // Store only 10 digits in controller.
      phoneController.text = digits;

      phoneVerified.value = false;

      signup.update((model) {
        if (model == null) {
          return;
        }

        model.phone = phone;

        model.phoneVerified = false;
      });

      await saveCurrentDraft();

      debugPrint(
        'Message Central verification ID: '
            '$returnedVerificationId',
      );

      return true;
    } catch (error, stackTrace) {
      debugPrint(
        'Send Message Central OTP Error: $error',
      );

      debugPrint(
        stackTrace.toString(),
      );

      Get.snackbar(
        'OTP Error',
        error.toString().replaceFirst(
          'Exception: ',
          '',
        ),
        snackPosition: SnackPosition.BOTTOM,
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> verifyMessageCentralOtp(
      String otp,
      ) async {
    final String code = otp.trim();

    if (!RegExp(
      r'^\d{6}$',
    ).hasMatch(code)) {
      Get.snackbar(
        'Invalid OTP',
        'Please enter the 6-digit OTP.',
        snackPosition: SnackPosition.BOTTOM,
      );

      return false;
    }

    final String digits =
    _phoneDigits(phoneController.text);

    if (!RegExp(
      r'^[6-9]\d{9}$',
    ).hasMatch(digits)) {
      Get.snackbar(
        'Invalid Phone',
        'Please enter a valid phone number.',
        snackPosition: SnackPosition.BOTTOM,
      );

      return false;
    }

    try {
      isLoading.value = true;

      final String phone = '+91$digits';

      debugPrint(
        '========================================',
      );

      debugPrint(
        'AITRADEX VERIFY MESSAGE CENTRAL OTP',
      );

      debugPrint(
        'Phone: $phone',
      );

      debugPrint(
        'OTP: $code',
      );

      debugPrint(
        '========================================',
      );

      final http.Response response =
      await http.post(
        Uri.parse(
          '$_apiBaseUrl/auth/verify-phone-otp',
        ),
        headers: {
          'Content-Type':
          'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'phone': phone,
          'otp': code,
        }),
      );

      debugPrint(
        'Verify Phone OTP Status: '
            '${response.statusCode}',
      );

      debugPrint(
        'Verify Phone OTP Response: '
            '${response.body}',
      );

      final Map<String, dynamic> data =
      _decodeJsonMap(response.body);

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw Exception(
          data['message'] ??
              'OTP verification failed.',
        );
      }

      final bool verified =
          data['verified'] == true ||
              data['data']?['verified'] == true;

      if (!verified) {
        throw Exception(
          data['message'] ??
              'Invalid OTP.',
        );
      }

      phoneVerified.value = true;

      signup.update((model) {
        if (model == null) {
          return;
        }

        model.phone = phone;

        model.phoneVerified = true;
      });

      await saveCurrentDraft();

      debugPrint(
        'MESSAGE CENTRAL PHONE VERIFIED SUCCESSFULLY',
      );

      Get.snackbar(
        'Phone Verified',
        'Your mobile number has been verified successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (error, stackTrace) {
      debugPrint(
        'Verify Message Central OTP Error: $error',
      );

      debugPrint(
        stackTrace.toString(),
      );

      Get.snackbar(
        'OTP Verification Failed',
        error.toString().replaceFirst(
          'Exception: ',
          '',
        ),
        snackPosition: SnackPosition.BOTTOM,
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> resendMessageCentralOtp() async {
    final String digits =
    _phoneDigits(phoneController.text);

    if (!RegExp(
      r'^[6-9]\d{9}$',
    ).hasMatch(digits)) {
      Get.snackbar(
        'Invalid Phone',
        'Please enter a valid mobile number.',
        snackPosition: SnackPosition.BOTTOM,
      );

      return false;
    }

    try {
      isLoading.value = true;

      final String phone = '+91$digits';

      final http.Response response =
      await http.post(
        Uri.parse(
          '$_apiBaseUrl/auth/resend-phone-otp',
        ),
        headers: {
          'Content-Type':
          'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'phone': phone,
        }),
      );

      debugPrint(
        'Resend OTP Status: '
            '${response.statusCode}',
      );

      debugPrint(
        'Resend OTP Response: '
            '${response.body}',
      );

      final Map<String, dynamic> data =
      _decodeJsonMap(response.body);

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw Exception(
          data['message'] ??
              'Unable to resend OTP.',
        );
      }

      final dynamic newVerificationId =
          data['data']?['verificationId'] ??
              data['verificationId'];

      if (newVerificationId != null &&
          newVerificationId
              .toString()
              .trim()
              .isNotEmpty) {
        verificationId.value =
            newVerificationId.toString();
      }

      phoneVerified.value = false;

      signup.update((model) {
        if (model == null) {
          return;
        }

        model.phone = phone;

        model.phoneVerified = false;
      });

      await saveCurrentDraft();

      Get.snackbar(
        'OTP Resent',
        'A new OTP has been sent to $phone.',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (error) {
      debugPrint(
        'Resend Message Central OTP Error: $error',
      );

      Get.snackbar(
        'Resend OTP',
        error.toString().replaceFirst(
          'Exception: ',
          '',
        ),
        snackPosition: SnackPosition.BOTTOM,
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================================================
  // 4. USERNAME
  // ==========================================================

  Future<bool> submitUsername() async {
    final String username =
    usernameController.text.trim();

    if (!RegExp(
      r'^[a-zA-Z0-9_]{3,20}$',
    ).hasMatch(username)) {
      _showValidationMessage(
        title: 'Invalid Username',
        message:
        'Username must contain 3-20 letters, numbers, or underscores.',
      );

      return false;
    }

    if (!phoneVerified.value) {
      _showValidationMessage(
        title: 'Phone Not Verified',
        message:
        'Please verify your phone number before choosing a username.',
      );

      return false;
    }

    final User? user =
        _firebaseAuth.currentUser;

    if (user == null) {
      Get.snackbar(
        'Signup Session Expired',
        'Please restart signup.',
        snackPosition: SnackPosition.BOTTOM,
      );

      return false;
    }

    try {
      await user.updateDisplayName(
        username,
      );

      signup.update((model) {
        if (model == null) {
          return;
        }

        model.username = username;

        model.fullName =
            nameController.text.trim();
      });

      await saveCurrentDraft();

      return true;
    } on FirebaseAuthException catch (error) {
      Get.snackbar(
        'Username',
        _firebaseErrorMessage(
          error.code,
          error.message,
        ),
        snackPosition: SnackPosition.BOTTOM,
      );

      return false;
    } catch (error) {
      debugPrint(
        'Submit username error: $error',
      );

      return false;
    }
  }

  // ==========================================================
  // 5. PASSWORD
  // ==========================================================

  Future<bool> submitPassword() async {
    _validateFields();

    final String password =
        passwordController.text;

    final String confirmPassword =
        confirmPasswordController.text;

    debugPrint(
      'Password submit: '
          'passwordLength=${password.length}, '
          'confirmLength=${confirmPassword.length}, '
          'match=${password == confirmPassword}',
    );

    if (password.length < 8) {
      _showValidationMessage(
        title: 'Invalid Password',
        message:
        'Password must contain at least 8 characters.',
      );

      return false;
    }

    if (confirmPassword.isEmpty ||
        password != confirmPassword) {
      _showValidationMessage(
        title: 'Passwords Do Not Match',
        message:
        'Please enter the same password in both fields.',
      );

      return false;
    }

    if (!emailVerified.value) {
      _showValidationMessage(
        title: 'Email Not Verified',
        message:
        'Please verify your email before continuing.',
      );

      return false;
    }

    if (!phoneVerified.value) {
      _showValidationMessage(
        title: 'Phone Not Verified',
        message:
        'Please verify your phone before continuing.',
      );

      return false;
    }

    updateSignupModel();

    // IMPORTANT:
    // Password is NOT stored in SignupModel
    // and NOT stored in SharedPreferences.
    await saveCurrentDraft();

    debugPrint(
      'Password validation successful.',
    );

    debugPrint(
      'Advancing from PasswordPage '
          'to ReviewInformationPage.',
    );

    return true;
  }

  // ==========================================================
  // 6. PROFILE IMAGE
  // ==========================================================

  void setProfileImage(String path) {
    final String normalizedPath = path.trim();

    profileImagePath.value = normalizedPath;

    signup.update((model) {
      if (model == null) {
        return;
      }

      model.profileImage = normalizedPath;
    });

    signup.refresh();
  }

  void removeProfileImage() {
    profileImagePath.value = '';

    signup.update((model) {
      if (model == null) {
        return;
      }

      model.profileImage = '';
    });

    signup.refresh();
  }

  // ==========================================================
  // 7. REFERRAL CODE
  // ==========================================================

  void setReferralCode(String value) {
    final String code = value.trim().toUpperCase();

    referralCodeRx.value = code;

    signup.update((model) {
      if (model == null) {
        return;
      }

      model.referralCode = code;
    });

    signup.refresh();
  }

  // ==========================================================
  // 8. REVIEW + CREATE ACCOUNT
  // ==========================================================


  Future<bool> createAccount() async {
    if (isSubmitting.value) {
      return false;
    }

    _validateFields();

    if (!isReviewValid) {
      Get.snackbar(
        'Incomplete Signup',
        'Please complete all required signup details and verify your email and phone number.',
        snackPosition: SnackPosition.BOTTOM,
      );

      return false;
    }

    isSubmitting.value = true;

    try {
      User? user =
          _firebaseAuth.currentUser;

      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message:
          'Signup session expired. Please start signup again.',
        );
      }

      // Reload Firebase Auth state.
      await user.reload();

      user = _firebaseAuth.currentUser;

      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message:
          'Firebase user could not be loaded.',
        );
      }

      // ------------------------------------------------------
      // EMAIL VERIFICATION CHECK
      // ------------------------------------------------------

      if (!user.emailVerified) {
        emailVerified.value = false;

        throw FirebaseAuthException(
          code: 'email-not-verified',
          message:
          'Please verify your email before creating the account.',
        );
      }

      emailVerified.value = true;

      // ------------------------------------------------------
      // PHONE VERIFICATION CHECK
      // ------------------------------------------------------

      if (!phoneVerified.value) {
        throw FirebaseAuthException(
          code: 'phone-not-verified',
          message:
          'Please verify your phone number before creating the account.',
        );
      }

      // ------------------------------------------------------
      // FINAL PASSWORD
      // ------------------------------------------------------

      final String finalPassword =
          passwordController.text;

      final String confirmPassword =
          confirmPasswordController.text;

      if (finalPassword.length < 8) {
        throw FirebaseAuthException(
          code: 'weak-password',
          message:
          'Password must contain at least 8 characters.',
        );
      }

      if (finalPassword != confirmPassword) {
        throw FirebaseAuthException(
          code: 'password-mismatch',
          message:
          'Passwords do not match.',
        );
      }

      // ------------------------------------------------------
      // UPDATE TEMPORARY FIREBASE PASSWORD
      // ------------------------------------------------------
      //
      // The Firebase user was created earlier with a temporary
      // password so Firebase could send the verification email.
      //
      // If Firebase requires recent authentication, reauthenticate
      // with the temporary password and then update the password.
      //
      // ------------------------------------------------------

      try {
        await user.updatePassword(
          finalPassword,
        );
      } on FirebaseAuthException catch (error) {
        if (error.code !=
            'requires-recent-login') {
          rethrow;
        }

        final String? firebaseEmail =
        user.email
            ?.trim()
            .toLowerCase();

        final String? temporaryPassword =
            _temporaryFirebasePassword;

        if (firebaseEmail == null ||
            firebaseEmail.isEmpty ||
            temporaryPassword == null ||
            temporaryPassword.isEmpty) {
          throw FirebaseAuthException(
            code: 'requires-recent-login',
            message:
            'Your signup session has expired. Please restart signup.',
          );
        }

        final AuthCredential credential =
        EmailAuthProvider.credential(
          email: firebaseEmail,
          password: temporaryPassword,
        );

        await user
            .reauthenticateWithCredential(
          credential,
        );

        await user.updatePassword(
          finalPassword,
        );
      }

      // ------------------------------------------------------
      // UPDATE FIREBASE DISPLAY NAME
      // ------------------------------------------------------

      final String username =
      usernameController.text.trim();

      if (username.isNotEmpty) {
        await user.updateDisplayName(
          username,
        );
      }

      // Reload Firebase user after updates.
      await user.reload();

      user = _firebaseAuth.currentUser;

      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message:
          'Firebase user could not be loaded after account creation.',
        );
      }

      // ------------------------------------------------------
      // NORMALIZED USER DATA
      // ------------------------------------------------------

      final String normalizedEmail =
          user.email
              ?.trim()
              .toLowerCase() ??
              emailController.text
                  .trim()
                  .toLowerCase();

      final String normalizedPhone =
          '+91${_phoneDigits(phoneController.text)}';

      // ------------------------------------------------------
      // UPDATE LOCAL SIGNUP MODEL
      // ------------------------------------------------------

      signup.value
        ..fullName =
        nameController.text.trim()
        ..email = normalizedEmail
        ..phone = normalizedPhone
        ..username = username
        ..profileImage = profileImagePath.value.trim()
        ..referralCode = referralCodeRx.value.trim().toUpperCase()
        ..emailVerified = true
        ..phoneVerified = true;

      signup.refresh();

      // ------------------------------------------------------
      // GET FRESH FIREBASE ID TOKEN
      // ------------------------------------------------------

      final String? idToken =
      await user.getIdToken(true);

      if (idToken == null ||
          idToken.trim().isEmpty) {
        throw Exception(
          'Firebase ID token could not be generated.',
        );
      }

      // ------------------------------------------------------
      // UPLOAD PROFILE IMAGE
      // ------------------------------------------------------
      //
      // Email/password Firebase users normally have no photoURL.
      // Upload the selected local image to the AiTradeX backend
      // first, then save the returned HTTPS URL in MongoDB.
      //
      await _uploadProfileImageToBackend(
        idToken: idToken,
      );

      // ------------------------------------------------------
      // FIREBASE -> MONGODB
      // ------------------------------------------------------

      final bool mongoSaved =
      await _saveFirebaseUserToMongoDB(
        user: user,
        fullName: nameController.text.trim(),
        username: username,
        email: normalizedEmail,
        phoneNumber: normalizedPhone,
        idToken: idToken,
      );

      if (!mongoSaved) {
        throw Exception(
          'Firebase account was created, but the user could not be saved to MongoDB.',
        );
      }

      // ------------------------------------------------------
      // SAVE NON-SENSITIVE DATA LOCALLY
      // ------------------------------------------------------

      await SharedPreferencesService
          .saveSignupData(
        signup.value,
      );

      // IMPORTANT:
      // Never save the Firebase password.
      _temporaryFirebasePassword = null;

      verificationId.value = '';

      debugPrint(
        '========================================',
      );

      debugPrint(
        'AITRADEX ACCOUNT CREATION SUCCESS',
      );

      debugPrint(
        '========================================',
      );

      debugPrint(
        'Firebase UID : ${user.uid}',
      );

      debugPrint(
        'Email        : $normalizedEmail',
      );

      debugPrint(
        'Phone        : $normalizedPhone',
      );

      debugPrint(
        'MongoDB      : SAVED',
      );

      debugPrint(
        '========================================',
      );

      Get.snackbar(
        'Account Created',
        'Your AiTradeX account has been created successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } on FirebaseAuthException catch (error) {
      debugPrint(
        'Create account Firebase error: '
            '${error.code} - ${error.message}',
      );

      Get.snackbar(
        'Account Creation Failed',
        _firebaseErrorMessage(
          error.code,
          error.message,
        ),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(
          seconds: 5,
        ),
      );

      return false;
    } catch (error, stackTrace) {
      debugPrint(
        'Create account error: $error',
      );

      debugPrint(
        stackTrace.toString(),
      );

      Get.snackbar(
        'Account Creation Failed',
        'Something went wrong while creating your account. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(
          seconds: 5,
        ),
      );

      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // ==========================================================
  // FIREBASE -> MONGODB SYNC
  // ==========================================================

  Future<bool> _saveFirebaseUserToMongoDB({
    required User user,
    required String fullName,
    required String username,
    required String email,
    required String phoneNumber,
    required String idToken,
  }) async {
    try {
      // ==========================================================
      // NORMALIZE DATA
      // ==========================================================

      final String normalizedFullName = fullName.trim();

      final String normalizedUsername =
      username.trim();

      final String normalizedEmail =
      email.trim().toLowerCase();

      final String normalizedPhone =
      phoneNumber.trim();

      // ==========================================================
      // VALIDATE DATA BEFORE API REQUEST
      // ==========================================================

      if (normalizedFullName.length < 2) {
        debugPrint(
          '❌ MongoDB sync stopped: fullName is empty.',
        );

        Get.snackbar(
          'Full Name Required',
          'Please enter your full name.',
          snackPosition: SnackPosition.BOTTOM,
        );

        return false;
      }

      if (normalizedUsername.isEmpty) {
        debugPrint(
          '❌ MongoDB sync stopped: username is empty.',
        );

        Get.snackbar(
          'Username Required',
          'Please enter your username.',
          snackPosition: SnackPosition.BOTTOM,
        );

        return false;
      }

      if (normalizedEmail.isEmpty) {
        debugPrint(
          '❌ MongoDB sync stopped: email is empty.',
        );

        return false;
      }

      if (normalizedPhone.isEmpty) {
        debugPrint(
          '❌ MongoDB sync stopped: phone number is empty.',
        );

        return false;
      }

      if (idToken.trim().isEmpty) {
        debugPrint(
          '❌ MongoDB sync stopped: Firebase ID token is empty.',
        );

        return false;
      }

      // ==========================================================
      // API URL
      // ==========================================================

      final Uri uri = Uri.parse(
        '$_apiBaseUrl/users',
      );

      // ==========================================================
      // REQUEST BODY
      // ==========================================================
      //
      // IMPORTANT:
      //
      // Firebase UID is NOT trusted from the request body.
      // The backend gets the trusted UID from:
      //
      // req.user.uid
      //
      // after Firebase Admin verifies the Bearer token.
      //
      // ==========================================================

      final Map<String, dynamic> body = {
        'fullName': normalizedFullName,
        'username': normalizedUsername,
        'email': normalizedEmail,
        'phoneNumber': normalizedPhone,
        'emailVerified': user.emailVerified,
        'phoneVerified': phoneVerified.value,
        'profileImage': _profileImageForBackend(
          user.photoURL,
          profileImagePath.value,
        ),
        'referredBy': referralCodeRx.value.trim().toUpperCase(),
        'firebaseCreatedAt':
        user.metadata.creationTime?.toIso8601String(),
        'firebaseLastSignInAt':
        user.metadata.lastSignInTime?.toIso8601String(),
      };

      // ==========================================================
      // DEBUG
      // ==========================================================

      debugPrint('');
      debugPrint('========================================');
      debugPrint('FIREBASE -> MONGODB USER SYNC');
      debugPrint('========================================');
      debugPrint('METHOD       : POST');
      debugPrint('URL          : $uri');
      debugPrint('Firebase UID : ${user.uid}');
      debugPrint('Full Name    : "$normalizedFullName"');
      debugPrint('Username     : "$normalizedUsername"');
      debugPrint('Email        : "$normalizedEmail"');
      debugPrint('Phone        : "$normalizedPhone"');
      debugPrint(
        'Profile Image: "${_profileImageForBackend(user.photoURL, profileImagePath.value)}"',
      );
      debugPrint(
        'Referred By  : "${referralCodeRx.value.trim().toUpperCase()}"',
      );
      debugPrint(
        'Email Verified: ${user.emailVerified}',
      );
      debugPrint(
        'Phone Verified: ${phoneVerified.value}',
      );
      debugPrint('========================================');

      // ==========================================================
      // SEND REQUEST
      // ==========================================================

      final http.Response response = await http
          .post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization':
          'Bearer ${idToken.trim()}',
        },
        body: jsonEncode(body),
      )
          .timeout(
        const Duration(seconds: 30),
      );

      // ==========================================================
      // RESPONSE DEBUG
      // ==========================================================

      debugPrint('');
      debugPrint('========================================');
      debugPrint('MONGODB SYNC RESPONSE');
      debugPrint('========================================');
      debugPrint(
        'STATUS: ${response.statusCode}',
      );
      debugPrint(
        'BODY  : ${response.body}',
      );
      debugPrint('========================================');

      // ==========================================================
      // DECODE RESPONSE
      // ==========================================================

      dynamic decoded;

      try {
        if (response.body.trim().isNotEmpty) {
          decoded = jsonDecode(
            response.body,
          );
        }
      } catch (error) {
        debugPrint(
          'MongoDB response JSON error: $error',
        );
      }

      // ==========================================================
      // SUCCESS
      // ==========================================================

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        if (decoded is Map<String, dynamic>) {
          final dynamic success =
          decoded['success'];

          if (success == false) {
            final String message =
                decoded['message']?.toString() ??
                    'MongoDB user synchronization failed.';

            debugPrint(
              '❌ MongoDB returned success=false',
            );

            Get.snackbar(
              'Database Sync Failed',
              message,
              snackPosition:
              SnackPosition.BOTTOM,
              duration:
              const Duration(seconds: 5),
            );

            return false;
          }
        }

        debugPrint('');
        debugPrint('========================================');
        debugPrint('✅ MONGODB USER SAVED SUCCESSFULLY');
        debugPrint('========================================');
        debugPrint(
          'Firebase UID : ${user.uid}',
        );
        debugPrint(
          'Full Name    : $normalizedFullName',
        );
        debugPrint(
          'Username     : $normalizedUsername',
        );
        debugPrint(
          'Email        : $normalizedEmail',
        );
        debugPrint(
          'Phone        : $normalizedPhone',
        );

        if (decoded is Map<String, dynamic>) {
          final dynamic responseUser = decoded['user'];
          if (responseUser is Map) {
            final String generatedReferralCode =
                responseUser['referralCode']?.toString().trim().toUpperCase() ?? '';

            if (generatedReferralCode.isNotEmpty) {
              debugPrint(
                'My Referral  : $generatedReferralCode',
              );
            }
          }
        }

        debugPrint('========================================');
        debugPrint('');

        return true;
      }

      // ==========================================================
      // UNAUTHORIZED
      // ==========================================================

      if (response.statusCode == 401) {
        debugPrint(
          '❌ Backend rejected Firebase authentication.',
        );

        Get.snackbar(
          'Authentication Error',
          'The Firebase session could not be authenticated by the backend.',
          snackPosition:
          SnackPosition.BOTTOM,
          duration:
          const Duration(seconds: 5),
        );

        return false;
      }

      // ==========================================================
      // VALIDATION / CONFLICT / SERVER ERROR
      // ==========================================================

      String message =
          'MongoDB sync failed with status '
          '${response.statusCode}.';

      if (decoded is Map<String, dynamic>) {
        if (decoded['message'] != null) {
          message =
              decoded['message'].toString();
        }
      }

      debugPrint(
        '❌ MongoDB sync failed: $message',
      );

      Get.snackbar(
        'Database Sync Failed',
        message,
        snackPosition:
        SnackPosition.BOTTOM,
        duration:
        const Duration(seconds: 5),
      );

      return false;
    } on TimeoutException {
      debugPrint(
        '❌ MongoDB sync failed: request timed out.',
      );

      Get.snackbar(
        'Database Sync Timeout',
        'The server took too long to respond. Please try again.',
        snackPosition:
        SnackPosition.BOTTOM,
        duration:
        const Duration(seconds: 5),
      );

      return false;
    } on http.ClientException catch (error) {
      debugPrint(
        '❌ MongoDB sync HTTP error: $error',
      );

      Get.snackbar(
        'Server Connection Error',
        'Could not connect to the AiTradeX backend.',
        snackPosition:
        SnackPosition.BOTTOM,
        duration:
        const Duration(seconds: 5),
      );

      return false;
    } catch (error, stackTrace) {
      debugPrint('');
      debugPrint('========================================');
      debugPrint('❌ MONGODB SYNC EXCEPTION');
      debugPrint('========================================');
      debugPrint('ERROR: $error');
      debugPrint('STACK: $stackTrace');
      debugPrint('========================================');

      Get.snackbar(
        'Database Sync Failed',
        'Could not save your account to MongoDB.',
        snackPosition:
        SnackPosition.BOTTOM,
        duration:
        const Duration(seconds: 5),
      );

      return false;
    }
  }

  // ==========================================================
  // DRAFT MANAGEMENT
  // ==========================================================

  Future<void> _loadDraft() async {
    try {
      isLoading.value = true;

      final SignupModel? draft =
      await SharedPreferencesService
          .getSignupData();

      if (draft != null) {
        signup.value = draft;

        // ----------------------------------------------------
        // Restore non-sensitive data only.
        // Passwords are NEVER restored.
        // ----------------------------------------------------

        if (nameController.text.isEmpty) {
          nameController.text =
              draft.fullName;
        }

        if (emailController.text.isEmpty) {
          emailController.text =
              draft.email;
        }

        if (phoneController.text.isEmpty) {
          phoneController.text =
              _phoneDigits(draft.phone);
        }

        if (usernameController.text.isEmpty) {
          usernameController.text =
              draft.username;
        }

        profileImagePath.value =
            draft.profileImage.trim();

        referralCodeRx.value =
            draft.referralCode.trim().toUpperCase();

        emailVerified.value =
            draft.emailVerified;

        phoneVerified.value =
            draft.phoneVerified;

        _validateFields();

        debugPrint(
          'Signup draft restored: '
              'emailVerified=${emailVerified.value}, '
              'phoneVerified=${phoneVerified.value}',
        );
      }
    } catch (error) {
      debugPrint(
        'Load signup draft error: $error',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveDraft() async {
    try {
      updateSignupModel();

      await SharedPreferencesService
          .saveSignupData(
        signup.value,
      );
    } catch (error) {
      debugPrint(
        'Save signup draft error: $error',
      );
    }
  }

  Future<void> saveCurrentDraft() async {
    updateSignupModel();

    await saveDraft();
  }

  // ==========================================================
  // PASSWORD CLEAR
  // ==========================================================

  void clearPasswordFields() {
    passwordController.clear();

    confirmPasswordController.clear();

    _validateFields();
  }

  // ==========================================================
  // CLEAR COMPLETE DRAFT
  // ==========================================================

  Future<void> clearDraft() async {
    signup.value = SignupModel();

    nameController.clear();

    emailController.clear();

    phoneController.clear();

    usernameController.clear();

    profileImagePath.value = '';
    referralCodeRx.value = '';

    passwordController.clear();

    confirmPasswordController.clear();

    emailVerified.value = false;

    phoneVerified.value = false;

    verificationId.value = '';

    _temporaryFirebasePassword = null;

    _validateFields();

    await SharedPreferencesService
        .clearSignupData();
  }

  // ==========================================================
  // UPDATE SIGNUP MODEL
  // ==========================================================

  void updateSignupModel() {
    final String phoneDigits =
    _phoneDigits(
      phoneController.text,
    );

    signup.value
      ..fullName =
      nameController.text.trim()
      ..email =
      emailController.text
          .trim()
          .toLowerCase()
      ..phone = phoneDigits.isEmpty
          ? ''
          : '+91$phoneDigits'
      ..username =
      usernameController.text.trim()
      ..profileImage =
      profileImagePath.value.trim()
      ..referralCode =
      referralCodeRx.value.trim().toUpperCase()
      ..emailVerified =
          emailVerified.value
      ..phoneVerified =
          phoneVerified.value;

    signup.refresh();
  }

  // ==========================================================
  // PROFILE IMAGE BACKEND VALUE
  // ==========================================================
  //
  // A local Android/iOS file path cannot be used as a permanent
  // MongoDB profile image URL. Keep local paths in the signup
  // draft, but only send an already-uploaded HTTPS URL to the
  // backend. Firebase photoURL is also accepted.
  //
  // ==========================================================

  Future<void> _uploadProfileImageToBackend({
    required String idToken,
  }) async {
    final String currentPath =
    profileImagePath.value.trim();

    if (currentPath.isEmpty) {
      debugPrint(
        'PROFILE IMAGE: No image selected.',
      );
      return;
    }

    // Already uploaded.
    if (_isRemoteUrl(currentPath)) {
      signup.value.profileImage = currentPath;
      signup.refresh();

      debugPrint(
        'PROFILE IMAGE: Already uploaded.',
      );
      debugPrint(
        'PROFILE IMAGE URL: $currentPath',
      );
      return;
    }

    final File file = File(currentPath);

    if (!await file.exists()) {
      throw Exception(
        'Selected profile image file could not be found.',
      );
    }

    final int fileSize = await file.length();

    if (fileSize <= 0) {
      throw Exception(
        'Selected profile image is empty.',
      );
    }

    debugPrint('');
    debugPrint('========================================');
    debugPrint('PROFILE IMAGE UPLOAD');
    debugPrint('========================================');
    debugPrint('FILE: $currentPath');
    debugPrint('SIZE: $fileSize bytes');
    debugPrint('========================================');

    final Uri uri = Uri.parse(
      '$_apiBaseUrl/upload/profile',
    );

    final http.MultipartRequest request =
    http.MultipartRequest(
      'POST',
      uri,
    );

    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer ${idToken.trim()}',
    });

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        file.path,
      ),
    );

    final http.StreamedResponse streamedResponse =
    await request.send().timeout(
      const Duration(seconds: 60),
    );

    final String responseBody =
    await streamedResponse.stream.bytesToString();

    debugPrint('');
    debugPrint('========================================');
    debugPrint('PROFILE IMAGE UPLOAD RESPONSE');
    debugPrint('========================================');
    debugPrint(
      'STATUS: ${streamedResponse.statusCode}',
    );
    debugPrint(
      'BODY  : $responseBody',
    );
    debugPrint('========================================');

    dynamic decoded;

    try {
      if (responseBody.trim().isNotEmpty) {
        decoded = jsonDecode(responseBody);
      }
    } catch (error) {
      debugPrint(
        'PROFILE IMAGE RESPONSE JSON ERROR: $error',
      );
    }

    if (streamedResponse.statusCode < 200 ||
        streamedResponse.statusCode >= 300) {
      final String message =
      decoded is Map<String, dynamic>
          ? decoded['message']?.toString() ??
          'Profile image upload failed.'
          : 'Profile image upload failed with status ${streamedResponse.statusCode}.';

      throw Exception(message);
    }

    if (decoded is! Map<String, dynamic> ||
        decoded['success'] != true) {
      throw Exception(
        decoded is Map<String, dynamic>
            ? decoded['message']?.toString() ??
            'Profile image upload failed.'
            : 'Invalid profile image upload response.',
      );
    }

    final dynamic rawUrl = decoded['url'];
    final String uploadedUrl =
        rawUrl?.toString().trim() ?? '';

    if (!_isRemoteUrl(uploadedUrl)) {
      throw Exception(
        'Backend did not return a valid profile image URL.',
      );
    }

    profileImagePath.value = uploadedUrl;
    signup.value.profileImage = uploadedUrl;
    signup.refresh();

    debugPrint(
      '✅ PROFILE IMAGE UPLOADED: $uploadedUrl',
    );
  }

  bool _isRemoteUrl(String value) {
    final String normalized = value.trim().toLowerCase();

    return normalized.startsWith('https://') ||
        normalized.startsWith('http://');
  }

  String _profileImageForBackend(
      String? firebasePhotoUrl,
      String localOrRemotePath,
      ) {
    final String firebaseUrl =
        firebasePhotoUrl?.trim() ?? '';

    if (_isRemoteUrl(firebaseUrl)) {
      return firebaseUrl;
    }

    final String selectedPath =
    localOrRemotePath.trim();

    if (_isRemoteUrl(selectedPath)) {
      return selectedPath;
    }

    return '';
  }

  // ==========================================================
  // PHONE NORMALIZATION
  // ==========================================================

  String _phoneDigits(String phone) {
    String digits =
    phone.replaceAll(
      RegExp(r'\D'),
      '',
    );

    if (digits.startsWith('91') &&
        digits.length > 10) {
      digits =
          digits.substring(2);
    }

    return digits;
  }

  // ==========================================================
  // TEMPORARY FIREBASE PASSWORD
  // ==========================================================
  //
  // Used only to create the temporary Firebase Auth user.
  //
  // IMPORTANT:
  // This value is NOT saved to:
  // - SharedPreferences
  // - SignupModel
  // - MongoDB
  //
  // ==========================================================

  String _generateTemporaryPassword() {
    const String letters =
        'AaBbCcDdEeFfGgHhIiJjKkLlMm'
        'NnOoPpQqRrSsTtUuVvWwXxYyZz';

    const String numbers =
        '0123456789';

    const String symbols =
        '!@#\$%^&*';

    final Random random =
    Random.secure();

    final StringBuffer password =
    StringBuffer();

    // Letters
    for (int i = 0; i < 20; i++) {
      password.write(
        letters[
        random.nextInt(
          letters.length,
        )
        ],
      );
    }

    // Numbers
    for (int i = 0; i < 8; i++) {
      password.write(
        numbers[
        random.nextInt(
          numbers.length,
        )
        ],
      );
    }

    // Symbols
    for (int i = 0; i < 4; i++) {
      password.write(
        symbols[
        random.nextInt(
          symbols.length,
        )
        ],
      );
    }

    return password.toString();
  }

  // ==========================================================
  // JSON HELPER
  // ==========================================================

  Map<String, dynamic> _decodeJsonMap(
      String body,
      ) {
    if (body.trim().isEmpty) {
      return <String, dynamic>{};
    }

    try {
      final dynamic decoded =
      jsonDecode(body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return <String, dynamic>{};
    } catch (error) {
      debugPrint(
        'JSON decode error: $error',
      );

      return <String, dynamic>{};
    }
  }

  // ==========================================================
  // FIREBASE ERROR MESSAGES
  // ==========================================================

  String _firebaseErrorMessage(
      String code,
      String? firebaseMessage,
      ) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered. Please use another email or login.';

      case 'invalid-email':
        return 'Please enter a valid email address.';

      case 'weak-password':
        return 'The password is too weak.';

      case 'operation-not-allowed':
        return 'Email/Password authentication is not enabled in Firebase Console.';

      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';

      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again later.';

      case 'invalid-verification-code':
        return 'The OTP is invalid. Please check the code and try again.';

      case 'invalid-verification-id':
        return 'The OTP session expired. Please request a new OTP.';

      case 'credential-already-in-use':
        return 'This credential is already linked to another Firebase account.';

      case 'provider-already-linked':
        return 'This credential is already linked to this account.';

      case 'requires-recent-login':
        return 'Your Firebase signup session expired. Please restart signup.';

      case 'user-disabled':
        return 'This Firebase account has been disabled.';

      case 'user-not-found':
        return 'Firebase signup session was not found. Please restart signup.';

      case 'email-not-verified':
        return 'Please verify your email before continuing.';

      case 'phone-not-verified':
        return 'Please verify your phone number before continuing.';

      case 'password-mismatch':
        return 'The passwords do not match.';

      default:
        if (firebaseMessage != null &&
            firebaseMessage.trim().isNotEmpty) {
          return firebaseMessage.trim();
        }

        return 'Firebase authentication failed. Please try again.';
    }
  }

  // ==========================================================
  // VALIDATION MESSAGE
  // ==========================================================

  void _showValidationMessage({
    String title = 'Invalid Details',
    String message =
    'Please complete this step.',
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition:
      SnackPosition.BOTTOM,
    );
  }

  String _currentPageValidationMessage() {
    switch (currentPage.value) {
      case 0:
        return 'Please enter your full name.';

      case 1:
        return 'Please verify your email address from Gmail.';

      case 2:
        return 'Please verify your mobile number with OTP.';

      case 3:
        return 'Please enter a valid username.';

      case 4:
        return 'Please enter and confirm your password.';

      case 5:
        return 'Profile image is optional. You can continue without one.';

      case 6:
        return 'Referral code is optional. You can continue without one.';

      case 7:
        return 'Please complete all required signup information.';

      default:
        return 'Please complete this step.';
    }
  }
}

