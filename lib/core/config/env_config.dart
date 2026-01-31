import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration for Trippified
///
/// Values are loaded from .env file at runtime using flutter_dotenv.
/// Fallback to --dart-define flags for CI/CD builds.
abstract final class EnvConfig {
  // Supabase
  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ??
      const String.fromEnvironment('SUPABASE_URL');

  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ??
      const String.fromEnvironment('SUPABASE_ANON_KEY');

  // Google
  static String get googlePlacesApiKey =>
      dotenv.env['GOOGLE_PLACES_API_KEY'] ??
      const String.fromEnvironment('GOOGLE_PLACES_API_KEY');

  static String get googleMapsApiKey =>
      dotenv.env['GOOGLE_MAPS_API_KEY'] ??
      const String.fromEnvironment('GOOGLE_MAPS_API_KEY');

  // Amadeus
  static String get amadeusApiKey =>
      dotenv.env['AMADEUS_API_KEY'] ??
      const String.fromEnvironment('AMADEUS_API_KEY');

  static String get amadeusApiSecret =>
      dotenv.env['AMADEUS_API_SECRET'] ??
      const String.fromEnvironment('AMADEUS_API_SECRET');

  // Clawdbot Proxy (routes to Claude AI)
  static String get clawdbotApiUrl =>
      dotenv.env['CLAWDBOT_API_URL'] ??
      const String.fromEnvironment('CLAWDBOT_API_URL');

  static String get clawdbotApiToken =>
      dotenv.env['CLAWDBOT_API_TOKEN'] ??
      const String.fromEnvironment('CLAWDBOT_API_TOKEN');

  // Feature flags
  static bool get enableAnalytics =>
      dotenv.env['ENABLE_ANALYTICS']?.toLowerCase() == 'true' ||
      const bool.fromEnvironment('ENABLE_ANALYTICS');

  static bool get enableCrashReporting =>
      dotenv.env['ENABLE_CRASH_REPORTING']?.toLowerCase() == 'true' ||
      const bool.fromEnvironment('ENABLE_CRASH_REPORTING');

  /// Validates that required environment variables are set
  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  /// Returns a list of missing required configurations
  static List<String> get missingConfigurations {
    final missing = <String>[];
    if (supabaseUrl.isEmpty) missing.add('SUPABASE_URL');
    if (supabaseAnonKey.isEmpty) missing.add('SUPABASE_ANON_KEY');
    return missing;
  }
}
