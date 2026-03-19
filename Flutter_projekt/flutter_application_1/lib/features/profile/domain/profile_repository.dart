import '../../../core/models/profile.dart';

/// Sučelje za pristup profilima.
abstract class ProfileRepository {
  /// Dohvaća profil korisnika po ID-u.
  Future<Profile?> getProfile(String userId);

  /// Dohvaća sve profile (samo za admina).
  Future<List<Profile>> getAllProfiles();

  /// Kreira ili ažurira profil nakon registracije.
  Future<void> createProfileIfNotExists(String userId, {String? email, String? fullName});

  /// Ažurira profil (role, membership_active - samo admin).
  Future<void> updateProfile(String userId, {String? role, bool? membershipActive});
}
