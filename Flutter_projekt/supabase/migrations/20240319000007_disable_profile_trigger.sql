-- Ukloni trigger koji uzrokuje "Database error saving new user"
-- Profil se kreira iz aplikacije nakon prijave (createProfileIfNotExists u login/register flowu)

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
