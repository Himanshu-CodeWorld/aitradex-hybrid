class SignupModel {
  // ==========================================================
  // Personal Details
  // ==========================================================

  String fullName;
  String email = "";
  String phone = "";
  String countryCode = "";
  String profileImage;
  String gender;
  String dob;
  String birthPlace;

  // ==========================================================
  // Investment
  // ==========================================================

  String investmentGoal;
  String investmentExperience;

  // ==========================================================
  // Employment
  // ==========================================================

  String occupation;
  String monthlyIncome;
  String companyName;
  String jobTitle;

  // ==========================================================
  // KYC
  // ==========================================================

  String panNumber;
  String panImageUrl;

  String aadhaarNumber;
  String aadhaarFrontUrl;
  String aadhaarBackUrl;

  String selfieUrl;

  // ==========================================================
  // Address
  // ==========================================================

  String address;
  String city;
  String state;
  String pincode;

  // ==========================================================
  // Bank
  // ==========================================================

  String bankName;
  String accountHolderName;
  String accountNumber;
  String ifscCode;
  String accountType;

  // ==========================================================
  // Nominee
  // ==========================================================

  String nomineeName;
  String nomineeDob;
  String nomineeRelation;

  // ==========================================================
  // Digital Signature
  // ==========================================================

  String signatureUrl;

  // ==========================================================
  // Security
  // ==========================================================

  String mpin;

  // ==========================================================
  // Verification
  // ==========================================================

  bool emailVerified;
  bool phoneVerified;
  bool kycVerified;

  // ==========================================================
  // Account
  // ==========================================================

  String accountStatus;

  // ==========================================================
  // Device
  // ==========================================================

  String fcmToken;
  String deviceType;

  // ==========================================================
  // Referral
  // ==========================================================

  String referralCode;
  String? referredBy;

  SignupModel({
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.countryCode = '+91',
    this.profileImage = '',
    this.gender = '',
    this.dob = '',
    this.birthPlace = '',
    this.investmentGoal = '',
    this.investmentExperience = '',
    this.occupation = '',
    this.monthlyIncome = '',
    this.companyName = '',
    this.jobTitle = '',
    this.panNumber = '',
    this.panImageUrl = '',
    this.aadhaarNumber = '',
    this.aadhaarFrontUrl = '',
    this.aadhaarBackUrl = '',
    this.selfieUrl = '',
    this.address = '',
    this.city = '',
    this.state = '',
    this.pincode = '',
    this.bankName = '',
    this.accountHolderName = '',
    this.accountNumber = '',

    this.ifscCode = '',
    this.accountType = "Savings",
    this.nomineeName = '',
    this.nomineeDob = '',
    this.nomineeRelation = '',
    this.signatureUrl = '',
    this.mpin = '',

    this.emailVerified = false,
    this.phoneVerified = false,
    this.kycVerified = false,

    this.accountStatus = "Pending",

    this.fcmToken = "",
    this.deviceType = "",

    this.referralCode = "",
    this.referredBy,
  });

  // ==========================================================
  // TO JSON
  // ==========================================================

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'phone' : phone,
      'countryCode' : countryCode,
      "profileImage": profileImage,
      'gender': gender,
      'dob': dob,
      'birthPlace': birthPlace,

      'investmentGoal': investmentGoal,
      'investmentExperience': investmentExperience,

      'occupation': occupation,
      'monthlyIncome': monthlyIncome,
      'companyName': companyName,
      'jobTitle': jobTitle,

      'panNumber': panNumber,
      'panImageUrl': panImageUrl,

      'aadhaarNumber': aadhaarNumber,
      'aadhaarFrontUrl': aadhaarFrontUrl,
      'aadhaarBackUrl': aadhaarBackUrl,

      'selfieUrl': selfieUrl,

      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,

      'bankName': bankName,
      'accountHolderName': accountHolderName,
      'accountNumber': accountNumber,
      'ifscCode': ifscCode,
      "accountType": accountType,

      'nomineeName': nomineeName,
      'nomineeDob': nomineeDob,
      'nomineeRelation': nomineeRelation,

      'signatureUrl': signatureUrl,

      'mpin': mpin,

      'emailVerified': emailVerified,
      'phoneVerified': phoneVerified,
      'kycVerified': kycVerified,

      'accountStatus': accountStatus,

      'fcmToken': fcmToken,
      'deviceType': deviceType,

      'referralCode': referralCode,
      'referredBy': referredBy,
    };
  }

  // ==========================================================
  // FROM JSON
  // ==========================================================

  factory SignupModel.fromJson(Map<String, dynamic> json) {
    return SignupModel(
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      countryCode: json["countryCode"] ?? "+91",
      profileImage: json["profileImage"] ?? '',
      gender: json['gender'] ?? '',
      dob: json['dob'] ?? '',
      birthPlace: json['birthPlace'] ?? '',

      investmentGoal: json['investmentGoal'] ?? '',
      investmentExperience: json['investmentExperience'] ?? '',

      occupation: json['occupation'] ?? '',
      monthlyIncome: json['monthlyIncome'] ?? '',
      companyName: json['companyName'] ?? '',
      jobTitle: json['jobTitle'] ?? '',

      panNumber: json['panNumber'] ?? '',
      panImageUrl: json['panImageUrl'] ?? '',

      aadhaarNumber: json['aadhaarNumber'] ?? '',
      aadhaarFrontUrl: json['aadhaarFrontUrl'] ?? '',
      aadhaarBackUrl: json['aadhaarBackUrl'] ?? '',

      selfieUrl: json['selfieUrl'] ?? '',

      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? '',

      bankName: json['bankName'] ?? '',
      accountHolderName: json['accountHolderName'] ?? '',
      accountNumber: json['accountNumber'] ?? '',

      ifscCode: json['ifscCode'] ?? '',
      accountType: json["accountType"] ?? "Savings",

      nomineeName: json['nomineeName'] ?? '',
      nomineeDob: json['nomineeDob'] ?? '',
      nomineeRelation: json['nomineeRelation'] ?? '',


      signatureUrl: json['signatureUrl'] ?? '',

      mpin: json['mpin'] ?? '',

      emailVerified: json['emailVerified'] ?? false,
      phoneVerified: json['phoneVerified'] ?? false,
      kycVerified: json['kycVerified'] ?? false,

      accountStatus: json['accountStatus'] ?? "Pending",

      fcmToken: json['fcmToken'] ?? "",
      deviceType: json['deviceType'] ?? "",

      referralCode: json['referralCode'] ?? "",
      referredBy: json['referredBy'],
    );
  }

  // ==========================================================
  // COPY WITH
  // ==========================================================

  SignupModel copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? countryCode,
    String? profileImage,
    String? gender,
    String? dob,
    String? birthPlace,
    String? investmentGoal,
    String? investmentExperience,
    String? occupation,
    String? monthlyIncome,
    String? companyName,
    String? jobTitle,
    String? panNumber,
    String? panImageUrl,
    String? aadhaarNumber,
    String? aadhaarFrontUrl,
    String? aadhaarBackUrl,
    String? selfieUrl,
    String? address,
    String? city,
    String? state,
    String? pincode,
    String? bankName,
    String? accountHolderName,
    String? accountNumber,
    String? ifscCode,
    String? accountType,
    String? nomineeName,
    String? nomineeDob,
    String? nomineeRelation,
    String? signatureUrl,
    String? mpin,

    bool? emailVerified,
    bool? phoneVerified,
    bool? kycVerified,

    String? accountStatus,

    String? fcmToken,
    String? deviceType,

    String? referralCode,
    String? referredBy,
  }) {
    return SignupModel(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      countryCode: countryCode ?? this.countryCode,
      profileImage: profileImage ?? this.profileImage,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      birthPlace: birthPlace ?? this.birthPlace,
      investmentGoal: investmentGoal ?? this.investmentGoal,
      investmentExperience:
      investmentExperience ?? this.investmentExperience,
      occupation: occupation ?? this.occupation,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      companyName: companyName ?? this.companyName,
      jobTitle: jobTitle ?? this.jobTitle,
      panNumber: panNumber ?? this.panNumber,
      panImageUrl: panImageUrl ?? this.panImageUrl,
      aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
      aadhaarFrontUrl:
      aadhaarFrontUrl ?? this.aadhaarFrontUrl,
      aadhaarBackUrl:
      aadhaarBackUrl ?? this.aadhaarBackUrl,
      selfieUrl: selfieUrl ?? this.selfieUrl,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      bankName: bankName ?? this.bankName,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      accountNumber: accountNumber ?? this.accountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      accountType: accountType ?? this.accountType,
      nomineeName: nomineeName ?? this.nomineeName,
      nomineeDob: nomineeDob ?? this.nomineeDob,
      nomineeRelation: nomineeRelation ?? this.nomineeRelation,
      signatureUrl: signatureUrl ?? this.signatureUrl,
      mpin: mpin ?? this.mpin,

      emailVerified: emailVerified ?? this.emailVerified,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      kycVerified: kycVerified ?? this.kycVerified,

      accountStatus: accountStatus ?? this.accountStatus,

      fcmToken: fcmToken ?? this.fcmToken,
      deviceType: deviceType ?? this.deviceType,

      referralCode: referralCode ?? this.referralCode,
      referredBy: referredBy ?? this.referredBy,

    );
  }
}