# Trippified — Product Requirements Document

## 1. App Overview

**Trippified** is a mobile trip planning app that helps users move through the planning process faster and more intuitively. It serves casual planners who don't want to spend hours researching and frequent travelers who want efficiency.

### Core Value Proposition
Fast, streamlined trip planning that doesn't overwhelm you.

### Key Differentiator
Social media import with AI-powered extraction—users can save travel content from TikTok and Instagram, and Trippified automatically extracts locations and generates smart itineraries from saved collections.

---

## 2. Target Audience

### Primary Users
- **Casual Planners**: Want simplicity, don't want to spend hours planning
- **Frequent Travelers**: Want speed and efficiency, have done this before

### User Characteristics
- Mobile-first behavior (plan on the couch, access on the go)
- Discover travel inspiration on social media
- Value suggestions but want control over final decisions
- Travel solo, as couples, with family, or in friend groups

---

## 3. Core Features and Functionality

### 3.1 Three Entry Points

Users can enter the planning flow from three different starting points depending on their stage of travel planning:

| Flow | Purpose | User State |
|------|---------|------------|
| **Trippified** | Plan a trip immediately | "I know where I'm going" |
| **Explore** | Browse destinations and pre-made itineraries | "I don't know where to go yet" |
| **Saved** | View and organize saved items | "I've been collecting inspiration" |

All three flows ultimately lead to creating a trip itinerary.

---

### 3.2 Trippified Flow (Trip Planner)

#### Screen 1: Trip Setup
- **Input**: Countries (autocomplete, multiple allowed)
- **Input**: Trip size (Short / Week-long / Long or open-ended)
- **Output**: Recommended routes

**Acceptance Criteria:**
- User can add multiple countries via autocomplete
- Countries display as removable chips
- Trip size is single-select
- CTA disabled until ≥1 country and trip size selected

#### Screen 2: Recommended Routes
- Display pre-made city routes grouped by country
- Routes are suggestions, not constraints
- User can select one route per country or create custom

**Acceptance Criteria:**
- Routes never cross countries
- User can skip routes for a country
- "Create custom route" option always visible
- CTA enabled when ≥1 route selected OR custom route started

#### Screen 3: Itinerary Blocks (Trip Skeleton)
- Vertical list of city blocks with day counts
- Map showing all cities with connectors
- Drag-and-drop reordering (cities can be interleaved across countries)

**Acceptance Criteria:**
- Day counts auto-assigned but editable
- Connectors show transport method and duration (informational)
- User can add/remove cities
- Tapping a city block enters Day Builder

---

### 3.3 Day Builder

The Day Builder fills in meaning for each day within a city.

#### Layout (Fixed)
- **Top half**: Map (collapsible/expandable)
- **Bottom half**: Two tabs only — Overview | Itinerary

#### Overview Tab ("What" the day is)

**Initial State:**
```
Day 1 — Free day        [Generate]
Day 2 — Free day        [Generate]
Day 3 — Free day        [Generate]
```

**Generate Behavior (One-Click):**
1. No questions asked upfront
2. System automatically selects best anchor for the city
3. Builds coherent daily route (~4-5 activities)
4. Ensures tight geographic clustering
5. Day becomes "Generated day" with label (e.g., "Temple day")

**Generated Day States:**
- Collapsed: `Day 2 — Temple day [Edit] (see 2 other options)`
- Expanded peek: Shows 3-4 bullet points (no times, no editing)

**Anchor Rules:**
- Every generated day has ONE anchor
- Anchor defines the day label
- Swap anchor via options → label updates
- Remove anchor manually → becomes "Custom day"
- Remove everything → becomes "Free day"

#### Itinerary Tab ("How" the day works)

**Layout:**
- Map focused on selected day
- Activities grouped by time buckets (Morning / Midday / Afternoon / Evening)
- Travel time between stops shown
- No strict clock times

**Edit Mode (via Edit button):**
- Reorder activities
- Remove activities
- Add nearby places
- Swap/remove anchor
- Clear the day

