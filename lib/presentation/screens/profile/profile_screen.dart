import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:trippified/core/constants/app_colors.dart';
import 'package:trippified/core/constants/app_spacing.dart';
import 'package:trippified/core/services/supabase_service.dart';
import 'package:trippified/presentation/navigation/app_router.dart';

/// Profile screen with user info and settings
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = SupabaseService.instance.currentUser;
    final isAuthenticated = SupabaseService.instance.isAuthenticated;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Profile Header
                  _buildProfileHeader(
                    isAuthenticated: isAuthenticated,
                    email: user?.email,
                    userName: _getUserName(user?.email),
                  ),

                  // Menu Section
                  _buildMenuSection(context, isAuthenticated),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader({
    required bool isAuthenticated,
    String? email,
    required String userName,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isAuthenticated
                  ? Text(
                      _getInitials(email),
                      style: GoogleFonts.dmSans(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textTertiary,
                      ),
                    )
                  : const Icon(
                      LucideIcons.user,
                      size: 36,
                      color: Color(0xFF9CA3AF),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          // Name Section
          Text(
            isAuthenticated ? userName : 'Guest User',
            style: GoogleFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isAuthenticated ? (email ?? '') : 'Sign in to sync your trips',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, bool isAuthenticated) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // My Tickets - Highlighted row
          _buildTicketsMenuItem(
            context: context,
            ticketCount: 3,
          ),
          const SizedBox(height: 4),

          // Settings row
          _buildMenuItem(
            icon: LucideIcons.settings,
            label: 'Settings',
            onTap: () => context.push(AppRoutes.settings),
          ),
          const SizedBox(height: 4),

          // Notifications row
          _buildMenuItem(
            icon: LucideIcons.bell,
            label: 'Notifications',
            onTap: () => _showComingSoon(context),
          ),
          const SizedBox(height: 4),

          // Help & Support row
          _buildMenuItem(
            icon: LucideIcons.lifeBuoy,
            label: 'Help & Support',
            onTap: () => _showComingSoon(context),
          ),

          // Log Out - only if authenticated
          if (isAuthenticated) ...[
            const SizedBox(height: 24),
            _buildLogOutItem(context),
          ],
        ],
      ),
    );
  }

  Widget _buildTicketsMenuItem({
    required BuildContext context,
    required int ticketCount,
  }) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.myTickets),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Icon(
                  LucideIcons.ticket,
                  size: 20,
                  color: Color(0xFF16A34A),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Label
            Text(
              'My Tickets',
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const Spacer(),
            // Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$ticketCount',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
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

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Label
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: AppColors.primary,
              ),
            ),
            const Spacer(),
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

  Widget _buildLogOutItem(BuildContext context) {
    return GestureDetector(
      onTap: () => _signOut(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Icon(
                  LucideIcons.logOut,
                  size: 20,
                  color: Color(0xFFDC2626),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Label
            Text(
              'Log Out',
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFDC2626),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String? email) {
    if (email == null || email.isEmpty) return '?';
    final parts = email.split('@');
    if (parts.isEmpty) return '?';
    final name = parts[0];
    if (name.isEmpty) return '?';
    return name[0].toUpperCase();
  }

  String _getUserName(String? email) {
    if (email == null || email.isEmpty) return 'User';
    final parts = email.split('@');
    if (parts.isEmpty) return 'User';
    final name = parts[0];
    if (name.isEmpty) return 'User';
    // Capitalize first letter
    return name[0].toUpperCase() + name.substring(1);
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon!')),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        title: Text(
          'Sign Out',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: GoogleFonts.dmSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.dmSans(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Sign Out',
              style: GoogleFonts.dmSans(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if ((confirmed ?? false) && context.mounted) {
      await SupabaseService.instance.signOut();
      if (context.mounted) {
        context.go(AppRoutes.login);
      }
    }
  }
}
