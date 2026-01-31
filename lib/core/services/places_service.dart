import 'dart:convert';

import 'package:http/http.dart' as http;

/// Place result from OpenStreetMap Nominatim
class PlaceResult {
  const PlaceResult({
    required this.placeId,
    required this.name,
    required this.displayName,
    required this.lat,
    required this.lon,
    this.type,
    this.category,
    this.address,
  });

  factory PlaceResult.fromNominatim(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>?;
    return PlaceResult(
      placeId: json['place_id']?.toString() ?? '',
      name: json['name'] as String? ??
          json['display_name']?.toString().split(',').first ??
          'Unknown',
      displayName: json['display_name'] as String? ?? '',
      lat: double.tryParse(json['lat']?.toString() ?? '') ?? 0,
      lon: double.tryParse(json['lon']?.toString() ?? '') ?? 0,
      type: json['type'] as String?,
      category: json['category'] as String?,
      address: address != null ? PlaceAddress.fromJson(address) : null,
    );
  }

  final String placeId;
  final String name;
  final String displayName;
  final double lat;
  final double lon;
  final String? type;
  final String? category;
  final PlaceAddress? address;

  /// Get a shortened display address
  String get shortAddress {
    if (address == null) return '';
    final parts = <String>[];
    if (address!.neighbourhood != null) parts.add(address!.neighbourhood!);
    if (address!.suburb != null) parts.add(address!.suburb!);
    if (address!.city != null) parts.add(address!.city!);
    if (address!.country != null) parts.add(address!.country!);
    return parts.take(2).join(', ');
  }
}

/// Address components from Nominatim
class PlaceAddress {
  const PlaceAddress({
    this.houseNumber,
    this.road,
    this.neighbourhood,
    this.suburb,
    this.city,
    this.state,
    this.postcode,
    this.country,
    this.countryCode,
  });

  factory PlaceAddress.fromJson(Map<String, dynamic> json) {
    return PlaceAddress(
      houseNumber: json['house_number'] as String?,
      road: json['road'] as String?,
      neighbourhood: json['neighbourhood'] as String?,
      suburb: json['suburb'] as String?,
      city: json['city'] as String? ??
          json['town'] as String? ??
          json['village'] as String?,
      state: json['state'] as String?,
      postcode: json['postcode'] as String?,
      country: json['country'] as String?,
      countryCode: json['country_code'] as String?,
    );
  }

  final String? houseNumber;
  final String? road;
  final String? neighbourhood;
  final String? suburb;
  final String? city;
  final String? state;
  final String? postcode;
  final String? country;
  final String? countryCode;
}

/// Service for place searches using OpenStreetMap Nominatim (free, no API key)
class PlacesService {
  PlacesService._();

  static PlacesService? _instance;
  static PlacesService get instance => _instance ??= PlacesService._();

  static const _baseUrl = 'https://nominatim.openstreetmap.org';
  static const _userAgent = 'Trippified/1.0 (travel planning app)';

  /// Search for places by query string
  Future<List<PlaceResult>> search(
    String query, {
    String? countryCode,
    int limit = 10,
  }) async {
    if (query.trim().isEmpty) return [];

    final params = {
      'q': query,
      'format': 'json',
      'addressdetails': '1',
      'limit': limit.toString(),
    };

    if (countryCode != null) {
      params['countrycodes'] = countryCode.toLowerCase();
    }

    final uri = Uri.parse('$_baseUrl/search').replace(queryParameters: params);

    final response = await http.get(
      uri,
      headers: {'User-Agent': _userAgent},
    );

    if (response.statusCode != 200) {
      print('Nominatim error: ${response.statusCode}');
      return [];
    }

    final results = jsonDecode(response.body) as List;
    return results
        .map((r) => PlaceResult.fromNominatim(r as Map<String, dynamic>))
        .toList();
  }

  /// Search for places near a coordinate
  Future<List<PlaceResult>> searchNearby({
    required double lat,
    required double lon,
    String? query,
    int radiusMeters = 1000,
    int limit = 10,
  }) async {
    // Nominatim doesn't have a direct "nearby" search, but we can use
    // a bounding box search
    final latDelta = radiusMeters / 111320.0; // ~111km per degree latitude
    final lonDelta = radiusMeters / (111320.0 * _cosine(lat));

    final viewbox =
        '${lon - lonDelta},${lat - latDelta},${lon + lonDelta},${lat + latDelta}';

    final params = {
      'format': 'json',
      'addressdetails': '1',
      'limit': limit.toString(),
      'viewbox': viewbox,
      'bounded': '1',
    };

    if (query != null && query.isNotEmpty) {
      params['q'] = query;
    } else {
      // Default to searching for amenities if no query
      params['q'] = 'restaurant OR cafe OR attraction';
    }

    final uri = Uri.parse('$_baseUrl/search').replace(queryParameters: params);

    final response = await http.get(
      uri,
      headers: {'User-Agent': _userAgent},
    );

    if (response.statusCode != 200) {
      print('Nominatim error: ${response.statusCode}');
      return [];
    }

    final results = jsonDecode(response.body) as List;
    return results
        .map((r) => PlaceResult.fromNominatim(r as Map<String, dynamic>))
        .toList();
  }

  /// Reverse geocode a coordinate to get address info
  Future<PlaceResult?> reverseGeocode({
    required double lat,
    required double lon,
  }) async {
    final params = {
      'lat': lat.toString(),
      'lon': lon.toString(),
      'format': 'json',
      'addressdetails': '1',
    };

    final uri = Uri.parse('$_baseUrl/reverse').replace(queryParameters: params);

    final response = await http.get(
      uri,
      headers: {'User-Agent': _userAgent},
    );

    if (response.statusCode != 200) {
      print('Nominatim error: ${response.statusCode}');
      return null;
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (json.containsKey('error')) {
      return null;
    }

    return PlaceResult.fromNominatim(json);
  }

  /// Get place details by OSM place ID
  Future<PlaceResult?> getPlaceDetails(String placeId) async {
    final params = {
      'place_id': placeId,
      'format': 'json',
      'addressdetails': '1',
    };

    final uri = Uri.parse('$_baseUrl/details').replace(queryParameters: params);

    final response = await http.get(
      uri,
      headers: {'User-Agent': _userAgent},
    );

    if (response.statusCode != 200) {
      print('Nominatim error: ${response.statusCode}');
      return null;
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return PlaceResult.fromNominatim(json);
  }

  /// Search for specific category of places (restaurants, hotels, etc.)
  Future<List<PlaceResult>> searchCategory({
    required String category,
    required String city,
    int limit = 10,
  }) async {
    return search('$category in $city', limit: limit);
  }

  double _cosine(double degrees) {
    return _cos(degrees * 3.14159265359 / 180);
  }

  double _cos(double radians) {
    // Simple cosine approximation
    var x = radians;
    while (x > 3.14159265359) {
      x -= 2 * 3.14159265359;
    }
    while (x < -3.14159265359) {
      x += 2 * 3.14159265359;
    }
    final x2 = x * x;
    return 1 - x2 / 2 + x2 * x2 / 24 - x2 * x2 * x2 / 720;
  }
}
