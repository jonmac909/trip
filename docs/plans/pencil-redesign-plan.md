# Plan: Implement Flutter Code from Pencil Designs (Trippified_12.pen)

## Overview
Replace current Flutter screens with implementations matching the Pencil designs exactly. The design uses DM Sans font, a clean monochrome palette with lime-green accents, and follows mobile-first patterns.

---

## Design System Updates

### 1. Update Color Palette
**File:** `lib/core/constants/app_colors.dart`

| Token | Current | New (from Pencil) |
|-------|---------|-------------------|
| primary | #5D3A1A (chocolate) | #1A1A1A (black) |
| primaryLight | #8B5A3C | #F9FAFB |
| accent | #7A3E4D | #BFFF00 (lime green) |
| textPrimary | - | #1F2937 |
| textSecondary | - | #6B7280 / #9CA3AF |
| border | - | #E5E7EB |
| surface | - | #F9FAFB |

### 2. Update Typography
**File:** `lib/core/theme/app_theme.dart`

- Change font from Inter/Playfair to **DM Sans**
- Update font weights and sizes to match designs

### 3. Add Lucide Icons
**File:** `pubspec.yaml`

Add `lucide_icons` package for icon consistency with designs.

---

## Screens to Implement

### Screen 1: Splash Screen (NEW)
**Design ID:** `EBVXQ`
**File:** `lib/presentation/screens/splash/splash_screen.dart`

Layout:
- Full-bleed hero image with rounded bottom corners
- Gradient overlay from transparent to dark teal
- "Unveil The Travel Wonders" title
- "TRIPPIFIED" subtitle with letter spacing
- Description text
- CTA button "Explore Now →"

### Screen 2: Login Screen (UPDATE)
**Design ID:** `Jgwld`
**File:** `lib/presentation/screens/auth/login_screen.dart`

Layout:
- Logo (lime green circle with plane icon)
- "Welcome Back" title
- Subtitle
- Social login buttons (Google, Apple, Facebook)
- Divider with "or"
- Email/Password fields
- "Sign In" button
- "Don't have an account? Sign Up" link

### Screen 3: Home Screen (UPDATE)
**Design ID:** `7XXBb` (with trips) / `IF7R0` (empty)
**File:** `lib/presentation/screens/home/home_screen.dart`

Layout:
- "My Trips" header
- Tab bar: Upcoming | Drafts | Past | Wishlist
- Trip cards (or empty state)
- Bottom navigation: Trips | Explore | Saved | Profile
- FAB (lime green + icon)

### Screen 4: Trip Setup (UPDATE)
**Design ID:** `KEPq6`
**File:** `lib/presentation/screens/trip_setup/trip_setup_screen.dart`

Layout:
- Back arrow + "Plan a Trip" header
- "Where do you want to go?" section
  - Search field
  - Country chips (removable)
- "How long is your trip?" section
  - Radio options: Short trip | Week-long | Long or open-ended
- "See Recommended Routes →" CTA (black button)

### Screen 5: Routes Screen (NEW)
**Design ID:** `rfkvI`
**File:** `lib/presentation/screens/routes/recommended_routes_screen.dart`

Layout:
- Back arrow + "Routes" + country badge (e.g., "Japan 1/2")
- Subtitle
- Route cards with:
  - Thumbnail image
  - Route name + duration + city count
  - City flow chips (Tokyo → Kyoto → Osaka)
  - Optional star icon for featured
- "+ Create custom route" option
- "Next: [Country]" or "Create My Trip" CTA

### Screen 6: Itinerary Blocks (NEW)
**Design ID:** `QNXEv`
**File:** `lib/presentation/screens/itinerary/itinerary_blocks_screen.dart`

Layout:
- Back arrow + "Your Itinerary" + total days badge
- Subtitle: "Drag to reorder cities and countries"
- Country section headers with flag emoji
- City blocks:
  - Drag handle + City name + Days + Edit icon
  - Selected state with dark border
- Connectors between cities (transport + duration)
- "+ Add City" button
- "Create My Trip" CTA

### Screen 7: Trip Dashboard (NEW)
**Design ID:** `sZNhc`
**File:** `lib/presentation/screens/trip/trip_dashboard_screen.dart`

Layout:
- Hero image header
- Trip title + "Add dates?" link
- Stats row: Cities | Countries | Days
- "Trip Checklist" card with progress
- "Your Itineraries" section
  - City itinerary cards with image, name, dates, "Active" badge
  - Transport connectors between cities