**Acceptance Criteria:**
- Days are draggable in Overview (reorder updates numbering)
- Free days are valid and allowed forever
- No forced completion

---

### 3.4 Explore Flow

Browse destinations and pre-made itineraries when users don't know where to go yet.

**Features:**
- Browse cities and destinations
- View curated/pre-made itineraries
- Save items to Saved hub
- One-tap to use a pre-made itinerary as starting point

*(Detailed wireframes TBD)*

---

### 3.5 Saved Flow

Central hub for all saved inspiration.

**Sources:**
- Items saved from Explore tab
- Locations imported from TikTok/Instagram

**Features:**
- View all saved items organized by city/collection
- Auto-generate itinerary from saved collection (e.g., 10 London spots → full itinerary)
- Remove/organize saved items

*(Detailed wireframes TBD)*

---

### 3.6 Social Media Import

**Input Methods:**
- Share link directly into Trippified app
- Paste URL manually

**Extraction (AI-Powered):**
- Scan captions and descriptions
- Analyze video text overlays via AI vision
- Process video transcripts
- Extract location names and match to places database

**Technical Requirements:**
- Speed is critical — must feel instant
- Use AI vision API (Claude Vision, Gemini, or similar)
- Queue system for background processing with quick user feedback
- Match extracted text to Google Places for structured data

**Acceptance Criteria:**
- User shares TikTok/Instagram link
- App extracts locations within seconds
- Locations saved to Saved hub with city grouping
- User can generate itinerary from saved collection

---

### 3.7 Smart Itinerary Generation

When generating itineraries (from Saved items or Day Builder), the system should:

- Order activities by neighborhood/proximity to minimize travel
- Warn if an activity is far from others
- Warn if a location is closed (based on hours data)
- Cluster activities geographically
- Balance the day (not too packed, not too sparse)
- Consider user preferences (dietary, accessibility)

---

### 3.8 Collaboration

- Multiple users can view and edit the same trip
- All collaborators must have accounts
- No voting or task assignment features
- Simple shared access model

---

### 3.9 Bookings and Reservations

**Behavior:** Link out to external booking platforms (not in-app booking)

| Type | Source | Booking Link |
|------|--------|--------------|
| Restaurants | Google Places | Deep link with pre-filled date/time/party size |
| Hotels | TripAdvisor | Affiliate link |
| Flights | Amadeus | Affiliate link to booking platform |

**Monetization:** All booking links include affiliate codes for commission revenue.

---

### 3.10 Budget Tracking

Track trip expenses and manage travel budgets.

**Features:**
- Set overall trip budget
- Set per-city or per-day budgets
- Log expenses manually (amount, category, notes, photo of receipt)
- Auto-categorize expenses (food, transport, accommodation, activities, shopping)
- View spending by category, day, or city
- Budget vs. actual comparison
- Currency conversion (for international trips)
- Split expenses between travelers (for group trips)

**Expense Entry:**
```
- amount: number
- currency: string
- category: enum (food, transport, accommodation, activities, shopping, other)
- description: string
- date: date
- city: string
- receipt_photo: string (optional)
- split_with: string[] (user IDs, optional)
```

**Acceptance Criteria:**
- Quick expense entry (minimal taps)
- Running total always visible
- Warnings when approaching/exceeding budget
- Export expenses (CSV/PDF) for reimbursement

---

### 3.11 Live Trip Mode

Day-of features for when the user is actively traveling.

**Activation:**
- Automatically activates on trip start date
- Can be manually toggled

**Features:**
- **Today View**: Shows current day's itinerary prominently
- **Next Up**: Highlights upcoming activity with countdown
- **Navigation**: One-tap directions to next location (opens Apple Maps)
- **Check-ins**: Mark activities as done
- **Quick Changes**: Easy reschedule or skip activities
- **Notifications**: Reminders before activities (configurable timing)
- **Closure Alerts**: Real-time warnings if a planned location is unexpectedly closed
- **Weather Integration**: Current weather for the city
- **Time Zone Awareness**: Adjusts to local time automatically

