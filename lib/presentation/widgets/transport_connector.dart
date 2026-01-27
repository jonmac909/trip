import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:trippified/core/constants/app_colors.dart';
import 'package:trippified/core/constants/app_spacing.dart';

/// Transport type enum
enum TransportType {
  train,
  plane,
  bus,
  car,
  ferry,
  walk,
}

/// Shows transport type and duration between cities
/// Matches design 47/48 (Itinerary Blocks / Trip Dashboard)
class TransportConnector extends StatelessWidget {
  const TransportConnector({
    super.key,
    required this.transportType,
    required this.duration,
    this.destination,
    this.onTap,
  });

  final TransportType transportType;
  final String duration;
  final String? destination;
  final VoidCallback? onTap;

  IconData get _icon {
    switch (transportType) {
      case TransportType.train:
        return LucideIcons.train;
      case TransportType.plane:
        return LucideIcons.plane;
      case TransportType.bus:
        return LucideIcons.bus;
      case TransportType.car:
        return LucideIcons.car;
      case TransportType.ferry:
        return LucideIcons.ship;
      case TransportType.walk:
        return LucideIcons.footprints;
    }
  }

  String get _transportText {
    final typeText = switch (transportType) {
      TransportType.train => 'by train',
      TransportType.plane => 'flight',
      TransportType.bus => 'by bus',
      TransportType.car => 'by car',
      TransportType.ferry => 'by ferry',
      TransportType.walk => 'walk',
    };

    if (destination != null) {
      return '$duration $typeText to $destination';
    }
    return '$duration $typeText';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(left: 40),
        child: Row(
          children: [
            // Vertical line
            Container(
              width: 1,
              height: 20,
              color: AppColors.border,
            ),
            const SizedBox(width: 6),
            // Transport info
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _icon,
                  size: 14,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: 6),
                Text(
                  _transportText,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact transport connector for dashboard view
/// Shows emoji + text format
class DashboardTransportConnector extends StatelessWidget {
  const DashboardTransportConnector({
    super.key,
    required this.transportType,
    required this.duration,
  });

  final TransportType transportType;
  final String duration;

  String get _emoji {
    return switch (transportType) {
      TransportType.train => '\u{1F682}',
      TransportType.plane => '\u{2708}\u{FE0F}',
      TransportType.bus => '\u{1F68C}',
      TransportType.car => '\u{1F697}',
      TransportType.ferry => '\u{26F4}\u{FE0F}',
      TransportType.walk => '\u{1F6B6}',
    };
  }

  String get _typeText {
    return switch (transportType) {
      TransportType.train => 'train',
      TransportType.plane => 'flight',
      TransportType.bus => 'bus',
      TransportType.car => 'car',
      TransportType.ferry => 'ferry',
      TransportType.walk => 'walk',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 26),
      child: Row(
        children: [
          Container(
            width: 2,
            height: 20,
            color: AppColors.border,
          ),
          const SizedBox(width: 8),
          Text(
            '$_emoji $duration $_typeText',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Vertical connector line with optional add button
class VerticalConnector extends StatelessWidget {
  const VerticalConnector({
    super.key,
    this.showAddButton = false,
    this.onAdd,
  });

  final bool showAddButton;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 2,
            height: double.infinity,
            color: AppColors.border,
          ),
          if (showAddButton)
            GestureDetector(
              onTap: onAdd,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  shape: BoxShape.circle,
                  border: Border.fromBorderSide(
                    BorderSide(color: AppColors.border),
                  ),
                ),
                child: const Icon(
                  LucideIcons.plus,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
