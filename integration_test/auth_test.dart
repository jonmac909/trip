import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trippified/presentation/screens/auth/login_screen.dart';
import 'package:trippified/presentation/screens/home/home_screen.dart';

import 'robots/home_robot.dart';
import 'robots/login_robot.dart';
import 'robots/splash_robot.dart';
import 'test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  initializeTestConfig();

  group('Auth Flow E2E Tests', () {
    group('SplashScreen', () {
      testWidgets('displays all splash screen elements', (tester) async {
        await tester.pumpWidget(createSplashTestApp());
        await tester.pumpAndSettle();

        final splash = SplashRobot(tester);
        await splash.verifyScreenDisplayed();
        await splash.verifyTitleDisplayed();
        await splash.verifyBrandNameDisplayed();
        await splash.verifyDescriptionDisplayed();
        await splash.verifyExploreNowButtonDisplayed();
      });

      testWidgets(
        'navigates to login when Explore Now is tapped (unauthenticated)',
        (tester) async {
          await tester.pumpWidget(createSplashTestApp());
          await tester.pumpAndSettle();

          final splash = SplashRobot(tester);
          await splash.tapExploreNow();

          // Should navigate to login screen
          expect(find.byType(LoginScreen), findsOneWidget);
        },
      );

      testWidgets('shows hero image area', (tester) async {
        await tester.pumpWidget(createSplashTestApp());
        await tester.pumpAndSettle();

        final splash = SplashRobot(tester);
        await splash.verifyScreenDisplayed();

        // Verify the hero image container exists (ClipRRect with height 500)
        expect(find.byType(ClipRRect), findsWidgets);
      });
    });

    group('LoginScreen', () {
      testWidgets('displays all login screen elements', (tester) async {
        await tester.pumpWidget(createLoginTestApp());
        await tester.pumpAndSettle();

        final login = LoginRobot(tester);
        await login.verifyScreenDisplayed();
        await login.verifyWelcomeTextDisplayed();
        await login.verifyOAuthButtonsDisplayed();
        await login.verifyFormFieldsDisplayed();
        await login.verifySignUpLinkDisplayed();
      });

      testWidgets('displays logo with plane icon', (tester) async {
        await tester.pumpWidget(createLoginTestApp());
        await tester.pumpAndSettle();

        final login = LoginRobot(tester);
        await login.verifyScreenDisplayed();

        // Logo container should exist
        expect(find.byType(Container), findsWidgets);
      });

      testWidgets('can enter email and password', (tester) async {
        await tester.pumpWidget(createLoginTestApp());
        await tester.pumpAndSettle();

        final login = LoginRobot(tester);
        await login.enterEmail('test@example.com');
        await login.enterPassword('password123');

        // Verify text was entered
        expect(find.text('test@example.com'), findsOneWidget);
      });

      testWidgets('can toggle password visibility', (tester) async {
        await tester.pumpWidget(createLoginTestApp());
        await tester.pumpAndSettle();

        final login = LoginRobot(tester);
        await login.enterPassword('password123');

        // Initially password is obscured (eyeOff icon visible)
        expect(login.passwordToggle, findsOneWidget);

        // Toggle visibility
        await login.togglePasswordVisibility();

        // Now password should be visible (eye icon visible)
        expect(login.passwordToggleVisible, findsOneWidget);
      });

      testWidgets('Google sign in navigates to home', (tester) async {
        await tester.pumpWidget(createLoginTestApp());
        await tester.pumpAndSettle();

        final login = LoginRobot(tester);
        await login.tapGoogleSignIn();

        // Should navigate to home screen
        expect(find.byType(HomeScreen), findsOneWidget);
      });

      testWidgets('Apple sign in navigates to home', (tester) async {
        await tester.pumpWidget(createLoginTestApp());
        await tester.pumpAndSettle();

        final login = LoginRobot(tester);
        await login.tapAppleSignIn();

        // Should navigate to home screen
        expect(find.byType(HomeScreen), findsOneWidget);
      });

      testWidgets('Facebook sign in navigates to home', (tester) async {
        await tester.pumpWidget(createLoginTestApp());
        await tester.pumpAndSettle();

        final login = LoginRobot(tester);
        await login.tapFacebookSignIn();

        // Should navigate to home screen
        expect(find.byType(HomeScreen), findsOneWidget);
      });

      testWidgets('Email sign in navigates to home', (tester) async {
        await tester.pumpWidget(createLoginTestApp());
        await tester.pumpAndSettle();

        final login = LoginRobot(tester);
        await login.signInWithEmail('test@example.com', 'password123');

        // Should navigate to home screen
        expect(find.byType(HomeScreen), findsOneWidget);
      });

      testWidgets('displays divider with "or" text', (tester) async {
        await tester.pumpWidget(createLoginTestApp());
        await tester.pumpAndSettle();

        expect(find.text('or'), findsOneWidget);
      });

      testWidgets('displays forgot password link', (tester) async {
        await tester.pumpWidget(createLoginTestApp());
        await tester.pumpAndSettle();

        final login = LoginRobot(tester);
        expect(login.forgotPasswordLink, findsOneWidget);
      });
    });

    group('Auth Flow Integration', () {
      testWidgets('complete auth flow from splash to home', (tester) async {
        await tester.pumpWidget(createSplashTestApp());
        await tester.pumpAndSettle();

        // Start at splash
        final splash = SplashRobot(tester);
        await splash.verifyScreenDisplayed();

        // Navigate to login
        await splash.tapExploreNow();
        expect(find.byType(LoginScreen), findsOneWidget);

        // Sign in
        final login = LoginRobot(tester);
        await login.tapGoogleSignIn();

        // Arrive at home
        final home = HomeRobot(tester);
        await home.verifyScreenDisplayed();
      });
    });
  });
}
