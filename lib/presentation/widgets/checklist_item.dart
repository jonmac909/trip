import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:trippified/core/constants/app_colors.dart';

/// Model for checklist item data
class ChecklistItemData {
  const ChecklistItemData({
    required this.id,
    required this.title,
    this.subtitle,
    this.isChecked = false,
    this.badge,
  });

  final String id;
  final String title;
  final String? subtitle;
  final bool isChecked;
  final String? badge;

  ChecklistItemData copyWith({
    String? id,
    String? title,
    String? subtitle,
    bool? isChecked,
    String? badge,
  }) {
    return ChecklistItemData(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      isChecked: isChecked ?? this.isChecked,
      badge: badge ?? this.badge,
    );
  }
}

/// Checklist section data model
class ChecklistSectionData {
  const ChecklistSectionData({
    required this.id,
    required this.title,
    required this.icon,
    required this.items,
    this.isExpanded = false,
  });

  final String id;
  final String title;
  final IconData icon;
  final List<ChecklistItemData> items;
  final bool isExpanded;

  int get completedCount => items.where((item) => item.isChecked).length;
  int get totalCount => items.length;
  String get progressText => '$completedCount/$totalCount';

  ChecklistSectionData copyWith({
    String? id,
    String? title,
    IconData? icon,
    List<ChecklistItemData>? items,
    bool? isExpanded,
  }) {
    return ChecklistSectionData(
      id: id ?? this.id,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      items: items ?? this.items,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}

/// Individual checklist item widget
class ChecklistItemWidget extends StatelessWidget {
  const ChecklistItemWidget({
    required this.item,
    required this.onToggle,
    super.key,
  });

  final ChecklistItemData item;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: item.isChecked ? AppColors.surface : AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: item.isChecked ? null : Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Checkbox
            _CheckboxIcon(isChecked: item.isChecked),
            const SizedBox(width: 12),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: item.isChecked
                          ? AppColors.textTertiary
                          : AppColors.primary,
                      decoration: item.isChecked
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle!,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: item.isChecked
                            ? AppColors.textTertiary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Badge (only shown when checked)
            if (item.badge != null && item.isChecked)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.badge!,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Checkbox icon widget
class _CheckboxIcon extends StatelessWidget {
  const _CheckboxIcon({required this.isChecked});

  final bool isChecked;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: isChecked ? AppColors.primary : AppColors.background,
        borderRadius: BorderRadius.circular(6),
        border: isChecked
            ? null
            : Border.all(color: AppColors.borderDark, width: 2),
      ),
      child: isChecked
          ? const Icon(LucideIcons.check, size: 14, color: Colors.white)
          : null,
    );
  }
}

/// Checklist section header widget
class ChecklistSectionHeader extends StatelessWidget {
  const ChecklistSectionHeader({
    required this.section,
    required this.onTap,
    super.key,
  });

  final ChecklistSectionData section;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(section.icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(
              section.title,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const Spacer(),
            Text(
              section.progressText,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              section.isExpanded
                  ? LucideIcons.chevronDown
                  : LucideIcons.chevronRight,
              size: 20,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Complete checklist section widget with expand/collapse
class ChecklistSectionWidget extends StatelessWidget {
  const ChecklistSectionWidget({
    required this.section,
    required this.onToggleExpand,
    required this.onToggleItem,
    super.key,
  });

  final ChecklistSectionData section;
  final VoidCallback onToggleExpand;
  final void Function(String itemId) onToggleItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          ChecklistSectionHeader(section: section, onTap: onToggleExpand),
          if (section.isExpanded)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Column(
                children: section.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: ChecklistItemWidget(
                      item: item,
                      onToggle: () => onToggleItem(item.id),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
