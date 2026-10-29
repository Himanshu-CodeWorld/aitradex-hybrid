import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

/// Google + Firebase authentication for AiTradeX.
///
/// Keep all Google/Firebase authentication logic in this service. The GetX
/// controller should call this class rather than initializing Google Sign-In
/// a second time.
class GoogleAuthService {
  GoogleAuthService._();

  static final GoogleAuthService instance = GoogleAuthService._();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  static const String _baseUrl =
      'https://aitradex-api.onrender.com/api';

  // This must be the Web application OAuth client ID from the same Google
  // Cloud/Firebase project as the Android app. Do not use the Android client ID.
  static const String _serverClientId =
      '418085831140-vljcc8v8pnbe5ohgo5v2gvq4u0g55s0c.apps.googleusercontent.com';

  bool _initialized = false;
  Future<void>? _initializationFuture;

  Future<void> initialize() async {
    if (_initialized) return;

    // Share one in-flight initialization if calls happen close together.
    final Future<void>? pending = _initializationFuture;
    if (pending != null) {
      await pending;
      return;
    }

    final Future<void> initialization = _googleSignIn.initialize(
      serverClientId: _serverClientId,
    );
    _initializationFuture = initialization;

    try {
      await initialization;
      _initialized = true;
      debugPrint('[GoogleAuth] Google Sign-In initialized.');
    } catch (_) {
      // Allow a later attempt to retry initialization after a transient error.
      _initializationFuture = null;
      rethrow;
    }
  }

  /// Signs in through Google, signs the user into Firebase, and synchronizes
  /// the verified Firebase identity with the AiTradeX backend.
  ///
  /// Throws an exception with a user-readable message when any required step
  /// fails. Firebase may already have authenticated the user if backend sync
  /// fails; the logs make that distinction visible.
  Future<User> signInWithGoogle() async {
    await initialize();

    if (!_googleSignIn.supportsAuthenticate()) {
      throw Exception(
        'Google sign-in is not supported on this platform. '
            'Use the Android app or implement the platform-specific sign-in flow.',
      );
    }

    try {
      debugPrint('[GoogleAuth] Opening Google account picker...');
      final GoogleSignInAccount googleUser =
      await _authenticateGoogleAccountWithRecovery();

      final String? googleIdToken = googleUser.authentication.idToken;
      if (googleIdToken == null || googleIdToken.isEmpty) {
        throw Exception(
          'Google did not return an ID token. Check the Web OAuth client ID, '
              'Android SHA fingerprints, package name, and google-services.json.',
        );
      }

      debugPrint('[GoogleAuth] Google token received; signing into Firebase...');
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleIdToken,
      );

      final UserCredential userCredential =
      await _firebaseAuth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) {
        throw Exception('Firebase authentication returned no user.');
      }

      debugPrint(
        '[GoogleAuth] Firebase sign-in succeeded for ${user.email ?? user.uid}.',
      );

