import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import 'package:trippified/core/errors/exceptions.dart';
import 'package:trippified/core/services/auth_service.dart';
import 'package:trippified/core/services/supabase_service.dart';

/// Authentication state
@immutable
class AuthState {
  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  final supabase.User? user;
  final bool isLoading;
  final String? error;

  /// Check if user is authenticated with a real account (not anonymous)
  bool get isAuthenticated => user != null && user!.isAnonymous != true;

  /// Check if user is anonymous
  bool get isAnonymous => user?.isAnonymous ?? false;

  AuthState copyWith({
    supabase.User? user,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Authentication state notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _init();
  }

  StreamSubscription<supabase.AuthState>? _authSubscription;
  final _authService = AuthService.instance;
  final _supabaseService = SupabaseService.instance;

  void _init() {
    // Set initial user
    state = AuthState(user: _supabaseService.currentUser);

    // Listen for auth state changes
    _authSubscription =
        _supabaseService.authStateChanges.listen((authState) {
      final event = authState.event;
      final session = authState.session;

      switch (event) {
        case supabase.AuthChangeEvent.signedIn:
        case supabase.AuthChangeEvent.tokenRefreshed:
        case supabase.AuthChangeEvent.userUpdated:
          state = state.copyWith(user: session?.user, clearError: true);
        case supabase.AuthChangeEvent.signedOut:
          state = state.copyWith(clearUser: true, clearError: true);
        case supabase.AuthChangeEvent.passwordRecovery:
        case supabase.AuthChangeEvent.mfaChallengeVerified:
        // ignore: deprecated_member_use
        case supabase.AuthChangeEvent.userDeleted:
        case supabase.AuthChangeEvent.initialSession:
          // Handle if needed
          break;
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _authService.signInWithGoogle();
      state = state.copyWith(isLoading: false);
      return true;
    } on AuthCancelledException {
      state = state.copyWith(isLoading: false);
      return false;
    } on OAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Sign in with Apple
  Future<bool> signInWithApple() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _authService.signInWithApple();
      state = state.copyWith(isLoading: false);
      return true;
    } on AuthCancelledException {
      state = state.copyWith(isLoading: false);
      return false;
    } on OAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Sign in with email and password
  Future<bool> signInWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _authService.signInWithEmail(email: email, password: password);
      state = state.copyWith(isLoading: false);
      return true;
    } on supabase.AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Sign up with email and password
  Future<bool> signUpWithEmail(
    String email,
    String password, {
    String? fullName,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _authService.signUpWithEmail(
        email: email,
        password: password,
        fullName: fullName,
      );
      state = state.copyWith(isLoading: false);
      return true;
    } on supabase.AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _authService.signOut();
      state = state.copyWith(isLoading: false, clearUser: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Auth state provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

/// Convenience provider for checking if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});
