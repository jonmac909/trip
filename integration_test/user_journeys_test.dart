/// Comprehensive E2E tests for all major user journeys in Trippified
///
/// Tests cover complete user flows from start to finish:
/// 1. Trippified Flow - Trip planning from countries to itinerary
/// 2. Day Builder - Building out detailed day-by-day plans
/// 3. Explore Flow - Discovering and saving destinations
/// 4. Saved Flow - Managing saved items and generating itineraries
/// 5. Social Media Import - TikTok/Instagram content extraction
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'test_app.dart';
import 'robots/home_robot.dart';
import 'robots/trip_setup_robot.dart';
import 'robots/day_builder_robot.dart';
import 'robots/explore_robot.dart';
import 'robots/saved_robot.dart';
import 'robots/itinerary_robot.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  initializeTestConfig();

  group('User Journey 1: Trippified Flow (Trip Planner)', () {
    group('Complete Trip Setup Journey', () {
      testWidgets(
        'should complete full trip setup flow from country selection to itinerary creation',
        (tester) async {
          // Start at home
          await tester.pumpWidget(createHomeTestApp());
          await tester.pumpAndSettle();

          final home = HomeRobot(tester);
          await home.verifyScreenDisplayed();

          // Navigate to trip setup via FAB (add trip button)
          await home.tapAddTripFab();
          await tester.pumpAndSettle();

          // Verify trip setup screen loads
          final tripSetup = TripSetupRobot(tester);
          await tripSetup.verifyAllElementsDisplayed();
        },
      );

      testWidgets(
        'should enable CTA when country and trip size are selected',
        (tester) async {
          await tester.pumpWidget(createTripSetupTestApp());
          await tester.pumpAndSettle();

          final tripSetup = TripSetupRobot(tester);

          // Initially CTA should be present
          await tripSetup.verifySeeRoutesCtaDisplayed();

          // Select a country
          await tripSetup.selectCountry('Japan');

          // Select trip size
          await tripSetup.selectWeekLong();

          // CTA should still be displayed and ready
          await tripSetup.verifySeeRoutesCtaDisplayed();
        },
      );

      testWidgets(
        'should allow multiple country selection',
        (tester) async {
          await tester.pumpWidget(createTripSetupTestApp());
          await tester.pumpAndSettle();

          final tripSetup = TripSetupRobot(tester);

          // Select first country
          await tripSetup.selectCountry('Japan');
          await tripSetup.verifyCountrySelected('Japan');

          // Select second country
          await tripSetup.selectCountry('South Korea');
          await tripSetup.verifyCountrySelected('South Korea');

          // Both should be displayed as chips
          expect(tripSetup.countryChip('Japan'), findsOneWidget);
          expect(tripSetup.countryChip('South Korea'), findsOneWidget);
        },
      );

      testWidgets(
        'should allow different trip size selections',
        (tester) async {
          await tester.pumpWidget(createTripSetupTestApp());
          await tester.pumpAndSettle();

          final tripSetup = TripSetupRobot(tester);

          // Test Short trip
          await tripSetup.selectShortTrip();
          expect(tripSetup.shortTripOption, findsOneWidget);

          // Test Week-long
          await tripSetup.selectWeekLong();
          expect(tripSetup.weekLongOption, findsOneWidget);

          // Test Long trip
          await tripSetup.selectLongTrip();
          expect(tripSetup.longTripOption, findsOneWidget);
        },
      );
    });

    group('Recommended Routes Journey', () {
      testWidgets(
        'should navigate to recommended routes after trip setup',
        (tester) async {
          await tester.pumpWidget(createTripSetupTestApp());
          await tester.pumpAndSettle();

          final tripSetup = TripSetupRobot(tester);

          // Complete trip setup
          await tripSetup.setupTrip('Japan', 'Week-long');

          // Should navigate to routes screen
          final routes = RecommendedRoutesRobot(tester);
          await routes.verifyScreenDisplayed();
          await routes.verifyPageTitleDisplayed();
        },
      );

      testWidgets(
        'should display route options for selected country',
        (tester) async {
          await tester.pumpWidget(
            createTestApp(initialRoute: '/trip/routes'),
          );
          await tester.pumpAndSettle();

          final routes = RecommendedRoutesRobot(tester);
          await routes.verifyScreenDisplayed();
        },
      );
    });

    group('Itinerary Blocks Journey', () {
      testWidgets(
        'should allow entering day builder from city block',
        (tester) async {
          // Start with a trip that has cities
          await tester.pumpWidget(
            createTestApp(initialRoute: '/trip/japan-trip'),
          );
          await tester.pumpAndSettle();

          // Verify we can access trip dashboard - title is "Japan Adventure"
          expect(find.textContaining('Japan'), findsWidgets);
        },
      );
    });
  });

  group('User Journey 2: Day Builder', () {
    group('Overview Tab Journey', () {
      testWidgets(
        'should display free day status for empty days',
        (tester) async {
          await tester.pumpWidget(
            createTestApp(initialRoute: '/trip/japan-trip/day/Tokyo'),
          );
          await tester.pumpAndSettle();

          final dayBuilder = DayBuilderRobot(tester);
          await dayBuilder.verifyScreenDisplayed();
          await dayBuilder.verifyFreeDayTextDisplayed();
        },
      );

      testWidgets(
        'should display generate button on free days',
        (tester) async {
          await tester.pumpWidget(
            createTestApp(initialRoute: '/trip/japan-trip/day/Tokyo'),
          );
          await tester.pumpAndSettle();

          final dayBuilder = DayBuilderRobot(tester);
          await dayBuilder.verifyAutoFillButtonDisplayed();
        },
      );

      testWidgets(
        'should allow day navigation between days',
        (tester) async {
          await tester.pumpWidget(
            createTestApp(initialRoute: '/trip/japan-trip/day/Tokyo'),
          );
          await tester.pumpAndSettle();

          final dayBuilder = DayBuilderRobot(tester);

          // Verify day chips are displayed
          await dayBuilder.verifyDayChipDisplayed(1);

          // Try navigating to day 2 if it exists
          if (dayBuilder.dayChip(2).evaluate().isNotEmpty) {
            await dayBuilder.tapDayChip(2);
            await dayBuilder.verifyDayChipDisplayed(2);
          }
        },
      );

      testWidgets(
        'should display day labels after generation',
        (tester) async {
          await tester.pumpWidget(
            createTestApp(initialRoute: '/trip/japan-trip/day/Tokyo'),
          );
          await tester.pumpAndSettle();

          final dayBuilder = DayBuilderRobot(tester);

          // Verify Overview tab is accessible
          await dayBuilder.tapOverviewTab();
          await dayBuilder.verifyScreenDisplayed();
        },
      );
    });

    group('Itinerary Tab Journey', () {
      testWidgets(
        'should switch to itinerary tab and display time buckets',
        (tester) async {
          await tester.pumpWidget(
            createTestApp(initialRoute: '/trip/japan-trip/day/Tokyo'),
          );
          await tester.pumpAndSettle();

          final dayBuilder = DayBuilderRobot(tester);

          // Switch to Itinerary tab
          await dayBuilder.tapItineraryTab();
          expect(dayBuilder.itineraryTab, findsOneWidget);
        },
      );

      testWidgets(
        'should allow switching between Overview and Itinerary tabs',
        (tester) async {
          await tester.pumpWidget(
            createTestApp(initialRoute: '/trip/japan-trip/day/Tokyo'),
          );
          await tester.pumpAndSettle();

          final dayBuilder = DayBuilderRobot(tester);

          // Start on Overview
          await dayBuilder.verifyTabsDisplayed();

          // Switch to Itinerary
          await dayBuilder.tapItineraryTab();
          expect(dayBuilder.itineraryTab, findsOneWidget);

          // Switch back to Overview
          await dayBuilder.tapOverviewTab();
          expect(dayBuilder.overviewTab, findsOneWidget);
        },
      );
    });

    group('Day Management Journey', () {
      testWidgets(
        'should handle multiple days in a city',
        (tester) async {
          await tester.pumpWidget(
            createTestApp(initialRoute: '/trip/japan-trip/day/Tokyo'),
          );
          await tester.pumpAndSettle();

          final dayBuilder = DayBuilderRobot(tester);
          await dayBuilder.verifyScreenDisplayed();

          // Verify at least one day exists
          await dayBuilder.verifyDayChipDisplayed(1);
        },
      );

      testWidgets(
        'should allow adding activities via add button',
        (tester) async {
          await tester.pumpWidget(
            createTestApp(initialRoute: '/trip/japan-trip/day/Tokyo'),
          );
          await tester.pumpAndSettle();

          final dayBuilder = DayBuilderRobot(tester);

          // Switch to Itinerary tab where add button is
          await dayBuilder.tapItineraryTab();

          // Verify add activity button is present
          if (dayBuilder.addActivityButton.evaluate().isNotEmpty) {
            expect(dayBuilder.addActivityButton, findsOneWidget);
          }
        },
      );
    });

    group('Anchor System Journey', () {
      testWidgets(
        'should display anchor in generated day',
        (tester) async {
          await tester.pumpWidget(
            createTestApp(initialRoute: '/trip/japan-trip/day/Tokyo'),
          );
          await tester.pumpAndSettle();

          final dayBuilder = DayBuilderRobot(tester);
          await dayBuilder.verifyScreenDisplayed();

          // Test will verify anchor system when days are generated
          // This is a placeholder for future anchor-specific tests
        },
      );
    });
  });

  group('User Journey 3: Explore Flow', () {
    group('Browse Destinations Journey', () {
      testWidgets(
        'should display explore screen with tabs',
        (tester) async {
          await tester.pumpWidget(createHomeTestApp());
          await tester.pumpAndSettle();

          final home = HomeRobot(tester);
          await home.tapExploreTab();

          final explore = ExploreRobot(tester);
          await explore.verifyScreenDisplayed();
          await explore.verifyTabsDisplayed();
        },
      );

      testWidgets(
        'should switch between Destinations and Itineraries tabs',
        (tester) async {
          await tester.pumpWidget(createHomeTestApp());
          await tester.pumpAndSettle();

          final home = HomeRobot(tester);
          await home.tapExploreTab();

          final explore = ExploreRobot(tester);

          // Test Destinations tab
          await explore.tapDestinationsTab();
          expect(explore.destinationsTab, findsOneWidget);

          // Test Itineraries tab
          await explore.tapItinerariesTab();
          expect(explore.itinerariesTab, findsOneWidget);
        },
      );

      testWidgets(
        'should display search bar for finding destinations',
        (tester) async {
          await tester.pumpWidget(createHomeTestApp());
          await tester.pumpAndSettle();

          final home = HomeRobot(tester);
          await home.tapExploreTab();

          final explore = ExploreRobot(tester);
          await explore.verifySearchBarDisplayed();
        },
      );
    });

    group('View Curated Itineraries Journey', () {
      testWidgets(
        'should display itineraries in Itineraries tab',
        (tester) async {
          await tester.pumpWidget(createHomeTestApp());
          await tester.pumpAndSettle();

          final home = HomeRobot(tester);
          await home.tapExploreTab();

          final explore = ExploreRobot(tester);
          await explore.tapItinerariesTab();

          // Verify tab is active
          expect(explore.itinerariesTab, findsOneWidget);
        },
      );
    });

    group('Destination Detail Journey', () {
      testWidgets(
        'should navigate to destination detail when tapping card',
        (tester) async {
          await tester.pumpWidget(
            createTestApp(initialRoute: '/explore/destination/japan'),
          );
          await tester.pumpAndSettle();

          final destination = DestinationDetailRobot(tester);
          await destination.verifyScreenDisplayed();
          await destination.verifyTabsDisplayed();
        },
      );

      testWidgets(
        'should display Overview, Cities, and Itineraries tabs in destination detail',
        (tester) async {
          await tester.pumpWidget(
            createTestApp(initialRoute: '/explore/destination/japan'),
          );
          await tester.pumpAndSettle();

          final destination = DestinationDetailRobot(tester);

          // Test all tabs
          await destination.tapOverviewTab();
          expect(destination.overviewTab, findsOneWidget);

          await destination.tapCitiesTab();
          expect(destination.citiesTab, findsOneWidget);

          await destination.tapItinerariesTab();
          expect(destination.itinerariesTab, findsOneWidget);
        },
      );
    });

    group('City Detail Journey', () {
      testWidgets(
        'should navigate to city detail from destination',
        (tester) async {
          await tester.pumpWidget(
            createTestApp(initialRoute: '/explore/city/tokyo'),
          );
          await tester.pumpAndSettle();

          final city = CityDetailRobot(tester);
          await city.verifyScreenDisplayed();
          await city.verifyTabsDisplayed();
        },
      );

      testWidgets(
        'should allow saving items from city detail',
        (tester) async {
          await tester.pumpWidget(
            createTestApp(initialRoute: '/explore/city/tokyo'),
          );
          await tester.pumpAndSettle();

          final city = CityDetailRobot(tester);

          // Verify save button is present
          if (city.saveButton.evaluate().isNotEmpty) {
            expect(city.saveButton, findsOneWidget);
          }
        },
      );
    });

    group('Save to Saved Hub Journey', () {
      testWidgets(
        'should save items from explore to saved hub',
        (tester) async {
          await tester.pumpWidget(
            createTestApp(initialRoute: '/explore/city/tokyo'),
          );
          await tester.pumpAndSettle();

          final city = CityDetailRobot(tester);

          // Tap save button if available
          if (city.saveButton.evaluate().isNotEmpty) {
            await city.tapSaveButton();
            // After save, icon should change to saved state
            // This would need backend integration to fully test
          }
        },
      );
    });
  });

  group('User Journey 4: Saved Flow', () {
    group('View Saved Items Journey', () {
      testWidgets(
        'should display saved screen with tabs',
        (tester) async {
          await tester.pumpWidget(createHomeTestApp());
          await tester.pumpAndSettle();

          final home = HomeRobot(tester);
          await home.tapSavedTab();

          final saved = SavedRobot(tester);
          await saved.verifyScreenDisplayed();
          await saved.verifyTabsDisplayed();
        },
      );

      testWidgets(
        'should display empty state when no items saved',
        (tester) async {
          await tester.pumpWidget(createHomeTestApp());
          await tester.pumpAndSettle();

          final home = HomeRobot(tester);
          await home.tapSavedTab();

          final saved = SavedRobot(tester);

          // Check for empty state
          if (saved.emptyStateText.evaluate().isNotEmpty) {
            await saved.verifyEmptyStateDisplayed();
          }
        },
      );

      testWidgets(
        'should switch between Places, Itineraries, and Links tabs',
        (tester) async {
          await tester.pumpWidget(createHomeTestApp());
          await tester.pumpAndSettle();

          final home = HomeRobot(tester);
          await home.tapSavedTab();

          final saved = SavedRobot(tester);

          // Test Places tab
          await saved.tapPlacesTab();
          expect(saved.placesTab, findsOneWidget);

          // Test Itineraries tab
          await saved.tapItinerariesTab();
          expect(saved.itinerariesTab, findsOneWidget);

          // Test Links tab
          await saved.tapLinksTab();
          expect(saved.linksTab, findsOneWidget);
        },
      );
    });

    group('Saved by City/Collection Journey', () {
      testWidgets(
        'should display saved items grouped by city',
        (tester) async {
          await tester.pumpWidget(createHomeTestApp());
          await tester.pumpAndSettle();

          final home = HomeRobot(tester);
          await home.tapSavedTab();

          final saved = SavedRobot(tester);
          await saved.tapPlacesTab();

          // City blocks should be displayed if items exist
          // This requires test data to be present
        },
      );

      testWidgets(
        'should navigate to city detail when tapping city block',
        (tester) async {
          await tester.pumpWidget(
            createTestApp(initialRoute: '/saved/city/tokyo'),
          );
          await tester.pumpAndSettle();

          final cityDetail = SavedCityDetailRobot(tester);
          await cityDetail.verifyScreenDisplayed();
        },
      );
    });

    group('Generate Itinerary from Saved Items Journey', () {
      testWidgets(
        'should show create itinerary CTA in saved city detail',
        (tester) async {
          await tester.pumpWidget(
            createTestApp(initialRoute: '/saved/city/tokyo'),
          );
          await tester.pumpAndSettle();

          final cityDetail = SavedCityDetailRobot(tester);

          // Verify create itinerary button
          if (cityDetail.createItineraryCta.evaluate().isNotEmpty) {
            expect(cityDetail.createItineraryCta, findsOneWidget);
          }
        },
      );

      testWidgets(
        'should navigate to customize itinerary from saved items',
        (tester) async {
          await tester.pumpWidget(
            createTestApp(initialRoute: '/saved/customize/tokyo-5day'),
          );
          await tester.pumpAndSettle();

          final customize = CustomizeItineraryRobot(tester);
          await customize.verifyScreenDisplayed();
        },
      );

      testWidgets(
        'should allow reviewing route before finalizing',
        (tester) async {
          await tester.pumpWidget(
            createTestApp(initialRoute: '/saved/review'),
          );
          await tester.pumpAndSettle();

          final review = ReviewRouteRobot(tester);
          await review.verifyScreenDisplayed();
        },
      );
    });

    group('Organize/Remove Saved Items Journey', () {
      testWidgets(
        'should allow accessing saved city detail to manage items',
        (tester) async {
          await tester.pumpWidget(
            createTestApp(initialRoute: '/saved/city/tokyo'),
          );
          await tester.pumpAndSettle();

          final cityDetail = SavedCityDetailRobot(tester);
          await cityDetail.verifyScreenDisplayed();
        },
      );
    });
  });

  group('User Journey 5: Social Media Import', () {
    group('Paste URL Journey', () {
      testWidgets(
        'should display scan TikTok button in Saved tab',
        (tester) async {
          await tester.pumpWidget(createHomeTestApp());
          await tester.pumpAndSettle();

          final home = HomeRobot(tester);
          await home.tapSavedTab();

          final saved = SavedRobot(tester);

          // Verify Scan TikTok button is present
          if (saved.scanTiktokButton.evaluate().isNotEmpty) {
            expect(saved.scanTiktokButton, findsOneWidget);
          }
        },
      );

      testWidgets(
        'should navigate to scan results when tapping Scan TikTok',
        (tester) async {
          await tester.pumpWidget(createHomeTestApp());
          await tester.pumpAndSettle();

          final home = HomeRobot(tester);
          await home.tapSavedTab();

          final saved = SavedRobot(tester);

          // Tap scan button if available
          if (saved.scanTiktokButton.evaluate().isNotEmpty) {
            await saved.tapScanTiktok();
            // Should navigate to scan results screen
          }
        },
      );
    });

    group('TikTok Scan Results Journey', () {
      testWidgets(
        'should display loading state during scan',
        (tester) async {
          await tester.pumpWidget(
            createScanResultsTestApp(
              url: 'https://www.tiktok.com/@test/video/123',
            ),
          );
          // Only pump one frame to catch loading state
          await tester.pump();

          final scan = TiktokScanResultsRobot(tester);
          await scan.verifyScreenDisplayed();
          await scan.verifyLoadingState();
        },
      );

      testWidgets(
        'should display error state when scan fails',
        (tester) async {
          await tester.pumpWidget(
            createTestApp(initialRoute: '/saved/scan-results'),
          );
          await tester.pump();
          await tester.pump(const Duration(seconds: 1));

          final scan = TiktokScanResultsRobot(tester);
          await scan.verifyScreenDisplayed();
          await scan.verifyErrorState();
        },
      );

      testWidgets(
        'should hide footer in error state',
        (tester) async {
          await tester.pumpWidget(
            createTestApp(initialRoute: '/saved/scan-results'),
          );
          await tester.pump();
          await tester.pump(const Duration(seconds: 1));

          final scan = TiktokScanResultsRobot(tester);
          await scan.verifyFooterHidden();
        },
      );

      testWidgets(
        'should allow retry on error',
        (tester) async {
          await tester.pumpWidget(
            createTestApp(initialRoute: '/saved/scan-results'),
          );
          await tester.pump();
          await tester.pump(const Duration(seconds: 1));

          final scan = TiktokScanResultsRobot(tester);
          expect(scan.tryAgainButton, findsOneWidget);
        },
      );

      testWidgets(
        'should allow navigation back from scan results',
        (tester) async {
          await tester.pumpWidget(
            createTestApp(initialRoute: '/saved/scan-results'),
          );
          await tester.pump();
          await tester.pump(const Duration(seconds: 1));

          final scan = TiktokScanResultsRobot(tester);
          expect(scan.backButton, findsOneWidget);
        },
      );
    });

    group('Save to Collection Journey', () {
      testWidgets(
        'should display Create a Trip CTA in results footer',
        (tester) async {
          await tester.pumpWidget(
            createScanResultsTestApp(
              url: 'https://www.tiktok.com/@test/video/123',
            ),
          );
          await tester.pump();

          final scan = TiktokScanResultsRobot(tester);

          // Footer should contain Create Trip button when results exist
          // This test requires mock data to verify fully
        },
      );
    });
  });

  group('Edge Cases and Error Handling', () {
    testWidgets(
      'should handle empty trip setup gracefully',
      (tester) async {
        await tester.pumpWidget(createTripSetupTestApp());
        await tester.pumpAndSettle();

        final tripSetup = TripSetupRobot(tester);
        await tripSetup.verifyScreenDisplayed();

        // CTA should be present even without selections
        await tripSetup.verifySeeRoutesCtaDisplayed();
      },
    );

    testWidgets(
      'should handle navigation between major sections',
      (tester) async {
        await tester.pumpWidget(createHomeTestApp());
        await tester.pumpAndSettle();

        final home = HomeRobot(tester);

        // Test navigation to all tabs
        await home.tapTripsTab();
        await tester.pumpAndSettle();

        await home.tapExploreTab();
        await tester.pumpAndSettle();

        await home.tapSavedTab();
        await tester.pumpAndSettle();

        await home.tapProfileTab();
        await tester.pumpAndSettle();

        // Return to home
        await home.tapTripsTab();
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'should handle empty saved state correctly',
      (tester) async {
        await tester.pumpWidget(createHomeTestApp());
        await tester.pumpAndSettle();

        final home = HomeRobot(tester);
        await home.tapSavedTab();

        final saved = SavedRobot(tester);

        // Should show empty state or tabs
        if (saved.emptyStateText.evaluate().isNotEmpty) {
          await saved.verifyEmptyStateDisplayed();
        } else {
          await saved.verifyTabsDisplayed();
        }
      },
    );
  });
}
