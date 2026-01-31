import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:trippified/core/constants/app_colors.dart';
import 'package:trippified/core/constants/app_spacing.dart';
import 'package:trippified/presentation/providers/auth_provider.dart';

/// Login screen with OAuth options and email/password fallback
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSignUpMode = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Show error snackbar when error occurs
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.error != null && previous?.error != next.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Colors.white,
              onPressed: () {
                ref.read(authProvider.notifier).clearError();
              },
            ),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo - lime green rounded square with plane icon
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        LucideIcons.plane,
                        size: 32,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Welcome text
                  Text(
                    _isSignUpMode ? 'Create Account' : 'Welcome Back',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isSignUpMode
                        ? 'Sign up to start planning your trips'
                        : 'Sign in to continue planning your trips',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  // Social login buttons
                  _SocialButton(
                    svgAsset: 'assets/icons/google_logo.svg',
                    iconSize: 20,
                    label: 'Continue with Google',
                    onPressed: _signInWithGoogle,
                  ),
                  const SizedBox(height: AppSpacing.listItemSpacing),
                  _SocialButton(
                    svgAsset: 'assets/icons/apple_logo.svg',
                    iconSize: 22,
                    label: 'Continue with Apple',
                    onPressed: _signInWithApple,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Divider with "or"
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(color: AppColors.border, height: 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        child: Text(
                          'or',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(color: AppColors.border, height: 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Email field
                  _buildInputField(
                    label: 'Email',
                    hint: 'Enter your email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Password field
                  _buildInputField(
                    label: 'Password',
                    hint: 'Enter your password',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      child: Icon(
                        _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                        size: 20,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                  if (!_isSignUpMode) ...[
                    const SizedBox(height: AppSpacing.md),
                    // Forgot password
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () {
                          // TODO(auth): Navigate to forgot password
                        },
                        child: Text(
                          'Forgot password?',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  // Sign in/Sign up button
                  GestureDetector(
                    onTap: _isSignUpMode ? _signUp : _signInWithEmail,
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _isSignUpMode ? 'Sign Up' : 'Sign In',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Toggle sign up/sign in link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isSignUpMode
                            ? 'Already have an account?'
                            : "Don't have an account?",
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isSignUpMode = !_isSignUpMode;
                          });
                        },
                        child: Text(
                          _isSignUpMode ? 'Sign In' : 'Sign Up',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Loading overlay
          if (authState.isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.accent,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  obscureText: obscureText,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: AppColors.primary,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textTertiary,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
              if (suffixIcon != null) suffixIcon,
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _signInWithGoogle() async {
    await ref.read(authProvider.notifier).signInWithGoogle();
    // Navigation is handled by router redirect when auth state changes
  }

  Future<void> _signInWithApple() async {
    await ref.read(authProvider.notifier).signInWithApple();
    // Navigation is handled by router redirect when auth state changes
  }

  Future<void> _signInWithEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter email and password'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    await ref.read(authProvider.notifier).signInWithEmail(email, password);
    // Navigation is handled by router redirect when auth state changes
  }

  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter email and password'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    await ref.read(authProvider.notifier).signUpWithEmail(email, password);
    // Navigation is handled by router redirect when auth state changes
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.svgAsset,
    required this.label,
    required this.onPressed,
    this.iconSize = 20,
  });

  final String svgAsset;
  final String label;
  final VoidCallback onPressed;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Center(
                child: SvgPicture.asset(
                  svgAsset,
                  width: iconSize,
                  height: iconSize,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.listItemSpacing),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
