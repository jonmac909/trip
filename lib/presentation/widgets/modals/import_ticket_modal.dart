import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:trippified/core/constants/app_colors.dart';

/// Bottom sheet modal for importing tickets
class ImportTicketModal extends StatelessWidget {
  const ImportTicketModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Add Ticket',
                style: GoogleFonts.dmSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          // Options list
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                // From Email option
                _buildOptionItem(
                  context: context,
                  iconBgColor: const Color(0xFFF3E8FF),
                  iconColor: const Color(0xFF9333EA),
                  icon: LucideIcons.mail,
                  title: 'From Email',
                  subtitle: 'Scan inbox for booking confirmations',
                  onTap: () => _handleOptionTap(context, 'email'),
                ),
                const SizedBox(height: 4),
                // Upload File option
                _buildOptionItem(
                  context: context,
                  iconBgColor: const Color(0xFFDBEAFE),
                  iconColor: const Color(0xFF2563EB),
                  icon: LucideIcons.upload,
                  title: 'Upload File',
                  subtitle: 'PDF, screenshot, or photo of ticket',
                  onTap: () => _handleOptionTap(context, 'upload'),
                ),
                const SizedBox(height: 4),
                // Paste Booking Link option
                _buildOptionItem(
                  context: context,
                  iconBgColor: const Color(0xFFFEF3C7),
                  iconColor: const Color(0xFFD97706),
                  icon: LucideIcons.link,
                  title: 'Paste Booking Link',
                  subtitle: 'Enter confirmation URL from airline',
                  onTap: () => _handleOptionTap(context, 'link'),
                ),
                const SizedBox(height: 4),
                // Scan QR Code option
                _buildOptionItem(
                  context: context,
                  iconBgColor: const Color(0xFFDCFCE7),
                  iconColor: const Color(0xFF16A34A),
                  icon: LucideIcons.scan,
                  title: 'Scan QR Code',
                  subtitle: 'Use camera to scan boarding pass',
                  onTap: () => _handleOptionTap(context, 'scan'),
                ),
                const SizedBox(height: 4),
                // Add Manually option
                _buildOptionItem(
                  context: context,
                  iconBgColor: const Color(0xFFF3F4F6),
                  iconColor: AppColors.textSecondary,
                  icon: LucideIcons.pencil,
                  title: 'Add Manually',
                  subtitle: 'Enter flight or train details yourself',
                  onTap: () => _handleOptionTap(context, 'manual'),
                ),
              ],
            ),
          ),
          // Safe area padding for bottom
          SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
        ],
      ),
    );
  }

  Widget _buildOptionItem({
    required BuildContext context,
    required Color iconBgColor,
    required Color iconColor,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 22,
                  color: iconColor,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow
            const Icon(
              LucideIcons.chevronRight,
              size: 20,
              color: Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }

  void _handleOptionTap(BuildContext context, String option) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$option import coming soon!')),
    );
  }
}
