import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/profile.dart';
import '../../../core/models/room.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../profile/application/profile_providers.dart';
import '../data/admin_repository.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(ref.read(supabaseClientProvider));
});

final adminReservationsProvider = FutureProvider<List<AdminReservationView>>((ref) async {
  return ref.read(adminRepositoryProvider).getAllReservations();
});

final adminSpacesProvider = FutureProvider<List<Room>>((ref) async {
  return ref.read(adminRepositoryProvider).getAllSpaces();
});

final adminProfilesProvider = FutureProvider<List<Profile>>((ref) async {
  final repo = ref.read(profileRepositoryProvider);
  return repo.getAllProfiles();
});
