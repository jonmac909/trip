/// Application-wide constants for Trippified
abstract final class AppConstants {
  // App Info
  static const String appName = 'Trippified';
  static const String appVersion = '1.0.0';

  // Limits (Free Tier)
  static const int freeTripsLimit = 2;
  static const int freeSavedItemsLimit = 50;
  static const int freeSocialImportsPerMonth = 5;
  static const int freeDocumentsLimit = 5;

  // Trip Limits
  static const int maxCitiesPerTrip = 20;
  static const int maxDaysPerCity = 14;
  static const int maxActivitiesPerDay = 10;
  static const int maxCollaboratorsPerTrip = 10;

  // Day Builder
  static const int defaultActivitiesPerDay = 5;
  static const int maxAlternativeAnchors = 3;

  // Budget
  static const String defaultCurrency = 'USD';
  static const List<String> supportedCurrencies = [
    'USD',
    'EUR',
    'GBP',
    'JPY',
    'CAD',
    'AUD',
    'CHF',
    'CNY',
    'THB',
    'SGD',
  ];

  // File Upload
  static const int maxFileSizeBytes = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'heic',
  ];
  static const List<String> allowedDocumentExtensions = [
    'pdf',
    'jpg',
    'jpeg',
    'png',
  ];

  // Cache
  static const Duration cacheExpiry = Duration(minutes: 5);
  static const Duration placesDataExpiry = Duration(hours: 24);

  // API
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;

  // Animation
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Pagination
  static const int defaultPageSize = 20;
}
