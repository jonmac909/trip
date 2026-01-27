import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:trippified/core/constants/app_colors.dart';
import 'package:trippified/core/constants/app_spacing.dart';

/// Draggable city card with edit functionality
/// Matches design 47 (Itinerary Blocks)
class CityBlock extends StatelessWidget {
  const CityBlock({
    super.key,
    required this.cityName,
    required this.days,
    this.isSelected = false,
    this.onEdit,
    this.onTap,
    this.onRemove,
  });

  final String cityName;
  final int days;
  final bool isSelected;
  final VoidCallback? onEdit;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFF2A2A2E),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Drag handle
            const Icon(
              LucideIcons.gripVertical,
              size: 18,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 14),
            // City info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    cityName,
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '$days ${days == 1 ? 'day' : 'days'}',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (onEdit != null) ...[
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: onEdit,
                          child: const Icon(
                            LucideIcons.pencil,
                            size: 12,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Remove button
            if (onRemove != null)
              GestureDetector(
                onTap: onRemove,
                child: const Icon(
                  LucideIcons.x,
                  size: 18,
                  color: AppColors.textTertiary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Country section header with flag and drag handle
/// Matches design 47 (Itinerary Blocks)
class CountrySectionHeader extends StatelessWidget {
  const CountrySectionHeader({
    super.key,
    required this.countryName,
    required this.flag,
  });

  final String countryName;
  final String flag;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          const Icon(
            LucideIcons.gripVertical,
            size: 18,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            '$flag $countryName',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
