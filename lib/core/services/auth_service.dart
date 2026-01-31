import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:trippified/core/errors/exceptions.dart';
import 'package:trippified/core/services/supabase_service.dart';

/// Service for handling OAuth authentication flows
class AuthService {
  AuthService._();

  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();

  final _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // iOS client ID from Google Cloud Console
    clientId: kIsWeb
        ? null
        : Platform.isIOS
            ? '500863193538-un8dnveu1754c19044ou95tq6jbfcmpe.apps.googleusercontent.com'
            : null,
  );

  SupabaseClient get _supabase => SupabaseService.instance.client;

  /// Sign in with Google using native flow
  Future<AuthResponse> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthCancelledException();
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) {
        throw OAuthException('Google', 'No ID token received');
      }

      // Exchange Google token for Supabase session
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      return response;
    } on AuthCancelledException {
      rethrow;
    } catch (e) {
      if (e is OAuthException) rethrow;
      throw OAuthException('Google', e.toString());
    }
  }

  /// Sign in with Apple using native flow
  Future<AuthResponse> signInWithApple() async {
    try {
      debugPrint('Apple Sign-In: Starting...');
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      debugPrint('Apple Sign-In: Got credential');
      debugPrint('Apple Sign-In: authorizationCode=${credential.authorizationCode}');
      debugPrint('Apple Sign-In: identityToken=${credential.identityToken?.substring(0, 50)}...');

      final idToken = credential.identityToken;
      if (idToken == null) {
        throw OAuthException('Apple', 'No identity token received');
      }

      debugPrint('Apple Sign-In: Exchanging token with Supabase...');
      // Exchange Apple token for Supabase session
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
      );
      debugPrint('Apple Sign-In: Success! User=${response.user?.email}');

      // Apple only sends name on first sign-in, update profile if available
      if (credential.givenName != null || credential.familyName != null) {
        final fullName = [credential.givenName, credential.familyName]
            .where((n) => n != null && n.isNotEmpty)
            .join(' ');

        if (fullName.isNotEmpty) {
          await _supabase.auth.updateUser(
            UserAttributes(data: {'full_name': fullName}),
          );
        }
      }

      return response;
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw const AuthCancelledException();
      }
      throw OAuthException('Apple', e.message);
    } catch (e) {
      if (e is AuthCancelledException) rethrow;
      if (e is OAuthException) rethrow;
      throw OAuthException('Apple', e.toString());
    }
  }

  /// Sign in with email and password
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  /// Sign up with email and password
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? fullName,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: fullName != null ? {'full_name': fullName} : null,
    );
    return response;
  }

  /// Sign out from all providers
  Future<void> signOut() async {
    // Sign out from Google
    try {
      await _googleSignIn.signOut();
    } catch (_) {}

    // Sign out from Supabase (clears session)
    await _supabase.auth.signOut();
  }

  /// Check if user is authenticated with a real account (not anonymous)
  bool get isAuthenticatedWithAccount {
    final user = _supabase.auth.currentUser;
    return user != null && user.isAnonymous != true;
  }
}
