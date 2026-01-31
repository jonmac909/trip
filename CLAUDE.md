# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Run app (loads .env automatically via dart-define flags)
./scripts/run_dev.sh

# Run on specific iOS simulator
flutter run -d <DEVICE_ID>

# Run all tests
flutter test

# Run single test file
flutter test test/scan_pipeline_test.dart

# Run integration tests
flutter test integration_test/

# Run single integration test
flutter test integration_test/saved_test.dart

# Format and analyze
dart format . && dart analyze

# Install dependencies
flutter pub get
```

Environment variables are passed via `--dart-define` flags. The `scripts/run_dev.sh` script reads from `.env` and builds these flags automatically. The Gemini API key has a hardcoded default in `EnvConfig` so no flag is needed for AI features.

## Architecture

Flutter app using a simplified Clean Architecture pattern with Riverpod for state management, GoRouter for navigation, and Supabase as the backend.

### Layer Structure

```
lib/
├── core/           # Shared infrastructure (config, constants, errors, services, theme, widgets)
├── data/           # Repository implementations (Supabase queries)
├── domain/         # Models (Trip, CityBlock, Day, Activity, ScannedPlace, etc.)
├── presentation/   # UI layer (screens, widgets, providers, navigation)
└── main.dart       # Entry point (portrait-only, Supabase init, ProviderScope)
```

### Data Flow

**Screens** (ConsumerWidget) -> **Providers** (Riverpod) -> **Repositories** (data/) -> **Supabase**

Providers live in `lib/presentation/providers/`. Three provider types are used:
- `Provider<Repository>` — repository singletons
- `FutureProvider` / `FutureProvider.family` — async data fetching
- `StateNotifierProvider` — mutation operations (create/update/delete)

### Domain Model Hierarchy

`Trip` -> `CityBlock` (cities within a trip) -> `Day` -> `Activity`

Models use manual JSON serialization (`fromJson`/`toJson`/`copyWith`), not Freezed codegen. All models are immutable with `const` constructors.

### Navigation

GoRouter with route constants in `AppRoutes` class (`lib/presentation/navigation/app_router.dart`). Complex data is passed via `state.extra` as `Map<String, dynamic>` with typed casting at the route builder.

28 routes across modules: auth, trip setup, itinerary builder, day builder, explore, saved, profile, features.

### AI Services

Three services in `lib/core/services/` power the content scanning pipeline:

1. **SocialMediaMetadataService** — Fetches TikTok metadata via oEmbed API (`/oembed?url=`). Falls back to HTML og:tag scraping for Instagram. TikTok's WAF blocks direct HTML scraping, so oEmbed is required.

2. **GeminiService** — Gemini 2.5 Flash for two features:
   - Itinerary generation (`generateDayPlans`) — text-only, returns day plans with activities
   - Place extraction (4 methods) — text-only, text+image multimodal, screenshot vision, video vision. Returns `List<ScannedPlace>`.

3. **ContentScanService** — Orchestrator with three entry points: `scanUrl()`, `scanImages()`, `scanVideo()`. URL path uses multimodal (caption + thumbnail) when available.

### Exception Hierarchy

All custom exceptions extend `TrippifiedException` (`lib/core/errors/exceptions.dart`). Key subclasses: `ValidationException`, `ExternalServiceException`, `AiGenerationException`, `UnauthorizedException`, `NetworkException`.

## Design System

- **Font**: `GoogleFonts.dmSans()` everywhere
- **Icons**: `LucideIcons.*` only (never Material icons)
- **Accent**: `#BFFF00` (lime green) — `AppColors.limeGreen`
- **Maps**: Apple Maps with `mutedStandard` style, English labels. Do NOT use Google Maps.
- **Spacing**: 4px base unit (xs=4, sm=8, md=16, lg=24, xl=32)
- **Design source**: Pencil `.pen` files + exported JSON in `/design-exports/`

## Testing

Tests use a **Robot pattern** (Page Object Model). Each screen module has a robot class in `integration_test/robots/` with finders and verification methods.

Test app helpers in `integration_test/test_app.dart` — `createTestApp()`, `createHomeTestApp()`, `createScanResultsTestApp()`, etc. These wrap the widget in `ProviderScope` + `MaterialApp.router` with proper theme.

**Important**: Screens with `AnimationController.repeat()` (like the scan results pulse animation) will cause `pumpAndSettle` to hang indefinitely. Use `pump(Duration)` instead for those screens.

## OAuth Configuration

**Google OAuth Client IDs** (Google Cloud Console project `500863193538`):
- iOS: `500863193538-un8dnveu1754c19044ou95tq6jbfcmpe.apps.googleusercontent.com`
- Web: `500863193538-6oag4kr62ddm260j83pnne5kncoqt3fk.apps.googleusercontent.com`

**Supabase** (project `vawaszwwsuyuwsasgdtq`):
- Both client IDs must be in Authentication → Providers → Google → Client IDs
- Skip nonce checks: ON (required for iOS)
- Apple Sign-In: Bundle ID `com.jonmac.trippified` in Client IDs

## Key Constraints

- Supabase is optional — app runs in "demo mode" without credentials
- Video uploads to Gemini: 20MB max (inline `DataPart` base64)
- Portrait orientation only
- Free tier limits defined in `AppConstants` (2 trips, 50 saved items, 5 imports/month)
