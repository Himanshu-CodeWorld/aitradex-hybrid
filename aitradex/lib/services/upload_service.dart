import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// AiTradeX image upload service.
///
/// Profile images are uploaded to the AiTradeX backend and the backend
/// returns a permanent HTTPS URL. That URL is then stored in MongoDB.
class UploadService {
  UploadService._();

  static const String _baseUrl =
      'https://aitradex-api.onrender.com/api';

  static Future<String> uploadProfile({
    required File file,
    required String idToken,
  }) async {
    if (!await file.exists()) {
      throw Exception('Profile image file does not exist.');
    }

    final int size = await file.length();

    if (size <= 0) {
      throw Exception('Profile image file is empty.');
    }

    final Uri uri = Uri.parse('$_baseUrl/upload/profile');

    final request = http.MultipartRequest('POST', uri);

    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer ${idToken.trim()}',
    });

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        file.path,
      ),
    );

    final response = await request.send().timeout(
      const Duration(seconds: 60),
    );

    final String body =
    await response.stream.bytesToString();

    debugPrint(
      'PROFILE UPLOAD STATUS: ${response.statusCode}',
    );
    debugPrint(
      'PROFILE UPLOAD BODY: $body',
    );

    dynamic decoded;

    try {
      decoded = jsonDecode(body);
    } catch (_) {
      throw Exception(
        'Invalid response from profile image upload server.',
      );
    }

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        decoded is Map<String, dynamic>
            ? decoded['message']?.toString() ??
            'Profile image upload failed.'
            : 'Profile image upload failed.',
      );
    }

    if (decoded is! Map<String, dynamic> ||
        decoded['success'] != true) {
      throw Exception(
        decoded is Map<String, dynamic>
            ? decoded['message']?.toString() ??
            'Profile image upload failed.'
            : 'Profile image upload failed.',
      );
    }

    final String url =
        decoded['url']?.toString().trim() ?? '';

    if (!url.startsWith('http://') &&
        !url.startsWith('https://')) {
      throw Exception(
        'Profile image server returned an invalid URL.',
      );
    }

    return url;
  }
}
