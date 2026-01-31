import 'dart:typed_data' as typed_data;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:trippified/core/services/supabase_service.dart';
import 'package:trippified/presentation/screens/auth/login_screen.dart';
import 'package:trippified/presentation/screens/day_builder/day_builder_screen.dart';
import 'package:trippified/presentation/screens/explore/city_detail_screen.dart';
import 'package:trippified/presentation/screens/explore/destination_detail_screen.dart';
import 'package:trippified/presentation/screens/explore/explore_history_screen.dart';
import 'package:trippified/presentation/screens/explore/itinerary_preview_screen.dart';
import 'package:trippified/presentation/screens/features/add_itinerary_screen.dart';
import 'package:trippified/presentation/screens/features/day_builder_detail_screen.dart';
import 'package:trippified/presentation/screens/features/itinerary_detail_screen.dart';
import 'package:trippified/presentation/screens/features/itinerary_stacking_screen.dart';
import 'package:trippified/presentation/screens/home/home_screen.dart';
import 'package:trippified/presentation/screens/itinerary/itinerary_builder_screen.dart';
import 'package:trippified/presentation/screens/splash/splash_screen.dart';
import 'package:trippified/presentation/screens/trip/smart_tickets_screen.dart';
import 'package:trippified/presentation/screens/trip/trip_dashboard_screen.dart';
import 'package:trippified/presentation/screens/trip_setup/recommended_routes_screen.dart';
import 'package:trippified/presentation/screens/trip_setup/trip_setup_screen.dart';
import 'package:trippified/presentation/screens/profile/my_tickets_screen.dart';
import 'package:trippified/presentation/screens/profile/settings_screen.dart';
import 'package:trippified/presentation/screens/saved/tiktok_scan_results_screen.dart';
import 'package:trippified/presentation/screens/saved/trip_hub_drafts_screen.dart';
import 'package:trippified/presentation/screens/saved/saved_city_detail_screen.dart';
import 'package:trippified/presentation/screens/saved/customize_itinerary_screen.dart';
import 'package:trippified/presentation/screens/saved/review_route_screen.dart';
import 'package:trippified/presentation/screens/saved/saved_day_builder_screen.dart';

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
  static const smartTickets = '/trip/:id/tickets';
  static const dayBuilder = '/trip/:id/day/:cityName';

  // Explore routes
  static const explore = '/explore';
  static const exploreHistory = '/explore/history';
  static const destinationDetail = '/explore/destination/:id';
  static const cityDetail = '/explore/city/:id';
  static const itineraryPreview = '/explore/itinerary/:id';

  // Saved routes
  static const saved = '/saved';
  static const tripHubDrafts = '/saved/drafts';
  static const tiktokScanResults = '/saved/scan-results';
  static const savedCityDetail = '/saved/city/:id';
  static const customizeItinerary = '/saved/customize/:id';
  static const reviewRoute = '/saved/review';
  static const savedDayBuilder = '/saved/day-builder';

  // Profile routes
  static const profile = '/profile';
  static const myTickets = '/profile/tickets';
  static const settings = '/settings';

  // Feature routes
  static const itineraryStacking = '/features/stacking';
  static const dayBuilderDetail = '/features/day-detail';
  static const itineraryDetail = '/features/itinerary-detail';
  static const addItinerary = '/features/add-itinerary';

  /// Routes that don't require authentication
  static const publicRoutes = [splash, login];
}

/// Notifier that triggers router refresh on auth state changes
class _AuthStateNotifier extends ChangeNotifier {
  _AuthStateNotifier() {
    SupabaseService.instance.authStateChanges.listen((_) {
      notifyListeners();
    });
  }
}

