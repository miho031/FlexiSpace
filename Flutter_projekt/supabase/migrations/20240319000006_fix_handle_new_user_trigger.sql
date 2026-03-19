-- Ispravak triggera: često uzrokuje "Database error saving new user" (500)
-- Osiguraj da email stupac postoji
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS email TEXT;
-- 1. Koristi NEW.email iz auth.users
-- 2. Bezbijedno rukuje null vrijednostima
-- 3. Ako insert u profiles ne uspije, auth signup i dalje prolazi (profil će se kreirati iz app-a pri prvom loginu)

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_full_name TEXT := '';
  v_email TEXT := NULL;
BEGIN
  IF NEW.raw_user_meta_data IS NOT NULL THEN
    v_full_name := COALESCE(NEW.raw_user_meta_data->>'full_name', '');
  END IF;
  v_email := NEW.email;

  INSERT INTO public.profiles (id, full_name, role, email)
  VALUES (NEW.id, v_full_name, 'member', v_email);
  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    -- Nemoj prekinuti auth signup – profil će se kreirati iz aplikacije pri loginu
    RETURN NEW;
END;
$$;
