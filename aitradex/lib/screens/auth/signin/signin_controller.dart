import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:aitradex/services/shared_preferences_service.dart';

class SignInController extends GetxController {
  // ============================================================
  // FIREBASE AUTH
  // ============================================================

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ============================================================
  // TEXT CONTROLLERS
  // ============================================================

  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  // ============================================================
  // REACTIVE STATE
  // ============================================================

  final RxBool isLoading = false.obs;

  final RxBool isPasswordVisible = false.obs;

  final RxBool isSendingResetEmail = false.obs;

  // ============================================================
  // PASSWORD VISIBILITY
  // ============================================================

  void togglePasswordVisibility() {
    isPasswordVisible.toggle();
  }

  // ============================================================
  // EMAIL VALIDATION
  // ============================================================

  bool get isEmailValid {
    final String email =
    emailController.text.trim();

    if (email.isEmpty) {
      return false;
    }

    return RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(email);
  }

  // ============================================================
  // PASSWORD VALIDATION
  // ============================================================

  bool get isPasswordValid {
    return passwordController.text.length >= 6;
  }

  // ============================================================
  // SIGN IN
  // ============================================================

  Future<void> signIn() async {
    if (isLoading.value) {
      return;
    }

    // ----------------------------------------------------------
    // EMAIL VALIDATION
    // ----------------------------------------------------------

    if (!isEmailValid) {
      _showError(
        'Invalid Email',
        'Please enter a valid email address.',
      );
      return;
    }

    // ----------------------------------------------------------
    // PASSWORD VALIDATION
    // ----------------------------------------------------------

    if (passwordController.text.isEmpty) {
      _showError(
        'Password Required',
        'Please enter your password.',
      );
      return;
    }

    try {
      isLoading.value = true;

      debugPrint(
        '========================================',
      );
      debugPrint('AiTradeX SIGN IN');
      debugPrint(
        '========================================',
      );
      debugPrint(
        'Email: ${emailController.text.trim()}',
      );

      // --------------------------------------------------------
      // FIREBASE SIGN IN
      // --------------------------------------------------------

      final UserCredential credential =
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      User? user = credential.user;

      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message:
          'Unable to retrieve Firebase user.',
        );
      }

      // --------------------------------------------------------
      // REFRESH USER
      // --------------------------------------------------------

      await user.reload();

