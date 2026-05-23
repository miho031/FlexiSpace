-- Popravak za baze u kojima je tablica reservations kreirana bez updated_at.
-- Admin approve/reject kod ažurira ovaj stupac.

ALTER TABLE public.reservations
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT now();

UPDATE public.reservations
SET updated_at = COALESCE(updated_at, created_at, now())
WHERE updated_at IS NULL;

NOTIFY pgrst, 'reload schema';
