import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/profile.dart';
import '../../../core/supabase/supabase_client.dart';
import '../data/supabase_profile_repository.dart';
import '../domain/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return SupabaseProfileRepository(ref.read(supabaseClientProvider));
});

final currentProfileProvider = FutureProvider<Profile?>((ref) async {
  final userId = ref.watch(supabaseClientProvider).auth.currentUser?.id;
  if (userId == null) return null;
  return ref.read(profileRepositoryProvider).getProfile(userId);
});

final isAdminProvider = FutureProvider<bool>((ref) async {
  final profile = await ref.watch(currentProfileProvider.future);
  return profile?.role == 'admin';
});
