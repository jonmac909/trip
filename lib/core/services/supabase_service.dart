import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:trippified/core/config/env_config.dart';
import 'package:trippified/core/errors/exceptions.dart';

/// Service for managing Supabase connection
class SupabaseService {
  SupabaseService._();

  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  bool _isInitialized = false;

  /// Initialize Supabase with environment configuration
  Future<void> initialize() async {
    if (_isInitialized) return;

    if (!EnvConfig.isConfigured) {
      throw const TrippifiedException(
        'Supabase not configured. Set SUPABASE_URL and SUPABASE_ANON_KEY.',
        code: 'CONFIG_ERROR',
      );
    }

    await Supabase.initialize(
      url: EnvConfig.supabaseUrl,
      anonKey: EnvConfig.supabaseAnonKey,
    );

    _isInitialized = true;
  }

  /// Get the Supabase client
  SupabaseClient get client {
    if (!_isInitialized) {
      throw const TrippifiedException(
        'Supabase not initialized. Call initialize() first.',
        code: 'NOT_INITIALIZED',
      );
    }
    return Supabase.instance.client;
  }

  /// Get the current authenticated user
  User? get currentUser => _isInitialized ? client.auth.currentUser : null;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Get the auth state stream
  Stream<AuthState> get authStateChanges =>
      _isInitialized ? client.auth.onAuthStateChange : const Stream.empty();

  /// Sign out the current user
  Future<void> signOut() async {
    if (!_isInitialized) return;
    await client.auth.signOut();
  }
}