- Bottom navigation

### Screen 8: Day Builder (UPDATE)
**Design ID:** `zoZU9`
**File:** `lib/presentation/screens/day_builder/day_builder_screen.dart`

Layout:
- Collapsible map section with back button overlay
- "5 Days in Tokyo ∨" header + date badge
- Tab bar: Overview | Itinerary | Bookings
- "X days to plan" + "Auto-fill" button (lime green)
- Day list:
  - Day number + date + status
  - "Generate" button for each day
- Bottom navigation

### Screen 9: Explore Screen (NEW)
**Design ID:** `6jJDx` / `WFIE5`
**File:** `lib/presentation/screens/explore/explore_screen.dart`

Layout:
- "Explore" header with search icon
- Tab bar: Destinations | Itineraries
- Featured destination cards
- Bottom navigation

### Screen 10: Saved Screen (NEW)
**Design ID:** `hJ74D`
**File:** `lib/presentation/screens/saved/saved_screen.dart`

Layout:
- "Saved" header
- Collection sections
- Bottom navigation

### Screen 11: Profile Screen (NEW)
**Design ID:** `TzDWQ`
**File:** `lib/presentation/screens/profile/profile_screen.dart`

Layout:
- Avatar + name
- Menu items: Tickets & Bookings, Settings, Notifications, Help
- Bottom navigation

---

## Shared Components to Create

### 1. Bottom Navigation Bar
**File:** `lib/core/widgets/app_bottom_nav.dart`
- 4 tabs: Trips, Explore, Saved, Profile
- Lucide icons
- Active/inactive states

### 2. Country Chip
**File:** `lib/core/widgets/country_chip.dart`
- Removable chip with X button

### 3. Trip Size Option
**File:** `lib/core/widgets/trip_size_option.dart`
- Radio-style selection card

### 4. Route Card
**File:** `lib/presentation/widgets/route_card.dart`
- Image + title + stats + city flow

### 5. City Block
**File:** `lib/presentation/widgets/city_block.dart`
- Draggable city card with edit functionality

### 6. Transport Connector
**File:** `lib/presentation/widgets/transport_connector.dart`
- Shows transport type + duration between cities

### 7. Day Card
**File:** `lib/presentation/widgets/day_card.dart`
- Day number + date + status + Generate button

---

## Implementation Order

1. **Design System** - Update colors, fonts, add icons package
2. **Shared Widgets** - Bottom nav, chips, buttons
3. **Splash & Login** - Entry screens
4. **Home Screen** - Main hub with tabs
5. **Trip Setup** - Country + trip size selection
6. **Routes Screen** - Route selection flow
7. **Itinerary Blocks** - City arrangement
8. **Trip Dashboard** - Trip overview
9. **Day Builder** - Day planning
10. **Explore/Saved/Profile** - Supporting screens

---

## Verification Steps

1. After each screen, deploy to Cloudflare: `./scripts/deploy.sh`
2. Compare visually with Pencil screenshots
3. Test navigation flow between screens
4. Verify responsive behavior
5. Check all interactive elements work

---

## Critical Files to Modify

```
lib/
├── core/
│   ├── constants/
│   │   └── app_colors.dart          # Color updates
│   ├── theme/
│   │   └── app_theme.dart           # Typography updates
│   └── widgets/
│       ├── app_bottom_nav.dart      # NEW
│       ├── country_chip.dart        # NEW
│       └── trip_size_option.dart    # NEW
├── presentation/
│   ├── screens/
│   │   ├── splash/splash_screen.dart
│   │   ├── auth/login_screen.dart
│   │   ├── home/home_screen.dart
│   │   ├── trip_setup/trip_setup_screen.dart
│   │   ├── routes/recommended_routes_screen.dart  # NEW
│   │   ├── itinerary/itinerary_blocks_screen.dart # NEW
│   │   ├── trip/trip_dashboard_screen.dart        # NEW
│   │   ├── day_builder/day_builder_screen.dart
│   │   ├── explore/explore_screen.dart
│   │   ├── saved/saved_screen.dart
│   │   └── profile/profile_screen.dart
│   └── widgets/
│       ├── route_card.dart          # NEW
│       ├── city_block.dart          # NEW
│       ├── transport_connector.dart # NEW
│       └── day_card.dart            # NEW
└── pubspec.yaml                     # Add lucide_icons
```
