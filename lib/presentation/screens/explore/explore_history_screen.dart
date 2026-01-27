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

  // Sample data matching the design JSON
  static const _itineraries = [
    _ItineraryGridData(
      title: 'Ancient Rome',
      subtitle: 'Italy \u00b7 7 days',
      imageUrl:
          'https://images.unsplash.com/photo-1717445123544-a4543034d33e?w=400&q=80',
    ),
    _ItineraryGridData(
      title: 'Egyptian Wonders',
      subtitle: 'Egypt \u00b7 10 days',
      imageUrl:
          'https://images.unsplash.com/photo-1761688150081-03d62cc49678?w=400&q=80',
    ),
    _ItineraryGridData(
      title: 'Incan Trail',
      subtitle: 'Peru \u00b7 12 days',
      imageUrl:
          'https://images.unsplash.com/photo-1615239684960-f443deb29a61?w=400&q=80',
    ),
    _ItineraryGridData(
      title: 'Greek Odyssey',
      subtitle: 'Greece \u00b7 8 days',
      imageUrl:
          'https://images.unsplash.com/photo-1733338684434-399686e8cde8?w=400&q=80',
    ),
    _ItineraryGridData(
      title: 'Imperial China',
      subtitle: 'China \u00b7 14 days',
      imageUrl:
          'https://images.unsplash.com/photo-1539987225288-7d998989461e?w=400&q=80',
    ),
    _ItineraryGridData(
      title: 'Golden Triangle',
      subtitle: 'India \u00b7 9 days',
      imageUrl:
          'https://images.unsplash.com/photo-1679395397579-2094cbc46731?w=400&q=80',
    ),
  ];

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