      final String? firebaseIdToken = await user.getIdToken(true);
      if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
        throw Exception('Firebase did not return an ID token.');
      }

      // Firebase is the source of truth for authentication. Backend profile
      // synchronization is best-effort: a sleeping/unavailable Render service
      // must not turn a successful Firebase login into a failed login.
      try {
        await _syncUserWithBackend(
          user: user,
          firebaseIdToken: firebaseIdToken,
        );
        debugPrint('[GoogleAuth] Backend profile sync succeeded.');
      } on TimeoutException catch (error, stackTrace) {
        debugPrint(
          '[GoogleAuth] WARNING: Firebase login succeeded, but backend sync '
              'timed out. The user will still be signed in. Details: $error',
        );
        debugPrintStack(stackTrace: stackTrace);
      } catch (error, stackTrace) {
        debugPrint(
          '[GoogleAuth] WARNING: Firebase login succeeded, but backend sync '
              'failed. The user will still be signed in. Details: $error',
        );
        debugPrintStack(stackTrace: stackTrace);
      }

      return user;
    } on GoogleSignInException catch (error, stackTrace) {
      debugPrint(
        '[GoogleAuth] Google error: code=${error.code}, '
            'description=${error.description}',
      );
      debugPrintStack(stackTrace: stackTrace);

      if (error.code == GoogleSignInExceptionCode.canceled) {
        final String details = (error.description ?? '').toLowerCase();

        if (details.contains('account reauth failed')) {
          throw Exception(
            'Google could not re-authenticate this account ([16] Account reauth failed). '
                'Check that Firebase Google sign-in is enabled, the Android package name '
                'matches com.example.aitradex, the SHA-1 and SHA-256 fingerprints for '
                'this build are registered in Firebase, and google-services.json is '
                'from the same Firebase project and contains the Web OAuth client ID. '
                'Then rebuild and reinstall the app. This error happens before Firebase login.',
          );
        }

        throw Exception(
          'Google sign-in was cancelled or the Google credential could not be used. '
              'If this happens immediately after selecting an account, verify the Android '
              'SHA fingerprints and Web OAuth client ID in Firebase.',
        );
      }
      throw Exception(
        error.description ??
            'Google sign-in failed. Check the Google OAuth configuration.',
      );
    } on FirebaseAuthException catch (error, stackTrace) {
      debugPrint(
        '[GoogleAuth] Firebase error: ${error.code} - ${error.message}',
      );
      debugPrintStack(stackTrace: stackTrace);
      throw Exception(_firebaseErrorMessage(error));
    } on TimeoutException catch (error, stackTrace) {
      debugPrint('[GoogleAuth] Request timed out: $error');
      debugPrintStack(stackTrace: stackTrace);
      throw Exception(
        'The AiTradeX server timed out. Check your internet connection and try again.',
      );
    } catch (error, stackTrace) {
      debugPrint('[GoogleAuth] Sign-in flow failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Recover once from a stale Google account re-auth session.
  ///
  /// Credential Manager may report "[16] Account reauth failed" as cancellation.
  /// Clearing the Google session and retrying once can recover stale state.
  /// If it still fails, check the Firebase/OAuth configuration.
  Future<GoogleSignInAccount> _authenticateGoogleAccountWithRecovery() async {
    try {
      return await _googleSignIn.authenticate();
    } on GoogleSignInException catch (error) {
      final String description = (error.description ?? '').toLowerCase();
      final bool isReauthFailure =
          error.code == GoogleSignInExceptionCode.canceled &&
              description.contains('account reauth failed');

      if (!isReauthFailure) rethrow;

      debugPrint(
        '[GoogleAuth] Account re-auth failed. Clearing Google session and retrying once.',
      );

      try {
        await _googleSignIn.signOut();
      } catch (signOutError) {
        debugPrint('[GoogleAuth] Recovery sign-out warning: $signOutError');
      }

      // Retry only once to avoid an infinite loop if OAuth is misconfigured.
      return await _googleSignIn.authenticate();
    }
  }

  Future<void> _syncUserWithBackend({
    required User user,
    required String firebaseIdToken,
  }) async {
    final Uri url = Uri.parse('$_baseUrl/auth/google');

    debugPrint('[GoogleAuth] Starting backend profile sync: POST $url');

    final http.Response response = await http
        .post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $firebaseIdToken',
      },
      body: jsonEncode(<String, dynamic>{
        'firebaseUid': user.uid,
        'fullName': user.displayName ?? '',
        'email': user.email ?? '',
        'photoURL': user.photoURL ?? '',
        'provider': 'google.com',
      }),
    )
        .timeout(const Duration(seconds: 15));

    debugPrint(
      '[GoogleAuth] Backend response: HTTP ${response.statusCode} '
          '(${response.request?.url ?? url})',
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final String responseDetails = _safeResponseDetails(response.body);
      throw Exception(
        'Firebase sign-in succeeded, but AiTradeX could not sync your profile '
            '(HTTP ${response.statusCode}). $responseDetails',
      );
    }

    if (response.body.trim().isEmpty) return;

    try {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['success'] == false) {
        throw Exception(
          decoded['message']?.toString() ??
              'The AiTradeX backend rejected the profile.',
        );
      }
    } on FormatException {
      // Some APIs return plain text on successful requests. Only reject invalid
      // JSON if the response declares that it is JSON.
      final String contentType =
          response.headers['content-type']?.toLowerCase() ?? '';
      if (contentType.contains('application/json')) {
        throw Exception(
          'The AiTradeX backend returned invalid JSON while syncing your profile.',
        );
      }
    }
  }

  String _safeResponseDetails(String body) {
    final String trimmed = body.trim();
    if (trimmed.isEmpty) return '';

    try {
      final dynamic decoded = jsonDecode(trimmed);
      if (decoded is Map) {
        final dynamic message = decoded['message'] ?? decoded['error'];
        if (message != null && message.toString().trim().isNotEmpty) {
          return message.toString();
        }
      }
    } catch (_) {
      // Do not show an arbitrary HTML/proxy response in the snackbar.
    }
    return '';
  }

  String _firebaseErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email using another sign-in method.';
      case 'invalid-credential':
        return 'Google credential is invalid or expired. Check your OAuth configuration and try again.';
      case 'operation-not-allowed':
        return 'Google sign-in is disabled in Firebase Authentication. Enable the Google provider in Firebase Console.';
      case 'network-request-failed':
        return 'Network error while signing in. Check your internet connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a while and try again.';
      default:
        return error.message ?? 'Firebase authentication failed (${error.code}).';
    }
  }

  Future<void> signOut() async {
    // Sign out from both providers so the next attempt can choose another
    // Google account. A failure in Google sign-out should not prevent Firebase
    // sign-out.
    try {
      await _googleSignIn.signOut();
    } catch (error, stackTrace) {
      debugPrint('[GoogleAuth] Google sign-out failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }

    await _firebaseAuth.signOut();
    debugPrint('[GoogleAuth] Firebase sign-out completed.');
  }
}
