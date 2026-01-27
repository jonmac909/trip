-- Update saved_items table to support generic saved items (places, itineraries, social imports)
-- Previously only linked to activities; now supports standalone items from AI scanning

-- Drop the old foreign key constraint
ALTER TABLE public.saved_items DROP CONSTRAINT IF EXISTS saved_items_activity_id_fkey;

-- Drop old columns
ALTER TABLE public.saved_items DROP COLUMN IF EXISTS activity_id;
ALTER TABLE public.saved_items DROP COLUMN IF EXISTS source;
ALTER TABLE public.saved_items DROP COLUMN IF EXISTS city;
ALTER TABLE public.saved_items DROP COLUMN IF EXISTS saved_at;

-- Add new columns
ALTER TABLE public.saved_items ADD COLUMN IF NOT EXISTS item_type TEXT NOT NULL DEFAULT 'place'
  CHECK (item_type IN ('place', 'itinerary', 'activity', 'socialImport'));
ALTER TABLE public.saved_items ADD COLUMN IF NOT EXISTS item_id TEXT NOT NULL DEFAULT '';
ALTER TABLE public.saved_items ADD COLUMN IF NOT EXISTS title TEXT NOT NULL DEFAULT '';
ALTER TABLE public.saved_items ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE public.saved_items ADD COLUMN IF NOT EXISTS image_url TEXT;
ALTER TABLE public.saved_items ADD COLUMN IF NOT EXISTS metadata JSONB;
ALTER TABLE public.saved_items ADD COLUMN IF NOT EXISTS source_url TEXT;
ALTER TABLE public.saved_items ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW();

-- Add index for item_type queries
CREATE INDEX IF NOT EXISTS idx_saved_items_item_type ON public.saved_items(item_type);
CREATE INDEX IF NOT EXISTS idx_saved_items_item_id ON public.saved_items(item_id);
