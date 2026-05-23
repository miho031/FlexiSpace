-- Deaktivirani profili ne smiju kreirati nove rezervacije.
-- Zaštita je i kroz RLS policy i kroz trigger, tako da vrijedi i mimo aplikacije.

CREATE OR REPLACE FUNCTION public.has_active_membership(p_user_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.profiles
    WHERE id = p_user_id
      AND membership_active = true
  );
$$;

DROP POLICY IF EXISTS "Users can create own reservations" ON public.reservations;
CREATE POLICY "Users can create own reservations"
  ON public.reservations FOR INSERT
  WITH CHECK (
    auth.uid() = user_id
    AND public.has_active_membership(auth.uid())
  );

CREATE OR REPLACE FUNCTION public.prevent_inactive_profile_reservation()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NOT public.has_active_membership(NEW.user_id) THEN
    RAISE EXCEPTION 'Profil je deaktiviran i ne može kreirati rezervacije';
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS prevent_inactive_profile_reservation_trigger
  ON public.reservations;
CREATE TRIGGER prevent_inactive_profile_reservation_trigger
  BEFORE INSERT OR UPDATE OF user_id ON public.reservations
  FOR EACH ROW EXECUTE FUNCTION public.prevent_inactive_profile_reservation();

NOTIFY pgrst, 'reload schema';