**Acceptance Criteria:**
- Minimal battery drain
- Works with limited connectivity
- Non-intrusive notifications
- Quick access to essential info (address, hours, booking confirmation)

---

### 3.12 Offline Mode

Access trip information without internet connection.

**Downloadable Content:**
- Full itinerary with all activity details
- Maps for planned areas (via Apple Maps offline)
- Saved travel documents
- Booking confirmations
- Contact information for hotels/restaurants

**Sync Behavior:**
- Download prompt before trip starts
- Background sync when online
- Conflict resolution for offline edits
- Clear indicator of offline status

**Acceptance Criteria:**
- One-tap download of entire trip
- Storage size estimate before download
- Works in airplane mode
- Graceful degradation (core features work, some features unavailable)

---

### 3.13 Travel Documents Storage

Secure storage for travel-related documents.

**Supported Documents:**
- Passport (photo of ID page)
- Visas
- Travel insurance
- Booking confirmations (flights, hotels, activities)
- Vaccination records
- Driver's license
- Emergency contacts

**Features:**
- Upload photos or PDFs
- Organize by trip or document type
- Quick access during travel
- Expiration date tracking with reminders (passport, visa)
- Share documents with travel companions

**Security:**
- Encrypted storage (Supabase Storage with encryption)
- Optional PIN/biometric lock for sensitive documents
- Documents never shared without explicit consent

**Acceptance Criteria:**
- Easy upload (camera or file picker)
- Fast retrieval
- Works offline (downloaded documents)
- Passport expiration warnings (6 months before)

---

### 3.14 Local AI Recommendations

Context-aware suggestions during the trip.

**Triggers:**
- User location (with permission)
- Time of day
- Current weather
- User preferences (dietary, accessibility, travel style)
- What's already on the itinerary

**Recommendation Types:**
- "You're near [restaurant] — great for lunch and matches your vegetarian preference"
- "It's raining — here are indoor activities nearby"
- "You have free time this afternoon — here are 3 things to do near your hotel"
- "This museum closes in 2 hours — visit now or reschedule"

**Features:**
- Push notifications (optional, configurable)
- Recommendations surfaced in Live Trip Mode
- "Discover nearby" button for on-demand suggestions
- Learn from user behavior (accepted vs. dismissed suggestions)

**Acceptance Criteria:**
- Recommendations feel helpful, not spammy
- Respect user preferences and past behavior
- Battery-efficient location usage
- Easy to dismiss or disable

---

## 4. Technical Stack Recommendations

### Mobile Framework
**Recommendation: Flutter**
- Single codebase for iOS and Android
- Strong performance and native feel
- Rich widget library for custom UI
- Good for startups moving fast

*Alternative: React Native (if team has React experience)*

### Authentication
- OAuth 2.0 only (no email/password)
- Providers: Google, Apple, Facebook/Instagram
- JWT token-based session management

### UI Libraries

| Package | Purpose |
|---------|---------|
| `google_fonts` | DM Sans typography |
| `lucide_icons` | Consistent icon set |
| `go_router` | Declarative navigation |
| `cached_network_image` | Image caching and loading |

### APIs and Integrations

| Service | API | Purpose |
|---------|-----|---------|
| Places Data | Google Places API | Restaurants, attractions, activities |
| Hotels | TripAdvisor API | Hotel listings and booking links |
| Flights | Amadeus API | Flight data and booking links |
| Maps | Apple MapKit | Map display, routing, proximity calculations |
| AI Vision | Claude Vision / Gemini | Social media content extraction |

### Backend
**Supabase** (selected)
- Open-source Firebase alternative
- PostgreSQL database with real-time subscriptions
- Built-in authentication (supports OAuth providers)
- Storage for user files (travel documents)
- Edge functions for serverless logic
- Good documentation and Flutter SDK

### Key Technical Considerations
- Google Places API charges per request — implement caching
- AI vision APIs charge per image/video — consider usage limits on free tier
- Social import processing should be async with user feedback

