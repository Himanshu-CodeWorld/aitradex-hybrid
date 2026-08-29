class KycResponse {
  final bool success;
  final String message;
  final String? documentType;

  const KycResponse({
    required this.success,
    required this.message,
    this.documentType,
  });

  factory KycResponse.fromJson(Map<String, dynamic> json) {
    return KycResponse(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      documentType: json["documentType"],
    );
  }
}