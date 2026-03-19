-- Uskladivanje tablice spaces s aplikacijom
-- Tvoja shema ima: id, name, type, capacity, description, is_active, created_at
-- Aplikacija očekuje još: address, price_per_minute, has_wifi, has_water, image_url

ALTER TABLE public.spaces ADD COLUMN IF NOT EXISTS address TEXT;
ALTER TABLE public.spaces ADD COLUMN IF NOT EXISTS price_per_minute DECIMAL(10, 4) NOT NULL DEFAULT 0.05;
ALTER TABLE public.spaces ADD COLUMN IF NOT EXISTS has_wifi BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE public.spaces ADD COLUMN IF NOT EXISTS has_water BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE public.spaces ADD COLUMN IF NOT EXISTS image_url TEXT;
ALTER TABLE public.spaces ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT now();

-- Seed podataka – odkomentiraj i pokreni ako želiš primjer prostorija:
-- INSERT INTO public.spaces (name, address, price_per_minute, capacity, has_wifi, has_water, type, description)
-- VALUES
--   ('Orlando sala', 'Ul. od Puča 12', 0.08, 30, true, true, 'meeting_room', 'Velika sala za sastanke'),
--   ('Učionica 3C', 'Ul. Studentska 5', 0.05, 24, false, true, 'meeting_room', 'Učionica za rad u grupi'),
--   ('Study corner', 'Ul. Knjižnična 3', 0.04, 16, true, false, 'meeting_room', 'Kutak za samostalni rad'),
--   ('Library room', 'Ul. Knjižnična 1', 0.03, 4, false, false, 'meeting_room', 'Tiha prostorija'),
--   ('Collab zone', 'Ul. Suradnička 8', 0.06, 10, true, true, 'meeting_room', 'Zona za suradnju');
