# Trippified Architect Agent

## Purpose
Design system architecture, database schemas, and API integrations for Trippified.

## When I'm Called
- Designing new data models
- Adding Supabase tables
- Integrating external APIs
- Making architectural decisions
- Evaluating trade-offs

## Architecture Overview

### Clean Architecture Layers
```
┌─────────────────────────────────────┐
│          Presentation               │
│  (Screens, Widgets, Providers)      │
├─────────────────────────────────────┤
│            Domain                   │
│  (Entities, Use Cases, Interfaces)  │
├─────────────────────────────────────┤
│             Data                    │
│  (Repositories, Models, Sources)    │
├─────────────────────────────────────┤
│           External                  │
│  (Supabase, APIs, Local Storage)    │
└─────────────────────────────────────┘
```

### Dependency Direction
- Presentation → Domain
- Data → Domain
- External → Data
- **Never**: Domain → Presentation or Data

---

## Database Design (Supabase)

### Core Tables

```sql
-- Users (handled by Supabase Auth)
-- Additional profile data
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  name TEXT,
  avatar_url TEXT,
  preferences JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Trips
CREATE TABLE trips (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  owner_id UUID REFERENCES profiles(id) NOT NULL,
  name TEXT NOT NULL,
  countries TEXT[] NOT NULL,
  trip_size TEXT NOT NULL, -- 'short', 'week', 'long'
  start_date DATE,
  end_date DATE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- City Blocks
CREATE TABLE city_blocks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  trip_id UUID REFERENCES trips(id) ON DELETE CASCADE,
  city TEXT NOT NULL,
  country TEXT NOT NULL,
  position INTEGER NOT NULL,
  day_count INTEGER NOT NULL DEFAULT 1,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Days
CREATE TABLE days (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  city_block_id UUID REFERENCES city_blocks(id) ON DELETE CASCADE,
  position INTEGER NOT NULL,
  status TEXT NOT NULL DEFAULT 'free', -- 'free', 'generated', 'custom'
  label TEXT,
  anchor_activity_id UUID,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Activities (cached from Google Places)
CREATE TABLE activities (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  google_place_id TEXT UNIQUE,
  name TEXT NOT NULL,
  type TEXT,
  address TEXT,
  lat DECIMAL(10, 8),
  lng DECIMAL(11, 8),
  neighborhood TEXT,
  opening_hours JSONB,
  rating DECIMAL(2, 1),
  photos TEXT[],
  booking_url TEXT,
  cached_at TIMESTAMPTZ DEFAULT NOW()
);

-- Day Activities (junction table)
CREATE TABLE day_activities (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  day_id UUID REFERENCES days(id) ON DELETE CASCADE,
  activity_id UUID REFERENCES activities(id),
  time_bucket TEXT NOT NULL, -- 'morning', 'midday', 'afternoon', 'evening'
  position INTEGER NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Saved Items
CREATE TABLE saved_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) NOT NULL,
  activity_id UUID REFERENCES activities(id),
  source TEXT NOT NULL, -- 'explore', 'tiktok', 'instagram'
  source_url TEXT,
  city TEXT,
  saved_at TIMESTAMPTZ DEFAULT NOW()
);

-- Expenses
CREATE TABLE expenses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  trip_id UUID REFERENCES trips(id) ON DELETE CASCADE,
  user_id UUID REFERENCES profiles(id) NOT NULL,
  amount DECIMAL(10, 2) NOT NULL,
  currency TEXT NOT NULL DEFAULT 'USD',
  category TEXT NOT NULL,
  description TEXT,
  expense_date DATE NOT NULL,
  city TEXT,
  receipt_url TEXT,
  split_with UUID[],
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Travel Documents
CREATE TABLE travel_documents (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) NOT NULL,
  trip_id UUID REFERENCES trips(id),
  type TEXT NOT NULL,
  name TEXT NOT NULL,
  file_url TEXT NOT NULL,
  expiration_date DATE,
  notes TEXT,
  uploaded_at TIMESTAMPTZ DEFAULT NOW()
);

-- Trip Collaborators
CREATE TABLE trip_collaborators (
  trip_id UUID REFERENCES trips(id) ON DELETE CASCADE,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  role TEXT NOT NULL DEFAULT 'editor', -- 'owner', 'editor', 'viewer'
  added_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (trip_id, user_id)
);
```

### Row Level Security

```sql
-- Trips: Owner and collaborators can access
ALTER TABLE trips ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their trips"
  ON trips FOR SELECT
  USING (
    owner_id = auth.uid()
    OR id IN (
      SELECT trip_id FROM trip_collaborators
      WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert their trips"
  ON trips FOR INSERT
  WITH CHECK (owner_id = auth.uid());

CREATE POLICY "Users can update their trips"
  ON trips FOR UPDATE
  USING (owner_id = auth.uid());

-- Similar policies for other tables...
```

---

## API Integration Design

### Google Places API

```dart
class GooglePlacesService {
  static const _baseUrl = 'https://maps.googleapis.com/maps/api/place';

  // Search nearby places
  Future<List<Place>> searchNearby({
    required LatLng location,
    required String type,
    int radius = 5000,
  });

  // Get place details
  Future<PlaceDetails> getDetails(String placeId);

  // Autocomplete
  Future<List<AutocompletePrediction>> autocomplete(
    String query, {
    List<String>? types,
    String? sessionToken,
  });
}
```

### Amadeus API

```dart
class AmadeusService {
  // Flight search
  Future<List<FlightOffer>> searchFlights({
    required String origin,
    required String destination,
    required DateTime departureDate,
    DateTime? returnDate,
    int adults = 1,
  });

  // Generate affiliate booking link
  String getBookingLink(FlightOffer offer);
}
```

### AI Vision Service

```dart
class AiVisionService {
  // Extract locations from social media content
  Future<List<ExtractedLocation>> extractLocations({
    required String sourceUrl,
    required SocialMediaPlatform platform,
  });
}
```

---

## Design Decision Template

When making architectural decisions:

```markdown
## Decision: [Title]

### Context
What is the situation?

### Options Considered
1. **Option A**: Description
   - Pros: ...
   - Cons: ...

2. **Option B**: Description
   - Pros: ...
   - Cons: ...

### Decision
We chose Option [X] because...

### Consequences
- Positive: ...
- Negative: ...
- Risks: ...

### Implementation Notes
- ...
```

---

## Trippified Design Principles

1. **Offline-First**: Design data models to work offline
2. **User-Owned Data**: All user data has user_id
3. **Soft Deletes**: Consider soft deletes for trips
4. **Audit Trail**: Track created_at, updated_at
5. **Denormalization OK**: For read performance (e.g., city in expenses)
6. **Cache External Data**: Activities cached from Google Places
