import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/api/api_constants.dart';
import '../models/signup_model.dart';

class AuthService {
  /// Signup User
  Future<Map<String, dynamic>> signup(SignupModel model) async {
    try {
      final url = Uri.parse(ApiConstants.signup);

      final body = jsonEncode(model.toJson());

      print("========== SIGNUP API ==========");
      print("URL: $url");
      print("REQUEST:");
      print(body);

      final response = await http.post(
        url,
        headers: const {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: body,
      );

      print("========== SIGNUP RESPONSE ==========");
      print("STATUS CODE : ${response.statusCode}");
      print("BODY : ${response.body}");

      Map<String, dynamic> data = {};

      if (response.body.isNotEmpty) {
        data = jsonDecode(response.body);
      }

      return {
        "statusCode": response.statusCode,
        "success": response.statusCode >= 200 &&
            response.statusCode < 300,
        "message": data["message"] ??
            "Unknown error",
        "data": data,
      };
    } catch (e) {
      print("========== SIGNUP EXCEPTION ==========");
      print(e);

      return {
        "success": false,
        "message": e.toString(),
      };
    }
  }

  /// Login User
  Future<Map<String, dynamic>> login({
    required String email,
    required String mpin,
  }) async {
    try {
      final url = Uri.parse(ApiConstants.login);

      final body = jsonEncode({
        "email": email,
        "mpin": mpin,
      });

      print("========== LOGIN API ==========");
      print("URL: $url");
      print("REQUEST:");
      print(body);

      final response = await http
          .post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: body,
      )
          .timeout(const Duration(seconds: 30));

      print("========== LOGIN RESPONSE ==========");
      print("REQUEST URL : ${response.request?.url}");
      print("STATUS CODE : ${response.statusCode}");
      print("HEADERS : ${response.headers}");
      print("BODY : ${response.body}");

      Map<String, dynamic> data = {};

      if (response.body.isNotEmpty) {
        data = jsonDecode(response.body);
      }

      return {
        "statusCode": response.statusCode,
        "success": response.statusCode == 200,
        "message": data["message"],
        "data": data,
      };
    } catch (e, stackTrace) {
      print("========== LOGIN ERROR ==========");
      print(e);
      print(stackTrace);

      return {
        "success": false,
        "message": e.toString(),
      };
    }
  }

  /// Send Phone OTP
  Future<Map<String, dynamic>> sendPhoneOtp({
    required String phone,
    String purpose = "signup",
  }) async {
    try {
      final url = Uri.parse(ApiConstants.sendPhoneOtp);

      final response = await http.post(
        url,
        headers: const {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "phone": phone,
          "purpose": purpose,
        }),
      );

      print("========== SEND PHONE OTP ==========");
      print("STATUS : ${response.statusCode}");
      print("BODY : ${response.body}");

      Map<String, dynamic> data = {};

      if (response.body.isNotEmpty) {
        data = jsonDecode(response.body);
      }

      return {
        "success": response.statusCode == 200,
        "statusCode": response.statusCode,
        "message": data["message"] ?? "",
        "data": data,
      };
    } catch (e) {
      return {
        "success": false,
        "message": e.toString(),
      };
    }
  }

  /// Verify Phone OTP
  Future<Map<String, dynamic>> verifyPhoneOtp({
    required String phone,
    required String otp,
    String purpose = "signup",
  }) async {
    try {
      final url = Uri.parse(ApiConstants.verifyPhoneOtp);

      final response = await http.post(
        url,
        headers: const {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "phone": phone,
          "otp": otp,
          "purpose": purpose,
        }),
      );

      print("========== VERIFY PHONE OTP ==========");
      print("STATUS : ${response.statusCode}");
      print("BODY : ${response.body}");

      Map<String, dynamic> data = {};

      if (response.body.isNotEmpty) {
        data = jsonDecode(response.body);
      }

      return {
        "success": response.statusCode == 200,
        "statusCode": response.statusCode,
        "message": data["message"] ?? "",
        "data": data,
      };
    } catch (e) {
      return {
        "success": false,
        "message": e.toString(),
      };
    }
  }

  /// Resend Phone OTP
  Future<Map<String, dynamic>> resendPhoneOtp({
    required String phone,
    String purpose = "signup",
  }) async {
    try {
      final url = Uri.parse(ApiConstants.resendPhoneOtp);

      final response = await http.post(
        url,
        headers: const {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "phone": phone,
          "purpose": purpose,
        }),
      );

      print("========== RESEND PHONE OTP ==========");
      print("STATUS : ${response.statusCode}");
      print("BODY : ${response.body}");

      Map<String, dynamic> data = {};

      if (response.body.isNotEmpty) {
        data = jsonDecode(response.body);
      }

      return {
        "success": response.statusCode == 200,
        "statusCode": response.statusCode,
        "message": data["message"] ?? "",
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


