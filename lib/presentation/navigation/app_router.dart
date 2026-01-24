import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:trippified/presentation/screens/auth/login_screen.dart';
import 'package:trippified/presentation/screens/home/home_screen.dart';
import 'package:trippified/presentation/screens/itinerary/itinerary_builder_screen.dart';
import 'package:trippified/presentation/screens/splash/splash_screen.dart';
import 'package:trippified/presentation/screens/trip_setup/recommended_routes_screen.dart';
import 'package:trippified/presentation/screens/trip_setup/trip_setup_screen.dart';

/// Route names for type-safe navigation
abstract final class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const home = '/home';

  // Trip routes
  static const tripSetup = '/trip/setup';
  static const recommendedRoutes = '/trip/routes';
  static const itineraryBuilder = '/trip/builder';
  static const tripDetail = '/trip/:id';

  // Explore routes
  static const explore = '/explore';
  static const exploreDestination = '/explore/:destinationId';

  // Saved routes
  static const saved = '/saved';

  // Profile routes
  static const profile = '/profile';
  static const settings = '/settings';
}

/// App router configuration
final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.tripSetup,
      builder: (context, state) => const TripSetupScreen(),
    ),
    GoRoute(
      path: AppRoutes.recommendedRoutes,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        if (extra == null) {
          return const Scaffold(body: Center(child: Text('Missing trip data')));
        }
        return RecommendedRoutesScreen(
          destination: extra['destination'] as String,
          country: extra['country'] as String? ?? '',
          startDate: extra['startDate'] as DateTime,
          endDate: extra['endDate'] as DateTime,
          travelers: extra['travelers'] as int,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.itineraryBuilder,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        if (extra == null) {
          return const Scaffold(body: Center(child: Text('Missing trip data')));
        }
        return ItineraryBuilderScreen(
          destination: extra['destination'] as String,
          country: extra['country'] as String? ?? '',
          startDate: extra['startDate'] as DateTime,
          endDate: extra['endDate'] as DateTime,
          travelers: extra['travelers'] as int,
          routeIndex: extra['routeIndex'] as int?,
        );
      },
    ),
  ],
  errorBuilder: (context, state) =>
      Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
);
