import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

import 'package:trippified/core/constants/app_colors.dart';
import 'package:trippified/core/constants/app_spacing.dart';

/// Row item for history lists
class HistoryItem extends StatelessWidget {
  const HistoryItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    this.imageUrl,
    this.icon,
    this.onTap,
    this.onDelete,
  });

  final String title;
  final String subtitle;
  final DateTime timestamp;
  final String? imageUrl;
  final IconData? icon;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  String get _formattedTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Image or icon
            if (imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                child: CachedNetworkImage(
                  imageUrl: imageUrl!,
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
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Icon(
                      icon ?? LucideIcons.clock,
                      size: 24,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              )
            else
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(
                  icon ?? LucideIcons.clock,
                  size: 24,
                  color: AppColors.textSecondary,
                ),
              ),
            const SizedBox(width: AppSpacing.sm),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Timestamp and actions
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formattedTime,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
                if (onDelete != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  GestureDetector(
                    onTap: onDelete,
                    child: const Icon(
                      LucideIcons.x,
                      size: 16,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple history item without container
class HistoryItemSimple extends StatelessWidget {
  const HistoryItemSimple({
    super.key,
    required this.title,
    required this.timestamp,
    this.icon,
    this.onTap,
    this.onDelete,
  });

  final String title;
  final DateTime timestamp;
  final IconData? icon;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  String get _formattedTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.md,
        ),
        child: Row(
          children: [
            Icon(
              icon ?? LucideIcons.clock,
              size: 18,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              _formattedTime,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textTertiary,
              ),
            ),
            if (onDelete != null) ...[
              const SizedBox(width: AppSpacing.sm),
              GestureDetector(
                onTap: onDelete,
                child: const Icon(
                  LucideIcons.x,
                  size: 16,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Search history item
class SearchHistoryItem extends StatelessWidget {
  const SearchHistoryItem({
    super.key,
    required this.query,
    this.onTap,
    this.onDelete,
  });

  final String query;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.md,
        ),
        child: Row(
          children: [
            const Icon(
              LucideIcons.search,
              size: 18,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                query,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onDelete != null)
              GestureDetector(
                onTap: onDelete,
                child: const Icon(
                  LucideIcons.x,
                  size: 16,
                  color: AppColors.textTertiary,
                ),
              )
            else
              const Icon(
                LucideIcons.arrowUpLeft,
                size: 16,
                color: AppColors.textTertiary,
              ),
          ],
        ),
      ),
    );
  }
}
