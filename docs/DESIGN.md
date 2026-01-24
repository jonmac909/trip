# Trippified Design Reference

## Design File
All UI designs are maintained in **`Trippified_12.pen`** (Pencil app).

## Screen Index

| Screen | Design ID | Description |
|--------|-----------|-------------|
| Splash Screen | `EBVXQ` | Onboarding entry with hero image and CTA |
| Login Screen | `Jgwld` | Social auth buttons, email/password fallback |
| Home - With Trips | `7XXBb` | Trip list with tab navigation |
| Home - Empty | `IF7R0` | Empty state with illustration |
| Trip Setup | `KEPq6` | Country selection + trip duration |
| Routes - Japan | `rfkvI` | Recommended routes with city flow |
| Itinerary Blocks | `QNXEv` | Draggable city arrangement |
| Trip Dashboard | `sZNhc` | Trip overview with checklist and itineraries |
| Day Builder | `zoZU9` | Day planning with map and generate buttons |
| Explore - Destinations | `6jJDx` | Browse destinations |
| Explore - Itineraries | `WFIE5` | Browse pre-made itineraries |
| Saved | `hJ74D` | Saved items organized by collection |
| Profile | `TzDWQ` | User profile and settings menu |

## Design System

### Color Palette

| Token | Hex | Usage |
|-------|-----|-------|
| **Primary** | `#1A1A1A` | Buttons, headers, key UI elements |
| **Accent** | `#BFFF00` | FAB, highlights, active states, CTAs |
| **Surface** | `#F9FAFB` | Card backgrounds, input fields |
| **Background** | `#FFFFFF` | Screen backgrounds |
| **Text Primary** | `#1F2937` | Headings, body text |
| **Text Secondary** | `#6B7280` | Subtitles, descriptions |
| **Text Tertiary** | `#9CA3AF` | Placeholders, hints |
| **Border** | `#E5E7EB` | Dividers, card borders |

### Typography
- **Font Family**: DM Sans (Google Fonts)
- **Weights**: 400 (Regular), 500 (Medium), 600 (SemiBold), 700 (Bold)

### Icons
- **Library**: Lucide Icons
- **Style**: Outlined, 24px default size

## Key Screens

### Trip Setup (KEPq6)
- Back arrow + "Plan a Trip" header
- Country search field with autocomplete
- Selected countries as removable chips
- Trip duration radio options (Short / Week-long / Long or open-ended)
- "See Recommended Routes" CTA button

### Routes (rfkvI)
- Header with country badge (e.g., "Japan 1/2")
- Route cards with thumbnail, name, duration, city count
- City flow chips (Tokyo → Kyoto → Osaka)
- "+ Create custom route" option
- "Next: [Country]" or "Create My Trip" CTA

### Itinerary Blocks (QNXEv)
- Header with total days badge
- Country sections with flag emoji
- Draggable city blocks with day counts
- Transport connectors between cities
- "+ Add City" button
- "Create My Trip" CTA

### Trip Dashboard (sZNhc)
- Hero image header
- Trip title with "Add dates?" link
- Stats row: Cities | Countries | Days
- Trip Checklist card with progress
- City itinerary cards with transport connectors
- Bottom navigation

### Day Builder (zoZU9)
- Collapsible map section
- City/duration header with date badge
- Tab bar: Overview | Itinerary | Bookings
- "Auto-fill" button (lime green)
- Day list with Generate buttons
- Bottom navigation
