import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:trippified/core/constants/app_colors.dart';
import 'package:trippified/core/constants/app_spacing.dart';

/// Route card with horizontal layout: image on left, content on right
/// Matches design 45/46 (Routes screens)
class RouteCard extends StatelessWidget {
  const RouteCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.duration,
    required this.cityCount,
    required this.cities,
    this.isFeatured = false,
    this.isSelected = false,
    required this.onTap,
  });

  final String title;
  final String imageUrl;
  final String duration;
  final int cityCount;
  final List<String> cities;
  final bool isFeatured;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 136,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Image section (left)
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(
                  isSelected
                      ? AppSpacing.radiusXl - 2
                      : AppSpacing.radiusXl - 1,
                ),
                bottomLeft: Radius.circular(
                  isSelected
                      ? AppSpacing.radiusXl - 2
                      : AppSpacing.radiusXl - 1,
                ),
              ),
              child: SizedBox(
                width: 100,
                height: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
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
              ),
            ),
            // Content section (right)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Header row with title and featured badge
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                title,
                                style: GoogleFonts.dmSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$duration \u2022 ${cityCount == 1 ? '1 city' : '$cityCount cities'}',
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isFeatured)
                          Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              LucideIcons.star,
                              size: 14,
                              color: AppColors.primary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // City flow
                    Flexible(
                      child: _CityFlow(cities: cities),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CityFlow extends StatelessWidget {
  const _CityFlow({required this.cities});

  final List<String> cities;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (int i = 0; i < cities.length; i++) ...[
          _CityChip(name: cities[i]),
          if (i < cities.length - 1)
            const Icon(
              LucideIcons.arrowRight,
              size: 14,
              color: AppColors.textTertiary,
            ),
        ],
      ],
    );
  }
}

class _CityChip extends StatelessWidget {
  const _CityChip({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        name,
        style: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
