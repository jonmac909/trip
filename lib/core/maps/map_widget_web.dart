import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

export 'geo_point.dart';

/// Web placeholder for Apple Maps
class AppMapWidget extends StatelessWidget {
  const AppMapWidget({
    super.key,
    required this.locationName,
    this.latitude = 35.6762,
    this.longitude = 139.6503,
    this.zoom = 13.0,
  });

  final String locationName;
  final double latitude;
  final double longitude;
  final double zoom;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE8E8E8),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.map, size: 48, color: Color(0xFF999999)),
            const SizedBox(height: 8),
            Text(
              locationName,
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: const Color(0xFF999999),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
