import 'dart:convert';
import 'dart:typed_data';

import 'package:google_generative_ai/google_generative_ai.dart';

import 'package:trippified/core/config/env_config.dart';
import 'package:trippified/core/errors/exceptions.dart';
import 'package:trippified/domain/models/scanned_place.dart';

/// A single generated activity within a day plan
class GeneratedActivity {
  const GeneratedActivity({
    required this.name,
    required this.time,
    required this.category,
    required this.description,
    required this.location,
    required this.durationMinutes,
    this.isAnchor = false,
  });

  factory GeneratedActivity.fromJson(Map<String, dynamic> json) {
    return GeneratedActivity(
      name: json['name'] as String? ?? 'Activity',
      time: json['time'] as String? ?? '9:00 AM',
      category: json['category'] as String? ?? 'attraction',
      description: json['description'] as String? ?? '',
      location: json['location'] as String? ?? '',
      durationMinutes: json['duration_minutes'] as int? ?? 60,
      isAnchor: json['is_anchor'] as bool? ?? false,
    );
  }

  final String name;
  final String time;
  final String category;
  final String description;
  final String location;
  final int durationMinutes;
  final bool isAnchor;
}

/// A single generated day plan
class GeneratedDayPlan {
  const GeneratedDayPlan({
    required this.dayNumber,
    required this.themeLabel,
    required this.activities,
  });

  factory GeneratedDayPlan.fromJson(Map<String, dynamic> json) {
    final activitiesJson = json['activities'] as List? ?? [];
    return GeneratedDayPlan(
      dayNumber: json['day_number'] as int? ?? 1,
      themeLabel: json['theme_label'] as String? ?? 'Planned day',
      activities: activitiesJson
          .map((a) => GeneratedActivity.fromJson(
                a as Map<String, dynamic>,
              ))
          .toList(),
    );
  }

  final int dayNumber;
  final String themeLabel;
  final List<GeneratedActivity> activities;
}

/// Service for AI-powered itinerary generation using Google Gemini
class GeminiService {
  GeminiService._();

  static GeminiService? _instance;
  static GeminiService get instance => _instance ??= GeminiService._();

  GenerativeModel? _model;

