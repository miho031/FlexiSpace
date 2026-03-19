-- Tablica reservations
CREATE TABLE IF NOT EXISTS public.reservations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  space_id UUID NOT NULL REFERENCES public.spaces(id) ON DELETE CASCADE,
  start_time TIMESTAMPTZ NOT NULL,
  end_time TIMESTAMPTZ NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  CONSTRAINT valid_time_range CHECK (end_time > start_time)
);

-- Indeks za brzo pretraživanje
CREATE INDEX IF NOT EXISTS idx_reservations_user_id ON public.reservations(user_id);
CREATE INDEX IF NOT EXISTS idx_reservations_space_id ON public.reservations(space_id);
CREATE INDEX IF NOT EXISTS idx_reservations_start_time ON public.reservations(start_time);

-- RLS
ALTER TABLE public.reservations ENABLE ROW LEVEL SECURITY;

-- Korisnik može čitati samo svoje rezervacije
CREATE POLICY "Users can read own reservations"
  ON public.reservations FOR SELECT
  USING (auth.uid() = user_id);

-- Korisnik može kreirati rezervacije (samo za sebe)
CREATE POLICY "Users can create own reservations"
  ON public.reservations FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Admin može čitati sve (dodati nakon implementacije admin provjere)
-- CREATE POLICY "Admins can read all reservations"
--   ON public.reservations FOR SELECT
--   USING (
--     EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
--   );
