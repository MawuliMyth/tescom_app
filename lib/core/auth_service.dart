import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'api_client.dart';
import 'auth_tokens.dart';
import 'push_notification_service.dart';
import 'token_storage.dart';

class AuthService {
  AuthService({ApiClient? apiClient, TokenStorage? tokenStorage})
    : this._(tokenStorage ?? TokenStorage(), apiClient);

  AuthService._(TokenStorage tokenStorage, ApiClient? apiClient)
    : _tokenStorage = tokenStorage,
      _apiClient = apiClient ?? ApiClient(tokenStorage: tokenStorage);

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;
  static Future<void>? _googleInitFuture;

  Future<bool> hasSession() async {
    if (!await _tokenStorage.hasRefreshSession()) return false;
    if (await _tokenStorage.hasValidAccessSession()) return true;

    try {
      await _apiClient.refreshSession();
      return true;
    } on ApiException catch (error) {
      if (error.statusCode == 401 || error.statusCode == 403) {
        await _tokenStorage.clear();
        return false;
      }
      return true;
    } catch (error, stackTrace) {
      debugPrint('Session refresh check failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return true;
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    final data = await _apiClient.post(
      '/api/auth/login',
      auth: false,
      body: {'email': email, 'password': password},
    );
    await _saveTokens(data);
  }

  Future<void> signInWithGoogle() async {
    try {
      if (!await PushNotificationService.ensureFirebaseInitialized()) {
        throw const ApiException('Firebase is not configured for this app yet');
      }

      _googleInitFuture ??= GoogleSignIn.instance.initialize();
      await _googleInitFuture;
      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        throw const ApiException('Google sign-in is not supported here');
      }

      final googleUser = await GoogleSignIn.instance.authenticate();
      final googleIdToken = googleUser.authentication.idToken;
      if (googleIdToken == null) {
        throw const ApiException('Google did not return a sign-in token');
      }

      final credential = GoogleAuthProvider.credential(idToken: googleIdToken);
      final firebaseUser = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final firebaseIdToken = await firebaseUser.user?.getIdToken();
      if (firebaseIdToken == null) {
        throw const ApiException('Firebase did not return a sign-in token');
      }

      final data = await _apiClient.post(
        '/api/auth/firebase',
        auth: false,
        body: {'idToken': firebaseIdToken},
      );
      await _saveTokens(data);
    } on ApiException {
      rethrow;
    } on FirebaseAuthException catch (error) {
      throw ApiException(_firebaseAuthMessage(error));
    } catch (error) {
      final message = error.toString().toLowerCase();
      if (message.contains('cancel')) {
        throw const ApiException('Google sign-in was cancelled.');
      }
      throw const ApiException(
        'Google sign-in could not be completed. Please try again.',
      );
    }
  }

  Future<void> signUp({
    required String fullName,
    required String phone,
    required String institution,
    required String email,
    required String password,
  }) async {
    final data = await _apiClient.post(
      '/api/auth/register',
      auth: false,
      body: {
        'fullName': fullName,
        'phone': phone,
        'institution': institution,
        'email': email,
        'password': password,
      },
    );
    await _saveTokens(data);
  }

  Future<void> logout() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    try {
      final body = refreshToken == null
          ? <String, dynamic>{}
          : {'refreshToken': refreshToken};
      await _apiClient.post('/api/auth/logout', body: body);
    } catch (error, stackTrace) {
      debugPrint('Server logout failed, clearing local session: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      try {
        await FirebaseAuth.instance.signOut();
        await GoogleSignIn.instance.signOut();
      } catch (error, stackTrace) {
        debugPrint('Provider sign-out failed: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
      await _tokenStorage.clear();
    }
  }

  Future<void> _saveTokens(Map<String, dynamic> data) {
    return _tokenStorage.save(AuthTokens.fromJson(data['tokens']));
  }
}

String _firebaseAuthMessage(FirebaseAuthException error) {
  return switch (error.code) {
    'network-request-failed' =>
      'Could not reach Firebase. Check your internet connection and try again.',
    'account-exists-with-different-credential' =>
      'An account already exists with this email. Sign in using the original method.',
    'invalid-credential' =>
      'Google sign-in returned invalid credentials. Please try again.',
    'user-disabled' => 'This account has been disabled.',
    _ =>
      error.message?.trim().isNotEmpty == true
          ? error.message!.trim()
          : 'Google sign-in could not be completed. Please try again.',
  };
}