  GenerativeModel _getModel() {
    if (_model != null) return _model!;

    const apiKey = EnvConfig.geminiApiKey;
    if (apiKey.isEmpty) {
      throw const AiGenerationException(
        'Gemini API key not configured. '
        'Set GEMINI_API_KEY via --dart-define.',
      );
    }

    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        temperature: 0.8,
        maxOutputTokens: 4096,
      ),
    );

    return _model!;
  }

  /// Generate day plans for empty days in a city.
  ///
  /// [cityName] - The city to generate activities for.
  /// [totalDays] - Total number of days in the city block.
  /// [emptyDayNumbers] - Day numbers that need generation (1-indexed).
  /// [filledDayThemes] - Already-filled day themes to avoid duplication.
  Future<List<GeneratedDayPlan>> generateDayPlans({
    required String cityName,
    required int totalDays,
    required List<int> emptyDayNumbers,
    Map<int, String> filledDayThemes = const {},
    String? themePreference,
  }) async {
    if (emptyDayNumbers.isEmpty) return [];

    try {
      final model = _getModel();
      final prompt = _buildPrompt(
        cityName: cityName,
        totalDays: totalDays,
        emptyDayNumbers: emptyDayNumbers,
        filledDayThemes: filledDayThemes,
        themePreference: themePreference,
      );

      final response = await model.generateContent([
        Content.text(prompt),
      ]);

      final text = response.text;
      if (text == null || text.isEmpty) {
        throw const AiGenerationException(
          'AI returned an empty response. Please try again.',
        );
      }

      return _parseResponse(text);
    } on AiGenerationException {
      rethrow;
    } on GenerativeAIException catch (e) {
      throw AiGenerationException('AI service error: ${e.message}');
    } catch (e) {
      if (e is AiGenerationException) rethrow;
      throw const AiGenerationException(
        'Failed to generate itinerary. Please try again.',
      );
    }
  }

  String _buildPrompt({
    required String cityName,
    required int totalDays,
    required List<int> emptyDayNumbers,
    required Map<int, String> filledDayThemes,
    String? themePreference,
  }) {
    final filledContext = filledDayThemes.isNotEmpty
        ? 'Already planned days (DO NOT regenerate these, '
            'and avoid repeating their themes): '
            '${filledDayThemes.entries.map((e) => 'Day ${e.key}: ${e.value}').join(', ')}. '
        : '';

    final themeHint = themePreference != null
        ? 'IMPORTANT: Use "$themePreference" as the theme for the generated day(s). '
            'All activities should match this theme. '
        : '';

    return '''
You are a travel planning expert. Generate day-by-day itinerary plans for a trip to $cityName.

$filledContext
$themeHint
Generate plans ONLY for these days: ${emptyDayNumbers.join(', ')}.
The trip is $totalDays days total in $cityName.

Rules:
- Each day MUST have a unique theme label (e.g. "Temple day", "Food crawl", "Art & culture", "Shopping day", "Nature day", "Night tour")
- Each day should have 3-5 activities
- Exactly ONE activity per day should be marked as the anchor (the main highlight)
- Activities should be real, well-known places and experiences in $cityName
- Include a mix of morning, midday, afternoon, and evening activities
- Times should be in 12-hour format (e.g. "9:00 AM", "1:30 PM")
- Categories must be one of: attraction, restaurant, cafe, bar, nightlife, shopping, museum, park, beach, temple, landmark, entertainment, spa, sport, tour, transport
- Each activity needs a location (neighborhood or area name)
- Duration in minutes (30-180 range)
- Vary themes across days -- no two days should have the same theme

Return a JSON object with this exact structure:
{
  "days": [
    {
      "day_number": 1,
      "theme_label": "Temple day",
      "activities": [
        {
          "name": "Senso-ji Temple",
          "time": "9:00 AM",
          "category": "temple",
          "description": "Tokyo's oldest temple with stunning Kaminarimon gate",
          "location": "Asakusa",
          "duration_minutes": 90,
          "is_anchor": true
        }
      ]
    }
  ]
}
''';
  }

  List<GeneratedDayPlan> _parseResponse(String text) {
    try {
      final json = jsonDecode(text) as Map<String, dynamic>;
      final daysJson = json['days'] as List? ?? [];
      return daysJson
          .map((d) =>
              GeneratedDayPlan.fromJson(d as Map<String, dynamic>))
          .toList();
    } on FormatException {
      throw const AiGenerationException(
        'Could not parse AI response. Please try again.',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Place extraction from social media content
  // ---------------------------------------------------------------------------

  /// Extract places from caption/description text (URL path, no image).
  Future<List<ScannedPlace>> extractPlacesFromText(
    String captionText,
  ) async {
    if (captionText.trim().isEmpty) return [];

    try {
      final model = _getModel();
      final prompt = _buildTextOnlyPrompt(captionText);
      final response = await model.generateContent([Content.text(prompt)]);

      return _parsePlaceResponse(response.text);
    } on AiGenerationException {
      rethrow;
    } on GenerativeAIException catch (e) {
      throw AiGenerationException('AI service error: ${e.message}');
    } catch (e) {
      if (e is AiGenerationException) rethrow;
      throw const AiGenerationException(
        'Failed to extract places. Please try again.',
      );
    }
  }

  /// Extract places from caption text + video thumbnail image.
  ///
  /// Combines the written caption with vision analysis of the cover
  /// frame to catch text overlays, storefronts, signs, and landmarks.
  Future<List<ScannedPlace>> extractPlacesFromTextAndImage({
    required String captionText,
    required Uint8List imageBytes,
  }) async {
    try {
      final model = _getModel();
      final parts = <Part>[
        TextPart(_buildCaptionPlusVisionPrompt(captionText)),
        DataPart('image/jpeg', imageBytes),
      ];
      final response = await model.generateContent([
        Content.multi(parts),
      ]);

      return _parsePlaceResponse(response.text);
    } on AiGenerationException {
      rethrow;
    } on GenerativeAIException catch (e) {
      throw AiGenerationException('AI service error: ${e.message}');
    } catch (e) {
      if (e is AiGenerationException) rethrow;
      throw const AiGenerationException(
        'Failed to extract places. Please try again.',
      );
    }
  }

  /// Extract places from uploaded screenshots (media upload path).
  Future<List<ScannedPlace>> extractPlacesFromImages(
    List<Uint8List> imageBytesList,
  ) async {
    if (imageBytesList.isEmpty) return [];

    try {
      final model = _getModel();
      final parts = <Part>[
        TextPart(_buildScreenshotPrompt()),
        ...imageBytesList.map(
          (bytes) => DataPart('image/jpeg', bytes),
        ),
      ];
      final response = await model.generateContent([
        Content.multi(parts),
      ]);

      return _parsePlaceResponse(response.text);
    } on AiGenerationException {
      rethrow;
    } on GenerativeAIException catch (e) {
      throw AiGenerationException('AI service error: ${e.message}');
    } catch (e) {
      if (e is AiGenerationException) rethrow;
      throw const AiGenerationException(
        'Failed to extract places from images. Please try again.',
      );
    }
  }

  /// Extract places from an uploaded screen recording (video path).
  ///
  /// Gemini analyses every frame of the video, transcribes spoken
  /// words, reads text overlays, and identifies visible landmarks.
  Future<List<ScannedPlace>> extractPlacesFromVideo(
    Uint8List videoBytes,
  ) async {
    try {
      final model = _getModel();
      final parts = <Part>[
        TextPart(_buildVideoPrompt()),
        DataPart('video/mp4', videoBytes),
      ];
      final response = await model.generateContent([
        Content.multi(parts),
      ]);

      return _parsePlaceResponse(response.text);
    } on AiGenerationException {
      rethrow;
    } on GenerativeAIException catch (e) {
      throw AiGenerationException('AI service error: ${e.message}');
    } catch (e) {
      if (e is AiGenerationException) rethrow;
      throw const AiGenerationException(
        'Failed to extract places from video. Please try again.',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Prompts
  // ---------------------------------------------------------------------------

  static const _jsonSchema = '''
{
  "places": [
    {
      "name": "Ichiran Ramen",
      "category": "Restaurant",
      "location": "Shibuya, Tokyo",
      "confidence": 0.95,
      "description": "Famous tonkotsu ramen chain"
    }
  ]
}''';

  static const _rules = '''
Rules:
- Only include specific VENUES and ESTABLISHMENTS (restaurants, cafes, temples, shops, hotels, attractions, etc.)
- DO NOT include cities, countries, regions, provinces, islands, or neighborhoods as places. These are NOT venues. For example: "Phuket", "Bangkok", "Thailand", "Shibuya", "Bali" should NEVER appear as a place entry.
- Category must be one of: Restaurant, Attraction, Hotel, Cafe, Bar, Shopping, Museum, Temple, Landmark, Park, Beach, Entertainment, Spa, Nightlife
- Location should be the neighborhood/area and city where the venue is located
- Confidence: 0.0-1.0 (1.0 = clearly named, 0.7 = high confidence, 0.5 = inferred from context, 0.3 = uncertain)
- Include a short description for each place
- If no specific venues are found, return {"places": []}''';

  /// Text-only prompt (Instagram HTML fallback, no image available).
  String _buildTextOnlyPrompt(String captionText) {
    return '''
You are an expert travel content analyzer. Extract every specific place name mentioned in this social media caption.

Caption:
$captionText

Look for:
1. Named restaurants, cafes, bars, hotels, hostels
2. Named attractions, landmarks, temples, museums, parks
3. Named shops, markets, malls, entertainment venues
4. Any specific venue or establishment mentioned by name

Return JSON:
$_jsonSchema

$_rules
''';
  }

  /// Caption text + thumbnail vision (TikTok URL path).
  String _buildCaptionPlusVisionPrompt(String captionText) {
    return '''
You are an expert travel content analyzer. You have TWO sources of information about this social media post:

SOURCE 1 — Video caption:
$captionText

SOURCE 2 — Video thumbnail image (attached).

Analyze BOTH sources thoroughly and extract every specific place mentioned or identifiable. From the caption, look for named places. From the thumbnail image, look for:
- Text overlays showing place names or locations
- Visible storefront signs, restaurant names, hotel signs
- Recognizable landmarks or attractions
- Location tags or geotags visible on screen
- Any other text mentioning a specific venue

IMPORTANT: If the post describes a place without naming it (e.g. "this café", "this restaurant", "most magical café in Thailand"), use your knowledge to IDENTIFY the actual venue. Use visual clues (architecture, décor, setting, location context from hashtags) combined with your travel knowledge to determine the real name of the venue. Return it with a lower confidence score (0.3-0.5) to indicate it was inferred.

Combine findings from both sources. Do NOT duplicate the same place.

Return JSON:
$_jsonSchema

$_rules
''';
  }

  /// Screenshot vision prompt (user uploaded screenshots).
  String _buildScreenshotPrompt() {
    return '''
You are an expert travel content analyzer with vision. These are screenshots from a social media post (TikTok, Instagram, etc.) about travel. Analyze EVERY screenshot carefully and extract all places mentioned.

Look at each screenshot for:
1. TEXT OVERLAYS — Read every piece of text visible on screen. Look for place names, addresses, lists of recommendations
2. CAPTIONS / SUBTITLES — Read any caption text at the bottom of the screen, auto-generated subtitles, or description text
3. LOCATION TAGS — Check for tagged locations, geotags, or location stickers
4. SIGNS & STOREFRONTS — Read visible signs, restaurant names, hotel marquees, shop names
5. LANDMARKS — Identify recognizable landmarks, temples, monuments, attractions
6. LISTS / RANKINGS — If the post shows a numbered list (e.g. "Top 5 restaurants in Bangkok"), extract every item
7. MAP PINS — If a map is shown, read the pin labels

Be thorough — scan every pixel of text in every image.

Return JSON:
$_jsonSchema

$_rules
''';
  }

  /// Video vision prompt (user uploaded screen recording).
  String _buildVideoPrompt() {
    return '''
You are an expert travel content analyzer with vision and audio capabilities. This is a screen recording of a social media post (TikTok, Instagram, etc.) about travel.

Analyze the ENTIRE video frame by frame and extract every place mentioned through ANY channel:

1. TEXT OVERLAYS — Read every text overlay that appears at any point in the video. Place names, addresses, lists of recommendations
2. CAPTIONS / SUBTITLES — Read any caption text, auto-generated subtitles, or description text visible at any frame
3. AUDIO TRANSCRIPT — Listen to the spoken words and transcribe any place names mentioned verbally by the creator
4. LOCATION TAGS — Check for tagged locations, geotags, or location stickers
5. SIGNS & STOREFRONTS — Read visible signs, restaurant names, hotel marquees, shop names that appear in any frame
6. LANDMARKS — Identify recognizable landmarks, temples, monuments, attractions visible in the video
7. LISTS / RANKINGS — If the video shows a numbered list (e.g. "Top 5 restaurants in Bangkok"), extract every item
8. MAP PINS — If a map is shown at any point, read the pin labels
9. COMMENTS / REPLIES — If the recording shows comments mentioning places, extract those too

Be extremely thorough — watch the entire video and catch every place from every source.

Return JSON:
$_jsonSchema

$_rules
''';
  }

  List<ScannedPlace> _parsePlaceResponse(String? text) {
    if (text == null || text.isEmpty) {
      throw const AiGenerationException(
        'AI returned an empty response. Please try again.',
      );
    }

    try {
      final json = jsonDecode(text) as Map<String, dynamic>;
      final placesJson = json['places'] as List? ?? [];
      return placesJson
          .asMap()
          .entries
          .map((entry) {
            final placeJson = entry.value as Map<String, dynamic>;
            return ScannedPlace.fromJson({
              ...placeJson,
              'id': 'scanned-${entry.key}',
            });
          })
          .toList();
    } on FormatException {
      throw const AiGenerationException(
        'Could not parse place extraction response. Please try again.',
      );
    }
  }
}