/// App router configuration
final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: true,

  // Redirect logic for authentication
  redirect: (context, state) {
    final isAuthenticated = SupabaseService.instance.isAuthenticatedWithAccount;
    final isPublicRoute = AppRoutes.publicRoutes.contains(
      state.matchedLocation,
    );
    final isGoingToLogin = state.matchedLocation == AppRoutes.login;
    final isGoingToSplash = state.matchedLocation == AppRoutes.splash;

    // If on splash, let the splash screen handle navigation
    if (isGoingToSplash) {
      return null;
    }

    // If not authenticated and trying to access protected route, redirect to login
    if (!isAuthenticated && !isPublicRoute) {
      return AppRoutes.login;
    }

    // If authenticated and trying to access login, redirect to home
    if (isAuthenticated && isGoingToLogin) {
      return AppRoutes.home;
    }

    return null;
  },

  // Refresh listenable to re-evaluate routes when auth state changes
  refreshListenable: _AuthStateNotifier(),

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
        final countries = extra?['countries'] as List<String>? ?? [];
        return RecommendedRoutesScreen(countries: countries);
      },
    ),
    GoRoute(
      path: AppRoutes.itineraryBuilder,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;

        // Check if coming from routes flow (has countries and selectedRoutes)
        final countries = extra?['countries'] as List<String>?;
        final selectedRoutes = extra?['selectedRoutes'] as Map<String, int?>?;
        final customRouteCities =
            extra?['customRouteCities'] as Map<String, List<String>>?;

        if (countries != null && countries.isNotEmpty) {
          // Routes flow - derive data from selections
          final firstCountry = countries.first;
          final routeIndex = selectedRoutes?[firstCountry];
          final customCities = customRouteCities?[firstCountry] ?? [];
          final routeDurations = extra?['routeDurations'] as Map<String, int>?;

          // Use first city from custom route or country name as destination
          final destination = customCities.isNotEmpty
              ? customCities.join(' → ')
              : firstCountry;

          // Calculate total days by summing durations from ALL selected routes
          final startDate = DateTime.now().add(const Duration(days: 14));
          int totalDays;
          if (routeDurations != null && routeDurations.isNotEmpty) {
            // Sum up durations from all countries
            totalDays = routeDurations.values.fold(0, (sum, days) => sum + days);
          } else if (routeIndex == -1) {
            // Fallback for custom routes without durations
            totalDays = (customCities.length * 2).clamp(3, 14);
          } else {
            // Fallback default
            totalDays = 7;
          }
          final endDate = startDate.add(Duration(days: totalDays - 1));

          return ItineraryBuilderScreen(
            destination: destination,
            country: countries.join(', '), // Pass all countries, comma-separated
            startDate: startDate,
            endDate: endDate,
            travelers: 1,
            routeIndex: routeIndex,
          );
        }

        // Direct flow with explicit data
        final destination = extra?['destination'] as String?;
        final startDate = extra?['startDate'] as DateTime?;
        final endDate = extra?['endDate'] as DateTime?;
        final travelers = extra?['travelers'] as int?;

        if (destination == null ||
            startDate == null ||
            endDate == null ||
            travelers == null) {
          return const Scaffold(body: Center(child: Text('Missing trip data')));
        }
        return ItineraryBuilderScreen(
          destination: destination,
          country: extra?['country'] as String? ?? '',
          startDate: startDate,
          endDate: endDate,
          travelers: travelers,
          routeIndex: extra?['routeIndex'] as int?,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.tripDetail,
      builder: (context, state) {
        final tripId = state.pathParameters['id'] ?? '';
        return TripDashboardScreen(tripId: tripId);
      },
    ),
    GoRoute(
      path: AppRoutes.smartTickets,
      builder: (context, state) {
        final tripId = state.pathParameters['id'] ?? '';
        final extra = state.extra as Map<String, dynamic>?;
        final cityName = extra?['cityName'] as String? ?? 'Tokyo';
        final days = extra?['days'] as int? ?? 5;
        return SmartTicketsScreen(
          tripId: tripId,
          cityName: cityName,
          days: days,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.dayBuilder,
      builder: (context, state) {
        final cityName = state.pathParameters['cityName'] ?? 'City';
        final tripId = state.pathParameters['id'];
        final extra = state.extra as Map<String, dynamic>?;
        final days = extra?['days'] as int? ?? 5;

        // Parse trip cities list for the city switcher
        final rawCities = extra?['tripCities'] as List<dynamic>?;
        final tripCities =
            rawCities?.map((c) {
              final map = c as Map<String, dynamic>;
              return TripCityInfo(
                cityName: map['cityName'] as String,
                days: map['days'] as int,
              );
            }).toList() ??
            [];

        return DayBuilderScreen(
          cityName: cityName,
          days: days,
          tripCities: tripCities,
          tripId: tripId,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.exploreHistory,
      builder: (context, state) => const ExploreHistoryScreen(),
    ),
    GoRoute(
      path: AppRoutes.destinationDetail,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return DestinationDetailScreen(destinationId: id);
      },
    ),
    GoRoute(
      path: AppRoutes.cityDetail,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        final extra = state.extra as Map<String, dynamic>?;
        return CityDetailScreen(
          cityId: id,
          cityName: extra?['cityName'] as String?,
          region: extra?['region'] as String?,
          imageUrl: extra?['imageUrl'] as String?,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.itineraryPreview,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return ItineraryPreviewScreen(itineraryId: id);
      },
    ),
    // Feature routes
    GoRoute(
      path: AppRoutes.itineraryStacking,
      builder: (context, state) => const ItineraryStackingScreen(),
    ),
    GoRoute(
      path: AppRoutes.dayBuilderDetail,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final cityName = extra?['cityName'] as String? ?? 'City';
        final dayNumber = extra?['dayNumber'] as int? ?? 1;
        final totalDays = extra?['totalDays'] as int? ?? 4;
        // Support both old 'activities' (single day) and new 'allDaysActivities' (all days)
        final allDaysRaw = extra?['allDaysActivities'] as List<dynamic>?;
        final allDaysActivities = allDaysRaw?.map((dayList) {
          return (dayList as List<dynamic>).cast<Map<String, dynamic>>();
        }).toList() ?? [];
        // Fallback for old navigation calls
        final singleDayActivities =
            extra?['activities'] as List<Map<String, dynamic>>?;
        return DayBuilderDetailScreen(
          cityName: cityName,
          dayNumber: dayNumber,
          totalDays: totalDays,
          allDaysActivities: allDaysActivities.isNotEmpty
              ? allDaysActivities
              : (singleDayActivities != null ? [singleDayActivities] : []),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.itineraryDetail,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final itineraryId = extra?['itineraryId'] as String? ?? '';
        return ItineraryDetailScreen(itineraryId: itineraryId);
      },
    ),
    GoRoute(
      path: AppRoutes.addItinerary,
      builder: (context, state) => const AddItineraryScreen(),
    ),
    GoRoute(
      path: AppRoutes.myTickets,
      builder: (context, state) => const MyTicketsScreen(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
    // Saved routes
    GoRoute(
      path: AppRoutes.tripHubDrafts,
      builder: (context, state) => const TripHubDraftsScreen(),
    ),
    GoRoute(
      path: AppRoutes.tiktokScanResults,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final url = extra?['url'] as String?;
        final mediaBytes = extra?['mediaBytes'] as List<typed_data.Uint8List>?;
        final mediaType = extra?['mediaType'] as String?;
        return TiktokScanResultsScreen(
          url: url,
          mediaBytes: mediaBytes,
          mediaType: mediaType,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.savedCityDetail,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        final extra = state.extra as Map<String, dynamic>?;
        return SavedCityDetailScreen(
          cityId: id,
          cityName: extra?['cityName'] as String?,
          country: extra?['country'] as String?,
          placeCount: extra?['placeCount'] as int?,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.customizeItinerary,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        final extra = state.extra as Map<String, dynamic>?;
        return CustomizeItineraryScreen(
          itineraryId: id,
          cityName: extra?['cityName'] as String?,
          country: extra?['country'] as String?,
          places: (extra?['places'] as List<dynamic>?)?.cast<String>(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.reviewRoute,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return ReviewRouteScreen(
          name: extra?['name'] as String?,
          cityName: extra?['cityName'] as String?,
          country: extra?['country'] as String?,
          days: extra?['days'] as int?,
          places: (extra?['places'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.savedDayBuilder,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return SavedDayBuilderScreen(
          name: extra?['name'] as String?,
          cityName: extra?['cityName'] as String?,
          country: extra?['country'] as String?,
          days: extra?['days'] as int?,
          places: (extra?['places'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList(),
        );
      },
    ),
  ],
  errorBuilder: (context, state) =>
      Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
);
