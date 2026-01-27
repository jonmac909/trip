import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:trippified/core/constants/app_colors.dart';
import 'package:trippified/core/constants/app_spacing.dart';

/// Card for saved links
class LinkCard extends StatelessWidget {
  const LinkCard({
    super.key,
    required this.title,
    required this.url,
    this.description,
    this.imageUrl,
    this.favicon,
    this.onTap,
    this.onDelete,
  });

  final String title;
  final String url;
  final String? description;
  final String? imageUrl;
  final String? favicon;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  String get _domain {
    try {
      final uri = Uri.parse(url);
      return uri.host.replaceFirst('www.', '');
    } catch (_) {
      return url;
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
        child: Row(
          children: [
            // Thumbnail
            if (imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(AppSpacing.radiusLg - 1),
                ),
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.shimmerBase,
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.shimmerBase,
                      child: const Icon(
                        LucideIcons.link,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                ),
              )
            else
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(AppSpacing.radiusLg - 1),
                  ),
                ),
                child: const Icon(
                  LucideIcons.link,
                  size: 32,
                  color: AppColors.textTertiary,
                ),
              ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Domain
                    Row(
                      children: [
                        if (favicon != null) ...[
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusSm),
                            child: CachedNetworkImage(
                              imageUrl: favicon!,
                              width: 16,
                              height: 16,
                              placeholder: (context, url) => const SizedBox(
                                width: 16,
                                height: 16,
                              ),
                              errorWidget: (context, url, error) => const Icon(
                                LucideIcons.globe,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                        ] else ...[
                          const Icon(
                            LucideIcons.globe,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                        ],
                        Expanded(
                          child: Text(
                            _domain,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    // Title
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Description
                    if (description != null) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        description!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Actions
            if (onDelete != null)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: const Icon(
                      LucideIcons.trash2,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.only(right: AppSpacing.sm),
                child: Icon(
                  LucideIcons.externalLink,
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

/// Compact link card for lists
class LinkCardCompact extends StatelessWidget {
  const LinkCardCompact({
    super.key,
    required this.title,
    required this.url,
    this.favicon,
    this.onTap,
  });

  final String title;
  final String url;
  final String? favicon;
  final VoidCallback? onTap;

  String get _domain {
    try {
      final uri = Uri.parse(url);
      return uri.host.replaceFirst('www.', '');
    } catch (_) {
      return url;
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
            // Icon
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: favicon != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      child: CachedNetworkImage(
                        imageUrl: favicon!,
                        width: 20,
                        height: 20,
                        errorWidget: (context, url, error) => const Icon(
                          LucideIcons.link,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  : const Icon(
                      LucideIcons.link,
                      size: 20,
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
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    _domain,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow
            const Icon(
              LucideIcons.externalLink,
              size: 16,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
