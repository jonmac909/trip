import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:trippified/core/constants/app_colors.dart';
import 'package:trippified/core/constants/app_spacing.dart';

/// Day status enum
enum DayStatus {
  empty,
  generated,
  custom,
}

/// Data model for a day's activity preview
class DayActivityPreview {
  const DayActivityPreview({
    required this.name,
    this.isAnchor = false,
  });

  final String name;
  final bool isAnchor;
}

/// Day planning card with Generate button for empty days
/// or Edit button and activity preview for generated days
class DayCard extends StatelessWidget {
  const DayCard({
    super.key,
    required this.dayNumber,
    this.date,
    required this.status,
    this.themeLabel,
    this.activityCount = 0,
    this.activityPreviews,
    this.isRefreshing = false,
    this.onGenerate,
    this.onEdit,
    this.onTap,
    this.onRefresh,
  });

  final int dayNumber;
  final String? date;
  final DayStatus status;
  final String? themeLabel;
  final int activityCount;
  final List<DayActivityPreview>? activityPreviews;
  final bool isRefreshing;
  final VoidCallback? onGenerate;
  final VoidCallback? onEdit;
  final VoidCallback? onTap;
  final VoidCallback? onRefresh;

  String get _statusText {
    if (themeLabel != null && status != DayStatus.empty) {
      return '$date \u00b7 $themeLabel';
    }
    switch (status) {
      case DayStatus.empty:
        return '$date \u00b7 Free day';
      case DayStatus.generated:
        return '$date \u00b7 $activityCount activities';
      case DayStatus.custom:
        return '$date \u00b7 $activityCount activities';
    }
  }

  bool get _hasActivityPreviews =>
      activityPreviews != null && activityPreviews!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    // Use expanded card for generated days with previews
    if (status != DayStatus.empty && _hasActivityPreviews) {
      return _buildExpandedCard(context);
    }

    return _buildCompactCard(context);
  }

  Widget _buildCompactCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Day info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Day $dayNumber',
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _statusText,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (status != DayStatus.empty && onRefresh != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: GestureDetector(
                        onTap: isRefreshing ? null : onRefresh,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isRefreshing)
                              const SizedBox(
                                width: 10,
                                height: 10,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  color: AppColors.textSecondary,
                                ),
                              )
                            else
                              const Icon(
                                LucideIcons.refreshCw,
                                size: 11,
                                color: AppColors.primary,
                              ),
                            const SizedBox(width: 4),
                            Text(
                              isRefreshing ? 'Refreshing...' : 'Refresh',
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isRefreshing
                                    ? AppColors.textSecondary
                                    : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Generate/Edit button
            if (status == DayStatus.empty && onGenerate != null)
              _GenerateButton(onTap: onGenerate!)
            else if (status != DayStatus.empty && onEdit != null)
              _EditButton(onTap: onEdit!),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Day $dayNumber',
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _statusText,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onEdit != null) _EditButton(onTap: onEdit!),
              ],
            ),
            // Activity previews
            if (_hasActivityPreviews) ...[
              const SizedBox(height: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: activityPreviews!.map((activity) {
                    final text = activity.isAnchor
                        ? '\u2022 ${activity.name} (anchor)'
                        : '\u2022 ${activity.name}';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        text,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: const Color(0xFF4B5563),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
            // Refresh link
            if (onRefresh != null) ...[
              GestureDetector(
                onTap: isRefreshing ? null : onRefresh,
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isRefreshing)
                        const SizedBox(
                          width: 11,
                          height: 11,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: AppColors.textSecondary,
                          ),
                        )
                      else
                        const Icon(
                          LucideIcons.refreshCw,
                          size: 12,
                          color: AppColors.primary,
                        ),
                      const SizedBox(width: 4),
                      Text(
                        isRefreshing ? 'Refreshing...' : 'Refresh',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isRefreshing
                              ? AppColors.textSecondary
                              : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GenerateButton extends StatelessWidget {
  const _GenerateButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Generate',
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textOnPrimary,
          ),
        ),
      ),
    );
  }
}

class _EditButton extends StatelessWidget {
  const _EditButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
        child: Text(
          'Edit',
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
