-- Wi-Fi sifra za prostorije. Prikazuje se korisniku tek na odobrenoj rezervaciji.
ALTER TABLE public.spaces
ADD COLUMN IF NOT EXISTS wifi_password TEXT;

COMMENT ON COLUMN public.spaces.wifi_password IS
  'Wi-Fi sifra za prostoriju, namijenjena prikazu uz odobrene rezervacije.';
