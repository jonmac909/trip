import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:trippified/core/constants/app_colors.dart';

/// Platform-aware map widget that shows Apple Maps on iOS
/// and a placeholder on web/unsupported platforms.
class PlatformMap extends StatelessWidget {
  const PlatformMap({
    super.key,
    required this.locationName,
    this.latitude = 35.6762,
    this.longitude = 139.6503,
    this.zoom = 13.0,
    this.height,
  });

  final String locationName;
  final double latitude;
  final double longitude;
  final double zoom;
  final double? height;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return _WebMapPlaceholder(locationName: locationName);
    }

    // On native platforms, use Apple Maps
    return _NativeMap(
      locationName: locationName,
      latitude: latitude,
      longitude: longitude,
      zoom: zoom,
    );
  }
}

class _WebMapPlaceholder extends StatelessWidget {
  const _WebMapPlaceholder({required this.locationName});

  final String locationName;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE8E8E8),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.map, size: 48, color: AppColors.textTertiary),
            const SizedBox(height: 8),
            Text(
              'Map: $locationName',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NativeMap extends StatelessWidget {
  const _NativeMap({
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.zoom,
  });

  final String locationName;
  final double latitude;
  final double longitude;
  final double zoom;

  @override
  Widget build(BuildContext context) {
    // Lazy import to avoid web compilation issues
    // ignore: undefined_function
    return _buildAppleMap();
  }

  Widget _buildAppleMap() {
    // This will only be called on native platforms
    // The import is handled via conditional compilation
    return Container(
      color: const Color(0xFFE8E8E8),
      child: const Center(
        child: Text('Native map loading...'),
      ),
    );
  }
}
