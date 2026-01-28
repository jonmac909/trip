/// Environment configuration for Trippified
///
/// Values are loaded from --dart-define flags during build:
/// flutter run --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key
abstract final class EnvConfig {
  // Supabase
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );

  // Google
  static const String googlePlacesApiKey = String.fromEnvironment(
    'GOOGLE_PLACES_API_KEY',
  );
  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
  );

  // Amadeus
  static const String amadeusApiKey = String.fromEnvironment('AMADEUS_API_KEY');
  static const String amadeusApiSecret = String.fromEnvironment(
    'AMADEUS_API_SECRET',
  );

  // AI Vision
  static const String claudeApiKey = String.fromEnvironment('CLAUDE_API_KEY');

  // Gemini AI (required: --dart-define=GEMINI_API_KEY=your_key)
  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');

  // Feature flags
  static const bool enableAnalytics = bool.fromEnvironment('ENABLE_ANALYTICS');
  static const bool enableCrashReporting = bool.fromEnvironment(
    'ENABLE_CRASH_REPORTING',
  );

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
