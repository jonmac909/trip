import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:trippified/core/constants/app_colors.dart';
import 'package:trippified/core/constants/app_spacing.dart';
import 'package:trippified/core/widgets/app_bottom_nav.dart';
import 'package:trippified/presentation/navigation/app_router.dart';

/// Itinerary preview screen showing route overview and day breakdown
class ItineraryPreviewScreen extends StatelessWidget {
  const ItineraryPreviewScreen({
    super.key,
    required this.itineraryId,
  });

  final String itineraryId;

  // Itinerary data - would be loaded from API based on itineraryId
  ItineraryPreviewData get _itinerary {
    // Return empty placeholder - would be populated from API
    return ItineraryPreviewData(
      id: itineraryId,
      title: '',
      subtitle: '',
      description: '',
      imageUrl: '',
      days: 0,
      placeCount: 0,
      cities: const [],
      isSingleCity: true,
      dayOverviews: const [],
      routeStops: const [],
    );
  }

  @override
  Widget build(BuildContext context) {
    final itinerary = _itinerary;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeroSection(context, itinerary),
                  _buildBodySection(itinerary),
                ],
              ),
            ),
          ),
          _buildFooter(context),
          AppBottomNav(
            currentIndex: 1,
            onTap: (index) {
              switch (index) {
                case 0:
                  context.go(AppRoutes.home);
                case 1:
                  context.pop();
                case 2:
                  context.go(AppRoutes.saved);
                case 3:
                  context.go(AppRoutes.profile);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, ItineraryPreviewData itinerary) {
    return SizedBox(
      height: 220,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: itinerary.imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: AppColors.shimmerBase,
            ),
            errorWidget: (context, url, error) => Container(
              color: AppColors.shimmerBase,
              child: const Icon(
                LucideIcons.image,
                color: AppColors.textTertiary,
              ),
            ),
          ),
          // Gradient overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.5),
                  ],
                ),
              ),
            ),
          ),
          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 20,
            child: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.arrowLeft,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // Title overlay
          Positioned(
            left: 20,
            bottom: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  itinerary.title,
                  style: GoogleFonts.dmSans(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  itinerary.subtitle,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodySection(ItineraryPreviewData itinerary) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          Text(
            itinerary.description,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Stats row
          _buildStatsRow(itinerary),
          const SizedBox(height: AppSpacing.lg),
          // Route or Day Overview
          if (itinerary.isSingleCity)
            _buildDayOverview(itinerary)
          else
            _buildRouteOverview(itinerary),
        ],
      ),
    );
  }

  Widget _buildStatsRow(ItineraryPreviewData itinerary) {
    return Row(
      children: [
        Text(
          '${itinerary.days} days',
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        Text(
          ' \u00b7 ',
          style: GoogleFonts.dmSans(
            fontSize: 13,
            color: AppColors.textTertiary,
          ),
        ),
        Text(
          itinerary.isSingleCity
              ? '${itinerary.placeCount} places'
              : '${itinerary.cities.length} cities',
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          ' \u00b7 ',
          style: GoogleFonts.dmSans(
            fontSize: 13,
            color: AppColors.textTertiary,
          ),
        ),
        Text(
          itinerary.isSingleCity
              ? itinerary.cities.first
              : '${itinerary.placeCount} places',
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDayOverview(ItineraryPreviewData itinerary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: AppColors.border, height: 1),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Day Overview',
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...itinerary.dayOverviews.map((day) => _DayOverviewItem(day: day)),
      ],
    );
  }

  Widget _buildRouteOverview(ItineraryPreviewData itinerary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Route Overview',
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...itinerary.routeStops.asMap().entries.map((entry) {
          final index = entry.key;
          final stop = entry.value;
          final isLast = index == itinerary.routeStops.length - 1;
          return _RouteStopItem(
            stop: stop,
            showConnector: !isLast,
            nextTravelInfo: isLast
                ? null
                : itinerary.routeStops[index + 1].travelInfo,
          );
        }),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          // Save button
          Expanded(
            child: GestureDetector(
              onTap: () {
                // Save itinerary
              },
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Center(
                  child: Text(
                    'Save Itinerary',
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Use This Trip button
          Expanded(
            child: GestureDetector(
              onTap: () {
                // Navigate to create trip with this itinerary
                context.push(AppRoutes.tripSetup);
              },
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Use This Trip',
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      LucideIcons.arrowRight,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayOverviewItem extends StatelessWidget {
  const _DayOverviewItem({required this.day});

  final DayOverviewData day;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          // Day number circle
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${day.day}',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Day info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day.title,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  day.description,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteStopItem extends StatelessWidget {
  const _RouteStopItem({
    required this.stop,
    required this.showConnector,
    this.nextTravelInfo,
  });

  final RouteStopData stop;
  final bool showConnector;
  final String? nextTravelInfo;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // City row
        Row(
          children: [
            // Dot
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            // City info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stop.city,
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${stop.days} days',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        // Connector
        if (showConnector && nextTravelInfo != null)
          Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Row(
              children: [
                Container(
                  width: 2,
                  height: 20,
                  color: AppColors.border,
                ),
                const SizedBox(width: 17),
                Text(
                  nextTravelInfo!,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// Data classes
class ItineraryPreviewData {
  const ItineraryPreviewData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imageUrl,
    required this.days,
    required this.placeCount,
    required this.cities,
    required this.isSingleCity,
    required this.dayOverviews,
    required this.routeStops,
  });

  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String imageUrl;
  final int days;
  final int placeCount;
  final List<String> cities;
  final bool isSingleCity;
  final List<DayOverviewData> dayOverviews;
  final List<RouteStopData> routeStops;
}

class DayOverviewData {
  const DayOverviewData({
    required this.day,
    required this.title,
    required this.description,
  });

  final int day;
  final String title;
  final String description;
}

class RouteStopData {
  const RouteStopData({
    required this.city,
    required this.days,
    required this.travelInfo,
  });

  final String city;
  final int days;
  final String? travelInfo;
}
