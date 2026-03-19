-- Dodaj email stupac u profiles (ako ne postoji)
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS email TEXT;

-- Korisnik može kreirati svoj profil (npr. ako trigger nije uspio ili za starije račune)
CREATE POLICY "Users can insert own profile"
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = id);
