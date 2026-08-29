import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/api/api_constants.dart';

class UploadService {
  UploadService._();

  /// Upload Image
  static Future<String> uploadImage({
    required File image,
    required String folder,
  }) async {
    try {
      final uri = Uri.parse("${ApiConstants.baseUrl}/upload/image");

      final request = http.MultipartRequest(
        "POST",
        uri,
      );

      request.fields["folder"] = folder;

      request.files.add(
        await http.MultipartFile.fromPath(
          "image",
          image.path,
        ),
      );

      print("========== IMAGE UPLOAD ==========");
      print("URL : $uri");
      print("FILE : ${image.path}");
      print("FOLDER : $folder");

      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(
        streamedResponse,
      );

      print("========== IMAGE RESPONSE ==========");
      print("STATUS : ${response.statusCode}");
      print("BODY : ${response.body}");

      final Map<String, dynamic> data =
      jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data["success"] == true) {
        return data["url"];
      }

      throw Exception(
        data["message"] ?? "Image upload failed.",
      );
    } catch (e) {
      print("========== IMAGE UPLOAD ERROR ==========");
      print(e);
      rethrow;
    }
  }

  /// Profile
  static Future<String> uploadProfile(
      File image,
      ) {
    return uploadImage(
      image: image,
      folder: "profile",
    );
  }

  /// PAN
  static Future<String> uploadPan(
      File image,
      ) {
    return uploadImage(
      image: image,
      folder: "pan",
    );
  }

  /// Aadhaar Front
  static Future<String> uploadAadhaarFront(
      File image,
      ) {
    return uploadImage(
      image: image,
      folder: "aadhaar-front",
    );
  }

  /// Aadhaar Back
  static Future<String> uploadAadhaarBack(
      File image,
      ) {
    return uploadImage(
      image: image,
      folder: "aadhaar-back",
    );
  }

  /// Selfie
  static Future<String> uploadSelfie(
      File image,
      ) {
    return uploadImage(
      image: image,
      folder: "selfie",
    );
  }

  /// Signature
  static Future<String> uploadSignature(
      File image,
      ) {
    return uploadImage(
      image: image,
      folder: "signature",
    );
  }
}