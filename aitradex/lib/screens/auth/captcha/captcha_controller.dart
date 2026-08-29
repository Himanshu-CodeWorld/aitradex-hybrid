import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class CaptchaController extends GetxController {
  /// Loading state
  final RxBool isLoading = false.obs;

  /// Error message
  final RxString errorMessage = "".obs;

  /// Captcha URL
  static const String captchaBaseUrl =
      "https://aitradex-api.onrender.com/captcha";

  /// Open Cloudflare Turnstile
  Future<void> openCaptcha({
    required String email,
  }) async {
    // Prevent double click
    if (isLoading.value) return;

    try {
      isLoading.value = true;
      errorMessage.value = "";

      final Uri url = Uri.parse(
        "$captchaBaseUrl?email=${Uri.encodeComponent(email)}",
      );

      final bool launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        isLoading.value = false;

        Get.snackbar(
          "Error",
          "Unable to open browser.",
          snackPosition: SnackPosition.BOTTOM,
        );
      }

      // If launched successfully,
      // keep loading=true until deep link returns.
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();

      Get.snackbar(
        "Error",
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Called after deep link success
  void onCaptchaVerified() {
    reset();
  }

  /// Reset controller state
  void reset() {
    isLoading.value = false;
    errorMessage.value = "";
  }

  @override
  void onClose() {
    reset();
    super.onClose();
  }
}