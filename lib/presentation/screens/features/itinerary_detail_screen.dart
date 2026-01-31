import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:trippified/core/constants/app_colors.dart';
import 'package:trippified/core/constants/app_spacing.dart';

/// Itinerary detail screen showing full itinerary view
class ItineraryDetailScreen extends StatelessWidget {
  const ItineraryDetailScreen({
    super.key,
    required this.itineraryId,
  });

  final String itineraryId;

  @override
  Widget build(BuildContext context) {
    // Itinerary data - would be passed via navigation or loaded from API
    const itinerary = _ItineraryData(
      title: '',
      description: '',
      creatorName: '',
      creatorMeta: '',
      creatorAvatarUrl: '',
      heroImageUrl: '',
      days: 0,
      city: '',
      placesCount: 0,
      savesCount: '',
    );

    final List<_DayPreview> days = [];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroImage(context, itinerary.heroImageUrl),
            _buildContent(context, itinerary, days),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImage(BuildContext context, String imageUrl) {
    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl: imageUrl,
          height: 280,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            height: 280,
            color: AppColors.shimmerBase,
          ),
          errorWidget: (context, url, error) => Container(
            height: 280,
            color: AppColors.shimmerBase,
          ),
        ),
        // Back button
        Positioned(
          top: MediaQuery.of(context).padding.top + AppSpacing.sm,
          left: AppSpacing.md,
          child: GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.black26,
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
      ],
    );
  }

  Widget _buildContent(
    BuildContext context,
    _ItineraryData itinerary,
    List<_DayPreview> days,
  ) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCreatorRow(itinerary),
          const SizedBox(height: AppSpacing.lg),
          _buildTitleSection(itinerary),
          const SizedBox(height: AppSpacing.lg),
          _buildStatsRow(itinerary),
          const SizedBox(height: AppSpacing.lg),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: AppSpacing.lg),
          _buildPreviewSection(days),
          const SizedBox(height: AppSpacing.lg),
          _buildButtons(context),
        ],
      ),
    );
  }

  Widget _buildCreatorRow(_ItineraryData itinerary) {
    return Row(
      children: [
        ClipOval(
          child: CachedNetworkImage(
            imageUrl: itinerary.creatorAvatarUrl,
            width: 48,
            height: 48,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: 48,
              height: 48,
              color: AppColors.shimmerBase,
            ),
            errorWidget: (context, url, error) => Container(
              width: 48,
              height: 48,
              color: AppColors.shimmerBase,
              child: const Icon(LucideIcons.user),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                itinerary.creatorName,
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                itinerary.creatorMeta,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.secondaryDark,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          child: Text(
            'Follow',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textOnPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleSection(_ItineraryData itinerary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          itinerary.title,
          style: GoogleFonts.dmSans(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          itinerary.description,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            height: 1.5,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(_ItineraryData itinerary) {
    return Row(
      children: [
        _StatItem(
          icon: LucideIcons.calendar,
          text: '${itinerary.days} days \u00b7 ${itinerary.city}',
        ),
        const SizedBox(width: AppSpacing.lg),
        _StatItem(
          icon: LucideIcons.mapPin,
          text: '${itinerary.placesCount} places',
        ),
        const SizedBox(width: AppSpacing.lg),
        _StatItem(
          icon: LucideIcons.bookmark,
          text: '${itinerary.savesCount} saves',
        ),
      ],
    );
  }

  Widget _buildPreviewSection(List<_DayPreview> days) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "What's Inside",
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...days.map((day) => _DayPreviewCard(day: day)),
        const SizedBox(height: AppSpacing.sm),
        Center(
          child: Text(
            '+ 4 more days',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Itinerary saved!')),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppColors.border),
              ),
              alignment: Alignment.center,
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
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: GestureDetector(
            onTap: () {
              context.push('/features/stacking');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Use This Trip',
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textOnAccent,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  const Icon(
                    LucideIcons.arrowRight,
                    size: 18,
                    color: AppColors.textOnAccent,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.xs),
        Text(
          text,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _DayPreviewCard extends StatelessWidget {
  const _DayPreviewCard({required this.day});

  final _DayPreview day;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: day.isHighlighted ? AppColors.accent : AppColors.border,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Text(
                '${day.number}',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: day.isHighlighted
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    day.title,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    '${day.placesCount} places',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              LucideIcons.chevronRight,
              size: 18,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

class _ItineraryData {
  const _ItineraryData({
    required this.title,
    required this.description,
    required this.creatorName,
    required this.creatorMeta,
    required this.creatorAvatarUrl,
    required this.heroImageUrl,
    required this.days,
    required this.city,
    required this.placesCount,
    required this.savesCount,
  });

  final String title;
  final String description;
  final String creatorName;
  final String creatorMeta;
  final String creatorAvatarUrl;
  final String heroImageUrl;
  final int days;
  final String city;
  final int placesCount;
  final String savesCount;
}

class _DayPreview {
  const _DayPreview({
    required this.number,
    required this.title,
    required this.placesCount,
    required this.isHighlighted,
  });

  final int number;
  final String title;
  final int placesCount;
  final bool isHighlighted;
}
