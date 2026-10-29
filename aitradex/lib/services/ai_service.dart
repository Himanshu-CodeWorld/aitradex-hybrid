import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class AiService {
  AiService._();

  static const String baseUrl =
      'https://aitradex-api.onrender.com/api';

  static Future<String> sendMessage({
    required String message,
    List<Map<String, String>> history = const [],
  }) async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Please sign in to use AiTradeX AI.');
    }

    final String? idToken = await user.getIdToken(true);

    if (idToken == null || idToken.isEmpty) {
      throw Exception('Unable to authenticate with AiTradeX.');
    }

    final Uri url = Uri.parse('$baseUrl/ai/chat');

    final List<Map<String, String>> cleanHistory = history
        .where(
          (item) =>
      item['role'] != null &&
          item['content'] != null &&
          item['content']!.trim().isNotEmpty,
    )
        .map(
          (item) => {
        'role': item['role']!,
        'content': item['content']!,
      },
    )
        .toList();

    final http.Response response = await http
        .post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'message': message.trim(),
          'history': cleanHistory,
        },
      ),
    )
        .timeout(
      const Duration(seconds: 60),
    );

    Map<String, dynamic> data = <String, dynamic>{};

    try {
      final dynamic decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        data = decoded;
      }
    } catch (_) {
      throw Exception(
        'Invalid response received from AiTradeX server.',
      );
    }

    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        data['success'] == true) {
      final dynamic aiMessage = data['message'];

      if (aiMessage is String && aiMessage.trim().isNotEmpty) {
        return aiMessage.trim();
      }

      throw Exception(
        'AiTradeX AI returned an empty response.',
      );
    }

    final String serverMessage =
        data['message']?.toString().trim() ?? '';

    if (response.statusCode == 401) {
      throw Exception(
        'Your session has expired. Please sign in again.',
      );
    }

    if (response.statusCode == 429) {
      throw Exception(
        serverMessage.isNotEmpty
            ? serverMessage
            : 'AI is temporarily rate limited. Please try again shortly.',
      );
    }

    if (response.statusCode >= 500) {
      throw Exception(
        serverMessage.isNotEmpty
            ? serverMessage
            : 'AiTradeX AI server is temporarily unavailable.',
      );
    }

    throw Exception(
      serverMessage.isNotEmpty
          ? serverMessage
          : 'Unable to get an AI response.',
    );
  }
}