-- Rješava "infinite recursion detected in policy for relation profiles"
-- is_admin() ne smije čitati iz profiles jer profiles koristi is_admin u svojim RLS pravilima
-- Rješenje: pomoćna tablica admin_user_ids

-- 1. PRVO ukloni pravilа koja uzrokuju rekurziju
DROP POLICY IF EXISTS "Admins can read all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Admins can update profiles" ON public.profiles;

-- 2. Tablica za administratore (izbjegava rekurziju)
CREATE TABLE IF NOT EXISTS public.admin_user_ids (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE
);

ALTER TABLE public.admin_user_ids ENABLE ROW LEVEL SECURITY;

-- Nema dozvola za obične korisnike – pristup samo preko SECURITY DEFINER funkcija (is_admin, sync trigger)
-- Migriraj postojeće admine iz profiles
INSERT INTO public.admin_user_ids (user_id)
SELECT id FROM public.profiles WHERE role = 'admin'
ON CONFLICT (user_id) DO NOTHING;

-- Trigger: kada netko postane admin u profiles, dodaj u admin_user_ids
CREATE OR REPLACE FUNCTION public.sync_admin_user_ids()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.role = 'admin' THEN
    INSERT INTO public.admin_user_ids (user_id) VALUES (NEW.id)
    ON CONFLICT (user_id) DO NOTHING;
  ELSE
    DELETE FROM public.admin_user_ids WHERE user_id = NEW.id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

DROP TRIGGER IF EXISTS sync_admin_on_profile_update ON public.profiles;
CREATE TRIGGER sync_admin_on_profile_update
  AFTER INSERT OR UPDATE OF role ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.sync_admin_user_ids();

-- Nova is_admin() koja čita iz admin_user_ids (ne profiles) - nema rekurzije
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.admin_user_ids WHERE user_id = auth.uid()
  );
$$;

-- 4. Vrati admin pravilа na profiles (sada is_admin čita iz admin_user_ids)
CREATE POLICY "Admins can read all profiles"
  ON public.profiles FOR SELECT
  USING (public.is_admin());

CREATE POLICY "Admins can update profiles"
  ON public.profiles FOR UPDATE
  USING (public.is_admin());
