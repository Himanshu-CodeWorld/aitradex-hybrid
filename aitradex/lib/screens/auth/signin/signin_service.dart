import 'dart:convert';

import 'package:http/http.dart' as http;

class SignInService {
  // Render API Base URL
  static const String _baseUrl =
      "https://aitradex-api.onrender.com/api";

  // ==========================================================
  // SEND PHONE OTP
  // ==========================================================
  static Future<Map<String, dynamic>> sendPhoneOtp({
    required String phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/auth/send-phone-otp"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "phone": phone.trim(),
        }),
      );

      final Map<String, dynamic> data =
      jsonDecode(response.body);

      return {
        "success":
        response.statusCode == 200 ||
            response.statusCode == 201,
        "message": data["message"] ??
            (response.statusCode == 200
                ? "OTP sent successfully."
                : "Failed to send OTP."),
        "data": data,
      };
    } catch (e) {
      return {
        "success": false,
        "message":
        "Unable to connect to the server. Please try again.",
      };
    }
  }
}