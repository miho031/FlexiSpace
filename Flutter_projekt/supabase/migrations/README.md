# Supabase migracije

Ove migracije pokrenuti kada baza bude dostupna.

## Redoslijed izvršavanja

1. `20240319000001_create_profiles.sql` - tablica profila i trigger za signup
2. `20240319000002_create_spaces.sql` - tablica prostorija + seed podaci
3. `20240319000003_create_reservations.sql` - tablica rezervacija
4. `20240319000004_admin_policies.sql` - is_admin funkcija, RLS politike za admina, provjera preklapanja
5. `20240319000005_profiles_insert_and_email.sql` - email stupac u profiles, INSERT policy za kreiranje profila
6. `20240319000006_fix_handle_new_user_trigger.sql` - ispravak triggera (opcionalno)
7. `20240319000007_disable_profile_trigger.sql` - uklanja trigger koji uzrokuje 500 grešku (PREPORUČENO)
8. `20240319000008_fix_is_admin_recursion.sql` - rješava "infinite recursion" u RLS za profiles

## Način pokretanja

### Preko Supabase Dashboard

1. Otvori Supabase projekt
2. SQL Editor → New query
3. Kopiraj sadržaj svake datoteke i pokreni redom

### Preko Supabase CLI

```bash
supabase db push
```
