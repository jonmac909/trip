import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

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
          .map((a) => GeneratedActivity.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }

  final int dayNumber;
  final String themeLabel;
  final List<GeneratedActivity> activities;
}

/// Service for AI-powered itinerary generation using Clawdbot proxy (Claude)
class ClaudeService {
  ClaudeService._();

  static ClaudeService? _instance;
  static ClaudeService get instance => _instance ??= ClaudeService._();

  static const _model = 'anthropic/claude-sonnet-4-5';

  String _getApiUrl() {
    final url = EnvConfig.clawdbotApiUrl;
    if (url.isEmpty) {
      throw const AiGenerationException(
        'Clawdbot API URL not configured. Set CLAWDBOT_API_URL in .env file.',
      );
    }
    return '$url/v1/chat/completions';
  }

  String _getApiToken() {
    final token = EnvConfig.clawdbotApiToken;
    if (token.isEmpty) {
      throw const AiGenerationException(
        'Clawdbot API token not configured. Set CLAWDBOT_API_TOKEN in .env file.',
      );
    }
    return token;
  }

  Map<String, String> _buildHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${_getApiToken()}',
    };
  }

  /// Generate day plans for empty days across multiple destinations.
  ///
  /// [destinations] - List of cities/countries to visit (e.g., ["Bangkok", "Ho Chi Minh City"])
  /// The AI will intelligently distribute days across all destinations.
  ///
  /// Uses parallel API calls to speed up generation for longer trips.
  Future<List<GeneratedDayPlan>> generateDayPlans({
    required String cityName, // Keep for backwards compatibility
    required int totalDays,
    required List<int> emptyDayNumbers,
    Map<int, String> filledDayThemes = const {},
    String? themePreference,
    List<String>? destinations, // New: multiple destinations
  }) async {
    if (emptyDayNumbers.isEmpty) return [];

    // Use destinations list if provided, otherwise fall back to single cityName
    final allDestinations = destinations?.where((d) => d.isNotEmpty).toList() ?? [cityName];

    // For multi-destination trips, split days by destination and generate in parallel
    if (allDestinations.length > 1) {
      return _generateParallelByDestination(
        cityName: cityName,
        destinations: allDestinations,
        totalDays: totalDays,
        emptyDayNumbers: emptyDayNumbers,
        filledDayThemes: filledDayThemes,
        themePreference: themePreference,
      );
    }

    // For single destination, use parallel batches
    return _generateParallelBatches(
      cityName: cityName,
      destinations: allDestinations,
      totalDays: totalDays,
      emptyDayNumbers: emptyDayNumbers,
      filledDayThemes: filledDayThemes,
      themePreference: themePreference,
    );
  }

  /// Generate days in parallel by splitting across destinations
  Future<List<GeneratedDayPlan>> _generateParallelByDestination({
    required String cityName,
    required List<String> destinations,
    required int totalDays,
    required List<int> emptyDayNumbers,
    required Map<int, String> filledDayThemes,
    String? themePreference,
  }) async {
    // Distribute days across destinations
    final daysPerDestination = emptyDayNumbers.length ~/ destinations.length;
    final extraDays = emptyDayNumbers.length % destinations.length;

    final futures = <Future<List<GeneratedDayPlan>>>[];
    var dayIndex = 0;

    for (var i = 0; i < destinations.length; i++) {
      final daysForThis = daysPerDestination + (i < extraDays ? 1 : 0);
      if (daysForThis == 0) continue;

      final destinationDays = emptyDayNumbers.skip(dayIndex).take(daysForThis).toList();
      dayIndex += daysForThis;

      print('Parallel: generating ${destinationDays.length} days for ${destinations[i]}');

      // Each destination gets its own API call in parallel
      futures.add(_generateBatch(
        cityName: destinations[i],
        destinations: [destinations[i]], // Single destination for this batch
        totalDays: totalDays,
        emptyDayNumbers: destinationDays,
        filledDayThemes: filledDayThemes,
        themePreference: themePreference,
      ));
    }

    // Run all destination batches in parallel
    final results = await Future.wait(futures);

    // Flatten results
    final allPlans = <GeneratedDayPlan>[];
    for (final batch in results) {
      allPlans.addAll(batch);
    }

    // Sort by day number
    allPlans.sort((a, b) => a.dayNumber.compareTo(b.dayNumber));
    return allPlans;
  }

  /// Generate days in parallel batches (for single destination)
  Future<List<GeneratedDayPlan>> _generateParallelBatches({
    required String cityName,
    required List<String> destinations,
    required int totalDays,
    required List<int> emptyDayNumbers,
    required Map<int, String> filledDayThemes,
    String? themePreference,
  }) async {
    // Split into batches of 5 days each
    const batchSize = 5;
    final futures = <Future<List<GeneratedDayPlan>>>[];

    for (var i = 0; i < emptyDayNumbers.length; i += batchSize) {
      final batchDays = emptyDayNumbers.skip(i).take(batchSize).toList();
      print('Parallel batch: days $batchDays');

      futures.add(_generateBatch(
        cityName: cityName,
        destinations: destinations,
        totalDays: totalDays,
        emptyDayNumbers: batchDays,
        filledDayThemes: filledDayThemes,
        themePreference: themePreference,
      ));
    }

    // Run all batches in parallel
    final results = await Future.wait(futures);

    // Flatten and sort results
    final allPlans = <GeneratedDayPlan>[];
    for (final batch in results) {
      allPlans.addAll(batch);
    }

    allPlans.sort((a, b) => a.dayNumber.compareTo(b.dayNumber));
    return allPlans;
  }

  Future<List<GeneratedDayPlan>> _generateBatch({
    required String cityName,
    required List<String> destinations,
    required int totalDays,
    required List<int> emptyDayNumbers,
    required Map<int, String> filledDayThemes,
    String? themePreference,
    int retryCount = 0,
  }) async {
    const maxRetries = 3;

    try {
      final prompt = _buildItineraryPrompt(
        destinations: destinations,
        totalDays: totalDays,
        emptyDayNumbers: emptyDayNumbers,
        filledDayThemes: filledDayThemes,
        themePreference: themePreference,
      );

      final responseText = await _callClawdbot(prompt);
      print('Claude response (first 300 chars): ${responseText.substring(0, responseText.length > 300 ? 300 : responseText.length)}');

      return _parseItineraryResponse(responseText);
    } on AiGenerationException {
      rethrow;
    } catch (e) {
      print('Error in generateBatch: $e');

      if (_isRateLimitError(e.toString()) && retryCount < maxRetries) {
        final waitSeconds = _extractRetryDelay(e.toString());
        print('Rate limit hit. Waiting ${waitSeconds}s before retry ${retryCount + 1}/$maxRetries...');
        await Future<void>.delayed(Duration(seconds: waitSeconds));
        return _generateBatch(
          cityName: cityName,
          destinations: destinations,
          totalDays: totalDays,
          emptyDayNumbers: emptyDayNumbers,
          filledDayThemes: filledDayThemes,
          themePreference: themePreference,
          retryCount: retryCount + 1,
        );
      }

      if (e is AiGenerationException) rethrow;
      throw AiGenerationException('Failed to generate itinerary: $e');
    }
  }

  /// Call Clawdbot proxy with OpenAI-compatible format
  Future<String> _callClawdbot(
    String prompt, {
    List<Map<String, dynamic>>? images,
    int maxTokens = 4096,
  }) async {
    // Build content array (OpenAI format)
    final content = <Map<String, dynamic>>[];

    // Add images if provided (for vision tasks)
    if (images != null && images.isNotEmpty) {
      for (final img in images) {
        content.add({
          'type': 'image_url',
          'image_url': {
            'url': 'data:${img['media_type']};base64,${img['data']}',
          },
        });
      }
    }

    // Add text prompt
    content.add({
      'type': 'text',
      'text': prompt,
    });

    // Build request body (OpenAI-compatible format)
    final body = jsonEncode({
      'model': _model,
      'messages': [
        {
          'role': 'user',
          'content': images != null && images.isNotEmpty ? content : prompt,
        },
      ],
      'max_tokens': maxTokens,
    });

    final response = await http.post(
      Uri.parse(_getApiUrl()),
      headers: _buildHeaders(),
      body: body,
    );

    if (response.statusCode != 200) {
      final errorBody = response.body;
      print('Clawdbot API error: ${response.statusCode} - $errorBody');

      if (response.statusCode == 429) {
        throw const AiGenerationException('Rate limit exceeded. Please wait and try again.');
      } else if (response.statusCode == 401) {
        throw const AiGenerationException('Invalid API token. Check your CLAWDBOT_API_TOKEN.');
      } else if (response.statusCode == 400) {
        throw AiGenerationException('Bad request: $errorBody');
      }

      throw AiGenerationException('Clawdbot API error: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    // OpenAI format: choices[0].message.content
    final choices = json['choices'] as List?;
    if (choices == null || choices.isEmpty) {
      throw const AiGenerationException('AI returned an empty response.');
    }

    final message = (choices[0] as Map<String, dynamic>)['message'] as Map<String, dynamic>?;
    if (message == null) {
      throw const AiGenerationException('AI returned no message.');
    }

    final text = message['content'] as String?;
    if (text == null || text.isEmpty) {
      throw const AiGenerationException('AI returned empty content.');
    }

    return text;
  }

  bool _isRateLimitError(String message) {
    return message.contains('429') ||
        message.contains('rate') ||
        message.contains('limit') ||
        message.contains('overloaded');
  }

  int _extractRetryDelay(String message) {
    final regex = RegExp(r'(\d+)\s*second');
    final match = regex.firstMatch(message);
    if (match != null) {
      return int.tryParse(match.group(1) ?? '30') ?? 30;
    }
    return 30;
  }

  /// Build explicit day distribution for multi-destination trips
  String _buildDestinationDistribution(List<String> destinations, int totalDays) {
    if (destinations.length == 1) return '';

    final daysPerDestination = totalDays ~/ destinations.length;
    final extraDays = totalDays % destinations.length;

    final buffer = StringBuffer();
    var currentDay = 1;

    for (var i = 0; i < destinations.length; i++) {
      final daysForThis = daysPerDestination + (i < extraDays ? 1 : 0);
      final endDay = currentDay + daysForThis - 1;
      buffer.writeln('- Days $currentDay-$endDay: ${destinations[i]} ($daysForThis days)');
      currentDay = endDay + 1;
    }

    return buffer.toString();
  }

  String _buildItineraryPrompt({
    required List<String> destinations,
    required int totalDays,
    required List<int> emptyDayNumbers,
    required Map<int, String> filledDayThemes,
    String? themePreference,
  }) {
    final filledContext = filledDayThemes.isNotEmpty
        ? 'Already planned days (DO NOT regenerate these, and avoid repeating their themes): ${filledDayThemes.entries.map((e) => 'Day ${e.key}: ${e.value}').join(', ')}. '
        : '';

    final themeHint = themePreference != null
        ? 'IMPORTANT: Use "$themePreference" as the theme for the generated day(s). All activities should match this theme. '
        : '';

    // Handle single vs multiple destinations
    final destinationsText = destinations.length == 1
        ? destinations.first
        : destinations.join(', ');

    final multiDestinationHint = destinations.length > 1
        ? '''
*** CRITICAL - MULTI-COUNTRY/MULTI-DESTINATION TRIP ***
The traveler is visiting ${destinations.length} DIFFERENT PLACES: ${destinations.join(' AND ')}.

YOU MUST INCLUDE ALL DESTINATIONS. DO NOT IGNORE ANY.

MANDATORY DISTRIBUTION:
${_buildDestinationDistribution(destinations, emptyDayNumbers.length)}

RULES FOR MULTI-DESTINATION:
1. EVERY destination listed above MUST have at least 1-2 days of activities
2. Group consecutive days in the same country/city
3. Include the country/city name in EVERY activity's location field (e.g., "Ho Chi Minh City, Vietnam")
4. Start with ${destinations.first}, then move to ${destinations.length > 1 ? destinations.skip(1).join(', then ') : ''}
'''
        : '';

    return '''
You are a travel planning expert. Generate day-by-day itinerary plans for a trip visiting: $destinationsText.

$filledContext
$themeHint
$multiDestinationHint
Generate plans ONLY for these days: ${emptyDayNumbers.join(', ')}.
The trip is $totalDays days total.

Rules:
- Each day MUST have a unique theme label (e.g. "Temple day", "Food crawl", "Art & culture", "Shopping day", "Nature day", "Night tour")
- Each day should have 3-5 activities
- Exactly ONE activity per day should be marked as the anchor (the main highlight)
- Activities should be real, well-known places and experiences in the destination
- Include a mix of morning, midday, afternoon, and evening activities
- Times should be in 12-hour format (e.g. "9:00 AM", "1:30 PM")
- Categories must be one of: attraction, restaurant, cafe, bar, nightlife, shopping, museum, park, beach, temple, landmark, entertainment, spa, sport, tour, transport
- Each activity needs a location (neighborhood/area AND city/country name)
- Duration in minutes (30-180 range)
- Vary themes across days -- no two days should have the same theme

Return ONLY a JSON object (no markdown, no explanation) with this exact structure:
{
  "days": [
    {
      "day_number": 1,
      "theme_label": "Temple day",
      "activities": [
        {
          "name": "Wat Pho",
          "time": "9:00 AM",
          "category": "temple",
          "description": "Famous temple with giant reclining Buddha",
          "location": "Bangkok, Thailand",
          "duration_minutes": 90,
          "is_anchor": true
        }
      ]
    }
  ]
}''';
  }

  List<GeneratedDayPlan> _parseItineraryResponse(String text) {
    try {
      var cleanedText = text.trim();

      // Remove markdown code blocks if present
      if (cleanedText.startsWith('```json')) {
        cleanedText = cleanedText.substring(7);
      } else if (cleanedText.startsWith('```')) {
        cleanedText = cleanedText.substring(3);
      }
      if (cleanedText.endsWith('```')) {
        cleanedText = cleanedText.substring(0, cleanedText.length - 3);
      }
      cleanedText = cleanedText.trim();

      final json = jsonDecode(cleanedText) as Map<String, dynamic>;
      final daysJson = json['days'] as List? ?? [];

      if (daysJson.isEmpty) {
        throw const AiGenerationException('AI returned empty itinerary.');
      }

      return daysJson
          .map((d) => GeneratedDayPlan.fromJson(d as Map<String, dynamic>))
          .toList();
    } on FormatException catch (e) {
      print('Claude parse error: $e');
      print('Raw response: ${text.substring(0, text.length > 500 ? 500 : text.length)}');
      throw const AiGenerationException('Could not parse AI response.');
    }
  }

  // ---------------------------------------------------------------------------
  // Place extraction from social media content
  // ---------------------------------------------------------------------------

  /// Extract places from caption/description text.
  Future<List<ScannedPlace>> extractPlacesFromText(String captionText) async {
    if (captionText.trim().isEmpty) return [];

    try {
      final prompt = _buildTextOnlyPrompt(captionText);
      final responseText = await _callClawdbot(prompt);
      return _parsePlaceResponse(responseText);
    } catch (e) {
      if (e is AiGenerationException) rethrow;
      throw const AiGenerationException('Failed to extract places.');
    }
  }

  /// Extract places from caption text + image.
  Future<List<ScannedPlace>> extractPlacesFromTextAndImage({
    required String captionText,
    required Uint8List imageBytes,
  }) async {
    try {
      final prompt = _buildCaptionPlusVisionPrompt(captionText);
      final images = [
        {
          'media_type': 'image/jpeg',
          'data': base64Encode(imageBytes),
        },
      ];

      final responseText = await _callClawdbot(prompt, images: images);
      return _parsePlaceResponse(responseText);
    } catch (e) {
      if (e is AiGenerationException) rethrow;
      throw const AiGenerationException('Failed to extract places from image.');
    }
  }

  /// Extract places from uploaded screenshots.
  Future<List<ScannedPlace>> extractPlacesFromImages(
    List<Uint8List> imageBytesList,
  ) async {
    if (imageBytesList.isEmpty) return [];

    try {
      final prompt = _buildScreenshotPrompt();
      final images = imageBytesList
          .map((bytes) => {
                'media_type': 'image/jpeg',
                'data': base64Encode(bytes),
              })
          .toList();

      final responseText = await _callClawdbot(prompt, images: images);
      return _parsePlaceResponse(responseText);
    } catch (e) {
      if (e is AiGenerationException) rethrow;
      throw const AiGenerationException('Failed to extract places from images.');
    }
  }

  // ---------------------------------------------------------------------------
  // Prompts for place extraction
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
- DO NOT include cities, countries, regions, provinces, islands, or neighborhoods as places
- Category must be one of: Restaurant, Attraction, Hotel, Cafe, Bar, Shopping, Museum, Temple, Landmark, Park, Beach, Entertainment, Spa, Nightlife
- Location should be the neighborhood/area and city where the venue is located
- Confidence: 0.0-1.0 (1.0 = clearly named, 0.7 = high confidence, 0.5 = inferred, 0.3 = uncertain)
- Include a short description for each place
- If no specific venues are found, return {"places": []}
- Return ONLY JSON, no markdown or explanation''';

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

$_rules''';
  }

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

IMPORTANT: If the post describes a place without naming it (e.g. "this café", "this restaurant"), use visual clues and your travel knowledge to IDENTIFY the actual venue. Return it with lower confidence (0.3-0.5).

Combine findings from both sources. Do NOT duplicate the same place.

Return JSON:
$_jsonSchema

$_rules''';
  }

  String _buildScreenshotPrompt() {
    return '''
You are an expert travel content analyzer with vision. These are screenshots from a social media post about travel. Analyze EVERY screenshot carefully and extract all places mentioned.

Look at each screenshot for:
1. TEXT OVERLAYS — Read every piece of text visible on screen
2. CAPTIONS / SUBTITLES — Read any caption text or description
3. LOCATION TAGS — Check for tagged locations or geotags
4. SIGNS & STOREFRONTS — Read visible signs, restaurant names
5. LANDMARKS — Identify recognizable landmarks, temples, attractions
6. LISTS / RANKINGS — If shown, extract every item
7. MAP PINS — If a map is shown, read the pin labels

Be thorough — scan every pixel of text in every image.

Return JSON:
$_jsonSchema

$_rules''';
  }

  List<ScannedPlace> _parsePlaceResponse(String text) {
    try {
      var cleanedText = text.trim();

      // Remove markdown if present
      if (cleanedText.startsWith('```json')) {
        cleanedText = cleanedText.substring(7);
      } else if (cleanedText.startsWith('```')) {
        cleanedText = cleanedText.substring(3);
      }
      if (cleanedText.endsWith('```')) {
        cleanedText = cleanedText.substring(0, cleanedText.length - 3);
      }
      cleanedText = cleanedText.trim();

      final json = jsonDecode(cleanedText) as Map<String, dynamic>;
      final placesJson = json['places'] as List? ?? [];

      return placesJson.asMap().entries.map((entry) {
        final placeJson = entry.value as Map<String, dynamic>;
        return ScannedPlace.fromJson({
          ...placeJson,
          'id': 'scanned-${entry.key}',
        });
      }).toList();
    } on FormatException {
      throw const AiGenerationException('Could not parse place response.');
    }
  }
}
