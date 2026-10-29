import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  ApiService._();

  // ============================================================
  // BASE URL
  // ============================================================

  /// Production Render API.
  static const String baseUrl =
      'https://aitradex-api.onrender.com';

  // ============================================================
  // FIREBASE AUTH
  // ============================================================

  static FirebaseAuth get _firebaseAuth =>
      FirebaseAuth.instance;

  // ============================================================
  // GET FIREBASE ID TOKEN
  // ============================================================

  static Future<String?> _getFirebaseIdToken() async {
    try {
      final User? user =
          _firebaseAuth.currentUser;

      if (user == null) {
        debugPrint(
          'API AUTH: No Firebase user is currently signed in.',
        );

        return null;
      }

      final String? token =
      await user.getIdToken();

      if (token == null || token.trim().isEmpty) {
        debugPrint(
          'API AUTH: Firebase ID token is empty.',
        );

        return null;
      }

      return token.trim();
    } catch (e, stackTrace) {
      debugPrint(
        '========================================',
      );
      debugPrint(
        'FIREBASE ID TOKEN ERROR',
      );
      debugPrint(
        '========================================',
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

      return null;
    }
  }

  // ============================================================
  // COMMON HEADERS
  // ============================================================

  static Future<Map<String, String>>
  _authHeaders() async {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final String? token =
    await _getFirebaseIdToken();

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] =
      'Bearer $token';
    }

    return headers;
  }

  // ============================================================
  // DELETE ACCOUNT
  // ============================================================

  static Future<bool> deleteAccount() async {
    final User? user = _firebaseAuth.currentUser;
    if (user == null) {
      debugPrint('DELETE ACCOUNT: No signed-in Firebase user.');
      return false;
    }

    try {
      // Force-refresh so the backend receives a current Firebase ID token.
      final String? idToken = await user.getIdToken(true);
      if (idToken == null || idToken.trim().isEmpty) {
        debugPrint('DELETE ACCOUNT: Could not obtain Firebase ID token.');
        return false;
      }

      final http.Response response = await http
          .delete(
        Uri.parse('$baseUrl/api/auth/delete-account'),
        headers: <String, String>{
          'Authorization': 'Bearer ${idToken.trim()}',
          'Accept': 'application/json',
        },
      )
          .timeout(const Duration(seconds: 30));

      Map<String, dynamic> result = <String, dynamic>{};
      try {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) result = decoded;
      } catch (_) {
        // Keep a useful log if the server returned a non-JSON error page.
      }

      debugPrint('DELETE ACCOUNT STATUS: ${response.statusCode}');
      debugPrint('DELETE ACCOUNT RESPONSE: ${response.body}');

      return response.statusCode == 200 && result['success'] == true;
    } catch (error, stackTrace) {
      debugPrint('DELETE ACCOUNT REQUEST ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }
  }
}