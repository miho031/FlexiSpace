-- Tablica spaces (prostorije)
CREATE TABLE IF NOT EXISTS public.spaces (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  address TEXT,
  price_per_minute DECIMAL(10, 4) NOT NULL DEFAULT 0,
  capacity INTEGER NOT NULL DEFAULT 1,
  has_wifi BOOLEAN NOT NULL DEFAULT false,
  has_water BOOLEAN NOT NULL DEFAULT false,
  image_url TEXT,
  type TEXT NOT NULL DEFAULT 'meeting_room' CHECK (type IN ('desk', 'office', 'meeting_room')),
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- RLS
ALTER TABLE public.spaces ENABLE ROW LEVEL SECURITY;

-- Svi autentificirani korisnici mogu čitati aktivne prostorije
CREATE POLICY "Authenticated users can read active spaces"
  ON public.spaces FOR SELECT
  TO authenticated
  USING (is_active = true);

-- Seed podaci (opcionalno)
INSERT INTO public.spaces (name, address, price_per_minute, capacity, has_wifi, has_water, type)
VALUES
  ('Orlando sala', 'Ul. od Puča 12', 0.08, 30, true, true, 'meeting_room'),
  ('Učionica 3C', 'Ul. Studentska 5', 0.05, 24, false, true, 'meeting_room'),
  ('Study corner', 'Ul. Knjižnična 3', 0.04, 16, true, false, 'meeting_room'),
  ('Library room', 'Ul. Knjižnična 1', 0.03, 4, false, false, 'meeting_room'),
  ('Collab zone', 'Ul. Suradnička 8', 0.06, 10, true, true, 'meeting_room');
