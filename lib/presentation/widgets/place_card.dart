import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:trippified/core/constants/app_colors.dart';
import 'package:trippified/core/constants/app_spacing.dart';
import 'package:trippified/domain/models/place.dart';

/// Card for displaying places (restaurants, attractions, etc.)
class PlaceCard extends StatelessWidget {
  const PlaceCard({
    super.key,
    required this.place,
    this.onTap,
    this.onSave,
    this.isSaved = false,
  });

  final Place place;
  final VoidCallback? onTap;
  final VoidCallback? onSave;
  final bool isSaved;

  IconData get _typeIcon {
    switch (place.type) {
      case PlaceType.restaurant:
        return LucideIcons.utensils;
      case PlaceType.attraction:
        return LucideIcons.mapPin;
      case PlaceType.hotel:
        return LucideIcons.bed;
      case PlaceType.cafe:
        return LucideIcons.coffee;
      case PlaceType.bar:
        return LucideIcons.wine;
      case PlaceType.shopping:
        return LucideIcons.shoppingBag;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSpacing.radiusLg - 1),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: place.imageUrl,
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
                    // Save button
                    if (onSave != null)
                      Positioned(
                        top: AppSpacing.sm,
                        right: AppSpacing.sm,
                        child: GestureDetector(
                          onTap: onSave,
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.background.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isSaved
                                  ? LucideIcons.bookmark
                                  : LucideIcons.bookmark,
                              size: 18,
                              color: isSaved
                                  ? AppColors.accent
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    // Open/Closed badge
                    Positioned(
                      bottom: AppSpacing.sm,
                      left: AppSpacing.sm,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: place.isOpen
                              ? AppColors.success.withValues(alpha: 0.9)
                              : AppColors.error.withValues(alpha: 0.9),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusFull),
                        ),
                        child: Text(
                          place.isOpen ? 'Open' : 'Closed',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textOnPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row
                  Row(
                    children: [
                      Icon(
                        _typeIcon,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          place.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  // Location
                  Text(
                    place.location,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Rating and reviews
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.star,
                        size: 14,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        place.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '(${place.reviewCount})',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact place card for horizontal lists
class PlaceCardCompact extends StatelessWidget {
  const PlaceCardCompact({
    super.key,
    required this.place,
    this.onTap,
    this.width = 200,
  });

  final Place place;
  final VoidCallback? onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusLg - 1),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: CachedNetworkImage(
                    imageUrl: place.imageUrl,
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
              // Content
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.star,
                          size: 12,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: AppSpacing.xxs),
                        Text(
                          place.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
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
