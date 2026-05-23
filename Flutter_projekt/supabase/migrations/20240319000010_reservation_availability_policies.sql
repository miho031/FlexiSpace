-- Omogucuje korisnicima citanje odobrenih rezervacija za prikaz dostupnosti.
-- Vlastite rezervacije korisnik vec cita kroz postojecu RLS politiku.
DROP POLICY IF EXISTS "Authenticated users can read approved reservations for availability"
  ON public.reservations;
CREATE POLICY "Authenticated users can read approved reservations for availability"
  ON public.reservations FOR SELECT
  USING (auth.role() = 'authenticated' AND status = 'approved');

-- Sprjecava rezervaciju vec odobrenog termina i dvostruku aktivnu rezervaciju
-- iste osobe u istoj prostoriji. Rejected rezervacije se ignoriraju.
CREATE OR REPLACE FUNCTION public.check_reservation_booking_rules()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status != 'rejected' THEN
    IF EXISTS (
      SELECT 1 FROM public.reservations
      WHERE space_id = NEW.space_id
        AND id != NEW.id
        AND status = 'approved'
        AND start_time < NEW.end_time
        AND end_time > NEW.start_time
    ) THEN
      RAISE EXCEPTION 'Odabrani termin je vec odobren i nije dostupan';
    END IF;

    IF EXISTS (
      SELECT 1 FROM public.reservations
      WHERE user_id = NEW.user_id
        AND space_id = NEW.space_id
        AND id != NEW.id
        AND status != 'rejected'
        AND start_time < NEW.end_time
        AND end_time > NEW.start_time
    ) THEN
      RAISE EXCEPTION 'Vec imate rezervaciju za taj termin u toj prostoriji';
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS check_reservation_booking_rules_trigger ON public.reservations;
CREATE TRIGGER check_reservation_booking_rules_trigger
  BEFORE INSERT OR UPDATE ON public.reservations
  FOR EACH ROW EXECUTE FUNCTION public.check_reservation_booking_rules();
