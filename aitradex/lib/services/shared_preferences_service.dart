import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/signup_model.dart';

class SharedPreferencesService {
  SharedPreferencesService._();

  // ============================================================
  // STORAGE KEYS
  // ============================================================

  static const String _signupDataKey = 'signup_data';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _firebaseUidKey = 'firebase_uid';
  static const String _isFirstLaunchKey = 'is_first_launch';

  static const String _userNameKey = 'user_name';
  static const String _usernameKey = 'username';
  static const String _userEmailKey = 'user_email';
  static const String _userPhoneKey = 'user_phone';
  static const String _emailVerifiedKey = 'email_verified';
  static const String _phoneVerifiedKey = 'phone_verified';
  static const String _profileImageUrlKey = 'profile_image_url';
  static const String _authProviderKey = 'auth_provider';

  // MongoDB profile cache.
  static const String _mongoProfileKey = 'mongo_user_profile';

  static const String _apiBaseUrl =
      'https://aitradex-api.onrender.com/api';

  // ============================================================
  // SIGNUP DATA
  // ============================================================

  static Future<void> saveSignupData(
      SignupModel model,
      ) async {
    try {
      final SharedPreferences prefs =
      await SharedPreferences.getInstance();

      final Map<String, dynamic> data =
      Map<String, dynamic>.from(
        model.toJson(),
      );

      // Never store authentication secrets.
      data.remove('password');
      data.remove('confirmPassword');
      data.remove('otp');
      data.remove('verificationId');
      data.remove('accessToken');
      data.remove('idToken');
      data.remove('refreshToken');

      await prefs.setString(
        _signupDataKey,
        jsonEncode(data),
      );

      await saveUserProfile(
        name: model.fullName,
        username: model.username,
        email: model.email,
        phone: model.phone,
        emailVerified: model.emailVerified,
        phoneVerified: model.phoneVerified,
        profileImageUrl: model.profileImage,
      );
    } catch (error, stackTrace) {
      debugPrint('SAVE SIGNUP DATA ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  static Future<SignupModel?> getSignupData() async {
    try {
      final SharedPreferences prefs =
      await SharedPreferences.getInstance();

      final String? jsonData =
      prefs.getString(_signupDataKey);

      if (jsonData == null ||
          jsonData.trim().isEmpty) {
        return null;
      }

      final dynamic decoded =
      jsonDecode(jsonData);

      if (decoded is! Map) {
        return null;
      }

      return SignupModel.fromJson(
        Map<String, dynamic>.from(decoded),
      );
    } catch (error, stackTrace) {
      debugPrint('GET SIGNUP DATA ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);
      return null;
    }
  }

  static Future<bool> hasSignupData() async {
    try {
      final SharedPreferences prefs =
      await SharedPreferences.getInstance();

      final String? data =
      prefs.getString(_signupDataKey);

      return data != null &&
          data.trim().isNotEmpty;
    } catch (error, stackTrace) {
      debugPrint('HAS SIGNUP DATA ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }
  }

  static Future<void> updateSignupData(
      SignupModel model,
      ) async {
    await saveSignupData(model);
  }

  static Future<void> clearSignupData() async {
    try {
      final SharedPreferences prefs =
      await SharedPreferences.getInstance();

      await prefs.remove(_signupDataKey);
    } catch (error, stackTrace) {
      debugPrint('CLEAR SIGNUP DATA ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  // ============================================================
  // LOCAL USER PROFILE
  // ============================================================

  static Future<void> saveUserProfile({
    required String name,
    String username = '',
    required String email,
    String phone = '',
    bool emailVerified = false,
    bool phoneVerified = false,
    String profileImageUrl = '',
    String firebaseUid = '',
    String authProvider = '',
  }) async {
    try {
      final SharedPreferences prefs =
      await SharedPreferences.getInstance();

      await prefs.setString(
        _userNameKey,
        name.trim(),
      );

      await prefs.setString(
        _usernameKey,
        username.trim(),
      );

      await prefs.setString(
        _userEmailKey,
        email.trim().toLowerCase(),
      );

      await prefs.setString(
        _userPhoneKey,
        phone.trim(),
      );

      await prefs.setBool(
        _emailVerifiedKey,
        emailVerified,
      );

      await prefs.setBool(
        _phoneVerifiedKey,
        phoneVerified,
      );

      await prefs.setString(
        _profileImageUrlKey,
        profileImageUrl.trim(),
      );

      if (firebaseUid.trim().isNotEmpty) {
        await prefs.setString(
          _firebaseUidKey,
          firebaseUid.trim(),
        );
      }

      if (authProvider.trim().isNotEmpty) {
        await prefs.setString(
          _authProviderKey,
          authProvider.trim().toLowerCase(),
        );
      }
    } catch (error, stackTrace) {
      debugPrint('SAVE USER PROFILE ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  static Future<Map<String, dynamic>>
  getUserProfile() async {
    try {
      final SharedPreferences prefs =
      await SharedPreferences.getInstance();

      final String? cachedJson =
      prefs.getString(_mongoProfileKey);

      Map<String, dynamic> mongoProfile =
      <String, dynamic>{};

      if (cachedJson != null &&
          cachedJson.trim().isNotEmpty) {
        try {
          final dynamic decoded =
          jsonDecode(cachedJson);

          if (decoded is Map) {
            mongoProfile =
            Map<String, dynamic>.from(decoded);
          }
        } catch (_) {
          mongoProfile = <String, dynamic>{};
        }
      }

      return <String, dynamic>{
        ...mongoProfile,
        'firebaseUid':
        mongoProfile['firebaseUid'] ??
            prefs.getString(_firebaseUidKey) ??
            '',
        'fullName':
        mongoProfile['fullName'] ??
            prefs.getString(_userNameKey) ??
            '',
        'username':
        mongoProfile['username'] ??
            prefs.getString(_usernameKey) ??
            '',
        'email':
        mongoProfile['email'] ??
            prefs.getString(_userEmailKey) ??
            '',
        'phoneNumber':
        mongoProfile['phoneNumber'] ??
            prefs.getString(_userPhoneKey) ??
            '',
        'profileImage':
        mongoProfile['profileImage'] ??
            prefs.getString(_profileImageUrlKey) ??
            '',
        'emailVerified':
        mongoProfile['emailVerified'] ??
            prefs.getBool(_emailVerifiedKey) ??
            false,
        'phoneVerified':
        mongoProfile['phoneVerified'] ??
            prefs.getBool(_phoneVerifiedKey) ??
            false,
        'authProvider':
        mongoProfile['authProvider'] ??
            prefs.getString(_authProviderKey) ??
            '',
        'isActive':
        mongoProfile['isActive'] ?? true,
        'isBlocked':
        mongoProfile['isBlocked'] ?? false,
        'firebaseCreatedAt':
        mongoProfile['firebaseCreatedAt'] ?? '',
        'firebaseLastSignInAt':
        mongoProfile['firebaseLastSignInAt'] ?? '',
        'createdAt':
        mongoProfile['createdAt'] ?? '',
        'updatedAt':
        mongoProfile['updatedAt'] ?? '',
      };
    } catch (error, stackTrace) {
      debugPrint('GET USER PROFILE ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      return <String, dynamic>{
        'firebaseUid': '',
        'fullName': '',
        'username': '',
        'email': '',
        'phoneNumber': '',
        'profileImage': '',
        'emailVerified': false,
        'phoneVerified': false,
        'authProvider': '',
        'isActive': true,
        'isBlocked': false,
        'firebaseCreatedAt': '',
        'firebaseLastSignInAt': '',
        'createdAt': '',
        'updatedAt': '',
      };
    }
  }

  // ============================================================
  // FETCH CURRENT USER FROM FIREBASE + MONGODB
  // ============================================================

  static Future<Map<String, dynamic>>
  getCurrentUserProfile() async {
    final User? firebaseUser =
        FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      return getUserProfile();
    }

    /*
     * Firebase is the authentication source of truth.
     * MongoDB is the application profile source of truth.
     */
    final String uid = firebaseUser.uid;

    final String? idToken =
    await firebaseUser.getIdToken(true);

    if (idToken == null ||
        idToken.trim().isEmpty) {
      final Map<String, dynamic> fallback =
      await getUserProfile();

      return _mergeFirebaseUserIntoProfile(
        fallback,
        firebaseUser,
      );
    }

    try {
      final Uri url = Uri.parse(
        '$_apiBaseUrl/users/firebase/'
            '${Uri.encodeComponent(uid)}',
      );

      debugPrint('========================================');
      debugPrint('FETCH CURRENT AITRADEX USER');
      debugPrint('GET: $url');
      debugPrint('UID: $uid');
      debugPrint('========================================');

      final http.Response response =
      await http.get(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $idToken',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
      );

      debugPrint(
        'USER PROFILE STATUS: ${response.statusCode}',
      );

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        final dynamic decoded =
        jsonDecode(response.body);

        if (decoded is Map) {
          final Map<String, dynamic> body =
          Map<String, dynamic>.from(decoded);

          final dynamic rawUser =
          body['user'];

          if (rawUser is Map) {
            final Map<String, dynamic> user =
            Map<String, dynamic>.from(rawUser);

            user['firebaseUid'] =
                _stringValue(
                  user['firebaseUid'],
                  uid,
                );

            /*
             * For Google accounts the Firebase displayName
             * and photoURL are useful fallbacks.
             */
            user['fullName'] =
                _firstNonEmpty(
                  user['fullName'],
                  firebaseUser.displayName,
                );

            user['email'] =
                _firstNonEmpty(
                  user['email'],
                  firebaseUser.email,
                );

            user['profileImage'] =
                _firstNonEmpty(
                  user['profileImage'],
                  firebaseUser.photoURL,
                );

            user['emailVerified'] =
                user['emailVerified'] ??
                    firebaseUser.emailVerified;

            user['authProvider'] =
                _firstNonEmpty(
                  user['authProvider'],
                  _detectProvider(firebaseUser),
                );

            await saveMongoUserProfile(user);

            return user;
          }
        }
      }

      debugPrint(
        'MONGODB PROFILE REQUEST FAILED: '
            '${response.statusCode}',
      );
    } catch (error, stackTrace) {
      debugPrint(
        'GET CURRENT USER API ERROR: $error',
      );
      debugPrintStack(stackTrace: stackTrace);
    }

    /*
     * Backend unavailable -> use local profile and Firebase
     * Authentication data as a safe fallback.
     */
    final Map<String, dynamic> cached =
    await getUserProfile();

    final Map<String, dynamic> merged =
    _mergeFirebaseUserIntoProfile(
      cached,
      firebaseUser,
    );

    await saveMongoUserProfile(merged);

    return merged;
  }

  static Map<String, dynamic>
  _mergeFirebaseUserIntoProfile(
      Map<String, dynamic> profile,
      User user,
      ) {
    final Map<String, dynamic> merged =
    Map<String, dynamic>.from(profile);

    merged['firebaseUid'] =
        _firstNonEmpty(
          merged['firebaseUid'],
          user.uid,
        );

    merged['fullName'] =
        _firstNonEmpty(
          merged['fullName'],
          user.displayName,
        );

    merged['email'] =
        _firstNonEmpty(
          merged['email'],
          user.email,
        );

    merged['profileImage'] =
        _firstNonEmpty(
          merged['profileImage'],
          user.photoURL,
        );

    merged['emailVerified'] =
        merged['emailVerified'] ??
            user.emailVerified;

    merged['authProvider'] =
        _firstNonEmpty(
          merged['authProvider'],
          _detectProvider(user),
        );

    return merged;
  }

  static String _detectProvider(User user) {
    for (final UserInfo provider
    in user.providerData) {
      final String providerId =
      provider.providerId.toLowerCase();

      if (providerId == 'google.com') {
        return 'google';
      }

      if (providerId == 'password') {
        return 'password';
      }
    }

    return 'firebase';
  }

  static String _firstNonEmpty(
      dynamic first,
      dynamic second,
      ) {
    final String firstText =
        first?.toString().trim() ?? '';

    if (firstText.isNotEmpty) {
      return firstText;
    }

    return second?.toString().trim() ?? '';
  }

  static String _stringValue(
      dynamic value,
      String fallback,
      ) {
    final String text =
        value?.toString().trim() ?? '';

    return text.isEmpty ? fallback : text;
  }

  // ============================================================
  // SAVE MONGODB PROFILE TO LOCAL CACHE
  // ============================================================

  static Future<void> saveMongoUserProfile(
      Map<String, dynamic> user,
      ) async {
    try {
      final SharedPreferences prefs =
      await SharedPreferences.getInstance();

      await prefs.setString(
        _mongoProfileKey,
        jsonEncode(user),
      );

      final String uid =
      _stringValue(
        user['firebaseUid'],
        '',
      );

      final String name =
      _stringValue(
        user['fullName'],
        '',
      );

      final String username =
      _stringValue(
        user['username'],
        '',
      );

      final String email =
      _stringValue(
        user['email'],
        '',
      );

      final String phone =
      _stringValue(
        user['phoneNumber'],
        '',
      );

      final String image =
      _stringValue(
        user['profileImage'],
        '',
      );

      final bool emailVerified =
          user['emailVerified'] == true;

      final bool phoneVerified =
          user['phoneVerified'] == true;

      final String provider =
      _stringValue(
        user['authProvider'],
        '',
      );

      await saveUserProfile(
        name: name,
        username: username,
        email: email,
        phone: phone,
        emailVerified: emailVerified,
        phoneVerified: phoneVerified,
        profileImageUrl: image,
        firebaseUid: uid,
        authProvider: provider,
      );

      await setLoggedIn(true);

      debugPrint(
        'MONGODB PROFILE CACHED LOCALLY.',
      );
    } catch (error, stackTrace) {
      debugPrint(
        'SAVE MONGODB PROFILE ERROR: $error',
      );
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  // ============================================================
  // INDIVIDUAL PROFILE HELPERS
  // ============================================================

  static Future<void> saveUserName(
      String name,
      ) async {
    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    await prefs.setString(
      _userNameKey,
      name.trim(),
    );
  }

  static Future<String?> getUserName() async {
    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    return prefs.getString(_userNameKey);
  }

  static Future<void> saveUsername(
      String username,
      ) async {
    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    await prefs.setString(
      _usernameKey,
      username.trim(),
    );
  }

  static Future<String?> getUsername() async {
    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    return prefs.getString(_usernameKey);
  }

  static Future<void> saveUserEmail(
      String email,
      ) async {
    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    await prefs.setString(
      _userEmailKey,
      email.trim().toLowerCase(),
    );
  }

  static Future<String?> getUserEmail() async {
    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    return prefs.getString(_userEmailKey);
  }

  static Future<void> saveUserPhone(
      String phone,
      ) async {
    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    await prefs.setString(
      _userPhoneKey,
      phone.trim(),
    );
  }

  static Future<String?> getUserPhone() async {
    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    return prefs.getString(_userPhoneKey);
  }

  static Future<void> saveEmailVerified(
      bool value,
      ) async {
    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    await prefs.setBool(
      _emailVerifiedKey,
      value,
    );
  }

  static Future<bool> isEmailVerified() async {
    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    return prefs.getBool(
      _emailVerifiedKey,
    ) ??
        false;
  }

  static Future<void> savePhoneVerified(
      bool value,
      ) async {
    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    await prefs.setBool(
      _phoneVerifiedKey,
      value,
    );
  }

  static Future<bool> isPhoneVerified() async {
    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    return prefs.getBool(
      _phoneVerifiedKey,
    ) ??
        false;
  }

  static Future<void> saveProfileImageUrl(
      String url,
      ) async {
    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    await prefs.setString(
      _profileImageUrlKey,
      url.trim(),
    );
  }

  static Future<String?> getProfileImageUrl() async {
    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    return prefs.getString(
      _profileImageUrlKey,
    );
  }

  // ============================================================
  // FIREBASE UID
  // ============================================================

  static Future<void> saveFirebaseUid(
      String firebaseUid,
      ) async {
    final String value =
    firebaseUid.trim();

    if (value.isEmpty) {
      return;
    }

    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    await prefs.setString(
      _firebaseUidKey,
      value,
    );
  }

  static Future<String?> getFirebaseUid() async {
    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    return prefs.getString(
      _firebaseUidKey,
    );
  }

  static Future<void> saveUserId(
      String id,
      ) async {
    await saveFirebaseUid(id);
  }

  static Future<String?> getUserId() async {
    return getFirebaseUid();
  }

  // ============================================================
  // LOGIN STATE
  // ============================================================

  static Future<void> setLoggedIn(
      bool value,
      ) async {
    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    await prefs.setBool(
      _isLoggedInKey,
      value,
    );
  }

  static Future<bool> isLoggedIn() async {
    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    return prefs.getBool(
      _isLoggedInKey,
    ) ??
        false;
  }

  static Future<void> login({
    required String userId,
    String name = '',
    String username = '',
    String email = '',
    String phone = '',
    bool emailVerified = false,
    bool phoneVerified = false,
    String profileImageUrl = '',
    String authProvider = '',
  }) async {
    try {
      await setLoggedIn(true);

      await saveUserProfile(
        name: name,
        username: username,
        email: email,
        phone: phone,
        emailVerified: emailVerified,
        phoneVerified: phoneVerified,
        profileImageUrl: profileImageUrl,
        firebaseUid: userId,
        authProvider: authProvider,
      );

      final SharedPreferences prefs =
      await SharedPreferences.getInstance();

      await prefs.setBool(
        _isFirstLaunchKey,
        false,
      );
    } catch (error, stackTrace) {
      debugPrint('LOGIN STORAGE ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  // ============================================================
  // FIREBASE ACCOUNT VALIDATION
  // ============================================================

  static Future<bool>
  validateFirebaseAccount() async {
    try {
      final FirebaseAuth auth =
          FirebaseAuth.instance;

      User? user = auth.currentUser;

      if (user == null) {
        await clearAuthenticatedUserData();
        return false;
      }

      try {
        await user.reload();
      } on FirebaseAuthException catch (error) {
        debugPrint(
          'FIREBASE ACCOUNT RELOAD ERROR: '
              '${error.code} - ${error.message}',
        );

        if (error.code == 'user-not-found' ||
            error.code == 'user-disabled') {
          await auth.signOut();
          await clearAuthenticatedUserData();
          return false;
        }

        return true;
      }

      user = auth.currentUser;

      if (user == null) {
        await clearAuthenticatedUserData();
        return false;
      }

      await saveFirebaseUid(user.uid);
      await setLoggedIn(true);

      return true;
    } catch (error, stackTrace) {
      debugPrint(
        'VALIDATE FIREBASE ACCOUNT ERROR: $error',
      );
      debugPrintStack(stackTrace: stackTrace);

      return true;
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  static Future<void> logout() async {
    try {
      try {
        await FirebaseAuth.instance.signOut();
      } catch (firebaseError) {
        debugPrint(
          'FIREBASE SIGN OUT ERROR: $firebaseError',
        );
      }

      await clearAuthenticatedUserData();

      debugPrint('LOGOUT COMPLETE.');
    } catch (error, stackTrace) {
      debugPrint('LOGOUT ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  // ============================================================
  // CLEAR AUTHENTICATED DATA
  // ============================================================

  static Future<void>
  clearAuthenticatedUserData() async {
    try {
      final SharedPreferences prefs =
      await SharedPreferences.getInstance();

      const List<String> keys = <String>[
        _isLoggedInKey,
        _firebaseUidKey,
        _userNameKey,
        _usernameKey,
        _userEmailKey,
        _userPhoneKey,
        _emailVerifiedKey,
        _phoneVerifiedKey,
        _profileImageUrlKey,
        _authProviderKey,
        _signupDataKey,
        _mongoProfileKey,
      ];

      for (final String key in keys) {
        await prefs.remove(key);
      }

      debugPrint(
        'AUTHENTICATED USER DATA CLEARED.',
      );
    } catch (error, stackTrace) {
      debugPrint(
        'CLEAR AUTH USER DATA ERROR: $error',
      );
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  // ============================================================
  // FIRST LAUNCH
  // ============================================================

  static Future<bool> isFirstLaunch() async {
    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    return prefs.getBool(
      _isFirstLaunchKey,
    ) ??
        true;
  }

  static Future<void>
  setFirstLaunchCompleted() async {
    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    await prefs.setBool(
      _isFirstLaunchKey,
      false,
    );
  }

  // ============================================================
  // CLEAR EVERYTHING
  // ============================================================

  static Future<void> clearAll() async {
    try {
      final SharedPreferences prefs =
      await SharedPreferences.getInstance();

      await prefs.clear();

      debugPrint(
        'ALL SHARED PREFERENCES CLEARED.',
      );
    } catch (error, stackTrace) {
      debugPrint('CLEAR ALL ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  // ============================================================
// GENERIC STRING PREFERENCE
// ============================================================

  static Future<void> saveString(
      String key,
      String value,
      ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(
        key,
        value,
      );
    } catch (error, stackTrace) {
      debugPrint(
        'SAVE STRING ERROR [$key]: $error',
      );

      debugPrint(
        stackTrace.toString(),
      );
    }
  }

  static Future<String?> getString(
      String key,
      ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      return prefs.getString(key);
    } catch (error, stackTrace) {
      debugPrint(
        'GET STRING ERROR [$key]: $error',
      );

      debugPrint(
        stackTrace.toString(),
      );

      return null;
    }
  }

// ============================================================
// GENERIC BOOLEAN PREFERENCE
// ============================================================

  static Future<void> saveBool(
      String key,
      bool value,
      ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool(
        key,
        value,
      );
    } catch (error, stackTrace) {
      debugPrint(
        'SAVE BOOL ERROR [$key]: $error',
      );

      debugPrint(
        stackTrace.toString(),
      );
    }
  }

  static Future<bool?> getBool(
      String key,
      ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      return prefs.getBool(key);
    } catch (error, stackTrace) {
      debugPrint(
        'GET BOOL ERROR [$key]: $error',
      );

      debugPrint(
        stackTrace.toString(),
      );

      return null;
    }
  }
}
