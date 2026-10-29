import 'dart:convert';

class SignupModel {
  // ============================================================
  // BASIC INFORMATION
  // ============================================================

  String fullName;
  String email;
  String phone;
  String username;

  // ============================================================
  // PHONE / COUNTRY
  // ============================================================

  String countryCode;

  // ============================================================
  // PROFILE
  // ============================================================

  String profileImage;

  // ============================================================
  // REFERRAL
  // ============================================================

  String referralCode;
  String referredBy;

  // ============================================================
  // VERIFICATION STATUS
  // ============================================================

  bool emailVerified;
  bool phoneVerified;

  // ============================================================
  // CONSTRUCTOR
  // ============================================================

  SignupModel({
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.username = '',
    this.countryCode = '+91',
    this.profileImage = '',
    this.referralCode = '',
    this.referredBy = '',
    this.emailVerified = false,
    this.phoneVerified = false,
  });

  // ============================================================
  // COPY WITH
  // ============================================================

  SignupModel copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? username,
    String? countryCode,
    String? profileImage,
    String? referralCode,
    String? referredBy,
    bool? emailVerified,
    bool? phoneVerified,
  }) {
    return SignupModel(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      username: username ?? this.username,
      countryCode: countryCode ?? this.countryCode,
      profileImage: profileImage ?? this.profileImage,
      referralCode: referralCode ?? this.referralCode,
      referredBy: referredBy ?? this.referredBy,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneVerified: phoneVerified ?? this.phoneVerified,
    );
  }

  // ============================================================
  // TO MAP
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName.trim(),
      'email': email.trim().toLowerCase(),
      'phone': phone.trim(),
      'username': username.trim().toLowerCase(),
      'countryCode': countryCode.trim(),
      'profileImage': profileImage.trim(),
      'referralCode': referralCode.trim().toUpperCase(),
      'referredBy': referredBy.trim(),
      'emailVerified': emailVerified,
      'phoneVerified': phoneVerified,
    };
  }

  // ============================================================
  // FROM MAP
  // ============================================================

  factory SignupModel.fromMap(Map<String, dynamic> map) {
    return SignupModel(
      fullName: map['fullName']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      username: map['username']?.toString() ?? '',
      countryCode: map['countryCode']?.toString() ?? '+91',
      profileImage: map['profileImage']?.toString() ?? '',
      referralCode: map['referralCode']?.toString() ?? '',
      referredBy: map['referredBy']?.toString() ?? '',
      emailVerified: _parseBool(map['emailVerified']),
      phoneVerified: _parseBool(map['phoneVerified']),
    );
  }

  // ============================================================
  // TO JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return toMap();
  }

  // ============================================================
  // FROM JSON
  // ============================================================

  factory SignupModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return SignupModel.fromMap(json);
  }

  // ============================================================
  // JSON STRING
  // ============================================================

  String toJsonString() {
    return jsonEncode(toJson());
  }

  factory SignupModel.fromJsonString(
      String value,
      ) {
    if (value.trim().isEmpty) {
      throw const FormatException(
        'SignupModel JSON cannot be empty.',
      );
    }

    final dynamic decoded;

    try {
      decoded = jsonDecode(value);
    } catch (_) {
      throw const FormatException(
        'Invalid SignupModel JSON.',
      );
    }

    if (decoded is! Map) {
      throw const FormatException(
        'Invalid SignupModel JSON.',
      );
    }

    return SignupModel.fromJson(
      Map<String, dynamic>.from(decoded),
    );
  }

  // ============================================================
  // VALIDATION
  // ============================================================

  bool get hasName {
    return fullName.trim().isNotEmpty;
  }

  bool get hasEmail {
    return email.trim().isNotEmpty;
  }

  bool get hasPhone {
    return phone.trim().isNotEmpty;
  }

  bool get hasUsername {
    return username.trim().isNotEmpty;
  }

  bool get hasProfileImage {
    return profileImage.trim().isNotEmpty;
  }

  bool get hasReferralCode {
    return referralCode.trim().isNotEmpty;
  }

  bool get isEmailVerified {
    return emailVerified;
  }

  bool get isPhoneVerified {
    return phoneVerified;
  }

  // ============================================================
  // REQUIRED ACCOUNT COMPLETION
  // ============================================================

  bool get isComplete {
    return hasName &&
        hasEmail &&
        hasPhone &&
        hasUsername &&
        emailVerified &&
        phoneVerified;
  }

  // ============================================================
  // REFERRAL CODE NORMALIZATION
  // ============================================================

  void normalizeReferralCode() {
    referralCode = referralCode.trim().toUpperCase();
  }

  // ============================================================
  // USERNAME NORMALIZATION
  // ============================================================

  void normalizeUsername() {
    username = username.trim().toLowerCase();
  }

  // ============================================================
  // EMAIL NORMALIZATION
  // ============================================================

  void normalizeEmail() {
    email = email.trim().toLowerCase();
  }

  // ============================================================
  // NORMALIZE MODEL
  // ============================================================

  void normalize() {
    fullName = fullName.trim();
    email = email.trim().toLowerCase();
    phone = phone.trim();
    username = username.trim().toLowerCase();
    countryCode = countryCode.trim();
    profileImage = profileImage.trim();
    referralCode = referralCode.trim().toUpperCase();
    referredBy = referredBy.trim();
  }

  // ============================================================
  // COPY NORMALIZED MODEL
  // ============================================================

  SignupModel normalizedCopy() {
    return copyWith(
      fullName: fullName.trim(),
      email: email.trim().toLowerCase(),
      phone: phone.trim(),
      username: username.trim().toLowerCase(),
      countryCode: countryCode.trim(),
      profileImage: profileImage.trim(),
      referralCode: referralCode.trim().toUpperCase(),
      referredBy: referredBy.trim(),
      emailVerified: emailVerified,
      phoneVerified: phoneVerified,
    );
  }

  // ============================================================
  // CLEAR SENSITIVE / TEMPORARY DATA
  // ============================================================

  void clearReferralData() {
    referralCode = '';
    referredBy = '';
  }

  // ============================================================
  // BOOLEAN PARSER
  // ============================================================

  static bool _parseBool(
      dynamic value,
      ) {
    if (value is bool) {
      return value;
    }

    if (value is String) {
      final String normalized = value.trim().toLowerCase();

      if (normalized == 'true' ||
          normalized == '1' ||
          normalized == 'yes') {
        return true;
      }

      if (normalized == 'false' ||
          normalized == '0' ||
          normalized == 'no') {
        return false;
      }
    }

    if (value is num) {
      return value != 0;
    }

    return false;
  }

  // ============================================================
  // DEBUG
  // ============================================================

  @override
  String toString() {
    return 'SignupModel('
        'fullName: $fullName, '
        'email: $email, '
        'phone: $phone, '
        'username: $username, '
        'countryCode: $countryCode, '
        'profileImage: $profileImage, '
        'referralCode: $referralCode, '
        'referredBy: $referredBy, '
        'emailVerified: $emailVerified, '
        'phoneVerified: $phoneVerified'
        ')';
  }
}