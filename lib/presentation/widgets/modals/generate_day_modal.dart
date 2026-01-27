import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:trippified/core/constants/app_colors.dart';
import 'package:trippified/core/constants/app_spacing.dart';

/// Data model for a day theme option
class DayThemeOption {
  const DayThemeOption({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
}

/// Bottom sheet modal for generating a day plan
class GenerateDayModal extends StatefulWidget {
  const GenerateDayModal({
    required this.dayNumber,
    required this.cityName,
    this.onGenerate,
    super.key,
  });

  final int dayNumber;
  final String cityName;
  final void Function(DayThemeOption selectedTheme)? onGenerate;

  /// Show the modal as a bottom sheet
  static Future<DayThemeOption?> show({
    required BuildContext context,
    required int dayNumber,
    required String cityName,
  }) {
    return showModalBottomSheet<DayThemeOption>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GenerateDayModal(
        dayNumber: dayNumber,
        cityName: cityName,
        onGenerate: (theme) => Navigator.of(context).pop(theme),
      ),
    );
  }

  @override
  State<GenerateDayModal> createState() => _GenerateDayModalState();
}

class _GenerateDayModalState extends State<GenerateDayModal> {
  String? _selectedThemeId;

  // Default theme options - would be customized per city in production
  List<DayThemeOption> get _themeOptions => [
        DayThemeOption(
          id: 'temple',
          title: 'Temple Day',
          description: 'Temples, shrines & gardens walk',
          icon: LucideIcons.church,
          iconColor: const Color(0xFFDC2626),
        ),
        DayThemeOption(
          id: 'digital_art',
          title: 'Digital Art Day',
          description: 'Museums & modern art exploration',
          icon: LucideIcons.sparkles,
          iconColor: const Color(0xFF4F46E5),
        ),
        DayThemeOption(
          id: 'fashion',
          title: 'Fashion & Shopping Day',
          description: 'Shopping districts & boutiques',
          icon: LucideIcons.shirt,
          iconColor: const Color(0xFFDB2777),
        ),
        DayThemeOption(
          id: 'food_crawl',
          title: 'Street Food Crawl',
          description: 'Food markets & local tastings',
          icon: LucideIcons.fish,
          iconColor: const Color(0xFFEA580C),
        ),
        DayThemeOption(
          id: 'cooking',
          title: 'Cooking Class Day',
          description: 'Market tour + hands-on cooking lesson',
          icon: LucideIcons.chefHat,
          iconColor: const Color(0xFFD97706),
        ),
        DayThemeOption(
          id: 'nightlife',
          title: 'Night Tour',
          description: 'Bar hopping & nightlife exploration',
          icon: LucideIcons.wine,
          iconColor: const Color(0xFF7C3AED),
        ),
      ];

  DayThemeOption? get _selectedTheme {
    if (_selectedThemeId == null) return null;
    return _themeOptions.firstWhere(
      (theme) => theme.id == _selectedThemeId,
      orElse: () => _themeOptions.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandleBar(),
          _buildHeader(),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                children: _themeOptions
                    .map((option) => Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: _buildOptionCard(option),
                        ))
                    .toList(),
              ),
            ),
          ),
          _buildBottomSection(),
        ],
      ),
    );
  }

  Widget _buildHandleBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Generate Day ${widget.dayNumber}',
                  style: GoogleFonts.dmSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Each day is built around one anchor',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.x,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(DayThemeOption option) {
    final isSelected = _selectedThemeId == option.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedThemeId = option.id;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.background : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Icon(
                option.icon,
                size: 22,
                color: option.iconColor,
              ),
            ),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    option.description,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        MediaQuery.of(context).padding.bottom + AppSpacing.lg,
      ),
      child: GestureDetector(
        onTap: _selectedTheme != null
            ? () => widget.onGenerate?.call(_selectedTheme!)
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: _selectedTheme != null
                ? AppColors.primary
                : AppColors.border,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.sparkles,
                size: 20,
                color: _selectedTheme != null
                    ? AppColors.textOnPrimary
                    : AppColors.textTertiary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Generate Day',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _selectedTheme != null
                      ? AppColors.textOnPrimary
                      : AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
