import 'dart:convert';

import 'package:http/http.dart' as http;

class CaptchaService {
  // ===============================
  // API Base URL
  // ===============================
  static const String baseUrl =
      "https://aitradex-api.onrender.com/api";

  // ===============================
  // Verify Turnstile Token
  // ===============================
  Future<bool> verifyTurnstile({
    required String email,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/verify-turnstile"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": email,
          "token": token,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data["success"] == true;
      }

      throw Exception(
        data["message"] ?? "Captcha verification failed.",
      );
    } catch (e) {
      throw Exception(
        "Unable to verify captcha.\n$e",
      );
    }
  }
}