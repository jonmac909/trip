# Quick Reference

## Colors
| Token | Hex | Const |
|-------|-----|-------|
| Primary | #1A1A1A | AppColors.primary |
| Accent | #BFFF00 | AppColors.accent |
| Surface | #F9FAFB | AppColors.surface |
| Text Primary | #1F2937 | AppColors.textPrimary |
| Text Secondary | #6B7280 | AppColors.textSecondary |
| Border | #E5E7EB | AppColors.border |

## Typography
GoogleFonts.dmSans(fontSize: X, fontWeight: FontWeight.wY)
- Title: 24px w700
- Subtitle: 16px w600
- Body: 14px w400
- Caption: 12px w400

## File Naming
- Screen: {name}_screen.dart
- Widget: {name}_card.dart, {name}_chip.dart
- Modal: {name}_sheet.dart, {name}_modal.dart

## New Screen Checklist
1. Read design JSON from /design-exports/
2. Create file in lib/presentation/screens/{module}/
3. Add route to app_router.dart
4. Use AppColors, AppSpacing, LucideIcons
5. Run: flutter analyze
