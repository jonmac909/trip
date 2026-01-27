import 'dart:typed_data';

import 'package:trippified/core/services/gemini_service.dart';
import 'package:trippified/core/services/social_media_metadata_service.dart';
import 'package:trippified/domain/models/scanned_place.dart';

/// Input type for content scanning
enum ScanInputType { url, images, video }

/// Result from a content scan
class ScanResult {
  const ScanResult({
    required this.places,
    required this.inputType,
    this.sourceUrl,
    this.sourceLabel,
  });

  final List<ScannedPlace> places;
  final ScanInputType inputType;
  final String? sourceUrl;
  final String? sourceLabel;
}

/// Orchestrates content scanning from URLs or media uploads
class ContentScanService {
  ContentScanService({
    GeminiService? geminiService,
    SocialMediaMetadataService? metadataService,
  })  : _gemini = geminiService ?? GeminiService.instance,
        _metadata = metadataService ?? SocialMediaMetadataService();

  final GeminiService _gemini;
  final SocialMediaMetadataService _metadata;

  /// Scan a TikTok/Instagram URL for places.
  ///
  /// Uses oEmbed to get the caption text + video thumbnail, then sends
  /// both to Gemini for multimodal analysis (text + vision).
  Future<ScanResult> scanUrl(String url) async {
    final meta = await _metadata.extractMetadata(url);

    // Use multimodal (text + thumbnail) when we have the image,
    // otherwise fall back to text-only analysis.
    final List<ScannedPlace> places;
    if (meta.thumbnailBytes != null) {
      places = await _gemini.extractPlacesFromTextAndImage(
        captionText: meta.captionText,
        imageBytes: meta.thumbnailBytes!,
      );
    } else {
      places = await _gemini.extractPlacesFromText(meta.captionText);
    }

    final sourceLabel = meta.authorHandle != null
        ? '@${meta.authorHandle}'
        : _extractDomain(url);

    return ScanResult(
      places: places,
      inputType: ScanInputType.url,
      sourceUrl: url,
      sourceLabel: sourceLabel,
    );
  }

  /// Scan uploaded images (screenshots) for places
  Future<ScanResult> scanImages(List<Uint8List> imageBytesList) async {
    final places = await _gemini.extractPlacesFromImages(imageBytesList);
    final count = imageBytesList.length;
    return ScanResult(
      places: places,
      inputType: ScanInputType.images,
      sourceLabel: '$count screenshot${count > 1 ? 's' : ''}',
    );
  }

  /// Scan uploaded video (screen recording) for places
  Future<ScanResult> scanVideo(Uint8List videoBytes) async {
    final places = await _gemini.extractPlacesFromVideo(videoBytes);
    return ScanResult(
      places: places,
      inputType: ScanInputType.video,
      sourceLabel: 'Screen recording',
    );
  }

  String _extractDomain(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return 'Social media';
    if (uri.host.contains('tiktok')) return 'TikTok video';
    if (uri.host.contains('instagram')) return 'Instagram post';
    return uri.host;
  }
}
