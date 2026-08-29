import 'dart:convert';

import 'package:http/http.dart' as http;

class SignupService {

  static const String baseUrl =
      "https://aitradex-api.onrender.com/api";

  static Future<bool> checkEmail(String email) async {

    final response = await http.post(
      Uri.parse("$baseUrl/auth/check-email"),
      headers: {
        "Content-Type":"application/json",
      },
      body: jsonEncode({
        "email": email,
      }),
    );

    final data = jsonDecode(response.body);

    if(response.statusCode==200){

      return data["exists"];

    }

    throw Exception(data["message"]);
  }

}