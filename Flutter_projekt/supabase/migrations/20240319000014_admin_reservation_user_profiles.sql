-- Popuni email/ime za postojeće profile i omogući admin panelu stabilan dohvat
-- korisničkih podataka za prikaz rezervacija.

UPDATE public.profiles p
SET
  email = COALESCE(NULLIF(p.email, ''), u.email),
  full_name = COALESCE(NULLIF(p.full_name, ''), u.raw_user_meta_data->>'full_name', '')
FROM auth.users u
WHERE p.id = u.id
  AND (
    p.email IS NULL
    OR p.email = ''
    OR p.full_name IS NULL
    OR p.full_name = ''
  );

CREATE OR REPLACE FUNCTION public.get_admin_reservation_profiles(user_ids UUID[])
RETURNS TABLE (
  id UUID,
  email TEXT,
  full_name TEXT
)
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT p.id, p.email, p.full_name
  FROM public.profiles p
  WHERE p.id = ANY(user_ids)
    AND public.is_admin();
$$;

NOTIFY pgrst, 'reload schema';
