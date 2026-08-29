import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/signup_model.dart';

class SharedPreferencesService {
  SharedPreferencesService._();

  static const String _signupKey = "signup_data";
  static const String _isLoggedInKey = "is_logged_in";
  static const String _userIdKey = "user_id";
  static const String _authTokenKey = "auth_token";
  static const String _isFirstLaunchKey = "is_first_launch";

  // ==========================================================
  // Signup Draft
  // ==========================================================

  static Future<void> saveSignupData(SignupModel model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_signupKey, jsonEncode(model.toJson()));
  }

  static Future<SignupModel?> getSignupData() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString(_signupKey);

    if (data == null || data.isEmpty) return null;

    return SignupModel.fromJson(jsonDecode(data));
  }

  static Future<bool> hasSignupData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_signupKey);
  }

  static Future<void> clearSignupData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_signupKey);
  }

  // ==========================================================
  // First Launch
  // ==========================================================

  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(_isFirstLaunchKey) ?? true;
  }

  static Future<void> setFirstLaunchCompleted() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_isFirstLaunchKey, false);
  }

  // ==========================================================
  // Login
  // ==========================================================

  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, value);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  static Future<void> login({
    required String userId,
    required String token,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_authTokenKey, token);
    await prefs.setBool(_isFirstLaunchKey, false);
  }

  // ==========================================================
  // User
  // ==========================================================

  static Future<void> saveUserId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, id);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  // ==========================================================
  // JWT
  // ==========================================================

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  // ==========================================================
  // Logout
  // ==========================================================

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_authTokenKey);

    // Optional:
    // await prefs.remove(_signupKey);
  }

  // ==========================================================
  // Clear All
  // ==========================================================

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}