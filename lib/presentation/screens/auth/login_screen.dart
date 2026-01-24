import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:trippified/core/constants/app_colors.dart';
import 'package:trippified/core/constants/app_spacing.dart';
import 'package:trippified/presentation/navigation/app_router.dart';

/// Login screen with OAuth options
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            children: [
              const Spacer(),
              // Logo and tagline
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                ),
                child: const Icon(
                  Icons.explore,
                  size: 56,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Welcome to Trippified',
                style: Theme.of(context).textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Plan trips effortlessly with smart itineraries',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              // OAuth buttons
              _OAuthButton(
                icon: Icons.g_mobiledata,
                label: 'Continue with Google',
                onPressed: () => _signInWithGoogle(context),
              ),
              const SizedBox(height: AppSpacing.md),
              _OAuthButton(
                icon: Icons.apple,
                label: 'Continue with Apple',
                backgroundColor: AppColors.textPrimary,
                onPressed: () => _signInWithApple(context),
              ),
              const SizedBox(height: AppSpacing.md),
              _OAuthButton(
                icon: Icons.facebook,
                label: 'Continue with Facebook',
                backgroundColor: const Color(0xFF1877F2),
                onPressed: () => _signInWithFacebook(context),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Terms
              Text(
                'By continuing, you agree to our Terms of Service\nand Privacy Policy',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    // TODO: Implement Google sign-in
    // For now, navigate to home for testing
    context.go(AppRoutes.home);
  }

  Future<void> _signInWithApple(BuildContext context) async {
    // TODO: Implement Apple sign-in
    context.go(AppRoutes.home);
  }

  Future<void> _signInWithFacebook(BuildContext context) async {
    // TODO: Implement Facebook sign-in
    context.go(AppRoutes.home);
  }
}

class _OAuthButton extends StatelessWidget {
  const _OAuthButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.surface;
    final fgColor = backgroundColor != null
        ? AppColors.textOnPrimary
        : AppColors.textPrimary;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          elevation: 0,
          side: backgroundColor == null
              ? const BorderSide(color: AppColors.border)
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: fgColor),
            ),
          ],
        ),
      ),
    );
  }
}
