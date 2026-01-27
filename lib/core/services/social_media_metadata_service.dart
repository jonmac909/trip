import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'package:trippified/core/errors/exceptions.dart';

/// Metadata extracted from a social media URL.
class SocialMediaMetadata {
  const SocialMediaMetadata({
    required this.captionText,
    this.thumbnailBytes,
    this.authorHandle,
    this.authorName,
  });

  final String captionText;
  final Uint8List? thumbnailBytes;
  final String? authorHandle;
  final String? authorName;
}

/// Extracts text metadata from TikTok/Instagram URLs.
///
/// TikTok: uses the public oEmbed API (no auth required).
/// Instagram: falls back to HTML og: meta tag scraping.
class SocialMediaMetadataService {
  SocialMediaMetadataService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  static const _allowedHosts = [
    'tiktok.com',
    'www.tiktok.com',
    'vm.tiktok.com',
    'vt.tiktok.com',
    'instagram.com',
    'www.instagram.com',
  ];

  static const _tiktokHosts = [
    'tiktok.com',
    'www.tiktok.com',
    'vm.tiktok.com',
    'vt.tiktok.com',
  ];

  /// Fetch metadata (caption, thumbnail, author) from a TikTok or Instagram
  /// URL.
  Future<SocialMediaMetadata> extractMetadata(String url) async {
    _validateUrl(url);

    final uri = Uri.parse(url);
    final isTiktok = _tiktokHosts.any(
      (host) => uri.host == host || uri.host.endsWith('.$host'),
    );

    try {
      if (isTiktok) {
        return _fetchTiktokOembed(url);
      }
      final text = await _fetchHtmlMetadata(url);
      return SocialMediaMetadata(captionText: text);
    } on TrippifiedException {
      rethrow;
    } catch (e) {
      throw const ExternalServiceException(
        'Could not fetch content from URL. '
        'Try uploading a screenshot instead.',
      );
    }
  }

  void _validateUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) {
      throw const ValidationException('Please enter a valid URL');
    }
  }

  // ---------------------------------------------------------------------------
  // TikTok oEmbed API
  // ---------------------------------------------------------------------------

  /// Use TikTok's public oEmbed endpoint to get caption + thumbnail.
  Future<SocialMediaMetadata> _fetchTiktokOembed(String url) async {
    final cleanUrl = _stripQueryParams(url);

    final oembedUri = Uri.https(
      'www.tiktok.com',
      '/oembed',
      {'url': cleanUrl},
    );
    final response = await _client
        .get(oembedUri, headers: _defaultHeaders)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw ExternalServiceException(
        'Could not fetch content from TikTok '
        '(status ${response.statusCode}). '
        'The link may be private or invalid.',
      );
    }

    final Map<String, dynamic> json;
    try {
      json = jsonDecode(response.body) as Map<String, dynamic>;
    } on FormatException {
      throw const ExternalServiceException(
        'TikTok returned an unexpected response. '
        'Try uploading a screenshot instead.',
      );
    }

    final title = json['title'] as String?;
    if (title == null || title.trim().isEmpty) {
      throw const ExternalServiceException(
        'No caption found in this TikTok. '
        'Try uploading a screenshot instead.',
      );
    }

    final authorName = json['author_name'] as String?;
    final authorHandle = json['author_unique_id'] as String?;
    final thumbnailUrl = json['thumbnail_url'] as String?;

    // Build caption text
    final captionParts = <String>[title.trim()];
    if (authorName != null && authorName.trim().isNotEmpty) {
      captionParts.add('Creator: $authorName');
    }

    // Download the video thumbnail for vision analysis
    Uint8List? thumbnailBytes;
    if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) {
      thumbnailBytes = await _downloadImage(thumbnailUrl);
    }

    return SocialMediaMetadata(
      captionText: captionParts.join('\n\n'),
      thumbnailBytes: thumbnailBytes,
      authorHandle: authorHandle,
      authorName: authorName,
    );
  }

  /// Download an image and return its bytes. Returns null on failure.
  Future<Uint8List?> _downloadImage(String imageUrl) async {
    try {
      final response = await _client
          .get(Uri.parse(imageUrl))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
    } catch (_) {
      // Non-critical — proceed without thumbnail
    }
    return null;
  }

  String _stripQueryParams(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return url;
    return uri.replace(query: '').toString().replaceAll('?', '');
  }

  // ---------------------------------------------------------------------------
  // HTML fallback (Instagram)
  // ---------------------------------------------------------------------------

  Future<String> _fetchHtmlMetadata(String url) async {
    final response = await _client
        .get(Uri.parse(url), headers: _defaultHeaders)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw const ExternalServiceException(
        'Could not fetch content from URL. '
        'The link may be private or invalid.',
      );
    }

    return _parseHtmlMetadata(response.body);
  }

  Map<String, String> get _defaultHeaders => const {
        'User-Agent':
            'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) '
            'AppleWebKit/537.36 (KHTML, like Gecko) '
            'Chrome/120.0.0.0 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml',
      };

  String _parseHtmlMetadata(String html) {
    final parts = <String>{};

    final ogDesc = _extractMeta(
      html,
      r'<meta[^>]*property="og:description"[^>]*content="([^"]*)"',
    );
    if (ogDesc != null) parts.add(ogDesc);

    final ogTitle = _extractMeta(
      html,
      r'<meta[^>]*property="og:title"[^>]*content="([^"]*)"',
    );
    if (ogTitle != null) parts.add(ogTitle);

    final title = _extractMeta(
      html,
      r'<title>([^<]+)</title>',
    );
    if (title != null) parts.add(title);

    final desc = _extractMeta(
      html,
      r'<meta[^>]*name="description"[^>]*content="([^"]*)"',
    );
    if (desc != null) parts.add(desc);

    if (parts.isEmpty) {
      throw const ExternalServiceException(
        'Could not extract any content from this URL. '
        'Try uploading a screenshot instead.',
      );
    }

    return parts.join('\n\n');
  }

  String? _extractMeta(String html, String pattern) {
    final match = RegExp(pattern, caseSensitive: false).firstMatch(html);
    final value = match?.group(1);
    if (value == null || value.trim().isEmpty) return null;
    return _decodeHtmlEntities(value.trim());
  }

  String _decodeHtmlEntities(String text) {
    return text
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&#x27;', "'");
  }
}
