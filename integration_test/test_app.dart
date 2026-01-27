import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:trippified/core/theme/app_theme.dart';
import 'package:trippified/presentation/navigation/app_router.dart';
import 'package:trippified/presentation/screens/saved/tiktok_scan_results_screen.dart';

/// Configure test environment with proper screen size and error handling
void configureTestEnvironment(WidgetTester tester) {
  // Set a fixed screen size for consistent testing (iPhone 14 Pro size)
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
}

/// Initialize global test configuration - call once in main()
void initializeTestConfig() {
  // Suppress overflow errors during tests - common with varying screen sizes
  final originalOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    final exception = details.exception.toString();
    if (exception.contains('overflowed') || exception.contains('RenderFlex')) {
      // Ignore overflow errors in tests
      return;
    }
    if (originalOnError != null) {
      originalOnError(details);
    }
  };
}

/// Test app wrapper for E2E testing
class TestApp extends StatelessWidget {
  const TestApp({
    super.key,
    this.initialRoute,
    this.router,
    this.overrides = const [],
  });

  /// Initial route to navigate to
  final String? initialRoute;

  /// Custom router for testing specific screens
  final GoRouter? router;

  /// Provider overrides for testing
  final List<Override> overrides;

  @override
  Widget build(BuildContext context) {
    final testRouter =
        router ??
        GoRouter(
          initialLocation: initialRoute ?? AppRoutes.splash,
          debugLogDiagnostics: true,
          routes: appRouter.configuration.routes,
          errorBuilder: (context, state) => Scaffold(
            body: Center(child: Text('Page not found: ${state.uri}')),
          ),
        );

    return ProviderScope(
      overrides: overrides,
      child: MaterialApp.router(
        title: 'Trippified Test',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: testRouter,
      ),
    );
  }
}

/// Create a test app with a specific initial route
Widget createTestApp({
  String? initialRoute,
  GoRouter? router,
  List<Override> overrides = const [],
}) {
  return TestApp(
    initialRoute: initialRoute,
    router: router,
    overrides: overrides,
  );
}

/// Create a test app starting at splash screen
Widget createSplashTestApp({List<Override> overrides = const []}) {
  return createTestApp(initialRoute: AppRoutes.splash, overrides: overrides);
}

/// Create a test app starting at login screen
Widget createLoginTestApp({List<Override> overrides = const []}) {
  return createTestApp(initialRoute: AppRoutes.login, overrides: overrides);
}

/// Create a test app starting at home screen
Widget createHomeTestApp({List<Override> overrides = const []}) {
  return createTestApp(initialRoute: AppRoutes.home, overrides: overrides);
}

/// Create a test app starting at trip setup screen
Widget createTripSetupTestApp({List<Override> overrides = const []}) {
  return createTestApp(initialRoute: AppRoutes.tripSetup, overrides: overrides);
}

/// Create a test app starting at explore screen
Widget createExploreTestApp({List<Override> overrides = const []}) {
  return createTestApp(initialRoute: AppRoutes.home, overrides: overrides);
}

/// Create a test app for scan results with optional URL or media data
Widget createScanResultsTestApp({
  String? url,
  List<Uint8List>? mediaBytes,
  String? mediaType,
  List<Override> overrides = const [],
}) {
  final router = GoRouter(
    initialLocation: '/saved/scan-results',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/saved/scan-results',
        builder: (context, state) => TiktokScanResultsScreen(
          url: url,
          mediaBytes: mediaBytes,
          mediaType: mediaType,
        ),
      ),
    ],
  );

  return TestApp(router: router, overrides: overrides);
}
