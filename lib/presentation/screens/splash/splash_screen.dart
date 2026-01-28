import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:trippified/core/constants/app_colors.dart';
import 'package:trippified/core/constants/app_spacing.dart';
import 'package:trippified/core/services/supabase_service.dart';
import 'package:trippified/presentation/navigation/app_router.dart';

/// Splash/onboarding screen with hero image and CTA
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  void _onExploreNow(BuildContext context) {
    if (SupabaseService.instance.isAuthenticated) {
      context.go(AppRoutes.home);
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    // Use 55% of screen for hero image, minimum 300, maximum 500
    final heroHeight = (screenHeight * 0.55).clamp(300.0, 500.0);
    
    return Scaffold(
      backgroundColor: AppColors.splashBackground,
      body: Column(
        children: [
          // Hero image with rounded bottom corners
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(40),
            ),
            child: SizedBox(
              height: heroHeight,
              width: double.infinity,
              child: Image.network(
                'https://images.unsplash.com/photo-1687960507238-5f6565a08b2f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0&ixlib=rb-4.1.0&q=80&w=1080',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.splashBackground,
                ),
              ),
            ),
          ),
          // Bottom section with gradient
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.splashGradientStart,
                    AppColors.splashGradientEnd,
                  ],
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(32, 40, 32, 48),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        'Unveil The\nTravel Wonders',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // Brand name - TRIPPIFIED
                      Text(
                        'TRIPPIFIED',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.5),
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // Description
                      Text(
                        'Take the first step into\nan unforgettable journey',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.6),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      // CTA Button
                      _buildCtaButton(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCtaButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _onExploreNow(context),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.splashButtonBg,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.splashButtonBorder),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Row(
          children: [
            // Icon circle with lime green background
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.navigation,
                size: 20,
                color: AppColors.splashGradientStart,
              ),
            ),
            const Spacer(),
            // Button text
            Text(
              'Explore Now',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            // Arrows indicator
            Text(
              '\u00bb',
              style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}
