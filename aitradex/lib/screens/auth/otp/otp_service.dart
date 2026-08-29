import 'dart:convert';
import 'package:http/http.dart' as http;

class OtpService {
  static const String _baseUrl =
      "https://aitradex-api.onrender.com/api";

  // ==========================================================
// SEND EMAIL OTP
// ==========================================================

  static Future<Map<String, dynamic>> sendOtp({
    required String email,
  }) async {
    try {
      final response = await http
          .post(
        Uri.parse("$_baseUrl/auth/send-otp"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": email.trim(),
        }),
      )
          .timeout(const Duration(seconds: 20));

      final data = jsonDecode(response.body);

      return {
        "success": response.statusCode == 200 ||
            response.statusCode == 201,
        "message": data["message"] ?? "",
        "data": data,
      };
    } catch (e) {
      print("SEND OTP ERROR: $e");

      return {
        "success": false,
        "message": e.toString(),
      };
    }
  }

  // ==========================================================
  // VERIFY EMAIL OTP
  // ==========================================================

  static Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/auth/verify-otp"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": email.trim(),
          "otp": otp.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      return {
        "success": response.statusCode == 200 ||
            response.statusCode == 201,
        "message":
        data["message"] ?? "OTP verification failed.",
        "data": data,
      };
    } catch (e) {
      return {
        "success": false,
        "message": e.toString(),
      };
    }
  }

  // ==========================================================
  // RESEND EMAIL OTP
  // ==========================================================

  static Future<Map<String, dynamic>> resendOtp({
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/auth/resend-otp"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": email.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      return {
        "success": response.statusCode == 200 ||
            response.statusCode == 201,
        "message":
        data["message"] ?? "Unable to resend OTP.",
        "data": data,
      };
    } catch (e) {
      return {
        "success": false,
        "message": e.toString(),
      };
    }
  }

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

      final data = jsonDecode(response.body);

      return {
        "success": response.statusCode == 200 ||
            response.statusCode == 201,
        "message":
        data["message"] ?? "OTP sent successfully.",
        "data": data,
      };
    } catch (e) {
      return {
        "success": false,
        "message": e.toString(),
      };
    }
  }

  // ==========================================================
  // VERIFY PHONE OTP
  // ==========================================================

  static Future<Map<String, dynamic>> verifyPhoneOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final uri = Uri.parse("$_baseUrl/auth/verify-phone-otp");

      print("==================================");
      print("VERIFY PHONE OTP API");
      print("URL    : $uri");
      print("Phone  : $phone");
      print("OTP    : $otp");

      final response = await http
          .post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "phone": phone.trim(),
          "otp": otp.trim(),
        }),
      )
          .timeout(const Duration(seconds: 30));

      print("==================================");
      print("STATUS : ${response.statusCode}");
      print("BODY   : ${response.body}");

      Map<String, dynamic> data = {};

      if (response.body.isNotEmpty) {
        data = jsonDecode(response.body);
      }

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        return {
          "success": true,
          "message": data["message"] ?? "OTP verified successfully.",
          "data": data,
        };
      }

      return {
        "success": false,
        "statusCode": response.statusCode,
        "message": data["message"] ??
            "Verification failed. (${response.statusCode})",
        "data": data,
      };
    } catch (e) {
      print("VERIFY PHONE OTP ERROR");
      print(e);

      return {
        "success": false,
        "message": e.toString(),
      };
    }
  }

  // ==========================================================
  // RESEND PHONE OTP
  // ==========================================================

  static Future<Map<String, dynamic>> resendPhoneOtp({
    required String phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/auth/resend-phone-otp"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "phone": phone.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      return {
        "success": response.statusCode == 200 ||
            response.statusCode == 201,
        "message":
        data["message"] ?? "OTP sent successfully.",
        "data": data,
      };
    } catch (e) {
      return {
        "success": false,
        "message": e.toString(),
      };
    }
  }
}