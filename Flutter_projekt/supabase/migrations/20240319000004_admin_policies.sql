-- Helper funkcija: je li trenutni korisnik admin?
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- profiles: admin može čitati sve profile
CREATE POLICY "Admins can read all profiles"
  ON public.profiles FOR SELECT
  USING (public.is_admin());

-- profiles: admin može ažurirati role i membership_active
CREATE POLICY "Admins can update profiles"
  ON public.profiles FOR UPDATE
  USING (public.is_admin());

-- spaces: admin može čitati sve (uključujući neaktivne)
CREATE POLICY "Admins can read all spaces"
  ON public.spaces FOR SELECT
  USING (public.is_admin());

-- spaces: admin može dodavati prostorije
CREATE POLICY "Admins can insert spaces"
  ON public.spaces FOR INSERT
  WITH CHECK (public.is_admin());

-- spaces: admin može ažurirati prostorije
CREATE POLICY "Admins can update spaces"
  ON public.spaces FOR UPDATE
  USING (public.is_admin());

-- spaces: admin može brisati prostorije
CREATE POLICY "Admins can delete spaces"
  ON public.spaces FOR DELETE
  USING (public.is_admin());

-- reservations: admin može čitati sve
CREATE POLICY "Admins can read all reservations"
  ON public.reservations FOR SELECT
  USING (public.is_admin());

-- reservations: admin može ažurirati status (approve/reject)
CREATE POLICY "Admins can update reservation status"
  ON public.reservations FOR UPDATE
  USING (public.is_admin());

-- Trigger: provjera preklapanja pri odobravanju
CREATE OR REPLACE FUNCTION public.check_reservation_overlap()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'approved' THEN
    IF EXISTS (
      SELECT 1 FROM public.reservations
      WHERE space_id = NEW.space_id
        AND id != NEW.id
        AND status = 'approved'
        AND (start_time, end_time) OVERLAPS (NEW.start_time, NEW.end_time)
    ) THEN
      RAISE EXCEPTION 'Rezervacija se preklapa s drugom odobrenom rezervacijom';
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS check_reservation_overlap_trigger ON public.reservations;
CREATE TRIGGER check_reservation_overlap_trigger
  BEFORE UPDATE ON public.reservations
  FOR EACH ROW EXECUTE FUNCTION public.check_reservation_overlap();
