import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/profile.dart';
import '../domain/profile_repository.dart';

/// Supabase implementacija ProfileRepository.
class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<Profile?> getProfile(String userId) async {
    final res = await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (res == null) return null;
    return Profile.fromJson(Map<String, dynamic>.from(res as Map));
  }

  @override
  Future<List<Profile>> getAllProfiles() async {
    final res = await _supabase.from('profiles').select();
    final list = res as List;
    return list
        .map((e) => Profile.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<void> createProfileIfNotExists(String userId, {String? email, String? fullName}) async {
    final existing = await getProfile(userId);
    if (existing != null) return;

    await _supabase.from('profiles').upsert({
      'id': userId,
      'full_name': fullName,
      'email': email,
      'role': 'member',
      'membership_active': true,
    }, onConflict: 'id');
  }

  @override
  Future<void> updateProfile(
    String userId, {
    String? role,
    bool? membershipActive,
  }) async {
    final updates = <String, dynamic>{'updated_at': DateTime.now().toIso8601String()};
    if (role != null) updates['role'] = role;
    if (membershipActive != null) updates['membership_active'] = membershipActive;

    await _supabase.from('profiles').update(updates).eq('id', userId);
  }
}