      user = _auth.currentUser;

      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message:
          'User session could not be restored.',
        );
      }

      debugPrint(
        'Firebase UID: ${user.uid}',
      );

      debugPrint(
        'Firebase Email: ${user.email}',
      );

      debugPrint(
        'Email Verified: ${user.emailVerified}',
      );

      // --------------------------------------------------------
      // SAVE LOCAL FIREBASE UID
      // --------------------------------------------------------

      await SharedPreferencesService.saveFirebaseUid(
        user.uid,
      );

      // --------------------------------------------------------
      // SAVE LOGIN STATE
      // --------------------------------------------------------

      await SharedPreferencesService.login(
        userId: user.uid,
      );

      // --------------------------------------------------------
      // SAVE USER PROFILE LOCALLY
      // --------------------------------------------------------

      await SharedPreferencesService.saveUserProfile(
        name: user.displayName ?? '',
        email: user.email ?? '',
        profileImageUrl:
        user.photoURL ?? '',
      );

      debugPrint(
        'Local login state saved successfully.',
      );

      debugPrint(
        'Opening BottomNav...',
      );

      debugPrint(
        '========================================',
      );

      // --------------------------------------------------------
      // OPEN BOTTOM NAVIGATION
      // --------------------------------------------------------

      if (Get.currentRoute != '/bottom-nav') {
        Get.offAllNamed('/bottom-nav');
      }
    } on FirebaseAuthException catch (e) {
      debugPrint(
        '========================================',
      );
      debugPrint(
        'FIREBASE SIGN IN ERROR',
      );
      debugPrint(
        'Code: ${e.code}',
      );
      debugPrint(
        'Message: ${e.message}',
      );
      debugPrint(
        '========================================',
      );

      _handleFirebaseSignInError(e);
    } catch (e, stackTrace) {
      debugPrint(
        '========================================',
      );
      debugPrint(
        'SIGN IN ERROR',
      );
      debugPrint(
        'Error: $e',
      );
      debugPrint(
        'StackTrace: $stackTrace',
      );
      debugPrint(
        '========================================',
      );

      _showError(
        'Sign In Failed',
        'Something went wrong. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // FORGOT PASSWORD
  // ============================================================

  Future<void> forgotPassword() async {
    if (isSendingResetEmail.value) {
      return;
    }

    final String email =
    emailController.text.trim();

    // ----------------------------------------------------------
    // EMAIL EMPTY
    // ----------------------------------------------------------

    if (email.isEmpty) {
      _showError(
        'Email Required',
        'Please enter your email address first.',
      );
      return;
    }

    // ----------------------------------------------------------
    // EMAIL INVALID
    // ----------------------------------------------------------

    if (!isEmailValid) {
      _showError(
        'Invalid Email',
        'Please enter a valid email address.',
      );
      return;
    }

    try {
      isSendingResetEmail.value = true;

      debugPrint(
        'Sending password reset email to: $email',
      );

      await _auth.sendPasswordResetEmail(
        email: email,
      );

      _showSuccess(
        'Reset Email Sent',
        'A password reset link has been sent to $email.',
      );
    } on FirebaseAuthException catch (e) {
      debugPrint(
        '========================================',
      );
      debugPrint(
        'FIREBASE PASSWORD RESET ERROR',
      );
      debugPrint(
        'Code: ${e.code}',
      );
      debugPrint(
        'Message: ${e.message}',
      );
      debugPrint(
        '========================================',
      );

      _handlePasswordResetError(e);
    } catch (e, stackTrace) {
      debugPrint(
        'PASSWORD RESET ERROR: $e',
      );

      debugPrint(
        'STACK TRACE: $stackTrace',
      );

      _showError(
        'Reset Failed',
        'Unable to send the password reset email.',
      );
    } finally {
      isSendingResetEmail.value = false;
    }
  }

  // ============================================================
  // FIREBASE SIGN-IN ERROR HANDLER
  // ============================================================

  void _handleFirebaseSignInError(
      FirebaseAuthException exception,
      ) {
    switch (exception.code) {
      case 'invalid-email':
        _showError(
          'Invalid Email',
          'Please enter a valid email address.',
        );
        break;

      case 'user-disabled':
        _showError(
          'Account Disabled',
          'This account has been disabled. Please contact support.',
        );
        break;

      case 'user-not-found':
        _showError(
          'Account Not Found',
          'No account was found with this email address.',
        );
        break;

      case 'wrong-password':
        _showError(
          'Incorrect Password',
          'The password you entered is incorrect.',
        );
        break;

      case 'invalid-credential':
        _showError(
          'Invalid Credentials',
          'The email or password is incorrect.',
        );
        break;

      case 'too-many-requests':
        _showError(
          'Too Many Attempts',
          'Too many unsuccessful attempts. Please try again later.',
        );
        break;

      case 'network-request-failed':
        _showError(
          'Network Error',
          'Please check your internet connection and try again.',
        );
        break;

      case 'operation-not-allowed':
        _showError(
          'Sign In Unavailable',
          'Email and password sign-in is not enabled in Firebase.',
        );
        break;

      case 'invalid-api-key':
        _showError(
          'Firebase Configuration Error',
          'The Firebase API key is invalid. Check firebase_options.dart and your Firebase project configuration.',
        );
        break;

      case 'internal-error':
        _showError(
          'Firebase Error',
          'Firebase returned an internal error. Please try again.',
        );
        break;

      default:
        _showError(
          'Sign In Failed',
          _firebaseErrorMessage(exception),
        );
        break;
    }
  }

  // ============================================================
  // FIREBASE ERROR MESSAGE
  // ============================================================

  String _firebaseErrorMessage(
      FirebaseAuthException exception,
      ) {
    final String? message =
        exception.message;

    if (message != null &&
        message.trim().isNotEmpty) {
      return message.trim();
    }

    switch (exception.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';

      case 'user-disabled':
        return 'This account has been disabled.';

      case 'user-not-found':
        return 'No account was found with this email address.';

      case 'wrong-password':
        return 'The password you entered is incorrect.';

      case 'invalid-credential':
        return 'The email or password is incorrect.';

      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';

      case 'network-request-failed':
        return 'Please check your internet connection.';

      case 'operation-not-allowed':
        return 'Email and password sign-in is not enabled in Firebase.';

      default:
        return 'Unable to sign in. Please try again.';
    }
  }

  // ============================================================
  // FIREBASE PASSWORD RESET ERROR HANDLER
  // ============================================================

  void _handlePasswordResetError(
      FirebaseAuthException exception,
      ) {
    switch (exception.code) {
      case 'invalid-email':
        _showError(
          'Invalid Email',
          'Please enter a valid email address.',
        );
        break;

      case 'user-not-found':
        _showError(
          'Account Not Found',
          'No account was found with this email address.',
        );
        break;

      case 'network-request-failed':
        _showError(
          'Network Error',
          'Please check your internet connection and try again.',
        );
        break;

      case 'too-many-requests':
        _showError(
          'Too Many Requests',
          'Please wait before requesting another reset email.',
        );
        break;

      case 'invalid-api-key':
        _showError(
          'Firebase Configuration Error',
          'The Firebase API key is invalid. Check your Firebase configuration.',
        );
        break;

      default:
        _showError(
          'Reset Failed',
          exception.message ??
              'Unable to send the password reset email.',
        );
        break;
    }
  }

  // ============================================================
  // ERROR SNACKBAR
  // ============================================================

  void _showError(
      String title,
      String message,
      ) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.red.shade50,
      colorText: Colors.red.shade900,
      icon: Icon(
        Icons.error_outline_rounded,
        color: Colors.red.shade700,
      ),
    );
  }

  // ============================================================
  // SUCCESS SNACKBAR
  // ============================================================

  void _showSuccess(
      String title,
      String message,
      ) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
      duration: const Duration(seconds: 4),
      backgroundColor: Colors.green.shade50,
      colorText: Colors.green.shade900,
      icon: Icon(
        Icons.check_circle_outline_rounded,
        color: Colors.green.shade700,
      ),
    );
  }

  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();

    super.onClose();
  }
}