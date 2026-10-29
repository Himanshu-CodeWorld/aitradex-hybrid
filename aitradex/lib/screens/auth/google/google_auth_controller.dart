import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'google_auth_service.dart';

/// GetX controller for the AiTradeX Google sign-in button.
///
/// The controller intentionally contains no GoogleSignIn initialization or
/// duplicate HTTP request. Google/Firebase/backend work belongs to the service.
class GoogleAuthController extends GetxController {
  final RxBool isLoading = false.obs;
  final GoogleAuthService _googleAuthService = GoogleAuthService.instance;

  Future<void> signInWithGoogle() async {
    if (isLoading.value) return;
    isLoading.value = true;

    try {
      final User user = await _googleAuthService.signInWithGoogle();
      debugPrint(
        '[GoogleAuthController] Login completed for ${user.email ?? user.uid}.',
      );

      // Ensure this route name exists in GetMaterialApp's getPages/routes.
      Get.offAllNamed('/bottom-nav');
    } on FirebaseAuthException catch (error, stackTrace) {
      debugPrint(
        '[GoogleAuthController] Firebase error: ${error.code} - ${error.message}',
      );
      debugPrintStack(stackTrace: stackTrace);
      _showError('Firebase Login Failed', error.message ?? error.code);
    } on TimeoutException catch (error, stackTrace) {
      debugPrint('[GoogleAuthController] Timeout: $error');
      debugPrintStack(stackTrace: stackTrace);
      _showError(
        'Connection Timeout',
        'Authentication took too long. Check your connection and try again.',
      );
    } catch (error, stackTrace) {
      final String message = error.toString().replaceFirst('Exception: ', '');
      debugPrint('[GoogleAuthController] Google login failed: $message');
      debugPrintStack(stackTrace: stackTrace);
      _showError('Google Sign-In Failed', message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleAuthService.signOut();
      Get.offAllNamed('/login');
    } catch (error, stackTrace) {
      debugPrint('[GoogleAuthController] Sign-out failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      _showError('Sign Out Failed', 'Unable to sign out. Please try again.');
    }
  }

  void _showError(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 6),
      margin: const EdgeInsets.all(12),
    );
  }
}
