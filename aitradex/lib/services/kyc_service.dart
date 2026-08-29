import 'dart:io';

import 'package:dio/dio.dart';

import '../models/kyc_response.dart';

class KycService {
  static const String baseUrl = "https://aitradex-api.onrender.com/api";

  final Dio dio = Dio();

  Future<KycResponse> verifyDocument({
    required File image,
    required String type,
  }) async {
    try {
      final formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(
          image.path,
          filename: image.path.split("/").last,
        ),
        "type": type,
      });

      final response = await dio.post(
        "$baseUrl/kyc/verify-document",
        data: formData,
      );

      return KycResponse.fromJson(response.data);
    } catch (e) {
      return const KycResponse(
        success: false,
        message: "Unable to verify document.",
      );
    }
  }
}