---

## 5. Conceptual Data Model

### User
```
- id: string (unique)
- email: string
- name: string
- avatar_url: string
- auth_provider: enum (google, apple, facebook, instagram)
- preferences: UserPreferences
- created_at: timestamp
```

### UserPreferences
```
- travel_styles: string[] (e.g., "adventure", "relaxation", "culture")
- dietary_restrictions: string[] (e.g., "vegetarian", "halal", "gluten-free")
- accessibility_needs: string[] (e.g., "wheelchair", "limited mobility")
```

### Trip
```
- id: string (unique)
- owner_id: string (User)
- collaborator_ids: string[] (Users)
- name: string
- countries: string[]
- trip_size: enum (short, week, long)
- cities: CityBlock[]
- created_at: timestamp
- updated_at: timestamp
```

### CityBlock
```
- id: string
- city_name: string
- country: string
- position: number (order in trip)
- day_count: number
- days: Day[]
- connector_to_next: Connector (optional)
```

### Day
```
- id: string
- position: number (day number)
- status: enum (free, generated, custom)
- anchor_id: string (Activity, optional)
- label: string (e.g., "Temple day")
- activities: DayActivity[]
```

### DayActivity
```
- id: string
- activity_id: string (Activity)
- time_bucket: enum (morning, midday, afternoon, evening)
- position: number (order within bucket)
```

### Activity (from Google Places)
```
- id: string
- google_place_id: string
- name: string
- type: enum (restaurant, attraction, activity, etc.)
- address: string
- coordinates: {lat, lng}
- neighborhood: string
- opening_hours: object
- rating: number
- photos: string[]
- booking_url: string (optional)
```

### SavedItem
```
- id: string
- user_id: string
- activity_id: string (Activity)
- source: enum (explore, tiktok, instagram)
- source_url: string (optional)
- city: string
- saved_at: timestamp
```

### Connector
```
- transport_type: enum (flight, train, bus, car, ferry)
- duration_minutes: number
```

### Budget
```
- id: string
- trip_id: string
- total_budget: number
- currency: string (default)
- city_budgets: CityBudget[] (optional)
```

### CityBudget
```
- city_block_id: string
- amount: number
```

### Expense
```
- id: string
- trip_id: string
- user_id: string (who logged it)
- amount: number
- currency: string
- amount_in_default_currency: number (converted)
- category: enum (food, transport, accommodation, activities, shopping, other)
- description: string
- date: date
- city: string
- receipt_url: string (optional, Supabase Storage)
- split_with: string[] (user IDs, optional)
- created_at: timestamp
```

### TravelDocument
```
- id: string
- user_id: string
- trip_id: string (optional, can be user-level)
- type: enum (passport, visa, insurance, booking, vaccination, license, emergency_contact, other)
- name: string
- file_url: string (Supabase Storage, encrypted)
- expiration_date: date (optional)
- notes: string (optional)
- uploaded_at: timestamp
```

### Notification
```
- id: string
- user_id: string
- trip_id: string
- type: enum (activity_reminder, budget_warning, document_expiry, recommendation, closure_alert)
- title: string
- body: string
- data: object (contextual info)
- read: boolean
- created_at: timestamp
```

---

## 6. UI Design Principles

### Visual Identity
- **Style**: Clean, minimal, modern, sophisticated
- **Reference**: Monochrome base with vibrant accent
- **Design File**: `Trippified_12.pen` (Pencil app)

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
- **Sizes**:
  - Display: 32px (Bold)
  - Title Large: 24px (SemiBold)
  - Title Medium: 18px (SemiBold)
  - Body: 16px (Regular)
  - Body Small: 14px (Regular)
  - Caption: 12px (Regular)

### Icons
- **Library**: Lucide Icons
- **Style**: Outlined, 24px default size
- **Stroke**: 1.5px weight

### Navigation
- Bottom tab bar (standard mobile pattern)
- Tabs: Trips | Explore | Saved | Profile
- Active state: Primary color with label
- Inactive state: Text tertiary

