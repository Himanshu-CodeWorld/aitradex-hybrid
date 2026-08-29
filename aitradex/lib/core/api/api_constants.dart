class ApiConstants {
  static const String baseUrl = "https://aitradex-api.onrender.com/api";

  // Auth
  static const String signup = "$baseUrl/auth/signup";
  static const String login = "$baseUrl/auth/login";
  static const String profile = "$baseUrl/auth/profile";

  static const String sendPhoneOtp = "$baseUrl/auth/send-phone-otp";
  static const String verifyPhoneOtp = "$baseUrl/auth/verify-phone-otp";
  static const String resendPhoneOtp = "$baseUrl/auth/resend-phone-otp";

  // User
  static const String dashboard = "$baseUrl/user/dashboard";
  static const String getProfile = "$baseUrl/user/profile";
  static const String updateProfile = "$baseUrl/user/profile";

  static const String uploadImage = "$baseUrl/upload/image";

  static const String updateKyc = "$baseUrl/user/kyc";
  static const String uploadPan = "$baseUrl/user/upload-pan";
  static const String uploadAadhaar = "$baseUrl/user/upload-aadhaar";
  static const String uploadSelfie = "$baseUrl/user/upload-selfie";
  static const String uploadSignature = "$baseUrl/user/upload-signature";

  static const String updateBank = "$baseUrl/user/bank";
  static const String updateNominee = "$baseUrl/user/nominee";

  static const String changeMpin = "$baseUrl/user/change-mpin";
  static const String deleteAccount = "$baseUrl/user/delete";
}