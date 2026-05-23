-- Osiguraj da svaki auth korisnik ima redak u profiles prije kreiranja rezervacija.
-- Ovo popravlja stare korisnike i ponovno uključuje sigurni trigger za nove korisnike.

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS email TEXT;

DROP POLICY IF EXISTS "Users can insert own profile" ON public.profiles;
CREATE POLICY "Users can insert own profile"
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

INSERT INTO public.profiles (id, full_name, role, email, membership_active)
SELECT
  u.id,
  COALESCE(u.raw_user_meta_data->>'full_name', ''),
  'member',
  u.email,
  true
FROM auth.users u
WHERE NOT EXISTS (
  SELECT 1
  FROM public.profiles p
  WHERE p.id = u.id
);

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_full_name TEXT := '';
BEGIN
  IF NEW.raw_user_meta_data IS NOT NULL THEN
    v_full_name := COALESCE(NEW.raw_user_meta_data->>'full_name', '');
  END IF;

  INSERT INTO public.profiles (id, full_name, role, email, membership_active)
  VALUES (NEW.id, v_full_name, 'member', NEW.email, true)
  ON CONFLICT (id) DO NOTHING;

  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
