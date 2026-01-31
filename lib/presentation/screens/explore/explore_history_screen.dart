import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:trippified/core/constants/app_colors.dart';
import 'package:trippified/core/constants/app_spacing.dart';

/// Screen showing all History & Culture itineraries
class ExploreHistoryScreen extends StatelessWidget {
  const ExploreHistoryScreen({super.key});

  // Itineraries data - populated from API
  static const List<_ItineraryGridData> _itineraries = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Icon(
                          LucideIcons.arrowLeft,
                          size: 20,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  // Title
                  Text(
                    'History & Culture',
                    style: GoogleFonts.dmSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            // Grid content
            Expanded(
              child: _buildGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Column 1
          Expanded(
            child: Column(
              children: [
                for (int i = 0; i < _itineraries.length; i += 2)
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: i < _itineraries.length - 2
                          ? AppSpacing.sm
                          : 0,
                    ),
                    child: _ItineraryGridCard(itinerary: _itineraries[i]),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Column 2
          Expanded(
            child: Column(
              children: [
                for (int i = 1; i < _itineraries.length; i += 2)
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: i < _itineraries.length - 1
                          ? AppSpacing.sm
                          : 0,
                    ),
                    child: _ItineraryGridCard(itinerary: _itineraries[i]),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ItineraryGridCard extends StatelessWidget {
  const _ItineraryGridCard({required this.itinerary});

  final _ItineraryGridData itinerary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to itinerary detail
      },
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: itinerary.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => const ColoredBox(
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
                        Colors.black.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                ),
              ),
              // Content
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      itinerary.title,
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      itinerary.subtitle,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItineraryGridData {
  const _ItineraryGridData({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
  });

  final String title;
  final String subtitle;
  final String imageUrl;
}
