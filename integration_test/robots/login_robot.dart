import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:trippified/presentation/screens/auth/login_screen.dart';

/// Robot for interacting with LoginScreen in tests
class LoginRobot {
  LoginRobot(this.tester);

  final WidgetTester tester;

  // Finders
  Finder get screen => find.byType(LoginScreen);
  Finder get welcomeText => find.text('Welcome Back');
  Finder get subtitle => find.text('Sign in to continue planning your trips');

  // OAuth buttons
  Finder get googleButton => find.text('Continue with Google');
  Finder get appleButton => find.text('Continue with Apple');
  Finder get facebookButton => find.text('Continue with Facebook');

  // Form fields
  Finder get emailLabel => find.text('Email');
  Finder get passwordLabel => find.text('Password');
  Finder get emailField => find.widgetWithText(TextField, 'Enter your email');
  Finder get passwordField =>
      find.widgetWithText(TextField, 'Enter your password');
  Finder get forgotPasswordLink => find.text('Forgot password?');
  Finder get signInButton => find.text('Sign In');
  Finder get signUpLink => find.text('Sign Up');
  Finder get noAccountText => find.text("Don't have an account?");
  Finder get passwordToggle => find.byIcon(LucideIcons.eyeOff);
  Finder get passwordToggleVisible => find.byIcon(LucideIcons.eye);

  // Verifications
  Future<void> verifyScreenDisplayed() async {
    expect(screen, findsOneWidget);
  }

  Future<void> verifyWelcomeTextDisplayed() async {
    expect(welcomeText, findsOneWidget);
  }

  Future<void> verifyOAuthButtonsDisplayed() async {
    expect(googleButton, findsOneWidget);
    expect(appleButton, findsOneWidget);
    expect(facebookButton, findsOneWidget);
  }

  Future<void> verifyFormFieldsDisplayed() async {
    expect(emailLabel, findsOneWidget);
    expect(passwordLabel, findsOneWidget);
    expect(signInButton, findsOneWidget);
  }

  Future<void> verifySignUpLinkDisplayed() async {
    expect(noAccountText, findsOneWidget);
    expect(signUpLink, findsOneWidget);
  }

  Future<void> verifyAllElementsDisplayed() async {
    await verifyScreenDisplayed();
    await verifyWelcomeTextDisplayed();
    await verifyOAuthButtonsDisplayed();
    await verifyFormFieldsDisplayed();
    await verifySignUpLinkDisplayed();
  }

  // Actions
  Future<void> tapGoogleSignIn() async {
    await tester.tap(googleButton);
    await tester.pumpAndSettle();
  }

  Future<void> tapAppleSignIn() async {
    await tester.tap(appleButton);
    await tester.pumpAndSettle();
  }

  Future<void> tapFacebookSignIn() async {
    await tester.tap(facebookButton);
    await tester.pumpAndSettle();
  }

  Future<void> enterEmail(String email) async {
    await tester.enterText(emailField, email);
    await tester.pumpAndSettle();
  }

  Future<void> enterPassword(String password) async {
    await tester.enterText(passwordField, password);
    await tester.pumpAndSettle();
  }

  Future<void> togglePasswordVisibility() async {
    final toggle = passwordToggle.evaluate().isNotEmpty
        ? passwordToggle
        : passwordToggleVisible;
    await tester.tap(toggle);
    await tester.pumpAndSettle();
  }

  Future<void> tapSignIn() async {
    // Scroll to make button visible if needed (may be below keyboard)
    final scrollable = find.byType(Scrollable);
    if (scrollable.evaluate().isNotEmpty) {
      await tester.scrollUntilVisible(
        signInButton,
        100,
        scrollable: scrollable.first,
      );
      await tester.pumpAndSettle();
    }
    await tester.tap(signInButton);
    await tester.pumpAndSettle();
  }

  Future<void> tapSignUp() async {
    await tester.tap(signUpLink);
    await tester.pumpAndSettle();
  }

  Future<void> tapForgotPassword() async {
    await tester.tap(forgotPasswordLink);
    await tester.pumpAndSettle();
  }

  Future<void> signInWithEmail(String email, String password) async {
    await enterEmail(email);
    await enterPassword(password);
    await tapSignIn();
  }
}
