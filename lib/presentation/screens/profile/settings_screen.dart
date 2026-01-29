import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:trippified/core/constants/app_colors.dart';
import 'package:trippified/core/constants/app_spacing.dart';

/// Settings screen with app preferences
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _buildSectionHeader('Preferences'),
          const SizedBox(height: AppSpacing.sm),
          _buildSettingsItem(
            icon: LucideIcons.globe,
            label: 'Language',
            value: 'English',
            onTap: () => _showComingSoon(context),
          ),
          _buildSettingsItem(
            icon: LucideIcons.palette,
            label: 'Theme',
            value: 'Light',
            onTap: () => _showComingSoon(context),
          ),
          _buildSettingsItem(
            icon: LucideIcons.ruler,
            label: 'Units',
            value: 'Metric',
            onTap: () => _showComingSoon(context),
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildSectionHeader('Notifications'),
          const SizedBox(height: AppSpacing.sm),
          _buildSwitchItem(
            icon: LucideIcons.bell,
            label: 'Push Notifications',
            value: true,
            onChanged: (v) => _showComingSoon(context),
          ),
          _buildSwitchItem(
            icon: LucideIcons.mail,
            label: 'Email Updates',
            value: false,
            onChanged: (v) => _showComingSoon(context),
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildSectionHeader('About'),
          const SizedBox(height: AppSpacing.sm),
          _buildSettingsItem(
            icon: LucideIcons.info,
            label: 'Version',
            value: '1.0.0',
            showChevron: false,
          ),
          _buildSettingsItem(
            icon: LucideIcons.fileText,
            label: 'Terms of Service',
            onTap: () => _showComingSoon(context),
          ),
          _buildSettingsItem(
            icon: LucideIcons.shield,
            label: 'Privacy Policy',
            onTap: () => _showComingSoon(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textTertiary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String label,
    String? value,
    VoidCallback? onTap,
    bool showChevron = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.border, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColors.primary,
                ),
              ),
            ),
            if (value != null)
              Text(
                value,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            if (showChevron && onTap != null) ...[
              const SizedBox(width: 8),
              const Icon(
                LucideIcons.chevronRight,
                size: 18,
                color: AppColors.textTertiary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: AppColors.primary,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon!')),
    );
  }
}
