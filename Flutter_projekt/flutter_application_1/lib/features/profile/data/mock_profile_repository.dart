import '../../../core/models/profile.dart';
import '../domain/profile_repository.dart';

/// Mock implementacija - za razvoj kad Supabase nije dostupan.
class MockProfileRepository implements ProfileRepository {
  @override
  Future<Profile?> getProfile(String userId) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return Profile(
      id: userId,
      fullName: 'Test User',
      role: 'member',
      membershipActive: true,
    );
  }

  @override
  Future<List<Profile>> getAllProfiles() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return [
      Profile(id: '1', fullName: 'Admin User', role: 'admin', membershipActive: true),
      Profile(id: '2', fullName: 'Member User', role: 'member', membershipActive: true),
    ];
  }

  @override
  Future<void> updateProfile(String userId, {String? role, bool? membershipActive}) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
  }
}
