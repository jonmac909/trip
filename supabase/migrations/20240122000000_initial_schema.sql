-- Trippified Initial Database Schema
-- This migration creates all tables needed for the app

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- PROFILES (extends Supabase auth.users)
-- ============================================
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT,
  avatar_url TEXT,
  preferences JSONB DEFAULT '{}'::jsonb,
  -- Preferences structure:
  -- {
  --   "travel_styles": ["adventure", "relaxation"],
  --   "dietary_restrictions": ["vegetarian"],
  --   "accessibility_needs": []
  -- }
  is_premium BOOLEAN DEFAULT FALSE,
  premium_expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- TRIPS
-- ============================================
CREATE TABLE IF NOT EXISTS public.trips (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  owner_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  countries TEXT[] NOT NULL DEFAULT '{}',
  trip_size TEXT NOT NULL CHECK (trip_size IN ('short', 'week', 'long')),
  start_date DATE,
  end_date DATE,
  status TEXT DEFAULT 'draft' CHECK (status IN ('draft', 'planned', 'active', 'completed', 'archived')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for faster queries
CREATE INDEX IF NOT EXISTS idx_trips_owner_id ON public.trips(owner_id);
CREATE INDEX IF NOT EXISTS idx_trips_status ON public.trips(status);

-- ============================================
-- TRIP COLLABORATORS
-- ============================================
CREATE TABLE IF NOT EXISTS public.trip_collaborators (
  trip_id UUID REFERENCES public.trips(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  role TEXT NOT NULL DEFAULT 'editor' CHECK (role IN ('owner', 'editor', 'viewer')),
  added_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (trip_id, user_id)
);

-- ============================================
-- CITY BLOCKS
-- ============================================
CREATE TABLE IF NOT EXISTS public.city_blocks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  trip_id UUID REFERENCES public.trips(id) ON DELETE CASCADE NOT NULL,
  city TEXT NOT NULL,
  country TEXT NOT NULL,
  position INTEGER NOT NULL,
  day_count INTEGER NOT NULL DEFAULT 1,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_city_blocks_trip_id ON public.city_blocks(trip_id);

-- ============================================
-- DAYS
-- ============================================
CREATE TABLE IF NOT EXISTS public.days (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  city_block_id UUID REFERENCES public.city_blocks(id) ON DELETE CASCADE NOT NULL,
  position INTEGER NOT NULL,
  status TEXT NOT NULL DEFAULT 'free' CHECK (status IN ('free', 'generated', 'custom')),
  label TEXT,
  anchor_activity_id UUID, -- References activities table
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_days_city_block_id ON public.days(city_block_id);

-- ============================================
-- ACTIVITIES (cached from Google Places)
-- ============================================
CREATE TABLE IF NOT EXISTS public.activities (
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

CREATE INDEX IF NOT EXISTS idx_activities_google_place_id ON public.activities(google_place_id);
CREATE INDEX IF NOT EXISTS idx_activities_neighborhood ON public.activities(neighborhood);

-- Add foreign key for anchor_activity_id now that activities table exists
ALTER TABLE public.days
  ADD CONSTRAINT fk_days_anchor_activity
  FOREIGN KEY (anchor_activity_id)
  REFERENCES public.activities(id)
  ON DELETE SET NULL;

-- ============================================
-- DAY ACTIVITIES (junction table)
-- ============================================
CREATE TABLE IF NOT EXISTS public.day_activities (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  day_id UUID REFERENCES public.days(id) ON DELETE CASCADE NOT NULL,
  activity_id UUID REFERENCES public.activities(id) NOT NULL,
  time_bucket TEXT NOT NULL CHECK (time_bucket IN ('morning', 'midday', 'afternoon', 'evening')),
  position INTEGER NOT NULL,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_day_activities_day_id ON public.day_activities(day_id);

-- ============================================
-- SAVED ITEMS
-- ============================================
CREATE TABLE IF NOT EXISTS public.saved_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  activity_id UUID REFERENCES public.activities(id),
  source TEXT NOT NULL CHECK (source IN ('explore', 'tiktok', 'instagram', 'manual')),
  source_url TEXT,
  city TEXT,
  saved_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_saved_items_user_id ON public.saved_items(user_id);
CREATE INDEX IF NOT EXISTS idx_saved_items_city ON public.saved_items(city);

-- ============================================
-- BUDGETS
-- ============================================
CREATE TABLE IF NOT EXISTS public.budgets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  trip_id UUID REFERENCES public.trips(id) ON DELETE CASCADE NOT NULL UNIQUE,
  total_budget DECIMAL(12, 2),
  currency TEXT NOT NULL DEFAULT 'USD',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- CITY BUDGETS
-- ============================================
CREATE TABLE IF NOT EXISTS public.city_budgets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  budget_id UUID REFERENCES public.budgets(id) ON DELETE CASCADE NOT NULL,
  city_block_id UUID REFERENCES public.city_blocks(id) ON DELETE CASCADE NOT NULL,
  amount DECIMAL(12, 2) NOT NULL,
  UNIQUE(budget_id, city_block_id)
);

-- ============================================
-- EXPENSES
-- ============================================
CREATE TABLE IF NOT EXISTS public.expenses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  trip_id UUID REFERENCES public.trips(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES public.profiles(id) NOT NULL,
  amount DECIMAL(12, 2) NOT NULL,
  currency TEXT NOT NULL DEFAULT 'USD',
  amount_in_default_currency DECIMAL(12, 2),
  category TEXT NOT NULL CHECK (category IN ('food', 'transport', 'accommodation', 'activities', 'shopping', 'other')),
  description TEXT,
  expense_date DATE NOT NULL,
  city TEXT,
  receipt_url TEXT,
  split_with UUID[], -- Array of user IDs
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_expenses_trip_id ON public.expenses(trip_id);
CREATE INDEX IF NOT EXISTS idx_expenses_user_id ON public.expenses(user_id);
CREATE INDEX IF NOT EXISTS idx_expenses_category ON public.expenses(category);

-- ============================================
-- TRAVEL DOCUMENTS
-- ============================================
CREATE TABLE IF NOT EXISTS public.travel_documents (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  trip_id UUID REFERENCES public.trips(id) ON DELETE SET NULL,
  type TEXT NOT NULL CHECK (type IN ('passport', 'visa', 'insurance', 'booking', 'vaccination', 'license', 'emergency_contact', 'other')),
  name TEXT NOT NULL,
  file_url TEXT NOT NULL,
  expiration_date DATE,
  notes TEXT,
  uploaded_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_travel_documents_user_id ON public.travel_documents(user_id);
CREATE INDEX IF NOT EXISTS idx_travel_documents_trip_id ON public.travel_documents(trip_id);

-- ============================================
-- NOTIFICATIONS
-- ============================================
CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  trip_id UUID REFERENCES public.trips(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('activity_reminder', 'budget_warning', 'document_expiry', 'recommendation', 'closure_alert', 'trip_shared')),
  title TEXT NOT NULL,
  body TEXT,
  data JSONB,
  read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_read ON public.notifications(read);

-- ============================================
-- PRE-MADE ITINERARIES (for Explore)
-- ============================================
CREATE TABLE IF NOT EXISTS public.itinerary_templates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT,
  city TEXT NOT NULL,
  country TEXT NOT NULL,
  duration_days INTEGER NOT NULL,
  cover_image_url TEXT,
  tags TEXT[],
  popularity_score INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_itinerary_templates_city ON public.itinerary_templates(city);
CREATE INDEX IF NOT EXISTS idx_itinerary_templates_country ON public.itinerary_templates(country);

-- ============================================
-- RECOMMENDED ROUTES
-- ============================================
CREATE TABLE IF NOT EXISTS public.recommended_routes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  country TEXT NOT NULL,
  cities TEXT[] NOT NULL,
  trip_size TEXT NOT NULL CHECK (trip_size IN ('short', 'week', 'long')),
  popularity_score INTEGER DEFAULT 0
);

CREATE INDEX IF NOT EXISTS idx_recommended_routes_country ON public.recommended_routes(country);

-- ============================================
-- ROW LEVEL SECURITY POLICIES
-- ============================================

-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trips ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trip_collaborators ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.city_blocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.days ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.day_activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.saved_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.budgets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.city_budgets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.travel_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.itinerary_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recommended_routes ENABLE ROW LEVEL SECURITY;

-- Profiles: Users can read/update their own profile
CREATE POLICY "Users can view their own profile"
  ON public.profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile"
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Trips: Owner and collaborators can access
CREATE POLICY "Users can view their trips"
  ON public.trips FOR SELECT
  USING (
    owner_id = auth.uid()
    OR id IN (
      SELECT trip_id FROM public.trip_collaborators
      WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert their own trips"
  ON public.trips FOR INSERT
  WITH CHECK (owner_id = auth.uid());

CREATE POLICY "Users can update their trips"
  ON public.trips FOR UPDATE
  USING (
    owner_id = auth.uid()
    OR id IN (
      SELECT trip_id FROM public.trip_collaborators
      WHERE user_id = auth.uid() AND role IN ('owner', 'editor')
    )
  );

CREATE POLICY "Users can delete their own trips"
  ON public.trips FOR DELETE
  USING (owner_id = auth.uid());

-- Trip Collaborators: Trip owner can manage, collaborators can view
CREATE POLICY "View trip collaborators"
  ON public.trip_collaborators FOR SELECT
  USING (
    trip_id IN (
      SELECT id FROM public.trips WHERE owner_id = auth.uid()
    )
    OR user_id = auth.uid()
  );

CREATE POLICY "Trip owner can manage collaborators"
  ON public.trip_collaborators FOR ALL
  USING (
    trip_id IN (
      SELECT id FROM public.trips WHERE owner_id = auth.uid()
    )
  );

-- City Blocks: Same access as trips
CREATE POLICY "Access city blocks through trips"
  ON public.city_blocks FOR ALL
  USING (
    trip_id IN (
      SELECT id FROM public.trips WHERE owner_id = auth.uid()
      UNION
      SELECT trip_id FROM public.trip_collaborators WHERE user_id = auth.uid()
    )
  );

-- Days: Same access as city blocks
CREATE POLICY "Access days through city blocks"
  ON public.days FOR ALL
  USING (
    city_block_id IN (
      SELECT cb.id FROM public.city_blocks cb
      JOIN public.trips t ON cb.trip_id = t.id
      WHERE t.owner_id = auth.uid()
      UNION
      SELECT cb.id FROM public.city_blocks cb
      JOIN public.trip_collaborators tc ON cb.trip_id = tc.trip_id
      WHERE tc.user_id = auth.uid()
    )
  );

-- Activities: Everyone can read (cached data)
CREATE POLICY "Anyone can view activities"
  ON public.activities FOR SELECT
  USING (true);

CREATE POLICY "System can insert activities"
  ON public.activities FOR INSERT
  WITH CHECK (true);

-- Day Activities: Same access as days
CREATE POLICY "Access day activities through days"
  ON public.day_activities FOR ALL
  USING (
    day_id IN (
      SELECT d.id FROM public.days d
      JOIN public.city_blocks cb ON d.city_block_id = cb.id
      JOIN public.trips t ON cb.trip_id = t.id
      WHERE t.owner_id = auth.uid()
      UNION
      SELECT d.id FROM public.days d
      JOIN public.city_blocks cb ON d.city_block_id = cb.id
      JOIN public.trip_collaborators tc ON cb.trip_id = tc.trip_id
      WHERE tc.user_id = auth.uid()
    )
  );

-- Saved Items: User's own items
CREATE POLICY "Users can manage their saved items"
  ON public.saved_items FOR ALL
  USING (user_id = auth.uid());

-- Budgets: Same access as trips
CREATE POLICY "Access budgets through trips"
  ON public.budgets FOR ALL
  USING (
    trip_id IN (
      SELECT id FROM public.trips WHERE owner_id = auth.uid()
      UNION
      SELECT trip_id FROM public.trip_collaborators WHERE user_id = auth.uid()
    )
  );

-- City Budgets: Same access as budgets
CREATE POLICY "Access city budgets through budgets"
  ON public.city_budgets FOR ALL
  USING (
    budget_id IN (
      SELECT b.id FROM public.budgets b
      JOIN public.trips t ON b.trip_id = t.id
      WHERE t.owner_id = auth.uid()
      UNION
      SELECT b.id FROM public.budgets b
      JOIN public.trip_collaborators tc ON b.trip_id = tc.trip_id
      WHERE tc.user_id = auth.uid()
    )
  );

-- Expenses: Same access as trips
CREATE POLICY "Access expenses through trips"
  ON public.expenses FOR ALL
  USING (
    trip_id IN (
      SELECT id FROM public.trips WHERE owner_id = auth.uid()
      UNION
      SELECT trip_id FROM public.trip_collaborators WHERE user_id = auth.uid()
    )
  );

-- Travel Documents: User's own documents
CREATE POLICY "Users can manage their documents"
  ON public.travel_documents FOR ALL
  USING (user_id = auth.uid());

-- Notifications: User's own notifications
CREATE POLICY "Users can manage their notifications"
  ON public.notifications FOR ALL
  USING (user_id = auth.uid());

-- Itinerary Templates: Everyone can read
CREATE POLICY "Anyone can view itinerary templates"
  ON public.itinerary_templates FOR SELECT
  USING (true);

-- Recommended Routes: Everyone can read
CREATE POLICY "Anyone can view recommended routes"
  ON public.recommended_routes FOR SELECT
  USING (true);

-- ============================================
-- FUNCTIONS & TRIGGERS
-- ============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at trigger to relevant tables
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_trips_updated_at
  BEFORE UPDATE ON public.trips
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_budgets_updated_at
  BEFORE UPDATE ON public.budgets
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Function to create profile on user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, name, avatar_url)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name'),
    NEW.raw_user_meta_data->>'avatar_url'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create profile on signup
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- SEED DATA: Popular Routes
-- ============================================
INSERT INTO public.recommended_routes (country, cities, trip_size) VALUES
-- Japan
('Japan', ARRAY['Tokyo', 'Kyoto'], 'short'),
('Japan', ARRAY['Tokyo', 'Kyoto', 'Osaka'], 'week'),
('Japan', ARRAY['Tokyo', 'Hakone', 'Kyoto', 'Osaka', 'Hiroshima'], 'long'),
('Japan', ARRAY['Tokyo'], 'short'),

-- Thailand
('Thailand', ARRAY['Bangkok', 'Chiang Mai'], 'short'),
('Thailand', ARRAY['Bangkok', 'Chiang Mai', 'Phuket'], 'week'),
('Thailand', ARRAY['Bangkok', 'Chiang Mai', 'Krabi', 'Phuket'], 'long'),

-- Italy
('Italy', ARRAY['Rome', 'Florence'], 'short'),
('Italy', ARRAY['Rome', 'Florence', 'Venice'], 'week'),
('Italy', ARRAY['Rome', 'Florence', 'Venice', 'Milan', 'Amalfi Coast'], 'long'),

-- France
('France', ARRAY['Paris'], 'short'),
('France', ARRAY['Paris', 'Nice'], 'week'),
('France', ARRAY['Paris', 'Lyon', 'Nice', 'Marseille'], 'long'),

-- Spain
('Spain', ARRAY['Barcelona', 'Madrid'], 'short'),
('Spain', ARRAY['Barcelona', 'Madrid', 'Seville'], 'week'),
('Spain', ARRAY['Barcelona', 'Madrid', 'Seville', 'Granada', 'Valencia'], 'long'),

-- UK
('United Kingdom', ARRAY['London'], 'short'),
('United Kingdom', ARRAY['London', 'Edinburgh'], 'week'),
('United Kingdom', ARRAY['London', 'Oxford', 'Edinburgh', 'Manchester'], 'long'),

-- USA
('United States', ARRAY['New York'], 'short'),
('United States', ARRAY['New York', 'Los Angeles'], 'week'),
('United States', ARRAY['New York', 'Chicago', 'Los Angeles', 'San Francisco'], 'long'),

-- Australia
('Australia', ARRAY['Sydney', 'Melbourne'], 'short'),
('Australia', ARRAY['Sydney', 'Melbourne', 'Brisbane'], 'week'),
('Australia', ARRAY['Sydney', 'Melbourne', 'Brisbane', 'Cairns'], 'long');

-- Grant permissions for service role
GRANT ALL ON ALL TABLES IN SCHEMA public TO service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO service_role;