### Key UI Patterns
- **Cards**: White background, subtle border (#E5E7EB), 12px border radius
- **Chips**: Removable tags with X button, pill shape
- **Buttons**:
  - Primary: Black (#1A1A1A) fill, white text
  - Accent: Lime green (#BFFF00) fill, black text
  - Ghost: Transparent with border
- **Inputs**: Light gray fill (#F9FAFB), rounded corners, no visible border until focus
- **FAB**: Lime green (#BFFF00) with black icon
- **Drag handles**: 6 dots pattern for reorderable items
- **Half-sheet modals**: For quick actions
- **Map**: Always visible in planning views (collapsible)

### Screen-Specific Layouts

| Screen | Design ID | Key Elements |
|--------|-----------|--------------|
| Splash | `EBVXQ` | Hero image, gradient overlay, CTA button |
| Login | `Jgwld` | Logo, social buttons, email/password fields |
| Home (Trips) | `7XXBb` / `IF7R0` | Tab bar (Upcoming/Drafts/Past/Wishlist), trip cards, FAB |
| Trip Setup | `KEPq6` | Country search + chips, trip size radio options |
| Routes | `rfkvI` | Route cards with thumbnails, city flow chips |
| Itinerary Blocks | `QNXEv` | Draggable city blocks, transport connectors |
| Trip Dashboard | `sZNhc` | Hero image, stats row, itinerary cards |
| Day Builder | `zoZU9` | Collapsible map, day list with Generate buttons |
| Explore | `6jJDx` | Tab bar (Destinations/Itineraries), featured cards |
| Saved | `hJ74D` | Collection sections |
| Profile | `TzDWQ` | Avatar, menu items |

---

## 7. Security Considerations

- OAuth 2.0 for authentication (no password storage)
- HTTPS for all API communications
- JWT tokens with expiration and refresh
- User data encrypted at rest
- API keys stored securely (not in client code)
- Rate limiting on API endpoints
- Input validation on all user inputs
- GDPR compliance for user data (deletion, export)

---

## 8. Development Phases

### Phase 1: Foundation
- Project setup (Flutter + state management)
- Supabase setup (database, auth, storage)
- Authentication flow (Google, Apple, Facebook)
- User profile and preferences
- Navigation structure (bottom tabs)

### Phase 2: Trippified Flow (Core Planning)
- Trip Setup screen
- Recommended Routes screen
- Itinerary Blocks screen
- Day Builder (Overview + Itinerary tabs)
- Google Places integration
- Apple Maps integration

### Phase 3: Explore Flow
- Destination browsing
- Pre-made itineraries
- Save to collection

### Phase 4: Saved Flow + Social Import
- Saved hub UI
- TikTok/Instagram link sharing
- AI vision integration for extraction
- Auto-generate itinerary from collection

### Phase 5: Smart Features
- Proximity-based ordering
- Closure/distance warnings
- Preference-aware suggestions
- Local AI recommendations

### Phase 6: Budget Tracking
- Budget setup (trip/city/day)
- Expense logging
- Category management
- Currency conversion
- Expense splitting
- Budget reports and export

### Phase 7: Travel Documents
- Document upload (camera + file picker)
- Secure encrypted storage
- Document organization
- Expiration tracking
- Offline access

### Phase 8: Live Trip Mode
- Today view
- Check-ins
- Quick rescheduling
- Smart notifications
- Weather integration
- Navigation integration

### Phase 9: Offline Mode
- Trip download system
- Offline storage management
- Sync conflict resolution
- Offline indicator UI

### Phase 10: Collaboration
- Trip sharing
- Multi-user editing
- Real-time sync (Supabase Realtime)

### Phase 11: Bookings Integration
- Restaurant booking links
- Hotel affiliate links (TripAdvisor)
- Flight affiliate links (Amadeus)
- Affiliate tracking

### Phase 12: Polish and Launch
- Performance optimization
- Error handling and edge cases
- Analytics integration
- Premium/freemium gating
- App Store / Play Store submission

---

## 9. Potential Challenges and Solutions

| Challenge | Solution |
|-----------|----------|
| **Google Places API costs** | Implement aggressive caching; batch requests; set usage alerts |
| **AI vision accuracy** | Test multiple providers (Claude, Gemini); implement fallback to manual entry; allow user corrections |
| **Social import speed** | Async processing with optimistic UI; show progress indicator; queue system |
| **Multi-country trip complexity** | Clear visual grouping; allow interleaving; smart route suggestions |
| **Real-time collaboration sync** | Use Supabase Realtime; handle conflicts gracefully |
| **Cross-platform consistency** | Flutter's single codebase helps; thorough testing on both platforms |
| **Offline data size** | Compress data; selective download; clear storage estimates |
| **Currency conversion accuracy** | Use reliable exchange rate API (e.g., Open Exchange Rates); cache rates daily |
| **Location permissions (for AI recommendations)** | Clear permission prompts; graceful degradation if denied; battery-efficient tracking |
| **Document security** | Supabase Storage encryption; optional biometric lock; secure deletion |
| **Notification fatigue** | Smart notification batching; user-configurable frequency; respect quiet hours |
| **Live trip battery drain** | Efficient location polling; background task optimization; user controls |

---

## 10. Monetization Strategy

### Freemium Model

**Free Tier:**
- Create up to 2 active trips
- Basic itinerary generation (Day Builder)
- Explore and save up to 50 items
- 5 social imports per month
- Budget tracking (basic)
- Travel documents (up to 5 documents)

**Premium Tier — "Trippified Pro" ($7.99/month or $59.99/year):**
- Unlimited active trips
- Unlimited saved items
- Unlimited social imports
- Advanced AI recommendations (personalized, contextual)
- Full offline mode (download entire trips)
- Unlimited document storage
- Advanced budget features (expense splitting, reports, export)
- Priority itinerary generation (faster AI processing)
- Early access to new features
- Ad-free experience

**Premium Upsell Moments:**
- When user hits free tier limits
- Before a trip starts ("Download for offline access")
- When adding 3rd trip
- When social import limit reached

### Affiliate Revenue
- All booking links (hotels, flights, restaurants) include affiliate codes
- Commission on completed bookings
- Track conversion by user segment (free vs. premium)
- A/B test affiliate partner placement

### Revenue Projections (for planning)
- Target: 5-10% free-to-premium conversion
- Affiliate revenue as supplementary income stream
- Consider annual plan discount to improve retention

---

## 11. Future Expansion Possibilities

- **Web app**: Full planning experience on desktop
- **Social features**: Share trips publicly, follow travelers, trip templates marketplace
- **Group voting**: Collaborative decision-making for group trips
- **Packing lists**: Smart packing suggestions based on destination and weather
- **Language assistance**: Common phrases, real-time translation
- **Restaurant reservations**: In-app booking (not just links)
- **Trip templates**: Save and reuse itinerary structures
- **Travel rewards integration**: Connect loyalty programs, track points

---

## 12. Success Metrics

### User Engagement
- Daily/Monthly Active Users (DAU/MAU)
- Trips created per user
- Day Builder completion rate
- Social imports per user

### Retention
- 7-day, 30-day retention rates
- Return visits after trip completion

### Revenue
- Affiliate link click-through rate
- Booking conversion rate
- Premium subscription conversion (if implemented)

### Quality
- App Store rating
- User feedback/NPS
- Crash-free session rate

---

## 13. Development Tooling (Claude Code Configuration)

Trippified will be built entirely using Claude Code. The following rules and agents will guide development.

### Rules (~/.claude/rules/)

| File | Purpose |
|------|---------|
| `security.md` | Mandatory security checks (input validation, auth, encryption, OWASP top 10) |
| `coding-style.md` | Immutability patterns, file size limits (<300 lines), naming conventions |
| `testing.md` | TDD approach, 80% coverage requirement, test naming conventions |
| `git-workflow.md` | Conventional commits, branch naming, PR requirements |
| `agents.md` | Subagent delegation rules, when to spawn agents |
| `patterns.md` | API response formats, error handling patterns, data structures |
| `performance.md` | Model selection guidelines (Haiku for quick tasks, Sonnet for standard, Opus for complex) |
| `hooks.md` | Hook documentation for pre-commit, linting, testing automation |

### Agents (~/.claude/agents/)

| File | Purpose |
|------|---------|
| `planner.md` | Break down features into actionable tasks |
| `architect.md` | System design, database schema, API design |
| `tdd-guide.md` | Write tests first, guide test implementation |
| `code-reviewer.md` | Quality review, code style, best practices |
| `security-reviewer.md` | Vulnerability scanning, security audit |
| `build-error-resolver.md` | Debug and fix build/compile errors |
| `e2e-runner.md` | End-to-end testing with integration tests |
| `refactor-cleaner.md` | Dead code removal, refactoring suggestions |
| `doc-updater.md` | Keep documentation synced with code changes |

### Development Workflow

1. **Planning**: Use `planner.md` agent to break down features
2. **Design**: Use `architect.md` agent for system design
3. **TDD**: Use `tdd-guide.md` to write tests before implementation
4. **Implementation**: Follow rules in `coding-style.md` and `patterns.md`
5. **Security**: Run `security-reviewer.md` agent on new code
6. **Review**: Use `code-reviewer.md` for quality checks
7. **Testing**: Run `e2e-runner.md` for integration tests
8. **Cleanup**: Use `refactor-cleaner.md` to remove dead code
9. **Documentation**: Use `doc-updater.md` to keep docs current
10. **Commit**: Follow `git-workflow.md` conventions

### Quality Target: 9/10 or 10/10 on All Metrics

All code must be built to pass the comprehensive review framework below with flying colors.

---

## 14. Post-Build Review Framework

This framework will be used to audit the completed codebase. **Target: 9/10 or higher on all scores.**

### Phase 0: Discovery (Context Gathering)
- Read pubspec.yaml (dependencies, scripts, project metadata)
- Check README, CONTRIBUTING, docs/ folder
- Scan directory structure 2-3 levels deep
- Identify entry points (main.dart, app files)
- Read config files (analysis_options.yaml, etc.)
- Look for existing tests (location, framework, patterns)
- Check for CI/CD configs

### Phase 1: Health Score Baseline

| Area | Target | Criteria |
|------|--------|----------|
| **Architecture** | 9/10 | Clean separation of concerns, proper dependency direction, no god files (>500 lines) or god functions (>50 lines) |
| **Code Quality** | 9/10 | Consistent naming, <5% code duplication, low cyclomatic complexity |
| **Reliability** | 9/10 | Comprehensive error handling, 80%+ test coverage, edge cases handled |
| **Security** | 10/10 | All inputs validated, no hardcoded secrets, proper auth/authz |
| **Performance** | 9/10 | No N+1 queries, efficient algorithms, proper caching |
| **Maintainability** | 9/10 | Self-documenting code, strong types, zero dead code |

### Phase 2: Architecture Analysis Requirements

**Pattern**: Clean Architecture with clear layers
```
lib/
├── core/           # Shared utilities, constants, themes
├── data/           # Data sources, repositories, models
├── domain/         # Business logic, entities, use cases
├── presentation/   # UI (screens, widgets, state management)
└── main.dart       # Entry point
```

**Data Flow**: User Input → Presentation → Domain → Data → External APIs → Response

**Key Requirements**:
- All business logic in domain layer (not in UI)
- Repository pattern for data access
- Dependency injection for testability
- No circular dependencies

### Phase 3: Dependency Audit Requirements

- All packages up to date (no major versions behind)
- No abandoned packages (>2 years without updates)
- No bloat (single-use packages for simple functions)
- Zero known vulnerabilities
- License compatibility verified

### Phase 4: Security Audit Checklist

All must pass (zero tolerance):
- [ ] No SQL/injection vulnerabilities (parameterized queries only)
- [ ] No hardcoded secrets/API keys (use env vars)
- [ ] Rate limiting on auth endpoints
- [ ] Proper session management (expiration, invalidation)
- [ ] No IDOR vulnerabilities
- [ ] Auth checks on all sensitive routes
- [ ] No sensitive data in logs
- [ ] No stack traces exposed to users
- [ ] Proper CORS configuration
- [ ] Security headers configured

### Phase 5: Performance Audit Checklist

**Database**:
- [ ] No N+1 queries
- [ ] Proper indexes on all queried fields
- [ ] All queries have LIMIT/pagination
- [ ] Connection pooling configured

**Backend/App**:
- [ ] No synchronous blocking operations
- [ ] Caching implemented where beneficial
- [ ] Efficient algorithms (no unnecessary O(n²))
- [ ] No memory leaks
- [ ] Lazy loading where appropriate

**API**:
- [ ] No over-fetching (request only needed fields)
- [ ] Pagination on all list endpoints
- [ ] Response compression enabled

### Phase 6: Code Quality Requirements

**Zero Tolerance**:
- No code duplication (DRY)
- No dead code (unused functions, commented code, orphan files)
- No god files (>500 lines) or god functions (>50 lines)
- No deep nesting (>3 levels)
- No magic numbers/strings (use constants)
- No type safety gaps (no `dynamic` without justification)

**Required**:
- Consistent naming conventions (camelCase for variables, PascalCase for classes)
- All public APIs documented
- Error handling on all async operations

### Phase 7: Scalability Requirements

**Database**:
- Queries must scale (no full table scans)
- Pagination support on all list queries
- Indexes on all foreign keys and frequently queried fields

**Application**:
- Stateless where possible (for horizontal scaling)
- No file system dependencies for user data

**External Services**:
- Rate limiting on outbound API calls
- Retry logic with exponential backoff
- Circuit breakers for external dependencies
- Graceful degradation when services unavailable

### Phase 8: Testing Requirements

**Coverage Target**: 80% minimum

**Critical Paths (100% coverage required)**:
- Authentication flows
- Payment/booking flows
- Data mutations (create, update, delete)
- Permission checks

**Test Types Required**:
- Unit tests for all business logic
- Widget tests for all screens
- Integration tests for critical user flows
- API tests for all endpoints

---

## Appendix: Design Reference

### Pencil Design File
All UI designs are maintained in **`Trippified_12.pen`** (Pencil app).

### Screen Index

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

### Design System Components

| Component | Description |
|-----------|-------------|
| Bottom Navigation | 4-tab bar: Trips, Explore, Saved, Profile |
| Country Chip | Removable pill with flag + X button |
| Trip Size Option | Radio-style selection card |
| Route Card | Image + title + stats + city flow chips |
| City Block | Draggable card with edit controls |
| Transport Connector | Shows transport type + duration between cities |
| Day Card | Day number + date + status + Generate button |

### Flow 3 — Trippified Flow (Trip Planner)
1. **Trip Setup** (`KEPq6`): Select countries and trip duration
2. **Routes** (`rfkvI`): Choose recommended routes per country
3. **Itinerary Blocks** (`QNXEv`): Arrange cities and days
4. **Trip Dashboard** (`sZNhc`): View trip overview
5. **Day Builder** (`zoZU9`): Plan individual days

### Day Builder Canonical Spec
- **Overview tab**: Day list with Generate buttons
- **Itinerary tab**: Time-bucketed activities (Morning/Midday/Afternoon/Evening)
- **Anchor rules**: Each generated day has one anchor defining the day label
- **Day states**: Free day → Generated day → Custom day

### Explore and Saved Flows
- **Explore** (`6jJDx`, `WFIE5`): Browse destinations and pre-made itineraries
- **Saved** (`hJ74D`): View and organize saved inspiration
- Reference Roamy app (roamy.travel) for social import patterns

---

*Document generated with assistance from Claude. Last updated: January 2026*
